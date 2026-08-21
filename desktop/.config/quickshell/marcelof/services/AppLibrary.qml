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
  required property var shellConfig

  property var iconIndex: ({})
  property var pendingIconIndex: ({})
  property var launcherMru: []
  property var launcherCounts: ({})

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
    var rows = AppSearch.sortedEntries(values, query, function(entry) {
      return root.isHiddenEntry(entry)
    })
    for (var i = 0; i < rows.length; i++) {
      var entry = rows[i].entry
      var id = String(entry && entry.id || "")
      var mru = root.launcherMru.indexOf(id)
      var favorite = root.isFavorite(id)
      rows[i].favorite = favorite
      rows[i].mru = mru
      rows[i].boost = (favorite ? 20000 : 0)
        + (mru < 0 ? 0 : 300 - Math.min(mru, 49) * 5)
        + Math.min(Number(root.launcherCounts[id] || 0), 20) * 10
      rows[i].score += rows[i].boost
    }
    rows.sort(function(a, b) {
      if (String(query || "").trim() && a.score !== b.score) return b.score - a.score
      if (!String(query || "").trim() && a.boost !== b.boost) return b.boost - a.boost
      if (!String(query || "").trim() && a.mru !== b.mru)
        return a.mru < 0 ? 1 : (b.mru < 0 ? -1 : a.mru - b.mru)
      return a.key < b.key ? -1 : (a.key > b.key ? 1 : 0)
    })
    return rows
  }

  function isFavorite(id) {
    var favorites = Array.isArray(root.shellSettings.favoriteAppIds)
      ? root.shellSettings.favoriteAppIds : []
    return favorites.indexOf(String(id || "")) !== -1
  }

  function toggleListValue(list, value) {
    var next = Array.isArray(list) ? list.slice() : []
    var index = next.indexOf(value)
    if (index < 0) next.push(value)
    else next.splice(index, 1)
    return next
  }

  function toggleFavoriteById(id) {
    var value = String(id || "")
    if (!value) return
    root.shellSettings.favoriteAppIds = root.toggleListValue(root.shellSettings.favoriteAppIds, value)
    root.appsChanged()
  }

  function hideById(id) {
    var value = String(id || "")
    if (!value) return
    root.shellSettings.hiddenAppIds = root.toggleListValue(root.shellSettings.hiddenAppIds, value)
    root.appsChanged()
  }

  function refreshMru() {
    if (!mruLoad.running) mruLoad.running = true
  }

  function updateMru(output) {
    var lines = String(output || "").split(/\n+/)
    var seen = ({})
    var entries = []
    var counts = ({})
    for (var i = 0; i < lines.length && entries.length < 50; i++) {
      var fields = lines[i].trim().split(/\t+/)
      var id = fields[0]
      if (!id || seen[id]) continue
      seen[id] = true
      entries.push(id)
      counts[id] = Math.max(1, Number(fields[1] || 1))
    }
    root.launcherMru = entries
    root.launcherCounts = counts
    root.appsChanged()
  }

  function recordUse(id) {
    var value = String(id || "")
    if (!value) return
    var next = [value]
    for (var i = 0; i < root.launcherMru.length && next.length < 50; i++)
      if (root.launcherMru[i] !== value) next.push(root.launcherMru[i])
    var counts = Object.assign({}, root.launcherCounts)
    counts[value] = Number(counts[value] || 0) + 1
    root.launcherMru = next
    root.launcherCounts = counts
    var cache = ""
    for (var j = 0; j < next.length; j++)
      cache += next[j] + "\t" + Number(counts[next[j]] || 1) + "\n"
    Quickshell.execDetached(root.shellConfig.launcherMruSave(cache))
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
    root.recordUse(id)
    var entry = root.entryById(id)
    if (entry && typeof entry.execute === "function") entry.execute()
    else Util.execDetached("gtk-launch " + Util.shellQuote(id + ".desktop"))
    root.appsChanged()
  }

  // Omarchy removes packages here. Local launcher removal is deliberately the
  // existing reversible hide action.
  function remove(desktopId, name) {
    root.hideById(String(desktopId || ""))
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
    id: mruLoad
    command: root.shellConfig.launcherMruLoad()
    running: true
    stdout: StdioCollector { onStreamFinished: root.updateMru(this.text) }
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
