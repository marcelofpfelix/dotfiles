import QtQuick
import Quickshell.Io
import qs.Commons

QtObject {
  id: root

  required property string path
  property var config: defaultConfig
  readonly property var barConfig: config && Util.isPlainObject(config.bar) ? config.bar : defaultConfig.bar
  readonly property var defaultConfig: ({
    version: 1,
    bar: {
      position: "top",
      transparent: false,
      centerAnchor: "marcelof.status-actions",
      layout: {
        left: [{ id: "omarchy.menu" }, { id: "omarchy.workspaces" }],
        center: [
          { id: "marcelof.status-actions", kind: "clock" },
          { id: "marcelof.status-actions", kind: "notifications" }
        ],
        right: [
          { id: "marcelof.board-status" },
          { id: "marcelof.status-actions", kind: "privacy" },
          { id: "marcelof.status-actions", kind: "audioctl" },
          { id: "omarchy.tray" },
          { id: "omarchy.bluetooth" },
          { id: "omarchy.network" },
          { id: "omarchy.audio" },
          { id: "omarchy.monitor" },
          { id: "omarchy.power" }
        ]
      }
    },
    plugins: [
      { id: "marcelof.board-dashboard" },
      { id: "marcelof.media-controls" },
      { id: "marcelof.network-tools" }
    ]
  })

  property FileView file: FileView {
    path: root.path
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.load(text())
    onLoadFailed: root.config = root.defaultConfig
    onFileChanged: reload()
  }

  function load(raw) {
    try {
      const parsed = JSON.parse(String(raw || ""))
      config = parsed && parsed.version === 1 ? parsed : defaultConfig
    } catch (error) {
      console.warn("shell.json parse failed:", error)
      config = defaultConfig
    }
  }

  function mutate(mutator) {
    const next = JSON.parse(JSON.stringify(config || defaultConfig))
    mutator(next)
    next.version = 1
    config = next
    file.setText(JSON.stringify(next, null, 2) + "\n")
  }

  function updateEntryInline(moduleName, settings) {
    let changed = false
    mutate(function(next) {
      for (const section of ["left", "center", "right"]) {
        const entries = next.bar.layout[section] || []
        for (let index = 0; index < entries.length; index++) {
          if (String(entries[index].id || "") !== String(moduleName)) continue
          const replacement = Object.assign({ id: moduleName }, settings)
          if (JSON.stringify(entries[index]) !== JSON.stringify(replacement)) {
            entries[index] = replacement
            changed = true
          }
        }
      }
    })
    return changed
  }
}
