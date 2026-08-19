import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// Adapted from Omarchy Quattro's MIT-licensed PluginRegistry. This local
// runtime deliberately supports reviewed overlay plugins only.
QtObject {
  id: registry

  property string pluginsDir: Quickshell.env("HOME") + "/.config/omarchy/plugins"
  property var enabledPluginIds: []
  property var installedPlugins: ({})
  property bool scanning: false

  signal pluginsChanged()

  function isSafeEntryPoint(value) {
    return typeof value === "string" && value.length > 0
      && value.charAt(0) !== "/" && value.indexOf("..") === -1
  }

  function validateManifest(manifest, sourcePath) {
    if (!Util.isPlainObject(manifest) || manifest.schemaVersion !== 1) return null
    var required = ["id", "name", "version", "kinds", "entryPoints"]
    for (var i = 0; i < required.length; i++)
      if (manifest[required[i]] === undefined) return null
    var id = String(manifest.id)
    if (!/^[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?$/.test(id)
        || id.indexOf("omarchy.") === 0) return null
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

  function supports(id) {
    var manifest = installedPlugins[String(id || "")]
    return !!(manifest && Array.isArray(manifest.kinds)
      && manifest.kinds.indexOf("overlay") !== -1
      && entryPointUrl(manifest, "overlay"))
  }

  function isEnabled(id) {
    return supports(id) && enabledPluginIds.indexOf(String(id || "")) !== -1
  }

  function parseScanOutput(text) {
    var plugins = ({})
    var source = ""
    var json = []
    var lines = String(text || "").split("\n")

    function flush() {
      if (!source) return
      try {
        var manifest = JSON.parse(json.join("\n").trim())
        manifest.__sourceDir = source
        manifest = registry.validateManifest(manifest, source + "/manifest.json")
        if (manifest) plugins[manifest.id] = manifest
      } catch (error) {
        console.warn("PluginRegistry: invalid manifest at " + source + ": " + error)
      }
      source = ""
      json = []
    }

    for (var i = 0; i < lines.length; i++) {
      var start = lines[i].match(/^===plugin::(.+)===$/)
      if (start) {
        flush()
        source = start[1].replace(/\/$/, "")
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
    var script = "for sub in \"$0\"/*/; do "
      + "[ -f \"$sub/manifest.json\" ] || continue; "
      + "printf '===plugin::%s===\\n' \"${sub%/}\"; "
      + "cat \"$sub/manifest.json\"; printf '\\n=== EOM ===\\n'; done"
    scanProcess.command = ["bash", "-c", script, pluginsDir]
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
