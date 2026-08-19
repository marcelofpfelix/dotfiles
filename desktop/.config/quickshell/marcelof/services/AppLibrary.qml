import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import "AppSearch.js" as AppSearch

// Adapted from Omarchy Quattro shell/services/AppLibrary.qml at f32ebbd.
// One application catalog serves the copied root menu and the local launcher.
Item {
  id: root

  required property var shellRoot
  required property var shellSettings

  property var iconIndex: ({})
  property var pendingIconIndex: ({})

  signal appsChanged()

  function entryName(entry) {
    return AppSearch.entryName(entry)
  }

  function entrySubtext(entry) {
    return AppSearch.entrySubtext(entry)
  }

  function isHiddenEntry(entry) {
    var id = String((entry && entry.id) || "")
    var hidden = Array.isArray(root.shellSettings.hiddenAppIds)
      ? root.shellSettings.hiddenAppIds : []
    return id === String(root.shellRoot.launcherSmokeHiddenId || "")
      || hidden.indexOf(id) !== -1
  }

  function sortedEntries(query) {
    var values = DesktopEntries.applications.values || []
    return AppSearch.sortedEntries(values, query, function(entry) {
      return root.isHiddenEntry(entry)
    })
  }

  function entryById(desktopId) {
    var id = String(desktopId || "")
    var values = DesktopEntries.applications.values || []
    for (var i = 0; i < values.length; i++)
      if (String(values[i] && values[i].id || "") === id) return values[i]
    return null
  }

  function iconSource(icon) {
    var value = String(icon || "")
    if (!value) return Quickshell.iconPath("application-x-executable", true)
    if (value.indexOf("file://") === 0 || value.indexOf("image://") === 0) return value
    if (value.charAt(0) === "/") return Util.fileUrl(value)
    var found = root.iconIndex[value]
    if (found) return Util.fileUrl(found)
    var themed = Quickshell.iconPath(value, true)
    return themed || Quickshell.iconPath("application-x-executable", true)
  }

  function refreshIcons() {
    if (!iconIndexScan.running) iconIndexScan.running = true
  }

  function launch(desktopId, name) {
    var id = String(desktopId || "")
    if (!id) return
    var entry = root.entryById(id)
    if (entry && typeof entry.execute === "function") entry.execute()
    else Util.execDetached("gtk-launch " + Util.shellQuote(id + ".desktop"))
  }

  // Omarchy removes packages here. Local launcher removal is deliberately the
  // existing reversible hide action.
  function remove(desktopId, name) {
    root.shellRoot.hideLauncherById(String(desktopId || ""))
    root.appsChanged()
  }

  function iconIndexScanCommand() {
    return [
      'dirs="$HOME/.icons $HOME/.local/share/icons";',
      'data_dirs="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"; IFS=":"; for d in $data_dirs; do dirs="$dirs $d/icons"; done; unset IFS;',
      'for ext in svg png; do',
      '  for base in $dirs; do',
      '    [[ -d $base ]] && find "$base" \\( -path "*/apps/*" -o -path "*/devices/*" \\) -name "*.$ext" 2>/dev/null;',
      '  done;',
      '  find /usr/share/pixmaps -maxdepth 1 -name "*.$ext" 2>/dev/null;',
      'done'
    ].join(' ')
  }

  function indexIconLine(path) {
    var value = String(path || "").trim()
    if (!value) return
    var file = value.slice(value.lastIndexOf("/") + 1)
    var dot = file.lastIndexOf(".")
    var name = dot > 0 ? file.slice(0, dot) : file
    if (name && root.pendingIconIndex[name] === undefined)
      root.pendingIconIndex[name] = value
  }

  Process {
    id: iconIndexScan
    command: ["bash", "-c", root.iconIndexScanCommand()]
    stdout: SplitParser { onRead: function(line) { root.indexIconLine(line) } }
    onStarted: root.pendingIconIndex = ({})
    onExited: root.iconIndex = root.pendingIconIndex
  }

  Timer {
    id: iconIndexDebounce
    interval: 750
    onTriggered: root.refreshIcons()
  }

  Connections {
    target: DesktopEntries.applications
    function onValuesChanged() {
      iconIndexDebounce.restart()
      root.appsChanged()
    }
  }

}
