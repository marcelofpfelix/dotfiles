import Quickshell
import Quickshell.Hyprland
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.Notifications
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ShellRoot {
  id: root

  property string launcherSmokeHiddenId: ""

  function toggleLauncher() {
    launcher.visible = !launcher.visible
    if (launcher.visible) {
      search.text = ""
      launcherMruRefresh.running = true
      root.rebuildLauncher()
      search.forceActiveFocus()
    }
  }

  function hideLauncher() {
    launcher.visible = false
  }

  function shellQuote(value) {
    return "'" + String(value).replace(/'/g, "'\"'\"'") + "'"
  }

  function webSearchSiteUrl(site) {
    for (let i = 0; i < root.webSearchSites.length; i++) {
      if (root.webSearchSites[i].key === site)
        return root.webSearchSites[i].url
    }
    return root.webSearchSites[0].url
  }

  function openWebSearch(site) {
    root.closeTransientPanels()
    root.webSearchSite = site && String(site).length > 0 ? String(site) : "google"
    root.webSearchOpen = true
    webSearchInput.text = ""
    webSearchInput.forceActiveFocus()
  }

  function toggleWebSearch(site) {
    if (root.webSearchOpen) {
      root.webSearchOpen = false
      return
    }
    root.openWebSearch(site)
  }

  function showOsd(icon, text) {
    root.osdIconText = icon
    root.osdBodyText = text
    root.osdOpen = true
    osdTimer.restart()
  }

  function showVolumeOsd() {
    const audio = root.defaultSinkAudio()
    if (!audio) {
      root.showOsd("", "Audio unavailable")
      return
    }
    root.showOsd(audio.muted ? "󰝟" : "", (audio.muted ? "Muted " : "Volume ") + Math.round(audio.volume * 100) + "%")
  }

  function showBrightnessOsd() {
    brightnessRefresh.running = true
    root.osdPendingKind = "brightness"
    osdRefreshLater.restart()
  }

  function showKbdOsd() {
    kbdBrightnessRefresh.running = true
    root.osdPendingKind = "kbd"
    osdRefreshLater.restart()
  }

  function showMicOsd() {
    privacyStatusRefresh.running = true
    root.showOsd("󰍬", "Microphone toggled")
  }

  function runWebSearch() {
    const query = webSearchInput.text.trim()
    if (query.length === 0)
      return
    const url = root.webSearchSiteUrl(root.webSearchSite) + encodeURIComponent(query)
    root.webSearchOpen = false
    Quickshell.execDetached(["sh", "-c", "command -v chrome-wayland >/dev/null 2>&1 && exec chrome-wayland " + root.shellQuote(url) + "; exec xdg-open " + root.shellQuote(url)])
  }

  function toggleKeybindings() {
    const next = !root.keybindingsOpen
    root.closeTransientPanels()
    root.keybindingsOpen = next
    if (next)
      keybindingsRefresh.running = true
  }

  function clipboardScore(entry, query) {
    const q = query.trim().toLowerCase()
    const text = String(entry || "").toLowerCase()
    if (q.length === 0)
      return 0
    const terms = q.split(/\s+/)
    for (let i = 0; i < terms.length; i++) {
      const term = terms[i]
      if (term.length > 0 && text.indexOf(term) < 0)
        return -1
    }
    const idx = text.indexOf(q)
    if (idx === 0) return 10000 - text.length
    if (idx > 0) return 8000 - idx * 10 - text.length
    return 5000 - text.length
  }

  function rebuildClipboardModel() {
    const query = clipSearch ? clipSearch.text : ""
    const rows = []
    for (let i = 0; i < root.clipboardEntries.length; i++) {
      const entry = String(root.clipboardEntries[i] || "")
      if (entry.length === 0)
        continue
      const score = root.clipboardScore(entry, query)
      if (score < 0)
        continue
      rows.push({ entry: entry, score: score, key: entry.toLowerCase() })
    }
    rows.sort((a, b) => {
      if (query.trim().length > 0 && a.score !== b.score)
        return b.score - a.score
      return a.key < b.key ? -1 : (a.key > b.key ? 1 : 0)
    })
    clipboardModel.clear()
    const count = Math.min(rows.length, 250)
    for (let i = 0; i < count; i++)
      clipboardModel.append({ text: rows[i].entry, preview: rows[i].entry.replace(/^\d+\s+/, "") })
    if (clipList) {
      clipList.currentIndex = clipboardModel.count > 0 ? 0 : -1
      Qt.callLater(() => { if (clipboardModel.count > 0) clipList.positionViewAtIndex(clipList.currentIndex, ListView.Contain) })
    }
  }

  function updateClipboardEntries(output) {
    const lines = String(output || "").split(/\n+/)
    const entries = []
    for (let i = 0; i < lines.length; i++) {
      const entry = lines[i].trim()
      if (entry.length > 0 && !root.looksSecretClipboardEntry(entry))
        entries.push(entry)
    }
    root.clipboardEntries = entries
    root.rebuildClipboardModel()
  }

  function looksSecretClipboardEntry(entry) {
    const text = String(entry || "")
    const body = text.replace(/^\d+\s+/, "")
    if (/^(password|passwd|secret|token|api[_-]?key|authorization|bearer)[:=]/i.test(body))
      return true
    if (/^(otpauth:\/\/|-----BEGIN (RSA |OPENSSH |EC |DSA |PGP )?PRIVATE KEY-----)/i.test(body))
      return true
    if (/^[A-Za-z0-9+\/=]{32,}$/.test(body) && /[A-Z]/.test(body) && /[a-z]/.test(body) && /[0-9]/.test(body))
      return true
    return false
  }

  function rebuildPassModel() {
    const query = passSearch ? passSearch.text : ""
    const rows = []
    for (let i = 0; i < root.passEntries.length; i++) {
      const entry = String(root.passEntries[i] || "")
      if (entry.length === 0)
        continue
      const score = root.clipboardScore(entry, query)
      if (score < 0)
        continue
      rows.push({ entry: entry, score: score, key: entry.toLowerCase() })
    }
    rows.sort((a, b) => {
      if (query.trim().length > 0 && a.score !== b.score)
        return b.score - a.score
      return a.key < b.key ? -1 : (a.key > b.key ? 1 : 0)
    })
    passModel.clear()
    const count = Math.min(rows.length, 250)
    for (let i = 0; i < count; i++)
      passModel.append({ path: rows[i].entry })
    if (passList) {
      passList.currentIndex = passModel.count > 0 ? 0 : -1
      Qt.callLater(() => { if (passModel.count > 0) passList.positionViewAtIndex(passList.currentIndex, ListView.Contain) })
    }
  }

  function updatePassEntries(output) {
    const lines = String(output || "").split(/\n+/)
    const entries = []
    for (let i = 0; i < lines.length; i++) {
      const entry = lines[i].trim()
      if (entry.length > 0)
        entries.push(entry)
    }
    root.passEntries = entries
    root.rebuildPassModel()
  }

  function updateKeybindingRows(output) {
    keybindingModel.clear()
    const lines = String(output || "").split(/\n+/)
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim()
      if (line.length === 0)
        continue
      const parts = line.split(/\t+/)
      if (parts.length < 2)
        continue
      keybindingModel.append({ shortcut: parts[0], action: parts.slice(1).join(" ") })
    }
  }

  function openClipboard() {
    root.closeTransientPanels()
    root.clipboardOpen = true
    clipSearch.text = ""
    root.clipboardEntries = []
    clipboardModel.clear()
    clipboardRefresh.running = true
    clipSearch.forceActiveFocus()
  }

  function passModeLabel() {
    if (root.passMode === "type-pass") return "Type password"
    if (root.passMode === "type-user") return "Type username"
    if (root.passMode === "type-name") return "Type entry name"
    return "Copy password"
  }

  function openPassmenu(mode, userKey, backend) {
    root.closeTransientPanels()
    root.passMode = String(mode || "copy")
    root.passUserKey = String(userKey || "username")
    root.passBackend = String(backend || "gopass")
    root.passMenuOpen = true
    passSearch.text = ""
    root.passEntries = []
    passModel.clear()
    passEntriesRefresh.running = true
    passSearch.forceActiveFocus()
  }

  function runPassEntry() {
    if (!root.passMenuOpen || passList.currentIndex < 0 || passList.currentIndex >= passModel.count)
      return
    const entry = passModel.get(passList.currentIndex).path
    root.passMenuOpen = false
    Quickshell.execDetached(["passmenu-action", root.passMode, root.passUserKey, root.passBackend, entry])
  }

  function toggleClipboard() {
    if (root.clipboardOpen) {
      root.clipboardOpen = false
      return
    }
    root.openClipboard()
  }

  function pasteClipboardEntry() {
    if (!root.clipboardOpen || clipList.currentIndex < 0 || clipList.currentIndex >= clipboardModel.count)
      return
    const entry = clipboardModel.get(clipList.currentIndex).text
    root.clipboardOpen = false
    Quickshell.execDetached(["sh", "-c", "printf %s " + root.shellQuote(entry) + " | cliphist decode | wl-copy"])
  }

  property var launcherEntries: []
  property var launcherMru: []
  property string launcherModeText: "Apps"
  property var launcherCounts: ({})
  property var clipboardEntries: []
  property var passEntries: []
  property bool clipboardOpen: false
  property bool passMenuOpen: false
  property string passMode: "copy"
  property string passUserKey: "username"
  property string passBackend: "gopass"
  property bool keybindingsOpen: false
  property bool webSearchOpen: false
  property string webSearchSite: "google"
  property var webSearchSites: [
    { key: "google", label: "Google", url: "https://www.google.com/search?q=" },
    { key: "youtube", label: "YouTube", url: "https://www.youtube.com/results?search_query=" },
    { key: "github", label: "GitHub", url: "https://github.com/search?q=org%3Ateam-telnyx+" },
    { key: "jira", label: "Jira", url: "https://telnyx.atlassian.net/secure/QuickSearch.jspa?searchString=" },
    { key: "guru", label: "Guru", url: "https://app.getguru.com/search?q=" },
    { key: "call", label: "Call", url: "http://search-tools.internal.telnyx.com/#!/session-lookup?sip_call_id=" }
  ]

  function launcherEntryId(entry) {
    return String(entry && entry.id || "")
  }

  function listContains(list, value) {
    return list && list.indexOf && list.indexOf(value) !== -1
  }

  function toggleListValue(list, value) {
    const next = list && list.slice ? list.slice() : []
    const index = next.indexOf(value)
    if (index === -1)
      next.push(value)
    else
      next.splice(index, 1)
    return next
  }

  function isLauncherFavorite(entry) {
    return root.listContains(shellSettings.favoriteAppIds, root.launcherEntryId(entry))
  }

  function isLauncherHidden(entry) {
    const id = root.launcherEntryId(entry)
    return id === root.launcherSmokeHiddenId || root.listContains(shellSettings.hiddenAppIds, id)
  }

  function toggleLauncherFavoriteById(id) {
    if (!id)
      return
    shellSettings.favoriteAppIds = root.toggleListValue(shellSettings.favoriteAppIds, id)
    root.rebuildLauncher()
  }

  function hideLauncherById(id) {
    if (!id)
      return
    shellSettings.hiddenAppIds = root.toggleListValue(shellSettings.hiddenAppIds, id)
    root.rebuildLauncher()
  }

  function launcherCommandEntries(query) {
    const raw = String(query || "").trim()
    if (raw.indexOf(">") !== 0)
      return []
    const arg = raw.slice(1).trim()
    const encoded = encodeURIComponent(arg.replace(/^web\s+/, "").replace(/^yt\s+/, "").replace(/^youtube\s+/, ""))
    const rows = []
    rows.push({ name: "Web search", subtext: arg.length > 0 ? arg : "Open web search", icon: "󰖟", command: arg.length > 0 ? ["sh", "-c", "chrome-wayland " + root.shellQuote(root.webSearchSiteUrl("google") + encoded)] : ["/home/marcelof/bin/qs-bar", "websearch"] })
    rows.push({ name: "YouTube search", subtext: arg.length > 0 ? arg : "Search YouTube", icon: "", command: arg.length > 0 ? ["sh", "-c", "chrome-wayland " + root.shellQuote(root.webSearchSiteUrl("youtube") + encoded)] : ["/home/marcelof/bin/qs-bar", "websearch"] })
    rows.push({ name: "Calculator", subtext: "Open calculator", icon: "󰪚", command: ["sh", "-c", "command -v gnome-calculator >/dev/null 2>&1 && exec gnome-calculator || notify-send Quickshell 'gnome-calculator missing'"] })
    rows.push({ name: "Wallpaper", subtext: "Open wallpaper picker", icon: "󰸉", command: ["/home/marcelof/bin/qs-bar", "wallpaper"] })
    rows.push({ name: "Controls", subtext: "Open desktop controls", icon: "󰒓", command: ["/home/marcelof/bin/qs-bar", "controls"] })
    rows.push({ name: "Settings", subtext: "Open shell settings", icon: "󰒓", command: ["/home/marcelof/bin/qs-bar", "settings"] })
    rows.push({ name: "Notifications", subtext: "Open notification history", icon: "󰂚", command: ["/home/marcelof/bin/qs-bar", "notifications"] })
    rows.push({ name: "Toggle DND", subtext: "Silence or allow notification popups", icon: "󰂛", command: ["/home/marcelof/bin/qs-bar", "dnd"] })
    rows.push({ name: "Media", subtext: "Open media controls", icon: "󰕾", command: ["/home/marcelof/bin/qs-bar", "media"] })
    rows.push({ name: "Screenshot", subtext: "Select area and edit", icon: "󰹑", command: ["screenshot-wayland", "edit"] })
    if (arg.length === 0)
      return rows
    return rows.filter(row => (row.name + " " + row.subtext).toLowerCase().indexOf(arg.toLowerCase()) >= 0 || raw.indexOf(">web ") === 0 || raw.indexOf(">yt ") === 0 || raw.indexOf(">youtube ") === 0)
  }

  function launcherEntryText(entry) {
    const keywords = entry && entry.keywords && entry.keywords.join ? entry.keywords.join(" ") : ""
    return [entry ? entry.name : "", entry ? entry.genericName : "", entry ? entry.comment : "", entry ? entry.id : "", keywords].join(" ").toLowerCase()
  }

  function launcherAcronym(entry) {
    const text = [entry ? entry.name : "", entry ? entry.genericName : "", entry ? entry.id : ""].join(" ").replace(/([a-z0-9])([A-Z])/g, "$1 $2").replace(/[._:/\-]+/g, " ").toLowerCase()
    const parts = text.split(/[^a-z0-9]+/)
    let result = ""
    for (let i = 0; i < parts.length; i++) {
      if (parts[i].length > 0)
        result += parts[i][0]
    }
    return result
  }

  function launcherScore(entry, query) {
    const q = query.trim().toLowerCase()
    const name = String(entry && entry.name || "").toLowerCase()
    const id = String(entry && entry.id || "").toLowerCase()
    const haystack = root.launcherEntryText(entry)
    if (q.length === 0)
      return 0

    const terms = q.split(/\s+/)
    for (let i = 0; i < terms.length; i++) {
      const term = terms[i]
      if (term.length === 0)
        continue
      if (haystack.indexOf(term) < 0 && !(term.length <= 5 && root.launcherAcronym(entry).indexOf(term) >= 0))
        return -1
    }

    const nameIndex = name.indexOf(q)
    const idIndex = id.indexOf(q)
    if (nameIndex === 0) return 10000 - name.length
    if (idIndex === 0) return 9500 - id.length
    if (nameIndex > 0) return 8000 - nameIndex * 10 - name.length
    if (idIndex > 0) return 7600 - idIndex * 10 - id.length

    const hayIndex = haystack.indexOf(q)
    if (hayIndex >= 0) return 6000 - hayIndex

    const acronymIndex = root.launcherAcronym(entry).indexOf(q)
    if (acronymIndex === 0) return 5000
    if (acronymIndex > 0) return 4600 - acronymIndex * 10
    return 4000 - name.length
  }

  function launcherMruIndex(entry) {
    const id = String(entry && entry.id || "")
    if (id.length === 0)
      return -1
    for (let i = 0; i < root.launcherMru.length; i++) {
      if (root.launcherMru[i] === id)
        return i
    }
    return -1
  }

  function launcherMruBoost(entry) {
    const index = root.launcherMruIndex(entry)
    return index < 0 ? 0 : 300 - Math.min(index, 49) * 5
  }

  function launcherMfuBoost(entry) {
    const id = String(entry && entry.id || "")
    const count = Number(root.launcherCounts[id] || 0)
    return Math.min(count, 20) * 10
  }

  function updateLauncherMru(output) {
    const lines = String(output || "").split(/\n+/)
    const seen = {}
    const entries = []
    const counts = {}
    for (let i = 0; i < lines.length && entries.length < 50; i++) {
      const fields = lines[i].trim().split(/\t+/)
      const id = fields[0]
      if (id.length === 0 || seen[id])
        continue
      const count = Number(fields[1] || 1)
      seen[id] = true
      entries.push(id)
      counts[id] = count > 0 ? count : 1
    }
    root.launcherMru = entries
    root.launcherCounts = counts
    if (launcher.visible)
      root.rebuildLauncher()
  }

  function recordLauncherUse(entry) {
    const id = String(entry && entry.id || "")
    if (id.length === 0)
      return
    const next = [id]
    for (let i = 0; i < root.launcherMru.length && next.length < 50; i++) {
      if (root.launcherMru[i] !== id)
        next.push(root.launcherMru[i])
    }
    const counts = Object.assign({}, root.launcherCounts)
    counts[id] = Number(counts[id] || 0) + 1
    root.launcherMru = next
    root.launcherCounts = counts
    let cache = ""
    for (let i = 0; i < next.length; i++)
      cache += next[i] + "\t" + Number(counts[next[i]] || 1) + "\n"
    Quickshell.execDetached(["sh", "-c", "dir=${XDG_CACHE_HOME:-$HOME/.cache}/quickshell/marcelof; file=$dir/launcher-mru.txt; tmp=$file.tmp; mkdir -p \"$dir\"; printf %s " + root.shellQuote(cache) + " > \"$tmp\" && mv \"$tmp\" \"$file\""])
  }


  function rebuildLauncher() {
    const values = DesktopEntries.applications.values || []
    const query = search ? search.text : ""
    const commandRows = root.launcherCommandEntries(query)
    if (query.trim().indexOf(">") === 0) {
      root.launcherModeText = "Commands"
      launcherModel.clear()
      launcherEntries = commandRows
      for (let i = 0; i < commandRows.length; i++)
        launcherModel.append({ name: commandRows[i].name, subtext: commandRows[i].subtext, icon: commandRows[i].icon, id: "", favorite: false })
      if (appList)
        appList.currentIndex = launcherModel.count > 0 ? 0 : -1
      return
    }
    root.launcherModeText = "Apps"
    const rows = []
    for (let i = 0; i < values.length; i++) {
      const entry = values[i]
      if (!entry || entry.noDisplay || !entry.name || root.isLauncherHidden(entry))
        continue
      const score = root.launcherScore(entry, query)
      if (score < 0)
        continue
      const favorite = root.isLauncherFavorite(entry)
      const boost = root.launcherMruBoost(entry) + root.launcherMfuBoost(entry) + (favorite ? 20000 : 0)
      rows.push({ entry: entry, score: score + boost, key: String(entry.name).toLowerCase(), mru: root.launcherMruIndex(entry), boost: boost, favorite: favorite })
    }

    rows.sort((a, b) => {
      if (query.trim().length > 0 && a.score !== b.score)
        return b.score - a.score
      if (query.trim().length === 0 && a.boost !== b.boost)
        return b.boost - a.boost
      if (query.trim().length === 0 && a.mru !== b.mru)
        return a.mru < 0 ? 1 : (b.mru < 0 ? -1 : a.mru - b.mru)
      return a.key < b.key ? -1 : (a.key > b.key ? 1 : 0)
    })

    launcherModel.clear()
    launcherEntries = []
    const count = Math.min(rows.length, 200)
    for (let i = 0; i < count; i++) {
      const entry = rows[i].entry
      launcherEntries.push(entry)
      launcherModel.append({
        name: String(entry.name || entry.id || "Application"),
        subtext: String(entry.genericName || entry.comment || entry.id || ""),
        icon: String(entry.icon || "application-x-executable"),
        id: root.launcherEntryId(entry),
        favorite: rows[i].favorite
      })
    }

    if (appList) {
      appList.currentIndex = launcherModel.count > 0 ? 0 : -1
      Qt.callLater(() => { if (launcherModel.count > 0) appList.positionViewAtIndex(appList.currentIndex, ListView.Contain) })
    }
  }

  function launchCurrentApp() {
    if (!launcher.visible || appList.currentIndex < 0 || appList.currentIndex >= launcherEntries.length)
      return
    const entry = launcherEntries[appList.currentIndex]
    launcher.visible = false
    search.text = ""
    if (entry && entry.command) {
      Quickshell.execDetached(entry.command)
      return
    }
    root.recordLauncherUse(entry)
    if (entry && entry.id)
      Quickshell.execDetached(["gtk-launch", String(entry.id).replace(/\.desktop$/, "")])
    else if (entry)
      entry.execute()
  }

  function launchAppAtIndex(index) {
    if (!launcher.visible || index < 0 || index >= launcherEntries.length)
      return
    appList.currentIndex = index
    root.launchCurrentApp()
  }

  readonly property var laptopScreen: Quickshell.screens.find(screen => screen.name === "eDP-1") || Quickshell.screens[0]

  property bool barHidden: false
  property bool trayExpanded: false
  property bool trayManageOpen: false
  property string sessionConfirmLabel: ""
  property string sessionConfirmIcon: ""
  property var sessionConfirmCommand: []
  property bool controlPanelOpen: false
  property bool mediaPanelOpen: false
  property bool screenPanelOpen: false
  property bool wallpaperPanelOpen: false
  property bool calendarOpen: false
  property bool workInboxOpen: false
  property bool settingsOpen: false
  property bool osdOpen: false
  property bool notificationCenterOpen: false
  property bool notificationToastOpen: false
  property int selectedNotificationIndex: -1
  property var notificationObjects: []
  property string notificationToastApp: ""
  property string notificationToastSummary: ""
  property string notificationToastBody: ""
  property int notificationToastSerial: 0
  property string brightnessText: "--"
  property real brightnessValue: 0
  property string kbdBrightnessText: ""
  property string networkStatusText: ""
  property string powerStatusText: ""
  property string fanStatusText: "Fan --"
  property string privacyStatusText: ""
  property string mediaNowText: ""
  property string weatherPanelText: ""
  property string externalBrightnessText: ""
  property real externalBrightnessValue: 0
  property string osdIconText: ""
  property string osdBodyText: ""
  property string osdPendingKind: ""
  property string inhibitStatusText: "inactive"
  property string lisbonClockText: "--"
  property string timePanelText: ""
  property string workInboxUpdatedText: ""
  property string workInboxSourceText: ""
  property bool workInboxSlackAvailable: false
  property int workInboxSlackUnread: 0
  property int workInboxSlackMentions: 0
  property string workInboxSlackReason: "not loaded"
  property bool workInboxGithubAvailable: false
  property int workInboxGithubReviews: 0
  property string workInboxGithubReason: "not loaded"
  property bool workInboxLinearAvailable: false
  property int workInboxLinearNotifications: 0
  property string workInboxLinearReason: "not loaded"
  readonly property var calendarWeekdays: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

  function calendarDayAt(index) {
    const date = clock.date
    const year = date.getFullYear()
    const month = date.getMonth()
    const firstWeekday = (new Date(year, month, 1).getDay() + 6) % 7
    const day = index - firstWeekday + 1
    const daysInMonth = new Date(year, month + 1, 0).getDate()
    return day >= 1 && day <= daysInMonth ? day : 0
  }

  function calendarCellCount() {
    const date = clock.date
    const year = date.getFullYear()
    const month = date.getMonth()
    const firstWeekday = (new Date(year, month, 1).getDay() + 6) % 7
    const daysInMonth = new Date(year, month + 1, 0).getDate()
    return firstWeekday + daysInMonth > 35 ? 42 : 35
  }

  function isCalendarToday(day) {
    const date = clock.date
    return day === date.getDate()
  }

  property string todoPanelText: ""
  property string sinkDescription: "Default output"
  property string audioIconText: "󰐊"
  property string audioDisplayText: ""
  property string audioStatusText: ""
  property string recordingStatusText: ""
  property string portalStatusText: ""
  property string wallpaperSource: "file:///home/marcelof/.local/share/backgrounds/bkg2.png"
  property string tooltipText: ""
  readonly property string stateDir: Quickshell.env("HOME") + "/.local/state/quickshell/marcelof"
  property real tooltipX: 0
  property real tooltipY: 0

  readonly property var allTrayItems: SystemTray.items.values || []
  readonly property var bluetoothAdapter: Bluetooth.defaultAdapter
  readonly property var bluetoothDevices: Bluetooth.devices.values || []
  readonly property var pinnedTrayItems: allTrayItems.filter(item => root.isTrayPinned(item) && !root.isTrayHidden(item))
  readonly property var drawerTrayItems: allTrayItems.filter(item => !root.isTrayPinned(item) && !root.isTrayHidden(item))

  function trayItemId(item) {
    return item.id || item.title || item.tooltipTitle || ""
  }

  function trayItemText(item) {
    const id = root.trayItemId(item)
    const rawTitle = item.tooltipTitle || item.title || id || "tray item"
    const title = rawTitle === "update-notifier" && id.length > 0 ? id.replace(/-/g, " ") : rawTitle
    const description = item.tooltipDescription || ""
    return description.length > 0 && title !== description && title.toLowerCase() !== description.toLowerCase() ? title + " - " + description : title
  }

  function isTrayPinned(item) {
    return shellSettings.pinnedTrayIds.indexOf(root.trayItemId(item)) !== -1
  }

  function isTrayHidden(item) {
    return shellSettings.hiddenTrayIds.indexOf(root.trayItemId(item)) !== -1
  }

  function toggleTrayPin(item) {
    const id = root.trayItemId(item)
    if (id.length === 0)
      return

    const next = shellSettings.pinnedTrayIds.slice()
    const idx = next.indexOf(id)
    if (idx === -1)
      next.push(id)
    else
      next.splice(idx, 1)
    shellSettings.pinnedTrayIds = next
  }

  function toggleTrayHide(item) {
    const id = root.trayItemId(item)
    if (id.length === 0)
      return

    const next = shellSettings.hiddenTrayIds.slice()
    const idx = next.indexOf(id)
    if (idx === -1)
      next.push(id)
    else
      next.splice(idx, 1)
    shellSettings.hiddenTrayIds = next
  }

  function showTooltip(target, text) {
    if (!target || !text)
      return

    const point = bar.contentItem.mapFromItem(target, target.width / 2 - 1, target.height + 6)
    tooltipX = Math.max(8, Math.round(point.x))
    tooltipY = Math.round(point.y)
    tooltipText = text
  }

  function hideTooltip() {
    tooltipText = ""
  }

  function isNetworkTrayItem(item) {
    const text = root.trayItemSearchText(item)
    return text.indexOf("nm-applet") !== -1 || text.indexOf("network") !== -1
  }

  function trayItemSearchText(item) {
    return ((item.id || "") + " " + (item.title || "") + " " + (item.tooltipTitle || "") + " " + (item.tooltipDescription || "")).toLowerCase()
  }

  function trayDirectCommand(item) {
    const text = root.trayItemSearchText(item)

    if (text.indexOf("nm-applet") !== -1 || text.indexOf("network") !== -1)
      return ["hypr-clean-env", "nm-connection-editor"]
    if (text.indexOf("software_update") !== -1 || text.indexOf("software update") !== -1 || text.indexOf("update-notifier") !== -1)
      return ["hypr-clean-env", "update-manager"]
    if (text.indexOf("livepatch") !== -1)
      return ["hypr-clean-env", "software-properties-gtk"]
    if (text.indexOf("slack") !== -1)
      return ["hypr-clean-env", "slack"]

    return []
  }

  function runTrayDirectAction(item) {
    const command = root.trayDirectCommand(item)
    if (command.length === 0)
      return false

    Quickshell.execDetached(command)
    return true
  }

  function closeTransientPanels() {
    root.hideLauncher()
    root.clipboardOpen = false
    root.passMenuOpen = false
    root.trayManageOpen = false
    root.controlPanelOpen = false
    root.mediaPanelOpen = false
    root.screenPanelOpen = false
    root.wallpaperPanelOpen = false
    root.calendarOpen = false
    root.workInboxOpen = false
    root.settingsOpen = false
    root.notificationCenterOpen = false
    root.keybindingsOpen = false
    root.webSearchOpen = false
    if (typeof networkPanel !== 'undefined')
      networkPanel.visible = false
    root.clearSessionConfirm()
    if (typeof exitDialog !== 'undefined')
      exitDialog.visible = false
  }

  function togglePowerMenu() {
    const next = !exitDialog.visible
    root.closeTransientPanels()
    exitDialog.visible = next
  }

  function toggleTrayManage() {
    const next = !root.trayManageOpen
    root.closeTransientPanels()
    root.trayManageOpen = next
  }

  function toggleControlPanel() {
    const next = !root.controlPanelOpen
    root.closeTransientPanels()
    root.controlPanelOpen = next
    if (next) {
      brightnessRefresh.running = true
      kbdBrightnessRefresh.running = true
      networkStatusRefresh.running = true
      powerStatusRefresh.running = true
      fanStatusRefresh.running = true
      inhibitStatusRefresh.running = true
      privacyStatusRefresh.running = true
      externalBrightnessRefresh.running = true
    }
  }

  function toggleNetworkPanel() {
    const next = !networkPanel.visible
    root.closeTransientPanels()
    networkPanel.visible = next
    if (next) {
      networkStatusRefresh.running = true
      networkRefresh.running = true
    }
  }

  function toggleMediaPanel() {
    const next = !root.mediaPanelOpen
    root.closeTransientPanels()
    root.mediaPanelOpen = next
    if (next)
      root.refreshAudioState()
  }

  function refreshScreenState() {
    screenRecordStatus.running = true
    portalStatusRefresh.running = true
    privacyStatusRefresh.running = true
  }

  function toggleScreenPanel() {
    const next = !root.screenPanelOpen
    root.closeTransientPanels()
    root.screenPanelOpen = next
    if (next)
      root.refreshScreenState()
  }

  function runScreenRecord(action) {
    Quickshell.execDetached(["/home/marcelof/bin/screen-record-wayland", action])
    screenRecordStatusLater.restart()
  }

  function updateWallpaperRows(output) {
    wallpaperModel.clear()
    const rows = output.trim().length > 0 ? output.trim().split("\n") : []
    for (let i = 0; i < rows.length; i++) {
      const parts = rows[i].split("\t")
      if (parts.length >= 2)
        wallpaperModel.append({ name: parts[0], path: parts[1], active: parts[2] === "*" })
    }
  }

  function refreshWallpapers() {
    wallpaperCurrent.running = true
    wallpaperListRefresh.running = true
  }

  function toggleWallpaperPanel() {
    const next = !root.wallpaperPanelOpen
    root.closeTransientPanels()
    root.wallpaperPanelOpen = next
    if (next)
      root.refreshWallpapers()
  }

  function setWallpaper(path) {
    root.wallpaperSource = "file://" + path
    Quickshell.execDetached(["/home/marcelof/bin/wallpaper-wayland", "set", path])
    wallpaperListRefreshLater.restart()
  }

  function toggleCalendar() {
    const next = !root.calendarOpen
    root.closeTransientPanels()
    root.calendarOpen = next
    if (next) {
      timePanelRefresh.running = true
      todoPanelRefresh.running = true
      weatherPanelRefresh.running = true
    }
  }

  function toggleWorkInbox() {
    const next = !root.workInboxOpen
    root.closeTransientPanels()
    root.workInboxOpen = next
    if (next)
      workInboxRefresh.running = true
  }

  function toggleSettings() {
    const next = !root.settingsOpen
    root.closeTransientPanels()
    root.settingsOpen = next
  }

  function toggleDnd() {
    shellSettings.doNotDisturb = !shellSettings.doNotDisturb
    if (shellSettings.doNotDisturb)
      root.notificationToastOpen = false
  }

  function toggleNotifications() {
    const next = !root.notificationCenterOpen
    root.closeTransientPanels()
    root.notificationCenterOpen = next
  }

  function clearNotifications() {
    for (let i = 0; i < root.notificationObjects.length; i++) {
      const notification = root.notificationObjects[i]
      if (notification && notification.dismiss)
        notification.dismiss()
    }
    root.notificationObjects = []
    notificationHistory.clear()
    notificationInboxModel.clear()
    root.selectedNotificationIndex = -1
  }

  function notificationAppAt(index) {
    if (index < 0 || index >= notificationHistory.count)
      return ""
    return String(notificationHistory.get(index).app || "")
  }

  function clearNotificationsForApp(app) {
    const target = String(app || "")
    if (target.length === 0)
      return
    for (let i = notificationHistory.count - 1; i >= 0; i--) {
      if (String(notificationHistory.get(i).app || "") === target)
        root.dismissNotification(i)
    }
  }

  function rebuildNotificationInbox() {
    const apps = []
    const counts = ({})
    for (let i = 0; i < notificationHistory.count; i++) {
      const app = String(notificationHistory.get(i).app || "Notification")
      if (!counts[app]) {
        counts[app] = 0
        apps.push(app)
      }
      counts[app] += 1
    }

    notificationInboxModel.clear()
    // ponytail: O(apps * notifications), capped at 50; index by app only if history grows.
    for (let appIndex = 0; appIndex < apps.length; appIndex++) {
      const app = apps[appIndex]
      notificationInboxModel.append({ kind: "group", app: app, count: counts[app], sourceIndex: -1, summary: "", body: "", text: "", actionsText: "", desktopEntry: "", time: "" })
      for (let i = 0; i < notificationHistory.count; i++) {
        const row = notificationHistory.get(i)
        if (String(row.app || "Notification") !== app)
          continue
        notificationInboxModel.append({ kind: "notification", app: row.app, count: counts[app], sourceIndex: i, summary: row.summary, body: row.body, text: row.text, actionsText: row.actionsText, desktopEntry: row.desktopEntry || "", time: row.time })
      }
    }
  }

  function cleanNotificationText(value) {
    return String(value || "").replace(/<[^>]+>/g, "").replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">").trim()
  }

  function notificationActionLabelsFrom(notification) {
    if (!notification || !notification.actions)
      return []

    const labels = []
    for (let i = 0; i < notification.actions.length; i++) {
      const text = root.cleanNotificationText(notification.actions[i].text)
      if (text.length > 0)
        labels.push(text)
    }
    return labels
  }

  function notificationPreview(summary, body, app) {
    if (summary.length > 0 && body.length > 0)
      return summary + " - " + body
    return summary.length > 0 ? summary : (body.length > 0 ? body : app)
  }

  function rememberNotification(notification) {
    if (!notification)
      return

    const app = root.cleanNotificationText(notification.appName || "Notification")
    const summary = root.cleanNotificationText(notification.summary)
    const body = root.cleanNotificationText(notification.body)
    const actionLabels = root.notificationActionLabelsFrom(notification)

    notificationHistory.insert(0, {
      app: app,
      summary: summary,
      body: body,
      text: root.notificationPreview(summary, body, app),
      actionsText: actionLabels.join(" | "),
      desktopEntry: root.cleanNotificationText(notification.desktopEntry),
      time: Qt.formatDateTime(new Date(), "HH:mm")
    })
    root.notificationObjects = [notification].concat(root.notificationObjects)
    root.selectedNotificationIndex = 0
    root.notificationToastApp = app
    root.notificationToastSummary = summary.length > 0 ? summary : app
    root.notificationToastBody = body
    root.notificationToastSerial += 1
    if (!shellSettings.doNotDisturb) {
      root.notificationToastOpen = false
      Qt.callLater(() => {
        root.notificationToastOpen = true
        notificationToastTimer.restart()
      })
    }
    while (notificationHistory.count > 50) {
      notificationHistory.remove(notificationHistory.count - 1)
      root.notificationObjects.pop()
    }
    root.rebuildNotificationInbox()
  }

  function dismissNotification(index) {
    if (index < 0 || index >= notificationHistory.count)
      return
    const notification = root.notificationObjects[index]
    if (notification && notification.dismiss)
      notification.dismiss()
    const next = root.notificationObjects.slice()
    next.splice(index, 1)
    root.notificationObjects = next
    notificationHistory.remove(index)
    root.rebuildNotificationInbox()
    if (notificationHistory.count === 0)
      root.selectedNotificationIndex = -1
    else if (root.selectedNotificationIndex === index)
      root.selectedNotificationIndex = -1
    else if (root.selectedNotificationIndex > index)
      root.selectedNotificationIndex -= 1
    else if (root.selectedNotificationIndex >= notificationHistory.count)
      root.selectedNotificationIndex = notificationHistory.count - 1
  }


  function notificationActionLabels(index) {
    return root.notificationActionLabelsFrom(root.notificationObjects[index])
  }

  function focusNotificationApp(index) {
    if (index < 0 || index >= notificationHistory.count)
      return
    const row = notificationHistory.get(index)
    Quickshell.execDetached(["/home/marcelof/bin/notification-focus-app", row.desktopEntry || "", row.app || ""])
  }

  function invokeNotificationAction(index, actionIndex) {
    const notification = root.notificationObjects[index]
    if (!notification || !notification.actions || actionIndex < 0 || actionIndex >= notification.actions.length)
      return

    notification.actions[actionIndex].invoke()
    if (!notification.resident)
      root.dismissNotification(index)
  }
  function updateAudioStreams(output) {
    audioStreams.clear()
    const lines = String(output || "").trim().split(/\n+/)
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i].trim()
      if (line.length === 0)
        continue
      const parts = line.split("|")
      if (parts.length < 5)
        continue
      audioStreams.append({ id: parts[0], app: parts[1], media: parts[2], volume: parts[3], muted: parts[4] })
    }
  }

  function updateAudioStatus(output) {
    const text = String(output || "").trim()
    root.audioStatusText = text
    const lines = text.split(/\n+/)
    let display = ""
    let icon = "󰐊"
    for (let i = 0; i < lines.length; i++) {
      if (lines[i].indexOf("display: ") === 0)
        display = lines[i].slice(9)
      else if (lines[i].indexOf("icon: ") === 0)
        icon = lines[i].slice(6)
    }
    root.audioDisplayText = display
    root.audioIconText = icon
  }

  function updateWorkInbox(output) {
    const text = String(output || "").trim()
    if (text.length === 0)
      return

    try {
      const data = JSON.parse(text)
      const slack = data.slack || {}
      const github = data.github || {}
      const linear = data.linear || {}
      root.workInboxUpdatedText = data.updated_at || ""
      root.workInboxSourceText = data.source || ""
      root.workInboxSlackAvailable = slack.available === true
      root.workInboxSlackUnread = Number(slack.unread || 0)
      root.workInboxSlackMentions = Number(slack.mentions || 0)
      root.workInboxSlackReason = slack.reason || "ok"
      root.workInboxGithubAvailable = github.available === true
      root.workInboxGithubReviews = Number(github.review_requests || 0)
      root.workInboxGithubReason = github.reason || "ok"
      root.workInboxLinearAvailable = linear.available === true
      root.workInboxLinearNotifications = Number(linear.notifications || 0)
      root.workInboxLinearReason = linear.reason || "ok"
    } catch (error) {
      root.workInboxSourceText = "parse error"
    }
  }

  function refreshAudioMixer() {
    audioStreamsRefresh.running = true
  }

  function refreshAudioState() {
    audioStatusRefresh.running = true
    if (root.mediaPanelOpen) {
      audioStreamsRefresh.running = true
      mediaNowRefresh.running = true
    }
  }

  function scheduleAudioRefresh() {
    audioRefreshLater.restart()
  }

  function audioNoiseRunning() {
    return root.audioStatusText.indexOf("brown-noise: running") >= 0
  }

  function audioMusicRunning() {
    return root.audioStatusText.indexOf("music: running") >= 0
  }

  function audioPlaybackActive() {
    return root.audioDisplayText.length > 0 && root.audioDisplayText.indexOf("(paused)") < 0
  }

  function runAudioctl(action) {
    Quickshell.execDetached(["/home/marcelof/bin/audioctl", action])
    root.scheduleAudioRefresh()
  }

  function runPlayerctl(action) {
    Quickshell.execDetached(["playerctl", "--all-players", action])
    root.scheduleAudioRefresh()
  }

  function sinkInputCommand(id, action) {
    if (!id)
      return []
    if (action === "mute")
      return ["pactl", "set-sink-input-mute", String(id), "toggle"]
    if (action === "up")
      return ["pactl", "set-sink-input-volume", String(id), "+5%"]
    if (action === "down")
      return ["pactl", "set-sink-input-volume", String(id), "-5%"]
    return []
  }

  function runSinkInputAction(id, action) {
    const command = root.sinkInputCommand(id, action)
    if (command.length === 0)
      return
    Quickshell.execDetached(command)
    root.scheduleAudioRefresh()
  }

  function setSinkInputVolume(id, value) {
    if (!id)
      return
    Quickshell.execDetached(["pactl", "set-sink-input-volume", String(id), Math.round(value * 100) + "%"])
    root.scheduleAudioRefresh()
  }

  function toggleBluetoothScan() {
    if (root.bluetoothAdapter && root.bluetoothAdapter.enabled)
      root.bluetoothAdapter.discovering = !root.bluetoothAdapter.discovering
  }

  function bluetoothDeviceLabel(device) {
    const name = device.name || "Bluetooth device"
    if (device.batteryAvailable)
      return name + " " + Math.round(device.battery * 100) + "%"
    return name
  }

  function bluetoothStatusText() {
    if (!root.bluetoothAdapter)
      return "No adapter"
    if (!root.bluetoothAdapter.enabled)
      return "Bluetooth off"

    const names = []
    for (let i = 0; i < root.bluetoothDevices.length; i++) {
      const device = root.bluetoothDevices[i]
      if (device && device.state === BluetoothDeviceState.Connected)
        names.push(root.bluetoothDeviceLabel(device))
    }
    return names.length > 0 ? names.join(", ") : "No devices connected"
  }

  function runNetwork(action) {
    Quickshell.execDetached(["/home/marcelof/bin/network-status", action])
    networkStatusRefreshLater.restart()
  }

  function setPowerProfile(profile) {
    Quickshell.execDetached(["/home/marcelof/bin/power-status", "set-profile", profile])
    powerStatusRefreshLater.restart()
  }

  function idleInhibitActive() {
    return root.inhibitStatusText.indexOf("active") === 0
  }

  function toggleIdleInhibit() {
    Quickshell.execDetached(["/home/marcelof/bin/desktop-inhibit", "toggle"])
    inhibitStatusRefreshLater.restart()
  }

  function toggleBluetooth() {
    if (root.bluetoothAdapter)
      root.bluetoothAdapter.enabled = !root.bluetoothAdapter.enabled
  }

  function showTrayMenu(item, visualItem, mouse) {
    if (!shellSettings.nativeTrayMenus)
      return false
    if (!item.hasMenu)
      return false

    const point = bar.contentItem.mapFromItem(visualItem, mouse.x, mouse.y)
    item.display(bar, point.x, point.y)
    return true
  }



  Component.onCompleted: Quickshell.execDetached(["mkdir", "-p", root.stateDir])

  FileView {
    id: settingsFile
    path: root.stateDir + "/settings.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onAdapterUpdated: writeAdapter()

    JsonAdapter {
      id: shellSettings
      property var pinnedTrayIds: ["nm-applet"]
      property var hiddenTrayIds: []
      property bool nativeTrayMenus: false
      property bool doNotDisturb: false
      property bool denseUi: false
      property string primaryColor: "#b4befe"
      property string weatherLocation: "Palmela, Portugal"
      property var favoriteAppIds: []
      property var hiddenAppIds: []
    }
  }

  ListModel { id: notificationHistory }
  ListModel { id: notificationInboxModel }
  ListModel { id: audioStreams }
  ListModel { id: wallpaperModel }

  Timer {
    id: notificationToastTimer
    interval: 5000
    repeat: false
    onTriggered: root.notificationToastOpen = false
  }

  NotificationServer {
    id: notifications
    keepOnReload: false
    actionsSupported: true
    onNotification: function(notification) { root.rememberNotification(notification) }
  }

  PwObjectTracker {
    objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
  }

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }

  Process {
    id: lisbonClock
    command: ["env", "TZ=Europe/Lisbon", "date", "+%a-%d %H:%M:%S"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.lisbonClockText = this.text.trim() }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: lisbonClock.running = true
  }

  Process {
    id: timePanelRefresh
    command: ["/home/marcelof/bin/check-time-panel"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.timePanelText = this.text.trim() }
  }

  Process {
    id: todoPanelRefresh
    command: ["/home/marcelof/bin/check-todo-panel"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.todoPanelText = this.text.trim() }
  }

  Process {
    id: weatherPanelRefresh
    command: ["sh", "-c", "WEATHER_LOCATION=" + root.shellQuote(shellSettings.weatherLocation) + " /home/marcelof/bin/check-weather panel"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.weatherPanelText = this.text.trim() }
  }

  Process {
    id: workInboxRefresh
    command: ["/home/marcelof/bin/work-inbox-status"]
    running: false
    stdout: StdioCollector { onStreamFinished: root.updateWorkInbox(this.text) }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: timePanelRefresh.running = root.calendarOpen
  }

  Timer {
    interval: 60000
    running: true
    repeat: true
    onTriggered: todoPanelRefresh.running = root.calendarOpen
  }

  Process {
    id: audioStreamsRefresh
    command: ["/home/marcelof/bin/check-audio-streams"]
    running: false
    stdout: StdioCollector { onStreamFinished: root.updateAudioStreams(this.text) }
  }

  Process {
    id: audioStatusRefresh
    command: ["/home/marcelof/bin/audioctl", "status"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.updateAudioStatus(this.text) }
  }

  Timer {
    id: audioRefreshLater
    interval: 350
    repeat: false
    onTriggered: root.refreshAudioState()
  }

  Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: root.refreshAudioState()
  }

  function defaultSinkAudio() {
    return Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio ? Pipewire.defaultAudioSink.audio : null
  }

  function adjustVolume(delta) {
    const audio = root.defaultSinkAudio()
    if (!audio)
      return

    audio.volume = Math.max(0, Math.min(1.5, audio.volume + delta))
    root.showVolumeOsd()
  }

  function toggleMute() {
    const audio = root.defaultSinkAudio()
    if (audio) {
      audio.muted = !audio.muted
      root.scheduleAudioRefresh()
      root.showVolumeOsd()
    }
  }

  function runBrightness(action) {
    Quickshell.execDetached(["/home/marcelof/bin/bri", action])
    brightnessRefreshLater.restart()
  }

  function setBrightness(value) {
    root.brightnessValue = Math.max(0, Math.min(100, Math.round(value)))
    root.brightnessText = root.brightnessValue + "%"
    root.runBrightness(String(root.brightnessValue))
    root.showOsd("󰃠", "Brightness " + root.brightnessText)
  }

  function setExternalBrightness(value) {
    root.externalBrightnessValue = Math.max(0, Math.min(100, Math.round(value)))
    Quickshell.execDetached(["/home/marcelof/bin/external-brightness", "set", String(root.externalBrightnessValue)])
    externalBrightnessRefreshLater.restart()
    root.showOsd("󰍹", "External brightness " + root.externalBrightnessValue + "%")
  }

  function runExternalBrightness(action) {
    Quickshell.execDetached(["/home/marcelof/bin/external-brightness", action])
    externalBrightnessRefreshLater.restart()
  }

  function runKbdBrightness(action) {
    Quickshell.execDetached(["/home/marcelof/bin/kbd-brightness", action])
    kbdBrightnessRefreshLater.restart()
    root.showKbdOsd()
  }

  function lockSession() {
    Quickshell.execDetached(["sh", "-c", "command -v hyprlock >/dev/null 2>&1 && exec hyprlock; command -v swaylock >/dev/null 2>&1 && exec swaylock -f; loginctl lock-session || notify-send Hyprland \"No Wayland locker found\""])
  }

  function suspendSession() {
    Quickshell.execDetached(["systemctl", "suspend"])
  }

  function setSessionConfirm(label, icon, command) {
    root.sessionConfirmLabel = label
    root.sessionConfirmIcon = icon
    root.sessionConfirmCommand = command
  }

  function openSessionConfirm(label, icon, command) {
    root.closeTransientPanels()
    exitDialog.visible = true
    root.setSessionConfirm(label, icon, command)
  }

  function clearSessionConfirm() {
    root.sessionConfirmLabel = ""
    root.sessionConfirmIcon = ""
    root.sessionConfirmCommand = []
  }

  function hidePowerMenu() {
    root.clearSessionConfirm()
    exitDialog.visible = false
  }

  function runSessionConfirm() {
    if (root.sessionConfirmCommand.length === 0)
      return
    const command = root.sessionConfirmCommand
    root.hidePowerMenu()
    Quickshell.execDetached(command)
  }

  component IconButton: Rectangle {
    property string icon: ""
    property string tooltip: ""
    signal triggered()

    readonly property int pad: 8

    implicitHeight: {
      const h = iconLabel.implicitHeight + pad * 2
      return h % 2 === 0 ? h : h + 1
    }
    implicitWidth: implicitHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    radius: Math.round(implicitHeight / 2)
    color: iconMouse.containsMouse ? "#45475a" : "#313244"

    Text {
      id: iconLabel
      anchors.centerIn: parent
      anchors.verticalCenterOffset: 1
      color: "#cdd6f4"
      font.family: "FiraCode Nerd Font"
      font.pixelSize: 15
      text: parent.icon
    }

    MouseArea {
      id: iconMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: if (parent.tooltip.length > 0) root.showTooltip(parent, parent.tooltip)
      onExited: root.hideTooltip()
      onClicked: parent.triggered()
    }
  }

  component ActionButton: Rectangle {
    id: actionButtonRoot
    property string icon: ""
    property string label: ""
    property string tooltip: ""
    property int minWidth: 76
    property bool active: false
    signal triggered()
    signal secondaryTriggered()

    implicitHeight: 32
    implicitWidth: Math.max(minWidth, actionRow.implicitWidth + 18)
    radius: 6
    color: actionMouse.containsMouse ? (active ? "#585b70" : "#45475a") : (active ? "#3b4252" : "#313244")

    RowLayout {
      id: actionRow
      anchors.centerIn: parent
      spacing: 6

      Text { color: "#cdd6f4"; font.family: "FiraCode Nerd Font"; font.pixelSize: 13; text: actionButtonRoot.icon }
      Text { color: "#cdd6f4"; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: actionButtonRoot.label }
    }

    MouseArea {
      id: actionMouse
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: if (parent.tooltip.length > 0) root.showTooltip(parent, parent.tooltip)
      onExited: root.hideTooltip()
      onClicked: mouse => {
        if (mouse.button === Qt.RightButton)
          parent.secondaryTriggered()
        else
          parent.triggered()
      }
    }
  }

  component TrayButton: Item {
    required property var modelData
    property string label: root.trayItemText(modelData)

    width: 22
    height: 22

    Image {
      anchors.centerIn: parent
      width: 18
      height: 18
      source: modelData.icon
    }

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onEntered: root.showTooltip(parent, label)
      onExited: root.hideTooltip()
      onPressed: mouse => {
        root.showTooltip(parent, label)

        if (mouse.button === Qt.MiddleButton) {
          root.toggleTrayPin(modelData)
        } else if (mouse.button === Qt.RightButton || modelData.onlyMenu || root.isNetworkTrayItem(modelData)) {
          if (root.runTrayDirectAction(modelData))
            return

          if (!root.showTrayMenu(modelData, parent, mouse))
            modelData.activate()
        } else {
          modelData.activate()
        }
      }
      onWheel: wheel => modelData.scroll(wheel.angleDelta.y, false)
    }
  }

  IpcHandler {
    target: "bar"

    function toggle() { root.barHidden = !root.barHidden }
    function show() { root.barHidden = false }
    function hide() { root.barHidden = true }
    function trayManage() { root.toggleTrayManage() }
    function controls() { root.toggleControlPanel() }
    function media() { root.toggleMediaPanel() }
    function screen() { root.toggleScreenPanel() }
    function wallpaper() { root.toggleWallpaperPanel() }
    function calendar() { root.toggleCalendar() }
    function workInbox() { root.toggleWorkInbox() }
    function notifications() { root.toggleNotifications() }
    function power() { root.togglePowerMenu() }
    function inhibit() { root.toggleIdleInhibit() }
    function dnd() { root.toggleDnd() }
    function settings() { root.toggleSettings() }
    function osdVolume() { root.showVolumeOsd() }
    function osdBrightness() { root.showBrightnessOsd() }
    function osdKbd() { root.showKbdOsd() }
    function osdMic() { root.showMicOsd() }
    function keybindings() { root.toggleKeybindings() }
    function clipboard() { root.toggleClipboard() }
    function clipboardVisible(): string { return root.clipboardOpen ? "visible" : "hidden" }
    function clipboardUpdate() { clipboardRefresh.running = true }
    function closePanels() { root.closeTransientPanels() }
  }

  IpcHandler {
    target: "websearch"

    function open() { root.openWebSearch("google") }
    function toggle() { root.toggleWebSearch("google") }
    function hide() { root.closeTransientPanels() }
  }

  IpcHandler {
    target: "lock"

    function lock() { root.lockSession() }
  }

  PanelWindow {
    id: wallpaper
    screen: root.laptopScreen

    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }

    WlrLayershell.layer: WlrLayer.Background
    color: "#11111b"

    Image {
      anchors.fill: parent
      source: root.wallpaperSource
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
    }
  }

  PanelWindow {
    id: bar
    screen: root.laptopScreen

    anchors {
      top: true
      left: true
      right: true
    }

    visible: !root.barHidden
    WlrLayershell.layer: WlrLayer.Top
    color: "#1e1e2e"
    implicitHeight: 32

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: 10
      anchors.rightMargin: 10
      spacing: 12

      RowLayout {
        Layout.alignment: Qt.AlignVCenter
        Layout.maximumWidth: 620
        spacing: 8

        Row {
          spacing: 4
          Layout.alignment: Qt.AlignVCenter

          Repeater {
            model: Hyprland.workspaces

            Rectangle {
              required property var modelData

              readonly property int windowCount: modelData.toplevels && modelData.toplevels.values ? modelData.toplevels.values.length : 0
              readonly property string workspaceName: String(modelData.name || modelData.id || "")
              readonly property bool specialWorkspace: workspaceName.indexOf("special:") === 0
              readonly property string workspaceLabel: workspaceName

              visible: !specialWorkspace
              width: visible ? 28 : 0
              height: 24
              radius: 4
              color: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData.id ? "#313244" : "transparent"

              Text {
                anchors.centerIn: parent
                color: parent.windowCount > 0 ? "#cdd6f4" : "#7f849c"
                font.family: "FiraCode Nerd Font"
                font.styleName: "Retina"
                font.pixelSize: 12
                font.bold: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData.id
                text: parent.workspaceLabel
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: modelData.activate()
              }
            }
          }
        }

        StatusText {
          command: ["/home/marcelof/bin/hypr-state", "watch"]
          interval: 30000
          watch: true
        }
      }

      Item { Layout.fillWidth: true }

      Row {
        id: trayRow
        spacing: 3
        Layout.alignment: Qt.AlignVCenter

        HoverHandler {
          onHoveredChanged: root.trayExpanded = hovered
        }

        Rectangle {
          width: 22
          height: 22
          radius: 4
          visible: root.drawerTrayItems.length > 0 || shellSettings.hiddenTrayIds.length > 0
          color: root.trayExpanded || root.trayManageOpen ? "#313244" : "transparent"

          Text {
            anchors.centerIn: parent
            color: "#cdd6f4"
            font.family: "FiraCode Nerd Font"
            font.styleName: "Retina"
            font.pixelSize: 12
            text: root.trayExpanded ? "" : ""
          }

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.showTooltip(parent, "Tray drawer")
            onExited: root.hideTooltip()
            onClicked: mouse => {
              if (mouse.button === Qt.RightButton)
                root.trayManageOpen = !root.trayManageOpen
              else
                root.trayExpanded = !root.trayExpanded
            }
          }
        }

        Row {
          spacing: 3
          clip: true
          width: root.trayExpanded ? implicitWidth : 0
          height: 22
          Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

          Repeater {
            model: root.drawerTrayItems
            TrayButton {}
          }
        }

        Repeater {
          model: root.pinnedTrayItems
          TrayButton {}
        }
      }

      StatusText { command: ["env", "BAR_COLOR_FORMAT=quickshell", "board", "--config", "/home/marcelof/.config/board/board.toml", "render", "quickshell", "quickshell-bar"]; interval: 1000; rich: true }
      StatusText { command: ["/home/marcelof/bin/desktop-privacy-status", "bar"]; interval: 5000; leftClickCommand: ["/home/marcelof/bin/qs-bar", "screen"]; rightClickCommand: ["/home/marcelof/bin/qs-bar", "media"] }

      Text {
        Layout.alignment: Qt.AlignVCenter
        visible: shellSettings.doNotDisturb
        color: shellSettings.primaryColor
        font.family: "FiraCode Nerd Font"
        font.pixelSize: 12
        text: "󰂛"
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.toggleDnd() }
      }

      Text {
        Layout.alignment: Qt.AlignVCenter
        color: root.defaultSinkAudio() && root.defaultSinkAudio().muted ? shellSettings.primaryColor : "#9399b2"
        font.family: "FiraCode Nerd Font"
              font.styleName: "Retina"
        font.pixelSize: 12
        text: {
          const audio = root.defaultSinkAudio()
          if (!audio)
            return " --"

          return (audio.muted ? "󰝟 " : " ") + Math.round(audio.volume * 100) + "%"
        }

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton | Qt.RightButton
          cursorShape: Qt.PointingHandCursor
          onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
              root.toggleMediaPanel()
            else
              root.toggleMute()
          }
          onWheel: wheel => {
            if (wheel.angleDelta.y > 0)
              root.adjustVolume(0.05)
            else if (wheel.angleDelta.y < 0)
              root.adjustVolume(-0.05)
          }
        }
      }

      Rectangle {
        Layout.alignment: Qt.AlignVCenter
        width: 24
        height: 22
        radius: 4
        color: pauseAllMouse.containsMouse ? "#313244" : "transparent"

        Text {
          anchors.centerIn: parent
          color: "#cdd6f4"
          font.family: "FiraCode Nerd Font"
          font.pixelSize: 12
          text: root.audioIconText
        }

        MouseArea {
          id: pauseAllMouse
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton | Qt.RightButton
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: root.showTooltip(parent, "Play/pause audio. Right-click for media")
          onExited: root.hideTooltip()
          onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
              root.toggleMediaPanel()
            else
              root.runAudioctl("play-pause-all")
          }
        }
      }


      StatusText { command: ["sh", "-c", "WEATHER_LOCATION=" + root.shellQuote(shellSettings.weatherLocation) + " /home/marcelof/bin/check-weather"]; interval: 900000 }
      StatusText { command: ["sh", "-c", "brightnessctl -m 2>/dev/null | awk -F, '{print \"󰃠 \" $4}' || printf '󰃠 --'"]; interval: 5000; leftClickCommand: ["/home/marcelof/bin/qs-bar", "controls"]; rightClickCommand: ["/home/marcelof/bin/qs-bar", "controls"]; wheelUpCommand: ["brightnessctl", "set", "+5%"]; wheelDownCommand: ["brightnessctl", "set", "5%-"] }
      StatusText { command: ["/home/marcelof/bin/network-status", "bar"]; interval: 10000; leftClickCommand: ["hypr-clean-env", "nm-connection-editor"]; rightClickCommand: ["hypr-clean-env", "nm-connection-editor"] }

      Text {
        Layout.alignment: Qt.AlignVCenter
        color: "#9399b2"
        font.family: "FiraCode Nerd Font"
              font.styleName: "Retina"
        font.pixelSize: 12
        text: UPower.displayDevice.ready ? "󰁹 " + Math.round(UPower.displayDevice.percentage * 100) + "%" : ""
      }

      Text {
        Layout.alignment: Qt.AlignVCenter
        color: "#9399b2"
        font.family: "FiraCode Nerd Font"
              font.styleName: "Retina"
        font.pixelSize: 12
        text: " " + root.lisbonClockText

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.toggleCalendar()
        }
      }

      Text {
        Layout.alignment: Qt.AlignVCenter
        color: notificationHistory.count > 0 ? shellSettings.primaryColor : "#9399b2"
        font.family: "FiraCode Nerd Font"
        font.styleName: "Retina"
        font.pixelSize: 12
        text: notificationHistory.count > 0 ? "󰂚 " + notificationHistory.count : "󰂜"

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: root.toggleNotifications()
        }
      }
    }

    PopupWindow {
      visible: root.tooltipText.length > 0
      color: "transparent"
      implicitWidth: tooltipBubble.implicitWidth
      implicitHeight: tooltipBubble.implicitHeight
      anchor.window: bar
      anchor.rect.x: root.tooltipX
      anchor.rect.y: root.tooltipY

      Rectangle {
        id: tooltipBubble
        radius: 5
        color: "#313244"
        border.color: "#585b70"
        border.width: 1
        implicitWidth: tooltipLabel.implicitWidth + 18
        implicitHeight: tooltipLabel.implicitHeight + 12

        Text {
          id: tooltipLabel
          anchors.centerIn: parent
          color: "#cdd6f4"
          font.family: "FiraCode Nerd Font"
          font.styleName: "Retina"
          font.pixelSize: 12
          text: root.tooltipText
        }
      }
    }

    PopupWindow {
      id: trayManageWindow
      visible: root.trayManageOpen
      color: "transparent"
      implicitWidth: 460
      implicitHeight: 420
      anchor.window: bar
      anchor.rect.x: Math.max(8, bar.width - implicitWidth - 10)
      anchor.rect.y: bar.height + 6

      Rectangle {
        anchors.fill: parent
        radius: 6
        color: "#11111b"
        border.color: "#45475a"
        border.width: 1

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: 12
          spacing: 10

          RowLayout {
            Layout.fillWidth: true
            Text { Layout.fillWidth: true; color: "#cdd6f4"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 15; text: "Tray items" }
            Text { color: "#9399b2"; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: root.allTrayItems.length + "" }
          }

          Text {
            Layout.fillWidth: true
            visible: root.allTrayItems.length === 0
            color: "#7f849c"
            font.family: "FiraCode Nerd Font"
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            text: "No tray items"
          }

          ListView {
            id: trayManageList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: root.allTrayItems

            delegate: Rectangle {
              required property var modelData
              width: trayManageList.width
              height: 44
              radius: 6
              color: root.isTrayHidden(modelData) ? "#181825" : "#1e1e2e"
              border.color: "#313244"
              border.width: 1

              RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 9
                anchors.rightMargin: 9
                spacing: 8

                Image { source: modelData.icon; Layout.preferredWidth: 18; Layout.preferredHeight: 18 }

                Text {
                  Layout.fillWidth: true
                  color: root.isTrayHidden(modelData) ? "#6c7086" : "#bac2de"
                  elide: Text.ElideRight
                  font.family: "FiraCode Nerd Font"
                  font.styleName: "Retina"
                  font.pixelSize: 12
                  text: root.trayItemText(modelData)
                }

                ActionButton { active: root.isTrayPinned(modelData); icon: "󰐃"; label: root.isTrayPinned(modelData) ? "Pinned" : "Pin"; minWidth: 76; tooltip: "Pin tray item"; onTriggered: root.toggleTrayPin(modelData) }
                ActionButton { active: root.isTrayHidden(modelData); icon: "󰖭"; label: root.isTrayHidden(modelData) ? "Hidden" : "Hide"; minWidth: 76; tooltip: "Hide tray item"; onTriggered: root.toggleTrayHide(modelData) }
              }
            }
          }
        }
      }
    }
  }

    PopupWindow {
      id: wallpaperPanelWindow
      visible: root.wallpaperPanelOpen
      color: "transparent"
      implicitWidth: 460
      implicitHeight: 420
      anchor.window: bar
      anchor.rect.x: Math.max(8, bar.width - implicitWidth - 10)
      anchor.rect.y: bar.height + 6

      Rectangle {
        anchors.fill: parent
        radius: 6
        color: "#11111b"
        border.color: "#45475a"
        border.width: 1

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: 12
          spacing: 9

          RowLayout {
            Layout.fillWidth: true
            Text { Layout.fillWidth: true; color: "#cdd6f4"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 15; text: "Wallpaper" }
            ActionButton { icon: "󰑓"; label: ""; minWidth: 34; tooltip: "Refresh"; onTriggered: root.refreshWallpapers() }
            ActionButton { icon: "󰈔"; label: ""; minWidth: 34; tooltip: "Open folder"; onTriggered: Quickshell.execDetached(["/home/marcelof/bin/wallpaper-wayland", "open-dir"]) }
          }

          Image {
            Layout.fillWidth: true
            Layout.preferredHeight: 130
            source: root.wallpaperSource
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
          }

          ListView {
            id: wallpaperList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 5
            model: wallpaperModel

            delegate: Rectangle {
              required property string name
              required property string path
              required property bool active
              width: wallpaperList.width
              height: 34
              radius: 4
              color: active ? "#313244" : (wallpaperMouse.containsMouse ? "#1e1e2e" : "transparent")

              RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 9
                anchors.rightMargin: 9
                spacing: 8
                Text { color: active ? "#a6e3a1" : "#7f849c"; font.family: "FiraCode Nerd Font"; font.pixelSize: 12; text: active ? "󰸉" : "󰋩" }
                Text { Layout.fillWidth: true; color: "#cdd6f4"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.pixelSize: 12; text: name }
              }

              MouseArea {
                id: wallpaperMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.setWallpaper(path)
              }
            }
          }
        }
      }
    }

    PopupWindow {
      id: screenPanelWindow
      visible: root.screenPanelOpen
      color: "transparent"
      implicitWidth: 460
      implicitHeight: 420
      anchor.window: bar
      anchor.rect.x: Math.max(8, bar.width - implicitWidth - 10)
      anchor.rect.y: bar.height + 6

      Rectangle {
        anchors.fill: parent
        radius: 6
        color: "#11111b"
        border.color: "#45475a"
        border.width: 1

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: 12
          spacing: 10

          RowLayout {
            Layout.fillWidth: true
            Text { Layout.fillWidth: true; color: "#cdd6f4"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 15; text: "Screen" }
            Text { color: root.recordingStatusText.indexOf("recording") === 0 ? "#f9e2af" : "#7f849c"; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: root.recordingStatusText.length > 0 ? root.recordingStatusText : "--" }
          }

          Text { Layout.fillWidth: true; color: "#7f849c"; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: "Screenshot" }

          RowLayout {
            Layout.fillWidth: true
            spacing: 7
            ActionButton { icon: "󰹑"; label: "Edit"; tooltip: "Select area and edit"; onTriggered: Quickshell.execDetached(["screenshot-wayland", "edit"]) }
            ActionButton { icon: "󰅇"; label: "Copy"; tooltip: "Copy selected area"; onTriggered: Quickshell.execDetached(["screenshot-wayland", "copy"]) }
            ActionButton { icon: "󰆞"; label: "Save"; tooltip: "Save selected area"; onTriggered: Quickshell.execDetached(["screenshot-wayland", "save"]) }
            ActionButton { icon: "󰍹"; label: "Full"; tooltip: "Save full screen"; onTriggered: Quickshell.execDetached(["screenshot-wayland", "full"]) }
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: 7
            ActionButton { icon: "󰆧"; label: "Window"; tooltip: "Save active window"; onTriggered: Quickshell.execDetached(["screenshot-wayland", "active"]) }
            ActionButton { icon: "󰭹"; label: "OCR"; tooltip: "OCR selected area to clipboard"; onTriggered: Quickshell.execDetached(["screenshot-wayland", "ocr"]) }
            ActionButton { icon: "󰈔"; label: "Open"; tooltip: "Open last screenshot"; onTriggered: Quickshell.execDetached(["screenshot-wayland", "open-last"]) }
            ActionButton { icon: "󰅇"; label: "Path"; tooltip: "Copy last screenshot path"; onTriggered: Quickshell.execDetached(["screenshot-wayland", "copy-path"]) }
          }

          Text { Layout.fillWidth: true; color: "#7f849c"; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: "Recording" }

          RowLayout {
            Layout.fillWidth: true
            spacing: 7
            ActionButton { icon: root.recordingStatusText.indexOf("recording") === 0 ? "󰓛" : "󰐊"; label: root.recordingStatusText.indexOf("recording") === 0 ? "Stop" : "Start"; tooltip: "Start or stop area recording"; onTriggered: root.runScreenRecord("toggle") }
            ActionButton { icon: "󰈔"; label: "Open"; tooltip: "Open last recording"; onTriggered: root.runScreenRecord("open-last") }
            ActionButton { icon: "󰅇"; label: "Path"; tooltip: "Copy last recording path"; onTriggered: root.runScreenRecord("copy-path") }
            ActionButton { icon: "󰑓"; label: "Refresh"; tooltip: "Refresh status"; onTriggered: root.refreshScreenState() }
          }

          Text { Layout.fillWidth: true; color: "#7f849c"; wrapMode: Text.Wrap; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: root.portalStatusText.length > 0 ? "Portal: " + root.portalStatusText : "Portal: --" }
          Text { Layout.fillWidth: true; color: "#f9e2af"; wrapMode: Text.Wrap; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: root.privacyStatusText.length > 0 ? root.privacyStatusText : "mic inactive\ncamera inactive\nshare inactive" }
        }
      }
    }

    PopupWindow {
      id: mediaPanelWindow
      visible: root.mediaPanelOpen
      color: "transparent"
      implicitWidth: 500
      implicitHeight: 420
      anchor.window: bar
      anchor.rect.x: Math.max(8, bar.width - implicitWidth - 10)
      anchor.rect.y: bar.height + 6

      Rectangle {
        anchors.fill: parent
        radius: 6
        color: "#11111b"
        border.color: "#45475a"
        border.width: 1

        ScrollView {
          id: mediaScroll
          anchors.fill: parent
          anchors.margins: 10
          clip: true

          ColumnLayout {
            width: mediaScroll.availableWidth
            spacing: 9

            RowLayout {
              Layout.fillWidth: true
              spacing: 8
              ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Text { Layout.fillWidth: true; color: "#cdd6f4"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 13; text: "Media" }
                Text { Layout.fillWidth: true; color: "#7f849c"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: root.mediaNowText.length > 0 ? root.mediaNowText : (root.audioDisplayText.length > 0 ? root.audioDisplayText : "No active playback") }
              }
              ActionButton { icon: "󰕾"; label: "Output"; minWidth: 92; tooltip: "Open volume mixer"; onTriggered: Quickshell.execDetached(["hypr-clean-env", "pavucontrol"]) }
            }

            RowLayout {
              Layout.fillWidth: true
              spacing: 7
              ActionButton { Layout.fillWidth: true; icon: "󰒮"; label: "Prev"; tooltip: "Previous track"; onTriggered: root.runPlayerctl("previous") }
              ActionButton { Layout.fillWidth: true; active: root.audioPlaybackActive(); icon: root.audioIconText; label: root.audioPlaybackActive() ? "Pause" : "Play"; tooltip: root.audioPlaybackActive() ? "Pause saved music and noise" : "Start saved music and noise"; onTriggered: root.runAudioctl("play-pause-all") }
              ActionButton { Layout.fillWidth: true; icon: "󰒭"; label: "Next"; tooltip: "Next track"; onTriggered: root.runPlayerctl("next") }
            }

            RowLayout {
              Layout.fillWidth: true
              spacing: 7
              ActionButton { Layout.fillWidth: true; active: root.audioNoiseRunning(); icon: "󰜗"; label: root.audioNoiseRunning() ? "Noise Off" : "Noise On"; tooltip: root.audioNoiseRunning() ? "Stop brown noise" : "Start brown noise"; onTriggered: root.runAudioctl("noise-toggle") }
              ActionButton { Layout.fillWidth: true; active: root.audioMusicRunning(); icon: ""; label: root.audioMusicRunning() ? "Music Off" : "Music On"; tooltip: root.audioMusicRunning() ? "Stop saved music" : "Start saved music"; onTriggered: root.runAudioctl("music-toggle") }
              ActionButton { Layout.fillWidth: true; icon: "󰓛"; label: "Stop"; tooltip: "Stop saved music and noise. Right-click: force kill"; onTriggered: root.runAudioctl("stop-all"); onSecondaryTriggered: root.runAudioctl("force-stop") }
            }

            RowLayout {
              Layout.fillWidth: true
              spacing: 10
              Text { color: "#bac2de"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 12; text: root.defaultSinkAudio() && !root.defaultSinkAudio().muted ? "" : "󰝟" }
              Slider { Layout.fillWidth: true; from: 0; to: 1.5; value: root.defaultSinkAudio() ? root.defaultSinkAudio().volume : 0; onMoved: if (root.defaultSinkAudio()) root.defaultSinkAudio().volume = value }
              Text { color: "#bac2de"; font.family: "FiraCode Nerd Font"; font.pixelSize: 12; text: root.defaultSinkAudio() ? Math.round(root.defaultSinkAudio().volume * 100) + "%" : "--" }
              IconButton { icon: "󰝟"; tooltip: "Mute output"; onTriggered: root.toggleMute() }
            }

            Text { Layout.fillWidth: true; color: "#7f849c"; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: audioStreams.count > 0 ? "Streams" : "No streams" }

            Repeater {
              model: audioStreams

              Rectangle {
                required property string id
                required property string app
                required property string media
                required property string volume
                required property string muted

                Layout.fillWidth: true
                implicitHeight: streamColumn.implicitHeight + 12
                radius: 6
                color: "#1e1e2e"
                border.color: "#313244"
                border.width: 1

                ColumnLayout {
                  id: streamColumn
                  anchors.left: parent.left
                  anchors.right: parent.right
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.leftMargin: 9
                  anchors.rightMargin: 9
                  spacing: 4

                  RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text { color: muted === "yes" ? "#f38ba8" : "#a6e3a1"; font.family: "FiraCode Nerd Font"; font.pixelSize: 13; text: muted === "yes" ? "󰝟" : "" }
                    ColumnLayout {
                      Layout.fillWidth: true
                      spacing: 0
                      Text { Layout.fillWidth: true; color: "#cdd6f4"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.pixelSize: 12; text: media }
                      Text { Layout.fillWidth: true; color: "#7f849c"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.pixelSize: 10; text: app }
                    }
                    Text { color: "#9399b2"; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: volume }
                    IconButton { icon: muted === "yes" ? "󰕾" : "󰝟"; tooltip: "Mute this stream"; onTriggered: root.runSinkInputAction(id, "mute") }
                  }

                  Slider {
                    Layout.fillWidth: true
                    from: 0
                    to: 1.5
                    enabled: muted !== "yes"
                    value: Math.max(0, Number(volume.replace("%", "")) / 100)
                    onMoved: root.setSinkInputVolume(id, value)
                  }
                }
              }
            }
          }
        }
      }
    }

    PopupWindow {
      id: controlPanelWindow
      visible: root.controlPanelOpen
      color: "transparent"
      implicitWidth: 460
      implicitHeight: 420
      anchor.window: bar
      anchor.rect.x: Math.max(8, bar.width - implicitWidth - 10)
      anchor.rect.y: bar.height + 6

      Rectangle {
        id: controlsFrame
        anchors.fill: parent
        radius: 6
        color: "#11111b"
        border.color: "#45475a"
        border.width: 1

        ScrollView {
          id: controlsScroll
          anchors.fill: parent
          anchors.margins: 10
          clip: true

          ColumnLayout {
            id: controlsColumn
            width: controlsScroll.availableWidth
            spacing: 9

          Text { Layout.fillWidth: true; color: "#7f849c"; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: "Quick actions" }

          RowLayout {
            Layout.fillWidth: true
            spacing: 7
            ActionButton { icon: "󰹑"; label: "Screen"; tooltip: "Screen tools"; onTriggered: root.toggleScreenPanel() }
            ActionButton { icon: "󰅇"; label: "Copy"; tooltip: "Copy screenshot area"; onTriggered: Quickshell.execDetached(["screenshot-wayland", "copy"]) }
            ActionButton { icon: "󰌾"; label: "Lock"; tooltip: "Lock session"; onTriggered: root.lockSession() }
            ActionButton { icon: shellSettings.doNotDisturb ? "󰂛" : "󰂚"; label: "DND"; active: shellSettings.doNotDisturb; tooltip: shellSettings.doNotDisturb ? "Allow notification popups" : "Silence notification popups"; onTriggered: root.toggleDnd() }
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: 7
            ActionButton { icon: root.idleInhibitActive() ? "󰒳" : "󰒲"; label: "Awake"; active: root.idleInhibitActive(); tooltip: root.idleInhibitActive() ? "Allow idle and sleep" : "Prevent idle and sleep"; onTriggered: root.toggleIdleInhibit() }
            ActionButton { icon: "󰒲"; label: "Sleep"; tooltip: "Suspend system"; onTriggered: root.suspendSession() }
            ActionButton { icon: "󰜉"; label: "Reboot"; tooltip: "Reboot system"; onTriggered: root.openSessionConfirm("Reboot", "󰜉", ["systemctl", "reboot"]) }
            ActionButton { icon: "⏻"; label: "Power"; tooltip: "Power menu"; onTriggered: root.togglePowerMenu() }
          }

          Text { Layout.fillWidth: true; color: "#7f849c"; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: "Menus" }

          RowLayout {
            Layout.fillWidth: true
            spacing: 7
            ActionButton { icon: "󰀻"; label: "Apps"; minWidth: 68; tooltip: "App launcher"; onTriggered: { root.closeTransientPanels(); root.toggleLauncher() } }
            ActionButton { icon: "󰇧"; label: "Web"; minWidth: 68; tooltip: "Web search"; onTriggered: root.toggleWebSearch("google") }
            ActionButton { icon: "󰌌"; label: "Keys"; minWidth: 68; tooltip: "Keybindings"; onTriggered: root.toggleKeybindings() }
            ActionButton { icon: "󰅇"; label: "Clip"; minWidth: 68; tooltip: "Clipboard history"; onTriggered: root.toggleClipboard() }
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: 7
            ActionButton { icon: "󰸉"; label: "Wall"; minWidth: 68; tooltip: "Wallpaper"; onTriggered: root.toggleWallpaperPanel() }
            ActionButton { icon: "󰍹"; label: "Screen"; minWidth: 68; tooltip: "Screen tools"; onTriggered: root.toggleScreenPanel() }
            ActionButton { icon: "󰕾"; label: "Media"; minWidth: 68; tooltip: "Media controls"; onTriggered: root.toggleMediaPanel() }
            ActionButton { icon: "󰖩"; label: "Net"; minWidth: 68; tooltip: "Network panel"; onTriggered: root.toggleNetworkPanel() }
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: 7
            ActionButton { icon: "󰥔"; label: "Time"; minWidth: 68; tooltip: "Calendar and time"; onTriggered: root.toggleCalendar() }
            ActionButton { icon: "󰻞"; label: "Work"; minWidth: 68; tooltip: "Unread work inbox"; onTriggered: root.toggleWorkInbox() }
            ActionButton { icon: "󰂚"; label: "Notes"; minWidth: 68; tooltip: "Notifications"; onTriggered: root.toggleNotifications() }
            ActionButton { icon: "󰒓"; label: "Set"; minWidth: 68; tooltip: "Shell settings"; onTriggered: root.toggleSettings() }
            ActionButton { icon: "󱊖"; label: "Tray"; minWidth: 68; tooltip: "Tray manager"; onTriggered: root.toggleTrayManage() }
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { color: "#bac2de"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 12; text: "󰃠" }
            Slider { Layout.fillWidth: true; from: 1; to: 100; value: root.brightnessValue; onMoved: root.setBrightness(value) }
            Text { width: 42; color: "#bac2de"; horizontalAlignment: Text.AlignRight; font.family: "FiraCode Nerd Font"; font.pixelSize: 12; text: root.brightnessText }
          }

          RowLayout {
            Layout.fillWidth: true
            visible: root.externalBrightnessText.length > 0
            spacing: 10
            Text { color: "#bac2de"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 12; text: "󰍹" }
            Slider { Layout.fillWidth: true; from: 0; to: 100; value: root.externalBrightnessValue; onMoved: root.setExternalBrightness(value) }
            Text { width: 128; color: "#bac2de"; horizontalAlignment: Text.AlignRight; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.pixelSize: 12; text: root.externalBrightnessText }
            ActionButton { icon: "-"; label: ""; minWidth: 34; tooltip: "External brightness down"; onTriggered: root.runExternalBrightness("down") }
            ActionButton { icon: "+"; label: ""; minWidth: 34; tooltip: "External brightness up"; onTriggered: root.runExternalBrightness("up") }
          }

          RowLayout {
            Layout.fillWidth: true
            visible: root.kbdBrightnessText.length > 0
            spacing: 10
            Text { color: "#bac2de"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 12; text: "󰌌" }
            Text { Layout.fillWidth: true; color: "#bac2de"; font.family: "FiraCode Nerd Font"; font.pixelSize: 12; text: root.kbdBrightnessText }
            ActionButton { icon: "-"; label: ""; minWidth: 34; tooltip: "Keyboard brightness down"; onTriggered: root.runKbdBrightness("down") }
            ActionButton { icon: "+"; label: ""; minWidth: 34; tooltip: "Keyboard brightness up"; onTriggered: root.runKbdBrightness("up") }
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { color: "#bac2de"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 12; text: root.bluetoothAdapter && root.bluetoothAdapter.enabled ? "󰂯" : "󰂲" }
            Text { Layout.fillWidth: true; color: "#bac2de"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.pixelSize: 12; text: root.bluetoothStatusText() }
            ActionButton { icon: root.bluetoothAdapter && root.bluetoothAdapter.enabled ? "󰂲" : "󰂯"; label: root.bluetoothAdapter && root.bluetoothAdapter.enabled ? "Off" : "On"; tooltip: "Toggle Bluetooth"; onTriggered: root.toggleBluetooth() }
            ActionButton { icon: root.bluetoothAdapter && root.bluetoothAdapter.discovering ? "󰑓" : "󰐊"; label: "Scan"; tooltip: "Toggle Bluetooth discovery"; onTriggered: root.toggleBluetoothScan() }
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { color: "#bac2de"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 12; text: root.networkStatusText.indexOf("Wi-Fi") === 0 ? "󰖩" : "󰈀" }
            Text { Layout.fillWidth: true; color: "#bac2de"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.pixelSize: 12; text: root.networkStatusText.length > 0 ? root.networkStatusText : "Network unavailable" }
            ActionButton { icon: "󰖩"; label: "Wi-Fi"; tooltip: "Toggle Wi-Fi"; onTriggered: root.runNetwork("wifi-toggle") }
            ActionButton { icon: "󰍜"; label: "Open"; tooltip: "Open network settings"; onTriggered: Quickshell.execDetached(["hypr-clean-env", "nm-connection-editor"]) }
          }

          RowLayout {
            Layout.fillWidth: true
            visible: root.powerStatusText.length > 0
            spacing: 10
            Text { color: "#bac2de"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 12; text: "󰁹" }
            Text { Layout.fillWidth: true; color: "#bac2de"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.pixelSize: 12; text: root.powerStatusText }
            ActionButton { icon: "󰾅"; label: "Save"; tooltip: "Power saver"; onTriggered: root.setPowerProfile("power-saver") }
            ActionButton { icon: "󰾆"; label: "Bal"; tooltip: "Balanced"; onTriggered: root.setPowerProfile("balanced") }
            ActionButton { icon: "󰓅"; label: "Perf"; tooltip: "Performance"; onTriggered: root.setPowerProfile("performance") }
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Text { color: "#bac2de"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 12; text: "󰈐" }
            Text { Layout.fillWidth: true; color: "#bac2de"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.pixelSize: 12; text: root.fanStatusText }
          }
          }
        }
      }
    }

    PopupWindow {
      id: settingsWindow
      visible: root.settingsOpen
      color: "transparent"
      implicitWidth: 460
      implicitHeight: 420
      anchor.window: bar
      anchor.rect.x: Math.max(8, bar.width - implicitWidth - 10)
      anchor.rect.y: bar.height + 6

      Rectangle {
        anchors.fill: parent
        radius: 6
        color: "#11111b"
        border.color: "#45475a"
        border.width: 1

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: 12
          spacing: 10
          Text { Layout.fillWidth: true; color: "#cdd6f4"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 15; text: "Shell settings" }
          RowLayout { Layout.fillWidth: true; spacing: 7
            ActionButton { Layout.fillWidth: true; icon: shellSettings.doNotDisturb ? "󰂛" : "󰂚"; label: "DND"; active: shellSettings.doNotDisturb; tooltip: "Toggle notification popups"; onTriggered: root.toggleDnd() }
            ActionButton { Layout.fillWidth: true; icon: shellSettings.nativeTrayMenus ? "󰍜" : "󰍛"; label: "Tray"; active: shellSettings.nativeTrayMenus; tooltip: "Toggle native tray menus"; onTriggered: shellSettings.nativeTrayMenus = !shellSettings.nativeTrayMenus }
            ActionButton { Layout.fillWidth: true; icon: root.barHidden ? "󰖰" : "󰖯"; label: "Bar"; active: !root.barHidden; tooltip: "Show or hide bar"; onTriggered: root.barHidden = !root.barHidden }
          }
          RowLayout { Layout.fillWidth: true; spacing: 7
            ActionButton { Layout.fillWidth: true; icon: "󰈙"; label: "Dense"; active: shellSettings.denseUi; tooltip: "Toggle compact shell spacing"; onTriggered: shellSettings.denseUi = !shellSettings.denseUi }
            ActionButton { Layout.fillWidth: true; icon: "󰖐"; label: "Palmela"; active: shellSettings.weatherLocation === "Palmela, Portugal"; tooltip: "Weather: Palmela"; onTriggered: { shellSettings.weatherLocation = "Palmela, Portugal"; weatherPanelRefresh.running = true } }
            ActionButton { Layout.fillWidth: true; icon: "󰖐"; label: "Lisbon"; active: shellSettings.weatherLocation === "Lisbon"; tooltip: "Weather: Lisbon"; onTriggered: { shellSettings.weatherLocation = "Lisbon"; weatherPanelRefresh.running = true } }
          }
          RowLayout { Layout.fillWidth: true; spacing: 7
            ActionButton { Layout.fillWidth: true; icon: "󰀻"; label: "Apps"; tooltip: "Open app launcher"; onTriggered: { root.closeTransientPanels(); root.toggleLauncher() } }
            ActionButton { Layout.fillWidth: true; icon: "󰂚"; label: "Notes"; tooltip: "Open notifications"; onTriggered: root.toggleNotifications() }
            ActionButton { Layout.fillWidth: true; icon: "󰒓"; label: "Controls"; tooltip: "Open controls"; onTriggered: root.toggleControlPanel() }
          }
          Text { Layout.fillWidth: true; color: "#7f849c"; wrapMode: Text.Wrap; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: "Favorites: " + shellSettings.favoriteAppIds.length + "  Hidden apps: " + shellSettings.hiddenAppIds.length + "  Weather: " + shellSettings.weatherLocation }
        }
      }
    }


    PopupWindow {
      id: calendarWindow
      visible: root.calendarOpen
      color: "transparent"
      implicitWidth: 430
      implicitHeight: 660
      anchor.window: bar
      anchor.rect.x: Math.max(8, bar.width - implicitWidth - 72)
      anchor.rect.y: bar.height + 6

      Rectangle {
        id: calendarFrame
        anchors.fill: parent
        radius: 6
        color: "#11111b"
        border.color: "#45475a"
        border.width: 1

        ColumnLayout {
          id: calendarColumn
          anchors.fill: parent
          anchors.margins: 10
          spacing: 8

          RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Text { Layout.fillWidth: true; color: "#cdd6f4"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 13; text: "Calendar" }
            Text { color: "#9399b2"; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: "Europe/Lisbon" }
          }

          Text {
            Layout.fillWidth: true
            color: "#bac2de"
            font.family: "FiraCode Nerd Font"
            font.styleName: "Retina"
            font.pixelSize: 22
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDateTime(clock.date, "dd MMMM yyyy")
          }

          Text {
            Layout.fillWidth: true
            color: "#f9e2af"
            font.family: "FiraCode Nerd Font"
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
            text: root.weatherPanelText.length > 0 ? root.weatherPanelText : "Weather --"
          }

          GridLayout {
            Layout.fillWidth: true
            columns: 7
            rowSpacing: 2
            columnSpacing: 4

            Repeater {
              model: root.calendarWeekdays
              Text {
                required property string modelData
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                color: "#9399b2"
                font.family: "FiraCode Nerd Font"
                font.pixelSize: 11
                text: modelData
              }
            }

            Repeater {
              model: root.calendarCellCount()
              Rectangle {
                required property int index
                readonly property int day: root.calendarDayAt(index)
                Layout.fillWidth: true
                implicitHeight: 22
                radius: 4
                color: day > 0 && root.isCalendarToday(day) ? shellSettings.primaryColor : "transparent"

                Text {
                  anchors.centerIn: parent
                  color: parent.day > 0 && root.isCalendarToday(parent.day) ? "#11111b" : (parent.day > 0 ? "#bac2de" : "transparent")
                  font.family: "FiraCode Nerd Font"
                  font.pixelSize: 12
                  text: parent.day > 0 ? parent.day : ""
                }
              }
            }
          }

          ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 160
            clip: true

            Text {
              width: parent.width
              color: "#bac2de"
              font.family: "FiraCode Nerd Font"
              font.pixelSize: 12
              lineHeight: 1.1
              wrapMode: Text.Wrap
              text: root.timePanelText.length > 0 ? root.timePanelText : "Loading time data..."
            }
          }

          Rectangle { Layout.fillWidth: true; height: 1; color: "#313244" }

          RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Text { Layout.fillWidth: true; color: "#cdd6f4"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 13; text: "Ready tasks" }
            ActionButton {
              icon: "󰄬"
              label: "Task"
              minWidth: 72
              tooltip: "Open next task"
              onTriggered: Quickshell.execDetached(["hypr-term", "task", "next"])
            }
          }

          Text {
            Layout.fillWidth: true
            color: "#bac2de"
            font.family: "FiraCode Nerd Font"
            font.pixelSize: 12
            maximumLineCount: 1
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            text: root.todoPanelText.length > 0 ? root.todoPanelText : "No todo data"
          }
        }
      }
    }


    PopupWindow {
      id: workInboxWindow
      visible: root.workInboxOpen
      color: "transparent"
      implicitWidth: 430
      implicitHeight: 300
      anchor.window: bar
      anchor.rect.x: Math.max(8, bar.width - implicitWidth - 10)
      anchor.rect.y: bar.height + 6

      Rectangle {
        anchors.fill: parent
        radius: 6
        color: "#11111b"
        border.color: "#45475a"
        border.width: 1

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: 10
          spacing: 9

          RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Text { Layout.fillWidth: true; color: "#cdd6f4"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 13; text: "Work Inbox" }
            Text { color: "#9399b2"; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: root.workInboxSourceText.length > 0 ? root.workInboxSourceText : "idle" }
            ActionButton { icon: "󰑓"; label: "Refresh"; minWidth: 82; tooltip: "Refresh work inbox counts"; onTriggered: workInboxRefresh.running = true }
          }

          Rectangle { Layout.fillWidth: true; height: 1; color: "#313244" }

          Rectangle {
            Layout.fillWidth: true
            implicitHeight: 52
            radius: 5
            color: "#1e1e2e"
            RowLayout {
              anchors.fill: parent
              anchors.margins: 10
              spacing: 10
              Text { color: root.workInboxSlackAvailable ? shellSettings.primaryColor : "#7f849c"; font.family: "FiraCode Nerd Font"; font.pixelSize: 18; text: "󰒱" }
              ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text { Layout.fillWidth: true; color: "#cdd6f4"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 12; text: "Slack" }
                Text { Layout.fillWidth: true; color: "#9399b2"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: root.workInboxSlackAvailable ? (root.workInboxSlackUnread + " unread, " + root.workInboxSlackMentions + " mentions") : root.workInboxSlackReason }
              }
              ActionButton { icon: "󰍉"; label: "Open"; minWidth: 62; tooltip: "Open Slack"; onTriggered: Quickshell.execDetached(["/home/marcelof/bin/slack-wayland"]) }
            }
          }

          Rectangle {
            Layout.fillWidth: true
            implicitHeight: 52
            radius: 5
            color: "#1e1e2e"
            RowLayout {
              anchors.fill: parent
              anchors.margins: 10
              spacing: 10
              Text { color: root.workInboxGithubAvailable ? shellSettings.primaryColor : "#7f849c"; font.family: "FiraCode Nerd Font"; font.pixelSize: 18; text: "󰊤" }
              ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text { Layout.fillWidth: true; color: "#cdd6f4"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 12; text: "GitHub" }
                Text { Layout.fillWidth: true; color: "#9399b2"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: root.workInboxGithubAvailable ? (root.workInboxGithubReviews + " review requests") : root.workInboxGithubReason }
              }
              ActionButton { icon: "󰍉"; label: "Open"; minWidth: 62; tooltip: "Open GitHub review requests"; onTriggered: Quickshell.execDetached(["/home/marcelof/bin/chrome-wayland", "https://github.com/pulls/review-requested"]) }
            }
          }

          Rectangle {
            Layout.fillWidth: true
            implicitHeight: 52
            radius: 5
            color: "#1e1e2e"
            RowLayout {
              anchors.fill: parent
              anchors.margins: 10
              spacing: 10
              Text { color: root.workInboxLinearAvailable ? shellSettings.primaryColor : "#7f849c"; font.family: "FiraCode Nerd Font"; font.pixelSize: 18; text: "󰘦" }
              ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text { Layout.fillWidth: true; color: "#cdd6f4"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 12; text: "Linear" }
                Text { Layout.fillWidth: true; color: "#9399b2"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: root.workInboxLinearAvailable ? (root.workInboxLinearNotifications + " notifications") : root.workInboxLinearReason }
              }
              ActionButton { icon: "󰍉"; label: "Open"; minWidth: 62; tooltip: "Open Linear inbox"; onTriggered: Quickshell.execDetached(["/home/marcelof/bin/chrome-wayland", "https://linear.app/inbox"]) }
            }
          }

          Text { Layout.fillWidth: true; color: "#7f849c"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: root.workInboxUpdatedText.length > 0 ? ("Updated " + root.workInboxUpdatedText) : "Counts load when opened" }
        }
      }
    }

    PopupWindow {
      id: notificationCenterWindow
      visible: root.notificationCenterOpen
      color: "transparent"
      implicitWidth: 460
      implicitHeight: 420
      anchor.window: bar
      anchor.rect.x: Math.max(8, bar.width - implicitWidth - 10)
      anchor.rect.y: bar.height + 6

      Rectangle {
        anchors.fill: parent
        radius: 6
        color: "#11111b"
        border.color: "#45475a"
        border.width: 1

        ColumnLayout {
          anchors.fill: parent
          anchors.margins: 10
          spacing: 8

          RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Text { Layout.fillWidth: true; color: "#cdd6f4"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 13; text: "Notifications" }
            Text { color: "#9399b2"; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: notificationHistory.count + "" }
            ActionButton {
              visible: root.selectedNotificationIndex >= 0
              icon: "󰅖"
              label: "App"
              minWidth: 58
              tooltip: "Clear selected app notifications"
              onTriggered: root.clearNotificationsForApp(root.notificationAppAt(root.selectedNotificationIndex))
            }
            ActionButton {
              icon: "󰅖"
              label: "All"
              minWidth: 58
              tooltip: "Clear all notifications"
              onTriggered: root.clearNotifications()
            }
            ActionButton { icon: shellSettings.doNotDisturb ? "󰂛" : "󰂚"; label: "DND"; minWidth: 58; active: shellSettings.doNotDisturb; tooltip: shellSettings.doNotDisturb ? "Allow popups" : "Silence popups"; onTriggered: root.toggleDnd() }
          }

          Text {
            Layout.fillWidth: true
            visible: notificationHistory.count === 0
            color: "#7f849c"
            font.family: "FiraCode Nerd Font"
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            text: "No notifications"
          }

          ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: notificationInboxModel

            delegate: Rectangle {
              id: notificationDelegate

              required property string kind
              required property string app
              required property int count
              required property int sourceIndex
              required property string summary
              required property string body
              required property string text
              required property string actionsText
              required property string desktopEntry
              required property string time

              readonly property int notificationIndex: sourceIndex
              readonly property bool isGroup: kind === "group"
              readonly property bool expanded: !isGroup && root.selectedNotificationIndex === notificationIndex
              width: ListView.view.width
              height: isGroup ? 32 : (expanded ? Math.max(104, detailColumn.implicitHeight + 22) : 60)
              radius: isGroup ? 0 : 5
              color: isGroup ? "transparent" : (expanded ? "#242438" : "#1e1e2e")
              border.color: expanded ? shellSettings.primaryColor : "transparent"
              border.width: expanded ? 1 : 0

              Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

              MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                enabled: !notificationDelegate.isGroup
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: { if (expanded) root.focusNotificationApp(notificationIndex); else root.selectedNotificationIndex = notificationIndex }
              }

              RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 2
                anchors.rightMargin: 2
                visible: notificationDelegate.isGroup
                spacing: 8
                Text { Layout.fillWidth: true; color: "#f9e2af"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 12; text: app }
                Text { color: "#9399b2"; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: count + "" }
                ActionButton { icon: "󰅖"; label: "App"; minWidth: 58; tooltip: "Clear app notifications"; onTriggered: root.clearNotificationsForApp(app) }
              }

              ColumnLayout {
                id: detailColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10
                visible: !notificationDelegate.isGroup
                spacing: 5

                RowLayout {
                  Layout.fillWidth: true
                  spacing: 8
                  Text { Layout.fillWidth: true; color: "#cdd6f4"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 12; text: summary.length > 0 ? summary : text }
                  Text { color: "#7f849c"; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: time }
                  Rectangle {
                    width: 22
                    height: 22
                    radius: 4
                    color: dismissMouse.containsMouse ? "#45475a" : "transparent"
                    Text { anchors.centerIn: parent; color: "#bac2de"; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: "󰅖" }
                    MouseArea { id: dismissMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: mouse => { mouse.accepted = true; root.dismissNotification(notificationIndex) } }
                  }
                }

                Text {
                  Layout.fillWidth: true
                  visible: !expanded && body.length > 0
                  color: "#bac2de"
                  elide: Text.ElideRight
                  font.family: "FiraCode Nerd Font"
                  font.pixelSize: 11
                  maximumLineCount: 1
                  wrapMode: Text.NoWrap
                  text: body
                }

                Text {
                  Layout.fillWidth: true
                  visible: expanded && body.length > 0
                  color: "#bac2de"
                  elide: expanded ? Text.ElideNone : Text.ElideRight
                  font.family: "FiraCode Nerd Font"
                  font.pixelSize: 11
                  maximumLineCount: expanded ? 8 : 1
                  wrapMode: expanded ? Text.Wrap : Text.NoWrap
                  text: expanded ? (body.length > 0 ? body : text) : body
                }

                RowLayout {
                  Layout.fillWidth: true
                  visible: expanded && (actionsText.length > 0 || desktopEntry.length > 0 || app.length > 0)
                  spacing: 6

                  ActionButton { icon: "󰍉"; label: "Open"; minWidth: 58; tooltip: "Focus source app"; onTriggered: root.focusNotificationApp(notificationIndex) }

                  Repeater {
                    model: root.notificationActionLabels(notificationIndex)

                    delegate: Rectangle {
                      required property string modelData
                      required property int index

                      Layout.preferredHeight: 24
                      Layout.preferredWidth: Math.max(64, actionLabel.implicitWidth + 18)
                      radius: 4
                      color: actionMouse.containsMouse ? "#45475a" : "#313244"

                      Text {
                        id: actionLabel
                        anchors.centerIn: parent
                        color: "#cdd6f4"
                        elide: Text.ElideRight
                        font.family: "FiraCode Nerd Font"
                        font.pixelSize: 11
                        text: modelData
                      }

                      MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                          mouse.accepted = true
                          root.invokeNotificationAction(notificationDelegate.notificationIndex, index)
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    PopupWindow {
      id: osdWindow
      visible: root.osdOpen
      color: "transparent"
      implicitWidth: 280
      implicitHeight: 68
      anchor.window: bar
      anchor.rect.x: Math.max(8, Math.round((bar.width - implicitWidth) / 2))
      anchor.rect.y: bar.height + 18
      Rectangle {
        anchors.fill: parent
        radius: 6
        color: "#1e1e2e"
        border.color: "#b4befe"
        border.width: 1
        RowLayout {
          anchors.fill: parent
          anchors.margins: 12
          spacing: 10
          Text { color: "#f9e2af"; font.family: "FiraCode Nerd Font"; font.pixelSize: 18; text: root.osdIconText }
          Text { Layout.fillWidth: true; color: "#cdd6f4"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 14; text: root.osdBodyText }
        }
      }
    }


    PopupWindow {
      visible: root.notificationToastOpen && !root.notificationCenterOpen && !shellSettings.doNotDisturb
      color: "transparent"
      implicitWidth: 380
      implicitHeight: toastCard.implicitHeight
      anchor.window: bar
      anchor.rect.x: Math.max(8, bar.width - implicitWidth - 10)
      anchor.rect.y: bar.height + 6

      Rectangle {
        id: toastCard
        width: parent.width
        implicitHeight: Math.max(96, toastColumn.implicitHeight + 20)
        radius: 6
        color: "#1e1e2e"
        border.color: "#b4befe"
        border.width: 1

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            root.notificationToastOpen = false
            root.notificationCenterOpen = true
          }
        }

        ColumnLayout {
          id: toastColumn
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.margins: 10
          spacing: 5

          RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Text { color: "#f9e2af"; font.family: "FiraCode Nerd Font"; font.pixelSize: 14; text: "󰂚" }
            Text { Layout.fillWidth: true; color: "#cdd6f4"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 12; text: root.notificationToastApp }
            Text { color: "#7f849c"; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: "now" }
          }

          Text {
            Layout.fillWidth: true
            color: "#cdd6f4"
            elide: Text.ElideNone
            font.family: "FiraCode Nerd Font"
            font.styleName: "Retina"
            font.pixelSize: 13
            maximumLineCount: 2
            wrapMode: Text.Wrap
            text: root.notificationToastSummary
          }

          Text {
            Layout.fillWidth: true
            visible: root.notificationToastBody.length > 0
            color: "#bac2de"
            elide: Text.ElideNone
            font.family: "FiraCode Nerd Font"
            font.pixelSize: 12
            maximumLineCount: 4
            wrapMode: Text.Wrap
            text: root.notificationToastBody
          }
        }
      }
    }

  Process {
    id: wallpaperCurrent
    command: ["/home/marcelof/bin/wallpaper-wayland", "current"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.wallpaperSource = "file://" + this.text.trim() }
  }

  Process {
    id: wallpaperListRefresh
    command: ["/home/marcelof/bin/wallpaper-wayland", "list"]
    stdout: StdioCollector { onStreamFinished: root.updateWallpaperRows(this.text) }
  }

  Timer {
    id: wallpaperListRefreshLater
    interval: 250
    repeat: false
    onTriggered: wallpaperListRefresh.running = true
  }

  Process {
    id: screenRecordStatus
    command: ["/home/marcelof/bin/screen-record-wayland", "status"]
    stdout: StdioCollector { onStreamFinished: root.recordingStatusText = this.text.trim() }
  }

  Timer {
    id: screenRecordStatusLater
    interval: 500
    repeat: false
    onTriggered: screenRecordStatus.running = true
  }

  Process {
    id: portalStatusRefresh
    command: ["sh", "-c", "printf 'hyprland '; systemctl --user is-active xdg-desktop-portal-hyprland.service 2>/dev/null || printf unavailable; printf ', portal '; systemctl --user is-active xdg-desktop-portal.service 2>/dev/null || printf unavailable"]
    stdout: StdioCollector { onStreamFinished: root.portalStatusText = this.text.trim() }
  }

  Process {
    id: brightnessRefresh
    command: ["sh", "-c", "brightnessctl -m 2>/dev/null | awk -F, '{print $4}' || printf -- --"]
    stdout: StdioCollector {
      onStreamFinished: {
        root.brightnessText = this.text.trim()
        root.brightnessValue = Number(root.brightnessText.replace("%", "")) || 0
      }
    }
  }

  Timer {
    id: brightnessRefreshLater
    interval: 250
    repeat: false
    onTriggered: brightnessRefresh.running = true
  }

  Process {
    id: kbdBrightnessRefresh
    command: ["/home/marcelof/bin/kbd-brightness", "status"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.kbdBrightnessText = this.text.trim() }
  }

  Timer {
    id: kbdBrightnessRefreshLater
    interval: 250
    repeat: false
    onTriggered: kbdBrightnessRefresh.running = true
  }

  Process {
    id: networkStatusRefresh
    command: ["/home/marcelof/bin/network-status", "details"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.networkStatusText = this.text.trim() }
  }

  Timer {
    id: networkStatusRefreshLater
    interval: 500
    repeat: false
    onTriggered: networkStatusRefresh.running = true
  }

  Process {
    id: powerStatusRefresh
    command: ["/home/marcelof/bin/power-status", "status"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.powerStatusText = this.text.trim() }
  }

  Process {
    id: fanStatusRefresh
    command: ["/home/marcelof/bin/fan-status"]
    stdout: StdioCollector { onStreamFinished: root.fanStatusText = this.text.trim().length > 0 ? this.text.trim() : "Fan --" }
  }

  Process {
    id: inhibitStatusRefresh
    command: ["/home/marcelof/bin/desktop-inhibit", "status"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.inhibitStatusText = this.text.trim() }
  }

  Timer {
    id: powerStatusRefreshLater
    interval: 500
    repeat: false
    onTriggered: powerStatusRefresh.running = true
  }

  Timer {
    id: inhibitStatusRefreshLater
    interval: 500
    repeat: false
    onTriggered: inhibitStatusRefresh.running = true
  }

  Process {
    id: privacyStatusRefresh
    command: ["/home/marcelof/bin/desktop-privacy-status", "status"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.privacyStatusText = this.text.trim() }
  }

  Process {
    id: externalBrightnessRefresh
    command: ["/home/marcelof/bin/external-brightness", "status"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: {
        root.externalBrightnessText = this.text.trim()
        const match = root.externalBrightnessText.match(/([0-9]+)%/)
        root.externalBrightnessValue = match ? Number(match[1]) : 0
      }
    }
  }

  Timer {
    id: externalBrightnessRefreshLater
    interval: 600
    repeat: false
    onTriggered: externalBrightnessRefresh.running = true
  }

  Process {
    id: mediaNowRefresh
    command: ["/home/marcelof/bin/media-now-playing"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.mediaNowText = this.text.trim() }
  }

  Timer {
    id: osdTimer
    interval: 1300
    repeat: false
    onTriggered: root.osdOpen = false
  }

  Timer {
    id: osdRefreshLater
    interval: 180
    repeat: false
    onTriggered: {
      if (root.osdPendingKind === "brightness")
        root.showOsd("󰃠", "Brightness " + root.brightnessText)
      else if (root.osdPendingKind === "kbd")
        root.showOsd("󰌌", root.kbdBrightnessText.length > 0 ? root.kbdBrightnessText : "Keyboard brightness")
      root.osdPendingKind = ""
    }
  }

  ListModel { id: launcherModel }

  Process {
    id: launcherMruRefresh
    command: ["sh", "-c", "cat \"${XDG_CACHE_HOME:-$HOME/.cache}/quickshell/marcelof/launcher-mru.txt\" 2>/dev/null || true"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.updateLauncherMru(this.text) }
  }
  ListModel { id: clipboardModel }
  ListModel { id: passModel }
  ListModel { id: keybindingModel }

  Process {
    id: clipboardRefresh
    command: ["sh", "-c", "cliphist list 2>/dev/null"]
    stdout: StdioCollector { onStreamFinished: root.updateClipboardEntries(this.text) }
  }

  Process {
    id: passEntriesRefresh
    command: ["sh", "-c", root.shellQuote(root.passBackend) + " ls --flat 2>/dev/null"]
    stdout: StdioCollector { onStreamFinished: root.updatePassEntries(this.text) }
  }

  Process {
    id: keybindingsRefresh
    command: ["/home/marcelof/bin/hypr-keys"]
    running: true
    stdout: StdioCollector { onStreamFinished: root.updateKeybindingRows(this.text) }
  }

  Connections {
    target: DesktopEntries.applications
    function onValuesChanged() { if (launcher.visible) root.rebuildLauncher() }
  }

  FloatingWindow {
    id: launcher
    title: "quickshell-launcher"
    screen: root.laptopScreen
    visible: false
    implicitWidth: 720
    implicitHeight: shellSettings.denseUi ? 480 : 520
    color: "transparent"

    HyprlandFocusGrab {
      active: launcher.visible
      windows: [launcher]
      onCleared: root.hideLauncher()
    }

    IpcHandler {
      target: "launcher"

      function toggle() { root.toggleLauncher() }
      function open() {
        launcher.visible = true
        search.text = ""
        root.rebuildLauncher()
        search.forceActiveFocus()
      }
      function show() { open() }
      function hide() { root.hideLauncher() }
      function visibleById(entryId: string): string {
        const previousSearch = search.text
        search.text = ""
        root.rebuildLauncher()
        let visible = false
        for (let i = 0; i < launcherModel.count; i++) {
          if (String(launcherModel.get(i).id || "") === String(entryId || "")) {
            visible = true
            break
          }
        }
        search.text = previousSearch
        if (launcher.visible)
          root.rebuildLauncher()
        return visible ? "visible" : "hidden"
      }
      function hiddenRoundTrip(entryId: string): string {
        const previousSmokeHiddenId = root.launcherSmokeHiddenId
        let before = "unknown"
        let hidden = "unknown"
        let after = "unknown"
        try {
          before = visibleById(entryId)
          root.launcherSmokeHiddenId = entryId
          hidden = visibleById(entryId)
        } finally {
          root.launcherSmokeHiddenId = previousSmokeHiddenId
          after = visibleById(entryId)
        }
        return before + "|" + hidden + "|" + after
      }
    }


    Rectangle {
      anchors.fill: parent
      radius: 6
      color: "#11111b"
      border.color: "#45475a"
      border.width: 1

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Rectangle {
          Layout.fillWidth: true
          height: 42
          color: "#1e1e2e"
          border.color: search.activeFocus ? "#b4befe" : "#313244"
          border.width: 1
          radius: 6

          TextInput {
            id: search
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            verticalAlignment: TextInput.AlignVCenter
            color: "#cdd6f4"
            selectionColor: "#45475a"
            selectedTextColor: "#cdd6f4"
            font.family: "FiraCode Nerd Font"
              font.styleName: "Retina"
            font.pixelSize: 16
            clip: true

            onTextChanged: root.rebuildLauncher()
            Keys.onEscapePressed: launcher.visible = false
            Keys.onDownPressed: { if (launcherModel.count > 0) appList.currentIndex = (appList.currentIndex + 1) % launcherModel.count }
            Keys.onUpPressed: { if (launcherModel.count > 0) appList.currentIndex = (appList.currentIndex - 1 + launcherModel.count) % launcherModel.count }
            Keys.onReturnPressed: root.launchCurrentApp()
            Keys.onEnterPressed: root.launchCurrentApp()
            Keys.onPressed: event => {
              if ((event.modifiers & Qt.AltModifier) && event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                root.launchAppAtIndex(event.key - Qt.Key_1)
                event.accepted = true
              }
            }
          }
        }

        ListView {
          id: appList
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          spacing: 4
          model: launcherModel
          currentIndex: -1

          delegate: Rectangle {
            required property var modelData
            required property int index
            width: appList.width
            height: 48
            color: ListView.isCurrentItem ? "#313244" : "transparent"
            radius: 4

            Text {
              anchors.fill: parent
              anchors.leftMargin: 44
              anchors.rightMargin: 82
              verticalAlignment: Text.AlignVCenter
              color: "#cdd6f4"
              elide: Text.ElideRight
              font.family: "FiraCode Nerd Font"
              font.styleName: "Retina"
              font.pixelSize: 14
              text: modelData.name + (modelData.subtext.length > 0 ? "  " + modelData.subtext : "")
            }

            Image {
              anchors.left: parent.left
              anchors.leftMargin: 10
              anchors.verticalCenter: parent.verticalCenter
              width: 22
              height: 22
              source: Quickshell.iconPath(modelData.icon, true)
            }

            Row {
              anchors.right: parent.right
              anchors.rightMargin: 8
              anchors.verticalCenter: parent.verticalCenter
              spacing: 6
              visible: modelData.id.length > 0
              Text { color: modelData.favorite ? "#f9e2af" : "#7f849c"; font.family: "FiraCode Nerd Font"; font.pixelSize: 13; text: modelData.favorite ? "" : ""; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: mouse => { mouse.accepted = true; root.toggleLauncherFavoriteById(modelData.id) } } }
              Text { color: "#7f849c"; font.family: "FiraCode Nerd Font"; font.pixelSize: 13; text: "󰈉"; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: mouse => { mouse.accepted = true; root.hideLauncherById(modelData.id) } } }
            }

            MouseArea {
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
              hoverEnabled: true
              onEntered: appList.currentIndex = index
              onClicked: mouse => {
                appList.currentIndex = index
                if (mouse.button === Qt.RightButton && modelData.id.length > 0)
                  root.toggleLauncherFavoriteById(modelData.id)
                else if (mouse.button === Qt.MiddleButton && modelData.id.length > 0)
                  root.hideLauncherById(modelData.id)
                else
                  root.launchCurrentApp()
              }
            }
          }
        }
      }
    }
  }
  FloatingWindow {
    id: clipboardPicker
    title: "quickshell-clipboard"
    screen: root.laptopScreen
    visible: root.clipboardOpen
    implicitWidth: 720
    implicitHeight: shellSettings.denseUi ? 480 : 500
    color: "transparent"

    HyprlandFocusGrab {
      active: clipboardPicker.visible
      windows: [clipboardPicker]
      onCleared: root.clipboardOpen = false
    }

    Rectangle {
      anchors.fill: parent
      color: "#11111b"
      border.color: "#45475a"
      border.width: 1
      radius: 6

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        RowLayout {
          Layout.fillWidth: true
          Text { Layout.fillWidth: true; color: "#cdd6f4"; font.family: "FiraCode Nerd Font"; font.pixelSize: 15; text: "Clipboard" }
          Text { color: "#9399b2"; font.family: "FiraCode Nerd Font"; font.pixelSize: 12; text: clipboardModel.count + " entries" }
        }

        Rectangle {
          Layout.fillWidth: true
          height: 42
          color: "#1e1e2e"
          border.color: clipSearch.activeFocus ? "#b4befe" : "#313244"
          border.width: 1
          radius: 6

          Text {
            anchors.fill: parent
            anchors.leftMargin: 12
            verticalAlignment: Text.AlignVCenter
            color: "#6c7086"
            font.family: "FiraCode Nerd Font"
            font.pixelSize: 13
            text: "Search clipboard"
            visible: clipSearch.text.length === 0
          }

          TextInput {
            id: clipSearch
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            verticalAlignment: TextInput.AlignVCenter
            color: "#cdd6f4"
            selectionColor: "#45475a"
            selectedTextColor: "#cdd6f4"
            font.family: "FiraCode Nerd Font"
            font.pixelSize: 16
            clip: true
            onTextChanged: root.rebuildClipboardModel()
            Keys.onEscapePressed: root.clipboardOpen = false
            Keys.onDownPressed: { if (clipboardModel.count > 0) clipList.currentIndex = (clipList.currentIndex + 1) % clipboardModel.count }
            Keys.onUpPressed: { if (clipboardModel.count > 0) clipList.currentIndex = (clipList.currentIndex - 1 + clipboardModel.count) % clipboardModel.count }
            Keys.onReturnPressed: root.pasteClipboardEntry()
            Keys.onEnterPressed: root.pasteClipboardEntry()
          }
        }

        ListView {
          id: clipList
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: clipboardModel.count > 0
          clip: true
          spacing: 4
          model: clipboardModel
          currentIndex: -1

          delegate: Rectangle {
            id: clipboardRow
            required property string text
            required property string preview
            required property int index
            width: clipList.width
            height: 40
            radius: 4
            color: ListView.isCurrentItem ? "#313244" : "transparent"
            Text { anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 10; verticalAlignment: Text.AlignVCenter; color: "#cdd6f4"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.pixelSize: 13; text: clipboardRow.preview }
            MouseArea { anchors.fill: parent; hoverEnabled: true; onEntered: clipList.currentIndex = index; onClicked: { clipList.currentIndex = index; root.pasteClipboardEntry() } }
          }
        }

        Rectangle {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: clipboardModel.count === 0
          radius: 6
          color: "#1e1e2e"
          border.color: "#313244"
          border.width: 1

          Text {
            anchors.centerIn: parent
            width: parent.width - 28
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            color: "#7f849c"
            font.family: "FiraCode Nerd Font"
            font.pixelSize: 12
            text: clipboardRefresh.running ? "Loading clipboard..." : (root.clipboardEntries.length > 0 ? "No clipboard matches" : "Clipboard history is empty")
          }
        }
      }
    }
  }

  FloatingWindow {
    id: passMenu
    title: "quickshell-passmenu"
    screen: root.laptopScreen
    visible: root.passMenuOpen
    implicitWidth: 720
    implicitHeight: shellSettings.denseUi ? 480 : 520
    color: "transparent"

    HyprlandFocusGrab {
      active: passMenu.visible
      windows: [passMenu]
      onCleared: root.passMenuOpen = false
    }

    IpcHandler {
      target: "passmenu"
      function open(mode: string, userKey: string, backend: string) { root.openPassmenu(mode, userKey, backend) }
      function hide() { root.passMenuOpen = false }
    }

    Rectangle {
      anchors.fill: parent
      color: "#11111b"
      border.color: "#45475a"
      border.width: 1
      radius: 6

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        RowLayout {
          Layout.fillWidth: true
          Text { Layout.fillWidth: true; color: "#cdd6f4"; font.family: "FiraCode Nerd Font"; font.pixelSize: 15; text: "Passwords" }
          Text { color: "#9399b2"; font.family: "FiraCode Nerd Font"; font.pixelSize: 12; text: root.passModeLabel() }
        }

        Rectangle {
          Layout.fillWidth: true
          height: 42
          color: "#1e1e2e"
          border.color: passSearch.activeFocus ? "#b4befe" : "#313244"
          border.width: 1
          radius: 6

          Text {
            anchors.fill: parent
            anchors.leftMargin: 12
            verticalAlignment: Text.AlignVCenter
            color: "#6c7086"
            font.family: "FiraCode Nerd Font"
            font.pixelSize: 13
            text: "Search passwords"
            visible: passSearch.text.length === 0
          }

          TextInput {
            id: passSearch
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            verticalAlignment: TextInput.AlignVCenter
            color: "#cdd6f4"
            selectionColor: "#45475a"
            selectedTextColor: "#cdd6f4"
            font.family: "FiraCode Nerd Font"
            font.pixelSize: 16
            clip: true
            onTextChanged: root.rebuildPassModel()
            Keys.onEscapePressed: root.passMenuOpen = false
            Keys.onDownPressed: { if (passModel.count > 0) passList.currentIndex = (passList.currentIndex + 1) % passModel.count }
            Keys.onUpPressed: { if (passModel.count > 0) passList.currentIndex = (passList.currentIndex - 1 + passModel.count) % passModel.count }
            Keys.onReturnPressed: root.runPassEntry()
            Keys.onEnterPressed: root.runPassEntry()
          }
        }

        ListView {
          id: passList
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: passModel.count > 0
          clip: true
          spacing: 4
          model: passModel
          currentIndex: -1

          delegate: Rectangle {
            id: passRow
            required property string path
            required property int index
            width: passList.width
            height: 40
            radius: 4
            color: ListView.isCurrentItem ? "#313244" : "transparent"
            Text { anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 10; verticalAlignment: Text.AlignVCenter; color: "#cdd6f4"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.pixelSize: 13; text: passRow.path }
            MouseArea { anchors.fill: parent; hoverEnabled: true; onEntered: passList.currentIndex = index; onClicked: { passList.currentIndex = index; root.runPassEntry() } }
          }
        }

        Rectangle {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: passModel.count === 0
          radius: 6
          color: "#1e1e2e"
          border.color: "#313244"
          border.width: 1

          Text {
            anchors.centerIn: parent
            width: parent.width - 28
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            color: "#7f849c"
            font.family: "FiraCode Nerd Font"
            font.pixelSize: 12
            text: passEntriesRefresh.running ? "Loading passwords..." : "No password entries"
          }
        }
      }
    }
  }



  PopupWindow {
    id: keybindingsPanel
    visible: root.keybindingsOpen
    implicitWidth: 560
    implicitHeight: 500
    color: "transparent"
    anchor.window: bar
    anchor.rect.x: Math.max(8, bar.width - implicitWidth - 10)
    anchor.rect.y: bar.height + 6

    Rectangle {
      anchors.fill: parent
      color: "#11111b"
      border.color: "#45475a"
      border.width: 1
      radius: 6

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8
        Text { Layout.fillWidth: true; color: "#cdd6f4"; font.family: "FiraCode Nerd Font"; font.pixelSize: 15; text: "Keybindings" }
        ScrollView {
          Layout.fillWidth: true
          Layout.fillHeight: true
          clip: true
          ColumnLayout {
            width: parent.width
            spacing: 5
            Repeater {
              model: keybindingModel
              RowLayout {
                required property string shortcut
                required property string action
                Layout.fillWidth: true
                spacing: 10
                Text { width: 170; color: "#b4befe"; font.family: "FiraCode Nerd Font"; font.pixelSize: 12; text: shortcut }
                Text { Layout.fillWidth: true; color: "#cdd6f4"; font.family: "FiraCode Nerd Font"; font.pixelSize: 12; text: action }
              }
            }
          }
        }
      }
    }
  }

  FloatingWindow {
    id: webSearch
    title: "quickshell-websearch"
    screen: root.laptopScreen
    visible: root.webSearchOpen
    implicitWidth: 640
    implicitHeight: 220
    color: "transparent"

    HyprlandFocusGrab {
      active: webSearch.visible
      windows: [webSearch]
      onCleared: root.webSearchOpen = false
    }

    Rectangle {
      anchors.fill: parent
      color: "#11111b"
      border.color: "#45475a"
      border.width: 1
      radius: 6

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        RowLayout {
          Layout.fillWidth: true
          spacing: 8
          Repeater {
            model: root.webSearchSites
            Rectangle {
              required property var modelData
              width: Math.max(66, siteLabel.implicitWidth + 22)
              height: 28
              radius: 4
              color: root.webSearchSite === modelData.key ? "#b4befe" : (siteMouse.containsMouse ? "#313244" : "#1e1e2e")
              Text { id: siteLabel; anchors.centerIn: parent; color: root.webSearchSite === modelData.key ? "#11111b" : "#cdd6f4"; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: modelData.label }
              MouseArea { id: siteMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.webSearchSite = modelData.key; webSearchInput.forceActiveFocus() } }
            }
          }
        }

        Rectangle {
          Layout.fillWidth: true
          height: 46
          color: "#1e1e2e"
          border.color: webSearchInput.activeFocus ? "#b4befe" : "#313244"
          border.width: 1
          radius: 6

          TextInput {
            id: webSearchInput
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            verticalAlignment: TextInput.AlignVCenter
            color: "#cdd6f4"
            selectionColor: "#45475a"
            selectedTextColor: "#cdd6f4"
            font.family: "FiraCode Nerd Font"
            font.pixelSize: 16
            clip: true
            Keys.onEscapePressed: root.webSearchOpen = false
            Keys.onReturnPressed: root.runWebSearch()
            Keys.onEnterPressed: root.runWebSearch()
          }
        }
      }
    }
  }



  PopupWindow {
    id: networkPanel
    visible: false
    implicitWidth: 460
    implicitHeight: 420
    color: "transparent"
    anchor.window: bar
    anchor.rect.x: Math.max(8, bar.width - implicitWidth - 10)
    anchor.rect.y: bar.height + 6

    IpcHandler {
      target: "network"
      function toggle() { root.toggleNetworkPanel() }
      function hide() { networkPanel.visible = false }
    }

    Rectangle {
      anchors.fill: parent
      radius: 6
      color: "#11111b"
      border.color: "#45475a"
      border.width: 1

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        RowLayout {
          Layout.fillWidth: true
          spacing: 8
          Text { Layout.fillWidth: true; color: "#cdd6f4"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 15; text: "Network" }
          ActionButton { icon: "󰑓"; label: ""; minWidth: 34; tooltip: "Refresh"; onTriggered: { networkStatusRefresh.running = true; networkRefresh.running = true } }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 10
          Text { color: "#bac2de"; font.family: "FiraCode Nerd Font"; font.styleName: "Retina"; font.pixelSize: 12; text: root.networkStatusText.indexOf("Wi-Fi") === 0 ? "󰖩" : "󰈀" }
          Text { Layout.fillWidth: true; color: "#bac2de"; elide: Text.ElideRight; font.family: "FiraCode Nerd Font"; font.pixelSize: 12; text: root.networkStatusText.length > 0 ? root.networkStatusText : "Network unavailable" }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 8
          ActionButton { Layout.fillWidth: true; icon: "󰖩"; label: "Wi-Fi"; tooltip: "Toggle Wi-Fi"; onTriggered: root.runNetwork("wifi-toggle") }
          ActionButton { Layout.fillWidth: true; icon: "󰍜"; label: "Settings"; tooltip: "Open network settings"; onTriggered: Quickshell.execDetached(["hypr-clean-env", "nm-connection-editor"]) }
        }

        Rectangle {
          Layout.fillWidth: true
          Layout.fillHeight: true
          radius: 6
          color: "#1e1e2e"
          border.color: "#313244"
          border.width: 1

          Text {
            id: networkText
            anchors.fill: parent
            anchors.margins: 10
            color: "#bac2de"
            elide: Text.ElideRight
            font.family: "FiraCode Nerd Font"
            font.styleName: "Retina"
            font.pixelSize: 12
            maximumLineCount: 8
            wrapMode: Text.Wrap
            text: ""
          }
        }
      }
    }

    Process {
      id: networkRefresh
      command: ["sh", "-c", "nmcli -t -f DEVICE,TYPE,STATE,CONNECTION dev status 2>/dev/null | sed 's/:/  /g' || ip -brief addr"]
      stdout: StdioCollector {
        onStreamFinished: networkText.text = this.text.trim()
      }
    }
  }

  PopupWindow {
    id: exitDialog
    visible: false
    implicitWidth: 460
    implicitHeight: 420
    color: "transparent"
    anchor.window: bar
    anchor.rect.x: Math.max(8, bar.width - implicitWidth - 10)
    anchor.rect.y: bar.height + 6

    IpcHandler {
      target: "session"

      function confirmExit() { root.togglePowerMenu() }
      function power() { root.togglePowerMenu() }
      function confirmReboot() { root.openSessionConfirm("Reboot", "󰜉", ["systemctl", "reboot"]) }
      function hide() { root.hidePowerMenu() }
    }

    Rectangle {
      anchors.fill: parent
      radius: 6
      color: "#11111b"
      border.color: "#45475a"
      border.width: 1

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        Text {
          Layout.fillWidth: true
          color: "#cdd6f4"
          font.family: "FiraCode Nerd Font"
              font.styleName: "Retina"
          font.pixelSize: 15
          text: "Session"
        }

        Text { Layout.fillWidth: true; color: "#7f849c"; font.family: "FiraCode Nerd Font"; font.pixelSize: 11; text: "Choose a session action" }

        RowLayout {
          Layout.fillWidth: true
          spacing: 8
          ActionButton { Layout.fillWidth: true; icon: "󰅖"; label: "Cancel"; tooltip: "Close this menu"; onTriggered: root.hidePowerMenu() }
          ActionButton { Layout.fillWidth: true; icon: "󰌾"; label: "Lock"; tooltip: "Lock session"; onTriggered: root.lockSession() }
          ActionButton { Layout.fillWidth: true; icon: "󰒲"; label: "Suspend"; tooltip: "Suspend system"; onTriggered: root.suspendSession() }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 8
          ActionButton { Layout.fillWidth: true; icon: "󰒓"; label: "Hibernate"; tooltip: "Hibernate system"; onTriggered: root.setSessionConfirm("Hibernate", "󰒓", ["systemctl", "hibernate"]) }
          ActionButton { Layout.fillWidth: true; icon: "󰜉"; label: "Reboot"; tooltip: "Reboot system"; onTriggered: root.setSessionConfirm("Reboot", "󰜉", ["systemctl", "reboot"]) }
          ActionButton { Layout.fillWidth: true; icon: "⏻"; label: "Shutdown"; tooltip: "Power off system"; onTriggered: root.setSessionConfirm("Shutdown", "⏻", ["systemctl", "poweroff"]) }
        }

        Text { Layout.fillWidth: true; visible: root.sessionConfirmLabel.length > 0; color: "#f9e2af"; font.family: "FiraCode Nerd Font"; font.pixelSize: 12; text: "Confirm " + root.sessionConfirmLabel + "?" }

        RowLayout {
          Layout.fillWidth: true
          visible: root.sessionConfirmLabel.length > 0
          spacing: 8
          ActionButton { Layout.fillWidth: true; icon: "󰅖"; label: "Cancel"; tooltip: "Cancel pending session action"; onTriggered: root.clearSessionConfirm() }
          ActionButton { Layout.fillWidth: true; active: true; icon: root.sessionConfirmIcon; label: "Confirm"; tooltip: "Run " + root.sessionConfirmLabel; onTriggered: root.runSessionConfirm() }
        }

        ActionButton { Layout.fillWidth: true; icon: "󰍃"; label: "Exit Hyprland"; tooltip: "Exit the current Hyprland session"; onTriggered: root.setSessionConfirm("Exit Hyprland", "󰍃", ["hyprctl", "dispatch", "exit"]) }
      }
    }
  }
}
