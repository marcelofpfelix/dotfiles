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
  function menuSize(id) { return shellConfig.menuSize(id, shellSettings.denseUi) }
  function menuWidthFor(id) { return root.menuSize(id).width }
  function menuHeightFor(id) { return root.menuSize(id).height }
  function menuCompactHeightFor(id) { return root.menuSize(id).compactHeight }

  function toggleLauncher() {
    launcher.panelOpen = !launcher.panelOpen
    if (launcher.panelOpen) {
      launcher.searchText = ""
      menuDataService.refreshLauncherMru()
      root.rebuildLauncher()
      launcher.focusSearch()
    }
  }

  function hideLauncher() {
    launcher.panelOpen = false
  }

  function shellQuote(value) {
    return shellConfig.shellQuote(value)
  }

  function webSearchSiteUrl(site) {
    for (let i = 0; i < root.webSearchSites.length; i++) {
      if (root.webSearchSites[i].key === site)
        return root.webSearchSites[i].url
    }
    return root.webSearchSites[0].url
  }

  function openUrlCommand(url) {
    return shellConfig.openUrl(url)
  }

  function openWebSearch(site) {
    webSearchPanel.openSearch(site)
  }

  function toggleWebSearch(site) {
    webSearchPanel.toggleSearch(site)
  }

  function showVolumeOsd() { overlays.showVolume(root.defaultSinkAudio()) }

  function showBrightnessOsd() {
    systemStatusService.refreshBrightness()
    overlays.showBrightnessSoon()
  }

  function showKbdOsd() {
    systemStatusService.refreshKbdBrightness()
    overlays.showKbdSoon()
  }

  function showMicOsd() {
    systemStatusService.refreshPrivacy()
    overlays.show("󰍬", "Microphone toggled")
  }

  function runWebSearch() {
    webSearchPanel.runSearch()
  }

  function toggleKeybindings() {
    const next = !root.keybindingsOpen
    root.closeTransientPanels()
    root.keybindingsOpen = next
    if (next)
      menuDataService.refreshKeybindings()
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
    const query = clipboardPanel.searchText
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
    if (clipboardPanel) {
      clipboardPanel.currentIndex = clipboardModel.count > 0 ? 0 : -1
      Qt.callLater(() => clipboardPanel.positionCurrent())
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
    const query = passMenuPanel.searchText
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
    if (passMenuPanel) {
      passMenuPanel.currentIndex = passModel.count > 0 ? 0 : -1
      Qt.callLater(() => passMenuPanel.positionCurrent())
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
    clipboardPanel.searchText = ""
    root.clipboardEntries = []
    clipboardModel.clear()
    menuDataService.refreshClipboard()
    clipboardPanel.focusSearch()
  }

  function passModeLabel() {
    if (root.passMode === "type-pass") return "Type password"
    if (root.passMode === "type-user") return "Type username"
    if (root.passMode === "type-name") return "Type entry name"
    return "Copy password"
  }

  function openPassmenu(mode, userKey, backend) {
    root.closeTransientPanels()
    root.passMode = String(mode || shellConfig.actions.copy)
    root.passUserKey = String(userKey || "username")
    root.passBackend = String(backend || "gopass")
    root.passMenuOpen = true
    passMenuPanel.searchText = ""
    root.passEntries = []
    passModel.clear()
    menuDataService.refreshPassEntries()
    passMenuPanel.focusSearch()
  }

  function runPassEntry() {
    if (!root.passMenuOpen || passMenuPanel.currentIndex < 0 || passMenuPanel.currentIndex >= passModel.count)
      return
    const entry = passModel.get(passMenuPanel.currentIndex).path
    root.passMenuOpen = false
    Quickshell.execDetached(shellConfig.passAction(root.passMode, root.passUserKey, root.passBackend, entry))
  }

  function toggleClipboard() {
    if (root.clipboardOpen) {
      root.clipboardOpen = false
      return
    }
    root.openClipboard()
  }

  function pasteClipboardEntry() {
    if (!root.clipboardOpen || clipboardPanel.currentIndex < 0 || clipboardPanel.currentIndex >= clipboardModel.count)
      return
    const entry = clipboardModel.get(clipboardPanel.currentIndex).text
    root.clipboardOpen = false
    Quickshell.execDetached(shellConfig.cliphistDecode(entry))
  }

  property var clipboardEntries: []
  property var passEntries: []
  property bool clipboardOpen: false
  property bool passMenuOpen: false
  property string passMode: shellConfig.actions.copy
  property string passUserKey: "username"
  property string passBackend: "gopass"
  property bool keybindingsOpen: false
  property bool networkPanelOpen: false
  property bool powerMenuOpen: false
  property bool webSearchOpen: false
  property string webSearchSite: shellConfig.defaultWebSearchSite
  readonly property var webSearchSites: shellConfig.webSearchSites

  function updateLauncherMru(output) { launcherService.updateMru(output) }
  function rebuildLauncher() { launcherService.rebuild() }
  function launchCurrentApp() { launcherService.launchCurrent() }
  function launchAppAtIndex(index) { launcherService.launchAtIndex(index) }
  function toggleLauncherFavoriteById(id) { launcherService.toggleFavoriteById(id) }
  function hideLauncherById(id) { launcherService.hideById(id) }

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
  property bool personalDashboardOpen: false
  property bool settingsOpen: false
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
  property string inhibitStatusText: "inactive"
  property string lisbonClockText: "--"
  property string timePanelText: ""
  property string agendaPanelText: ""
  property string pomodoroModeText: shellConfig.states.idle
  property string pomodoroLabelText: ""
  property int pomodoroRemainingSeconds: 0
  property bool pomodoroRunning: false
  property bool pomodoroPaused: false
  property bool pomodoroComplete: false
  property string pomodoroTimewText: "timew idle"
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
  property string personalDashboardSurface: "personal.today"
  property string personalDashboardText: ""
  readonly property var personalDashboardSurfaces: shellConfig.personalDashboardSurfaces
  property string todoPanelText: ""
  property string sinkDescription: "Default output"
  property string audioIconText: "󰐊"
  property string audioDisplayText: ""
  property string audioStatusText: ""
  property string recordingStatusText: ""
  property string portalStatusText: ""
  property string wallpaperSource: shellConfig.defaultWallpaperUrl
  property string tooltipText: ""
  readonly property string stateDir: shellConfig.stateDir
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

  function trayItemStatus(item) {
    const parts = []
    parts.push(root.isTrayHidden(item) ? "hidden" : (root.isTrayPinned(item) ? "pinned" : "drawer"))
    if (item && item.hasMenu)
      parts.push("menu")
    if (item && item.onlyMenu)
      parts.push("menu only")
    return parts.join(shellConfig.textSeparator)
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
    return shellConfig.isNetworkTrayText(text)
  }

  function trayItemSearchText(item) {
    return ((item.id || "") + " " + (item.title || "") + " " + (item.tooltipTitle || "") + " " + (item.tooltipDescription || "")).toLowerCase()
  }

  function trayDirectCommand(item) {
    const text = root.trayItemSearchText(item)

    if (shellConfig.isNetworkTrayText(text))
      return shellConfig.networkEditor()
    if (text.indexOf("software_update") !== -1 || text.indexOf("software update") !== -1 || text.indexOf("update-notifier") !== -1)
      return shellConfig.cleanEnv("update-manager")
    if (text.indexOf("livepatch") !== -1)
      return shellConfig.cleanEnv("software-properties-gtk")
    if (text.indexOf("slack") !== -1)
      return shellConfig.cleanEnv("slack")

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
    root.personalDashboardOpen = false
    root.settingsOpen = false
    root.notificationCenterOpen = false
    root.keybindingsOpen = false
    root.webSearchOpen = false
    root.networkPanelOpen = false
    root.clearSessionConfirm()
    root.powerMenuOpen = false
  }

  function togglePowerMenu() {
    const next = !root.powerMenuOpen
    root.closeTransientPanels()
    root.powerMenuOpen = next
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
    if (next)
      systemStatusService.refreshControls()
  }

  function toggleNetworkPanel() {
    const next = !root.networkPanelOpen
    root.closeTransientPanels()
    root.networkPanelOpen = next
    if (next)
      systemStatusService.refreshNetwork()
  }

  function toggleMediaPanel() {
    const next = !root.mediaPanelOpen
    root.closeTransientPanels()
    root.mediaPanelOpen = next
    if (next)
      root.refreshAudioState()
  }

  function refreshScreenState() {
    screenService.refresh()
    systemStatusService.refreshPrivacy()
  }

  function toggleScreenPanel() {
    const next = !root.screenPanelOpen
    root.closeTransientPanels()
    root.screenPanelOpen = next
    if (next)
      root.refreshScreenState()
  }

  function runScreenRecord(action) {
    screenService.runRecord(action)
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
    wallpaperService.refreshAll()
  }

  function toggleWallpaperPanel() {
    const next = !root.wallpaperPanelOpen
    root.closeTransientPanels()
    root.wallpaperPanelOpen = next
    if (next)
      root.refreshWallpapers()
  }

  function setWallpaper(path) {
    root.wallpaperSource = shellConfig.fileUrl(path)
    Quickshell.execDetached(shellConfig.wallpaper("set", path))
    wallpaperService.refreshListSoon()
  }

  function toggleCalendar() {
    const next = !root.calendarOpen
    root.closeTransientPanels()
    root.calendarOpen = next
    if (next) {
      calendarService.refreshAll()
    }
  }

  function toggleWorkInbox() {
    const next = !root.workInboxOpen
    root.closeTransientPanels()
    root.workInboxOpen = next
    if (next)
      dashboardService.refreshWorkInbox()
  }

  function togglePersonalDashboard() {
    const next = !root.personalDashboardOpen
    root.closeTransientPanels()
    root.personalDashboardOpen = next
    if (next)
      dashboardService.refreshPersonalDashboard()
  }

  function setPersonalDashboardSurface(surface) {
    root.personalDashboardSurface = surface
    dashboardService.refreshPersonalDashboard()
  }

  function runPersonalDashboardAction(actionName) {
    dashboardService.runPersonalDashboardAction(actionName)
  }

  function personalDashboardRichText() {
    const text = String(root.personalDashboardText || "").trim()
    return text.length > 0 ? text.replace(/\n/g, "<br/>") : "No board data"
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
        overlays.restartToastTimer()
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
    Quickshell.execDetached(shellConfig.notificationFocus(row.desktopEntry, row.app))
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

  function privacyMicActive() {
    return root.privacyStatusText.indexOf("mic active") >= 0
  }

  function privacyCameraActive() {
    return root.privacyStatusText.indexOf("camera active") >= 0
  }

  function privacyShareActive() {
    return root.privacyStatusText.indexOf("share active") >= 0 || root.privacyStatusText.indexOf("record recording") >= 0
  }

  function privacyCaptureActive() {
    return root.privacyMicActive() || root.privacyCameraActive() || root.privacyShareActive()
  }

  function privacyBarText() {
    const parts = []
    if (root.privacyMicActive())
      parts.push("󰍬")
    if (root.privacyCameraActive())
      parts.push("󰄀")
    if (root.privacyShareActive())
      parts.push("󰍹")
    if (shellSettings.doNotDisturb)
      parts.push("󰂛")
    return parts.join(" ")
  }

  function privacyBarColor() {
    if (root.privacyCaptureActive())
      return shellTheme.warning
    if (shellSettings.doNotDisturb)
      return shellSettings.primaryColor
    return shellTheme.textSubtle
  }

  function privacySummaryText() {
    const capture = root.privacyCaptureActive() ? "Capture active" : "No capture"
    return capture + shellConfig.textSeparator + (shellSettings.doNotDisturb ? "DND on" : "DND off")
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

  function formatPomodoroTime(seconds) {
    const total = Math.max(0, Number(seconds || 0))
    const minutes = Math.floor(total / 60)
    const rest = total % 60
    return minutes + ":" + (rest < 10 ? "0" : "") + rest
  }

  function pomodoroStatusText() {
    if (root.pomodoroModeText === shellConfig.states.idle)
      return "No Pomodoro"
    const mode = root.pomodoroModeText.replace("-", " ")
    const suffix = root.pomodoroPaused ? " paused" : (root.pomodoroComplete ? " done" : "")
    return mode + " " + root.formatPomodoroTime(root.pomodoroRemainingSeconds) + suffix
  }

  function updatePomodoro(output) {
    const text = String(output || "").trim()
    if (text.length === 0)
      return

    try {
      const data = JSON.parse(text)
      const timew = data.timew || {}
      root.pomodoroModeText = data.mode || shellConfig.states.idle
      root.pomodoroLabelText = data.label || ""
      root.pomodoroRemainingSeconds = Number(data.remaining_seconds || 0)
      root.pomodoroRunning = data.running === true
      root.pomodoroPaused = data.paused === true
      root.pomodoroComplete = data.complete === true
      root.pomodoroTimewText = timew.available === true ? (timew.tracking === true ? (timew.owned === true ? "timew pomodoro" : "timew busy") : "timew idle") : "timew unavailable"
    } catch (error) {
      root.pomodoroModeText = "parse error"
      root.pomodoroTimewText = "pomodoroctl parse error"
    }
  }

  function runPomodoro(action, extra) {
    Quickshell.execDetached(shellConfig.pomodoro(action, extra))
    calendarService.refreshPomodoroSoon()
  }

  function refreshAudioMixer() {
    audioService.refreshMixer()
  }

  function refreshAudioState() {
    audioService.refreshState()
  }

  function scheduleAudioRefresh() {
    audioService.refreshSoon()
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
    Quickshell.execDetached(shellConfig.audio(action))
    root.scheduleAudioRefresh()
  }

  function runPlayerctl(action) {
    Quickshell.execDetached(shellConfig.playerctl(action))
    root.scheduleAudioRefresh()
  }

  function runSinkInputAction(id, action) {
    const command = shellConfig.sinkInputAction(id, action)
    if (command.length === 0)
      return
    Quickshell.execDetached(command)
    root.scheduleAudioRefresh()
  }

  function setSinkInputVolume(id, value) {
    if (!id)
      return
    Quickshell.execDetached(shellConfig.sinkInputVolume(id, value))
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
    Quickshell.execDetached(shellConfig.network(action))
    systemStatusService.refreshNetworkSoon()
  }

  function setPowerProfile(profile) {
    Quickshell.execDetached(shellConfig.powerProfile(profile))
    systemStatusService.refreshPowerSoon()
  }

  function idleInhibitActive() {
    return root.inhibitStatusText.indexOf("active") === 0
  }

  function toggleIdleInhibit() {
    Quickshell.execDetached(shellConfig.inhibit("toggle"))
    systemStatusService.refreshInhibitSoon()
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

    let x = Math.max(8, bar.width - 24)
    let y = bar.height + 24
    if (visualItem && mouse) {
      const point = bar.contentItem.mapFromItem(visualItem, mouse.x, mouse.y)
      x = point.x
      y = point.y
    }
    item.display(bar, x, y)
    return true
  }

  function openTrayContext(item) {
    if (root.runTrayDirectAction(item))
      return
    if (!root.showTrayMenu(item) && item && item.activate)
      item.activate()
  }



  ShellConfig { id: shellConfig }
  ShellTheme { id: shellTheme }

  Component.onCompleted: Quickshell.execDetached(shellConfig.ensureStateDir())

  FileView {
    id: settingsFile
    path: root.stateDir + "/settings.json"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onAdapterUpdated: writeAdapter()

    ShellSettings { id: shellSettings }
  }

  ListModel { id: notificationHistory }
  ListModel { id: notificationInboxModel }
  ListModel { id: audioStreams }
  ListModel { id: wallpaperModel }


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

  ShellCalendarService {
    id: calendarService
    shellRoot: root
    shellConfig: shellConfig
    shellSettings: shellSettings
  }

  ShellDashboardService {
    id: dashboardService
    shellRoot: root
    shellConfig: shellConfig
  }

  ShellAudioService {
    id: audioService
    shellRoot: root
    shellConfig: shellConfig
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
    Quickshell.execDetached(shellConfig.brightness(action))
    systemStatusService.refreshBrightnessSoon()
  }

  function setBrightness(value) {
    root.brightnessValue = Math.max(0, Math.min(100, Math.round(value)))
    root.brightnessText = root.brightnessValue + "%"
    root.runBrightness(String(root.brightnessValue))
    overlays.show("󰃠", "Brightness " + root.brightnessText)
  }

  function setExternalBrightness(value) {
    root.externalBrightnessValue = Math.max(0, Math.min(100, Math.round(value)))
    Quickshell.execDetached(shellConfig.setExternalBrightness(root.externalBrightnessValue))
    systemStatusService.refreshExternalBrightnessSoon()
    overlays.show("󰍹", "External brightness " + root.externalBrightnessValue + "%")
  }

  function runExternalBrightness(action) {
    Quickshell.execDetached(shellConfig.externalBrightness(action))
    systemStatusService.refreshExternalBrightnessSoon()
  }

  function runKbdBrightness(action) {
    Quickshell.execDetached(shellConfig.keyboardBrightness(action))
    systemStatusService.refreshKbdBrightnessSoon()
    root.showKbdOsd()
  }

  function lockSession() {
    Quickshell.execDetached(shellConfig.locker())
  }

  function suspendSession() {
    Quickshell.execDetached(shellConfig.suspend())
  }

  function setSessionConfirm(label, icon, command) {
    root.sessionConfirmLabel = label
    root.sessionConfirmIcon = icon
    root.sessionConfirmCommand = command
  }

  function openSessionConfirm(label, icon, command) {
    root.closeTransientPanels()
    root.powerMenuOpen = true
    root.setSessionConfirm(label, icon, command)
  }

  function clearSessionConfirm() {
    root.sessionConfirmLabel = ""
    root.sessionConfirmIcon = ""
    root.sessionConfirmCommand = []
  }

  function hidePowerMenu() {
    root.clearSessionConfirm()
    root.powerMenuOpen = false
  }

  function runSessionConfirm() {
    if (root.sessionConfirmCommand.length === 0)
      return
    const command = root.sessionConfirmCommand
    root.hidePowerMenu()
    Quickshell.execDetached(command)
  }

  component IconButton: ShellIconButton { tooltipState: root }

  component ActionButton: ShellActionButton { tooltipState: root }

  component TrayButton: ShellTrayButton { shellRoot: root }

  IpcHandler {

    target: "bar"

    function toggle() { root.barHidden = !root.barHidden }
    function show() { root.barHidden = false }
    function hide() { root.barHidden = true }
    function trayManage() { root.toggleTrayManage() }
    function controls() { root.toggleControlPanel() }
    function controlsVisible(): string { return root.controlPanelOpen ? shellConfig.states.visible : shellConfig.states.hidden }
    function media() { root.toggleMediaPanel() }
    function screen() { root.toggleScreenPanel() }
    function wallpaper() { root.toggleWallpaperPanel() }
    function calendar() { root.toggleCalendar() }
    function workInbox() { root.toggleWorkInbox() }
    function personalDashboard() { root.togglePersonalDashboard() }
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
    function clipboardVisible(): string { return root.clipboardOpen ? shellConfig.states.visible : shellConfig.states.hidden }
    function clipboardUpdate() { menuDataService.refreshClipboard() }
    function closePanels() { root.closeTransientPanels() }
  }

  IpcHandler {
    target: "websearch"

    function open() { root.openWebSearch(shellConfig.defaultWebSearchSite) }
    function toggle() { root.toggleWebSearch(shellConfig.defaultWebSearchSite) }
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
    color: shellTheme.panel

    Image {
      anchors.fill: parent
      source: root.wallpaperSource
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
    }
  }

  ShellBar {
    id: bar
    barRoot: root
    barTheme: shellTheme
    barSettings: shellSettings
    barConfig: shellConfig
    notificationHistoryModel: notificationHistory
  }

    ShellWallpaperPanel {
      anchorWindow: bar
      shellRoot: root
      shellConfig: shellConfig
      wallpapersModel: wallpaperModel
      panelOpen: root.wallpaperPanelOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.wallpaper)
      compactHeight: root.menuCompactHeightFor(shellConfig.menuIds.wallpaper)
    }

    ShellScreenPanel {
      anchorWindow: bar
      shellRoot: root
      shellConfig: shellConfig
      panelOpen: root.screenPanelOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.screen)
      panelHeight: root.menuHeightFor(shellConfig.menuIds.screen)
    }

    ShellMediaPanel {
      anchorWindow: bar
      shellRoot: root
      shellConfig: shellConfig
      audioStreamsModel: audioStreams
      panelOpen: root.mediaPanelOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.media)
      panelHeight: root.menuHeightFor(shellConfig.menuIds.media)
    }

    ShellControlPanel {
      anchorWindow: bar
      shellRoot: root
      shellSettings: shellSettings
      shellConfig: shellConfig
      privacyRefresh: systemStatusService.privacyHandle
      panelOpen: root.controlPanelOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.controls)
      panelHeight: root.menuHeightFor(shellConfig.menuIds.controls)
    }

    ShellSettingsPanel {
      anchorWindow: bar
      shellRoot: root
      shellSettings: shellSettings
      shellConfig: shellConfig
      weatherRefresh: calendarService.weatherRefresh
      panelOpen: root.settingsOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.settings)
      panelHeight: root.menuHeightFor(shellConfig.menuIds.settings)
    }


    ShellCalendarPanel {
      anchorWindow: bar
      shellRoot: root
      shellSettings: shellSettings
      shellConfig: shellConfig
      clock: clock
      agendaRefresh: calendarService.agendaRefresh
      panelOpen: root.calendarOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.calendar)
      panelHeight: root.menuHeightFor(shellConfig.menuIds.calendar)
    }


    ShellWorkInboxPanel {
      anchorWindow: bar
      shellRoot: root
      shellSettings: shellSettings
      shellConfig: shellConfig
      refresh: dashboardService.workInboxHandle
      panelOpen: root.workInboxOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.workInbox)
      panelHeight: root.menuHeightFor(shellConfig.menuIds.workInbox)
    }

    ShellPersonalDashboardPanel {
      anchorWindow: bar
      shellRoot: root
      shellConfig: shellConfig
      refresh: dashboardService.personalDashboardHandle
      panelOpen: root.personalDashboardOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.personalDashboard)
      panelHeight: root.menuHeightFor(shellConfig.menuIds.personalDashboard)
    }

    ShellNotificationCenter {
      anchorWindow: bar
      shellRoot: root
      shellSettings: shellSettings
      historyModel: notificationHistory
      inboxModel: notificationInboxModel
      panelOpen: root.notificationCenterOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.notifications)
      panelHeight: root.menuHeightFor(shellConfig.menuIds.notifications)
    }

    ShellOverlays {
      id: overlays
      anchorWindow: bar
      shellRoot: root
      shellSettings: shellSettings
    }


  ShellWallpaperService {
    id: wallpaperService
    shellRoot: root
    shellConfig: shellConfig
  }

  ShellScreenService {
    id: screenService
    shellRoot: root
    shellConfig: shellConfig
  }

  ShellSystemStatusService {
    id: systemStatusService
    shellRoot: root
    shellConfig: shellConfig
  }



  ListModel { id: launcherModel }
  ListModel { id: clipboardModel }
  ListModel { id: passModel }
  ListModel { id: keybindingModel }

  ShellMenuDataService {
    id: menuDataService
    shellRoot: root
    shellConfig: shellConfig
  }


  ShellLauncherPanel {
    id: launcher
    shellRoot: root
    launcherModel: launcherModel
    panelHeight: root.menuHeightFor(shellConfig.menuIds.launcher)
  }

  ShellLauncherService {
    id: launcherService
    shellRoot: root
    shellConfig: shellConfig
    shellSettings: shellSettings
    launcherPanel: launcher
    launcherModel: launcherModel
  }

  ShellClipboardPanel {
    id: clipboardPanel
    shellRoot: root
    clipboardModel: clipboardModel
    panelOpen: root.clipboardOpen
    refreshRunning: menuDataService.clipboardRunning
    panelWidth: root.menuWidthFor(shellConfig.menuIds.clipboard)
    panelHeight: root.menuHeightFor(shellConfig.menuIds.clipboard)
  }

  ShellPassMenuPanel {
    id: passMenuPanel
    shellRoot: root
    passModel: passModel
    panelOpen: root.passMenuOpen
    refreshRunning: menuDataService.passRunning
    panelWidth: root.menuWidthFor(shellConfig.menuIds.passmenu)
    panelHeight: root.menuHeightFor(shellConfig.menuIds.passmenu)
  }


    ShellKeybindingsPanel {
      anchorWindow: bar
      keybindingsModel: keybindingModel
      panelOpen: root.keybindingsOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.keybindings)
      panelHeight: root.menuHeightFor(shellConfig.menuIds.keybindings)
    }

    ShellWebSearchPanel {
      id: webSearchPanel
      shellRoot: root
      shellConfig: shellConfig
      panelOpen: root.webSearchOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.websearch)
      panelHeight: root.menuHeightFor(shellConfig.menuIds.websearch)
    }

    ShellNetworkPanel {
      anchorWindow: bar
      shellRoot: root
      shellConfig: shellConfig
      statusRefresh: systemStatusService.networkHandle
      panelOpen: root.networkPanelOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.network)
      panelHeight: root.menuHeightFor(shellConfig.menuIds.network)
    }

    ShellPowerMenu {
      anchorWindow: bar
      shellRoot: root
      shellConfig: shellConfig
      panelOpen: root.powerMenuOpen
      panelHeight: root.menuHeightFor(shellConfig.menuIds.power)
    }

}
