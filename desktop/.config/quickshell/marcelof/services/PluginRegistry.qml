import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// Adapted from Omarchy Quattro's MIT-licensed PluginRegistry. This shell keeps
// its fixed bar layout, but loads reviewed overlays and bar widgets by manifest.
QtObject {
  id: registry

  property string pluginsDir: Quickshell.env("HOME") + "/.config/omarchy/plugins"
  property string firstPartyDir: ""
  property var enabledPluginIds: []
  property var installedPlugins: ({})
  property bool scanning: false
  readonly property string overlayKind: "overlay"
  readonly property string barWidgetKind: "bar-widget"

  signal pluginsChanged()

  function isSafeEntryPoint(value) {
    return typeof value === "string" && value.length > 0
      && value.charAt(0) !== "/" && value.indexOf("..") === -1
  }

  function validateManifest(manifest, sourcePath, firstParty) {
    if (!Util.isPlainObject(manifest) || manifest.schemaVersion !== 1) return null
    var required = ["id", "name", "version", "kinds", "entryPoints"]
    for (var i = 0; i < required.length; i++)
      if (manifest[required[i]] === undefined) return null
    var id = String(manifest.id)
    if (!/^[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?$/.test(id)
        || (!firstParty && id.indexOf("omarchy.") === 0)) return null
    if (!Array.isArray(manifest.kinds) || manifest.kinds.length === 0
        || !Util.isPlainObject(manifest.entryPoints)) return null
    for (var key in manifest.entryPoints)
      if (!isSafeEntryPoint(manifest.entryPoints[key])) return null
    return manifest
  }

  function entryPointUrl(manifest, kind) {
    if (!Util.isPlainObject(manifest) || !manifest.entryPoints) return ""
    var entry = manifest.entryPoints[kind]
    var dir = manifest.__sourceDir || ""
    if (!entry || !dir || !isSafeEntryPoint(entry)) return ""
    return Util.fileUrl(dir.replace(/\/$/, "") + "/" + String(entry))
  }

  function supportsKind(id, kind) {
    var manifest = installedPlugins[String(id || "")]
    return !!(manifest && Array.isArray(manifest.kinds)
      && manifest.kinds.indexOf(kind) !== -1
      && entryPointUrl(manifest, kind === barWidgetKind ? "barWidget" : kind))
  }

  function supports(id) {
    return supportsKind(id, overlayKind) || supportsKind(id, barWidgetKind)
  }

  function isEnabled(id) {
    return supports(id) && enabledPluginIds.indexOf(String(id || "")) !== -1
  }

  function parseScanOutput(text) {
    var plugins = ({})
    var source = ""
    var kind = ""
    var json = []
    var lines = String(text || "").split("\n")

    function flush() {
      if (!source) return
      try {
        var manifest = JSON.parse(json.join("\n").trim())
        manifest.__sourceDir = source
        manifest.__isFirstParty = kind === "firstparty"
        manifest = registry.validateManifest(manifest, source + "/manifest.json", manifest.__isFirstParty)
        if (manifest) plugins[manifest.id] = manifest
      } catch (error) {
        console.warn("PluginRegistry: invalid manifest at " + source + ": " + error)
      }
      source = ""
      kind = ""
      json = []
    }

    for (var i = 0; i < lines.length; i++) {
      var start = lines[i].match(/^===(firstparty|plugin)::(.+)===$/)
      if (start) {
        flush()
        kind = start[1]
        source = start[2].replace(/\/$/, "")
      } else if (lines[i] === "=== EOM ===") {
        flush()
      } else if (source) {
        json.push(lines[i])
      }
    }
    flush()
    installedPlugins = plugins
    scanning = false
    pluginsChanged()
  }

  function rescan() {
    if (scanning) return
    scanning = true
    var script = "emit() { local kind=\"$1\" dir=\"$2\"; "
      + "[ -f \"$dir/manifest.json\" ] || return; "
      + "printf '===%s::%s===\\n' \"$kind\" \"${dir%/}\"; "
      + "cat \"$dir/manifest.json\"; printf '\\n=== EOM ===\\n'; }; "
      + "if [ -n \"$0\" ]; then for sub in \"$0\"/*/; do emit firstparty \"$sub\"; done; fi; "
      + "if [ -n \"$1\" ]; then for sub in \"$1\"/*/; do emit plugin \"$sub\"; done; fi"
    scanProcess.command = ["bash", "-c", script, firstPartyDir, pluginsDir]
    scanProcess.running = true
  }

  property Process scanProcess: Process {
    stdout: StdioCollector { id: scanOutput; waitForEnd: true }
    onExited: registry.parseScanOutput(scanOutput.text || "")
  }

  property Process initProcess: Process {
    command: ["mkdir", "-p", registry.pluginsDir]
    onExited: registry.rescan()
  }

  Component.onCompleted: initProcess.running = true
}
