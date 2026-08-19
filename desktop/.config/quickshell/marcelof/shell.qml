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
import qs.Commons
import "plugins/menu" as OmarchyMenu
import "plugins/emojis" as EmojiPlugin
import "plugins/image-picker" as ImagePickerPlugin
import "plugins/panels/wifiqr" as WifiQrPlugin
import "services" as OmarchyServices

ShellRoot {
  id: root

  readonly property var pluginHost: pluginHostObject

  property string launcherSmokeHiddenId: ""
  readonly property var appLibrary: appLibraryService
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
    root.toggleTransientPanel("keybindingsOpen", function() { menuDataService.refreshKeybindings() })
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
    root.passUserKey = String(userKey || shellConfig.defaultPassUserKey)
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
  property string passUserKey: shellConfig.defaultPassUserKey
  property string passBackend: "gopass"
  readonly property bool rootMenuOpen: rootMenu.opened
  property bool keybindingsOpen: false
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
  property bool screenPanelOpen: false
  property bool calendarOpen: false
  property bool workInboxOpen: false
  property bool personalDashboardOpen: false
  property bool settingsOpen: false
  property bool notificationCenterOpen: false
  property bool notificationToastOpen: false
  property int selectedNotificationIndex: -1
  property var notificationObjects: []
  property bool notificationHistoryLoaded: false
  property string notificationToastApp: ""
  property string notificationToastAppIcon: ""
  property string notificationToastImage: ""
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
  property string weatherPanelText: ""
  property string inhibitStatusText: "inactive"
  readonly property string lisbonClockText: Qt.formatDateTime(clock.date, "ddd-dd HH:mm:ss")
  property string timePanelText: ""
  property string agendaPanelText: ""
  property string reminderPanelText: ""
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
    wifiQrOverlay.close()
    imagePicker.close()
    if (bar.activePopout) bar.activePopout.close()
    for (let menu in shellConfig.menuRegistry) {
      const entry = shellConfig.menuRegistry[menu]
      if (entry.hide && typeof root[entry.hide] === "function")
        root[entry.hide]()
      else if (entry.openProperty)
        root[entry.openProperty] = false
    }
    root.clearSessionConfirm()
  }

  function runShellCallback(name) {
    if (typeof name === "function") {
      name()
      return
    }
    const callback = String(name || "")
    if (callback.length > 0 && typeof root[callback] === "function")
      root[callback]()
  }

  function toggleTransientPanel(openProperty, onOpen) {
    const next = !root[openProperty]
    root.closeTransientPanels()
    root[openProperty] = next
    if (next)
      root.runShellCallback(onOpen)
  }

  function shellMenuId(id) {
    const raw = String(id || "").replace(/^omarchy[.-]/, "").replace(/_/g, "-")
    return shellConfig.menuAliases[raw] || raw
  }

  function shellMenuEntry(id) {
    return shellConfig.menuRegistry[root.shellMenuId(id)] || null
  }

  function shellMenuOpen(id) {
    const menu = root.shellMenuId(id)
    if (menu === "bar") return !root.barHidden
    if (menu === "launcher") return launcher.panelOpen
    if (menu === shellConfig.menuIds.rootMenu) return rootMenu.opened
    if (menu === shellConfig.menuIds.emojis) return emojiOverlay.opened
    if (menu === "wifiqr") return wifiQrOverlay.opened
    const entry = root.shellMenuEntry(menu)
    return !!(entry && entry.openProperty && root[entry.openProperty])
  }

  function hideShellMenu(id) {
    const menu = root.shellMenuId(id)
    if (menu === "all" || menu === "panels") {
      root.closeTransientPanels()
      return true
    }
    if (menu === "bar") {
      root.barHidden = true
      return true
    }
    if (menu === "launcher") {
      root.hideLauncher()
      return true
    }
    if (menu === "wifiqr") {
      wifiQrOverlay.close()
      return true
    }
    const entry = root.shellMenuEntry(menu)
    if (!entry) return false
    if (entry.hide && typeof root[entry.hide] === "function")
      root[entry.hide]()
    else if (entry.openProperty)
      root[entry.openProperty] = false
    return true
  }

  function toggleShellMenu(id, payloadJson) {
    const menu = root.shellMenuId(id)
    if (menu === "bar") {
      root.barHidden = !root.barHidden
      return true
    }
    if (menu === "launcher") {
      root.toggleLauncher()
      return true
    }
    if (menu === "wifiqr") {
      wifiQrOverlay.opened ? wifiQrOverlay.close() : wifiQrOverlay.open(payloadJson || "{}")
      return true
    }
    const action = shellConfig.actionRegistry[menu]
    if (action && typeof root[action] === "function") {
      root[action]()
      return true
    }
    const entry = root.shellMenuEntry(menu)
    if (!entry) return false
    if (entry.toggle && typeof root[entry.toggle] === "function") {
      root[entry.toggle](payloadJson)
      return true
    }
    if (entry.openProperty) {
      root.toggleTransientPanel(entry.openProperty, entry.refresh || "")
      return true
    }
    return false
  }

  function openShellMenu(id, payloadJson) {
    const menu = root.shellMenuId(id)
    if (menu === "bar") {
      root.barHidden = false
      return true
    }
    if (root.shellMenuOpen(menu)) {
      if (menu === "launcher")
        launcher.focusSearch()
      return true
    }
    return root.toggleShellMenu(menu, payloadJson)
  }

  function runMenuAction(action) {
    switch (String(action || "")) {
    case "apps":
      root.closeTransientPanels()
      root.toggleLauncher()
      break
    case "web": root.toggleWebSearch(shellConfig.defaultWebSearchSite); break
    case "keys": root.toggleKeybindings(); break
    case "clipboard": root.toggleClipboard(); break
    case "wallpaper": root.toggleWallpaperPanel(); break
    case "screen": root.toggleScreenPanel(); break
    case "media": root.toggleMediaPanel(); break
    case "network": root.toggleNetworkPanel(); break
    case "calendar": root.toggleCalendar(); break
    case "work": root.toggleWorkInbox(); break
    case "dashboard": root.togglePersonalDashboard(); break
    case "notifications": root.toggleNotifications(); break
    case "settings": root.toggleSettings(); break
    case "tray": root.toggleTrayManage(); break
    case "power": root.togglePowerMenu(); break
    }
  }

  function hideRootMenu() { rootMenu.close() }

  function hideEmojis() { emojiOverlay.close() }

  function toggleEmojis(payloadJson) {
    if (emojiOverlay.opened) {
      emojiOverlay.close()
      return
    }
    root.closeTransientPanels()
    emojiOverlay.open(payloadJson || "{}")
  }

  function toggleRootMenu(payloadJson) {
    if (rootMenu.opened) {
      rootMenu.close()
      return
    }
    root.closeTransientPanels()
    rootMenu.open(payloadJson || "{}")
  }

  function togglePassmenu() {
    if (root.passMenuOpen)
      root.passMenuOpen = false
    else
      root.openPassmenu(shellConfig.actions.copy, shellConfig.defaultPassUserKey, "gopass")
  }

  function toggleDefaultWebSearch() { root.toggleWebSearch(shellConfig.defaultWebSearchSite) }

  function refreshKeybindings() { menuDataService.refreshKeybindings() }
  function refreshControls() { systemStatusService.refreshControls() }
  function refreshNetwork() { systemStatusService.refreshNetwork() }
  function refreshPower() { systemStatusService.refreshPower() }
  function refreshCalendar() { calendarService.refreshAll() }
  function refreshWorkInbox() { dashboardService.refreshWorkInbox() }
  function refreshPersonalDashboard() { dashboardService.refreshPersonalDashboard() }

  function togglePowerMenu() { root.toggleTransientPanel("powerMenuOpen", function() { systemStatusService.refreshPower() }) }

  function toggleTrayManage() { root.toggleTransientPanel("trayManageOpen") }

  function toggleControlPanel() {
    root.toggleTransientPanel("controlPanelOpen", function() { systemStatusService.refreshControls() })
  }

  function toggleNetworkPanel() { bar.toggleNetworkPanel() }

  function toggleMediaPanel() { bar.toggleMediaPanel() }

  function refreshScreenState() {
    screenService.refresh()
    systemStatusService.refreshPrivacy()
  }

  function toggleScreenPanel() {
    root.toggleTransientPanel("screenPanelOpen", function() { root.refreshScreenState() })
  }

  function runScreenRecord(action) {
    screenService.runRecord(action)
  }

  function toggleWallpaperPanel() {
    if (imagePicker.opened) {
      imagePicker.close()
      return
    }
    root.closeTransientPanels()
    imagePicker.open(JSON.stringify({
      imageDirs: shellConfig.home + "/.local/share/backgrounds\n" + shellConfig.home + "/Pictures/Wallpapers\n" + shellConfig.home + "/Pictures/wallpapers",
      selectedImage: shellSettings.wallpaperPath,
      showLabels: true,
      filterable: true
    }))
  }

  function applyWallpaperPath(path) {
    if (String(path || "").length === 0)
      return
    root.wallpaperSource = shellConfig.fileUrl(path)
    shellSettings.wallpaperPath = path
  }

  function setWallpaper(path) {
    root.applyWallpaperPath(path)
    Quickshell.execDetached(shellConfig.wallpaper("set", path))
  }

  function toggleCalendar() {
    root.toggleTransientPanel("calendarOpen", function() { calendarService.refreshAll() })
  }

  function toggleWorkInbox() {
    root.toggleTransientPanel("workInboxOpen", function() { dashboardService.refreshWorkInbox() })
  }

  function togglePersonalDashboard() {
    root.toggleTransientPanel("personalDashboardOpen", function() { dashboardService.refreshPersonalDashboard() })
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

  function toggleSettings() { root.toggleTransientPanel("settingsOpen") }

  function toggleDnd() {
    shellSettings.doNotDisturb = !shellSettings.doNotDisturb
    if (shellSettings.doNotDisturb)
      root.notificationToastOpen = false
  }

  function toggleNotifications() { root.toggleTransientPanel("notificationCenterOpen") }

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
    root.scheduleNotificationHistorySave()
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
    const appIcons = ({})
    for (let i = 0; i < notificationHistory.count; i++) {
      const row = notificationHistory.get(i)
      const app = String(row.app || "Notification")
      if (!counts[app]) {
        counts[app] = 0
        apps.push(app)
      }
      counts[app] += 1
      if (!appIcons[app])
        appIcons[app] = String(row.appIcon || "")
    }

    notificationInboxModel.clear()
    // ponytail: O(apps * notifications), capped at 50; index by app only if history grows.
    for (let appIndex = 0; appIndex < apps.length; appIndex++) {
      const app = apps[appIndex]
      notificationInboxModel.append({ kind: "group", app: app, appIcon: appIcons[app] || "", image: "", count: counts[app], sourceIndex: -1, summary: "", body: "", text: "", actionsText: "", desktopEntry: "", time: "", sticky: false, liveActions: false, urgency: 1, timestamp: 0 })
      for (let i = 0; i < notificationHistory.count; i++) {
        const row = notificationHistory.get(i)
        if (String(row.app || "Notification") !== app)
          continue
        notificationInboxModel.append({ kind: "notification", app: row.app, appIcon: row.appIcon || "", image: row.image || "", count: counts[app], sourceIndex: i, summary: row.summary, body: row.body, text: row.text, actionsText: row.actionsText, desktopEntry: row.desktopEntry || "", time: row.time, sticky: !!row.sticky, liveActions: !!row.liveActions, urgency: Number(row.urgency || 1), timestamp: Number(row.timestamp || 0) })
      }
    }
  }

  function cleanNotificationText(value) {
    return String(value || "").replace(/<[^>]+>/g, "").replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">").trim()
  }

  function notificationActionsFrom(notification) {
    if (!notification || !notification.actions)
      return []
    if (notification.actions.map)
      return notification.actions.map(action => action)

    const actions = []
    for (let i = 0; i < notification.actions.length; i++)
      actions.push(notification.actions[i])
    return actions
  }

  function notificationActionLabelsFrom(notification) {
    const actions = root.notificationActionsFrom(notification)
    const labels = []
    for (let i = 0; i < actions.length; i++) {
      const text = root.cleanNotificationText(actions[i].text || actions[i].identifier)
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

  function notificationImageSource(value) {
    const source = String(value || "")
    if (source.length === 0)
      return ""
    if (source.indexOf("file://") === 0 || source.indexOf("image://") === 0)
      return source
    if (source.charAt(0) === "/")
      return "file://" + source
    return Quickshell.iconPath(source, true)
  }

  function notificationMatchesAny(text, values) {
    const haystack = String(text || "").toLowerCase()
    for (let i = 0; i < values.length; i++) {
      const needle = String(values[i] || "").toLowerCase()
      if (needle.length > 0 && haystack.indexOf(needle) !== -1)
        return true
    }
    return false
  }

  function shouldToastNotification(notification, app, summary, body, actionLabels) {
    const policy = shellConfig.notificationToastPolicy
    const urgency = Number(notification && notification.urgency || 0)
    if (urgency >= Number(policy.criticalUrgency || 2))
      return true
    if (root.notificationMatchesAny(app + "\n" + String(notification.desktopEntry || "") + "\n" + String(notification.appIcon || ""), policy.importantApps || []))
      return true
    if (root.notificationMatchesAny(actionLabels.join("\n"), policy.importantActions || []))
      return true
    return root.notificationMatchesAny(summary + "\n" + body, policy.importantPatterns || [])
  }

  function isNotificationSticky(notification, app, summary, body, actionLabels) {
    if (!notification)
      return false

    const expireTimeout = Number(notification.expireTimeout)
    if (notification.resident || (!isNaN(expireTimeout) && expireTimeout === 0))
      return true

    return root.shouldToastNotification(notification, app, summary, body, actionLabels)
  }

  function notificationActionCompletes(label) {
    return root.notificationMatchesAny(label, shellConfig.notificationToastPolicy.completeActions || [])
  }

  function notificationPersistable(row) {
    const text = String((row && row.app) || "") + "\n" + String((row && row.desktopEntry) || "")
    return !root.notificationMatchesAny(text, ["gopass", "passmenu", "password", "secret", "1password"])
  }

  function safeNotificationReference(value) {
    const ref = root.cleanNotificationText(value)
    if (ref.indexOf("data:") === 0 || ref.indexOf("http://") === 0 || ref.indexOf("https://") === 0)
      return ""
    return ref
  }

  function persistedNotificationRow(row) {
    const app = root.cleanNotificationText(row && row.app || "Notification")
    const summary = root.cleanNotificationText(row && row.summary || "")
    const body = root.cleanNotificationText(row && row.body || "")
    return {
      app: app,
      appIcon: root.safeNotificationReference(row && row.appIcon || ""),
      image: root.safeNotificationReference(row && row.image || ""),
      summary: summary,
      body: body,
      text: root.notificationPreview(summary, body, app),
      actionsText: root.cleanNotificationText(row && row.actionsText || ""),
      sticky: !!(row && row.sticky),
      liveActions: false,
      urgency: Number(row && row.urgency || 1),
      desktopEntry: root.cleanNotificationText(row && row.desktopEntry || ""),
      time: root.cleanNotificationText(row && row.time || ""),
      timestamp: Number(row && row.timestamp || Date.now())
    }
  }

  function loadNotificationHistory(raw) {
    if (root.notificationHistoryLoaded)
      return

    const lines = String(raw || "").trim().split(/\n+/)
    const rows = []
    for (let i = 0; i < lines.length; i++) {
      try {
        const row = root.persistedNotificationRow(JSON.parse(lines[i]))
        if (root.notificationPersistable(row))
          rows.push(row)
      } catch (e) {
      }
    }
    rows.sort((a, b) => Number(b.timestamp || 0) - Number(a.timestamp || 0))
    for (let j = 0; j < Math.min(50, rows.length); j++) {
      notificationHistory.append(rows[j])
      root.notificationObjects.push(null)
    }
    if (notificationHistory.count > 0)
      root.selectedNotificationIndex = 0
    root.notificationHistoryLoaded = true
    root.rebuildNotificationInbox()
  }

  function scheduleNotificationHistorySave() {
    if (root.notificationHistoryLoaded)
      notificationHistorySaveTimer.restart()
  }

  function saveNotificationHistory() {
    const lines = []
    for (let i = 0; i < Math.min(50, notificationHistory.count); i++) {
      const row = root.persistedNotificationRow(notificationHistory.get(i))
      if (root.notificationPersistable(row))
        lines.push(JSON.stringify(row))
    }
    notificationHistoryFile.setText(lines.join("\n") + (lines.length > 0 ? "\n" : ""))
  }

  function rememberNotification(notification) {
    if (!notification)
      return

    const app = root.cleanNotificationText(notification.appName || "Notification")
    const summary = root.cleanNotificationText(notification.summary)
    const body = root.cleanNotificationText(notification.body)
    const actionLabels = root.notificationActionLabelsFrom(notification)
    const sticky = root.isNotificationSticky(notification, app, summary, body, actionLabels)
    const now = new Date()

    notificationHistory.insert(0, {
      app: app,
      appIcon: root.cleanNotificationText(notification.appIcon),
      image: root.cleanNotificationText(notification.image),
      summary: summary,
      body: body,
      text: root.notificationPreview(summary, body, app),
      actionsText: actionLabels.join(" | "),
      sticky: sticky,
      liveActions: actionLabels.length > 0,
      urgency: Number(notification.urgency || 1),
      desktopEntry: root.cleanNotificationText(notification.desktopEntry),
      time: Qt.formatDateTime(now, "HH:mm"),
      timestamp: now.getTime()
    })
    root.notificationObjects = [notification].concat(root.notificationObjects)
    root.selectedNotificationIndex = 0
    root.notificationToastApp = app
    root.notificationToastAppIcon = root.cleanNotificationText(notification.appIcon)
    root.notificationToastImage = root.cleanNotificationText(notification.image)
    root.notificationToastSummary = summary.length > 0 ? summary : app
    root.notificationToastBody = body
    root.notificationToastSerial += 1
    if (!shellSettings.doNotDisturb && root.shouldToastNotification(notification, app, summary, body, actionLabels)) {
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
    root.scheduleNotificationHistorySave()
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
    root.scheduleNotificationHistorySave()
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
    const actions = root.notificationActionsFrom(notification)
    if (actionIndex < 0 || actionIndex >= actions.length)
      return

    const row = index >= 0 && index < notificationHistory.count ? notificationHistory.get(index) : null
    const actionLabel = String(actions[actionIndex].text || actions[actionIndex].identifier || "")
    actions[actionIndex].invoke()
    if (!row || !row.sticky || root.notificationActionCompletes(actionLabel))
      root.dismissNotification(index)
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

  function scheduleAudioRefresh() {
    audioService.refreshSoon()
  }

  function runAudioctl(action) {
    Quickshell.execDetached(shellConfig.audio(action))
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

  QtObject {
    id: pluginHostObject
    function hide(pluginId) {
      if (String(pluginId) === "omarchy.wifiqr") { wifiQrOverlay.close(); return true }
      return root.hideShellMenu(pluginId)
    }
    function summon(pluginId, payloadJson) {
      if (String(pluginId) === "omarchy.wifiqr") { wifiQrOverlay.open(payloadJson || "{}"); return true }
      return root.openShellMenu(pluginId, payloadJson || "{}")
    }
  }

  EmojiPlugin.Emojis {
    id: emojiOverlay
    pluginPath: shellConfig.home + "/.config/quickshell/marcelof/plugins/emojis"
    targetScreen: root.laptopScreen
    shell: pluginHostObject
    manifest: ({ id: "omarchy.emojis" })
  }

  WifiQrPlugin.Panel {
    id: wifiQrOverlay
    shell: pluginHostObject
    manifest: ({ id: "omarchy.wifiqr" })
  }

  ImagePickerPlugin.ImagePicker {
    id: imagePicker
    pluginPath: shellConfig.home + "/.config/quickshell/marcelof/plugins/image-picker"
    applyAction: function(path) { root.setWallpaper(path) }
  }

  // Local settings own the palette; copied Omarchy components consume it here.
  Binding { target: Color; property: "foreground"; value: shellTheme.text }
  Binding { target: Color; property: "background"; value: shellTheme.panel }
  Binding { target: Color; property: "accent"; value: shellSettings.primaryColor }
  Binding { target: Color; property: "urgent"; value: shellTheme.error }
  Binding { target: Color; property: "muted"; value: shellTheme.textMuted }
  Binding { target: Style; property: "fontFamily"; value: shellTheme.fontFamily }
  Binding { target: Style; property: "fontBaseSize"; value: shellTheme.fontMd }

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


  FileView {
    id: notificationHistoryFile
    path: root.stateDir + "/notifications.jsonl"
    watchChanges: false
    atomicWrites: true
    printErrors: false
    onLoaded: root.loadNotificationHistory(text())
    onLoadFailed: root.loadNotificationHistory("")
  }

  Timer {
    id: notificationHistorySaveTimer
    interval: 200
    repeat: false
    onTriggered: root.saveNotificationHistory()
  }
  ListModel { id: notificationHistory }
  ListModel { id: notificationInboxModel }


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

  function requestSessionAction(action) {
    const item = shellConfig.sessionAction(action)
    if (!item) return false
    if (action === "hide") root.hidePowerMenu()
    else if (action === "lock") root.lockSession()
    else if (action === "suspend") root.suspendSession()
    else root.openSessionConfirm(item.label, item.icon, shellConfig.sessionCommand(action))
    return true
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
    target: "shell"

    function ping(): string { return "ok" }
    function listMenus(): string { return JSON.stringify(shellConfig.menuIds) }
    function listPlugins(): string {
      const plugins = [{ id: "launcher", name: "launcher", kinds: ["menu"], enabled: true, active: true, canDisable: false, firstParty: true, clonedFrom: "" }]
      for (let id in shellConfig.menuRegistry)
        plugins.push({ id: id, name: id, kinds: ["menu"], enabled: true, active: true, canDisable: false, firstParty: true, clonedFrom: "" })
      plugins.sort((left, right) => left.id.localeCompare(right.id))
      return JSON.stringify(plugins)
    }
    function listShellConfig(): string {
      return JSON.stringify({ menus: shellConfig.menuIds, aliases: shellConfig.menuAliases })
    }
    function dndState(): string { return shellSettings.doNotDisturb ? "on" : "off" }
    function isDnd(): string { return dndState() }
    function toggleDnd(): string { root.toggleDnd(); return dndState() }
    function setDnd(value: string): string {
      const v = String(value || "").toLowerCase()
      shellSettings.doNotDisturb = v === "true" || v === "1" || v === "on" || v === "yes"
      if (shellSettings.doNotDisturb)
        root.notificationToastOpen = false
      return dndState()
    }
    function toggle(id: string, payloadJson: string): string { return root.toggleShellMenu(id, payloadJson) ? "ok" : "unknown" }
    function hide(id: string): string { return root.hideShellMenu(id) ? "ok" : "unknown" }
    function summon(id: string, payloadJson: string): string { return root.openShellMenu(id, payloadJson) ? "ok" : "unknown" }
    function state(id: string): string { return root.shellMenuOpen(id) ? "open" : "closed" }
    function closePanels() { root.closeTransientPanels() }
  }

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


    ShellScreenPanel {
      anchorWindow: bar
      shellRoot: root
      shellConfig: shellConfig
      visibilityAction: value => value ? root.openShellMenu(shellConfig.menuIds.screen, "{}") : root.hideShellMenu(shellConfig.menuIds.screen)
      panelOpen: root.screenPanelOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.screen)
      panelHeight: root.menuHeightFor(shellConfig.menuIds.screen)
    }


    ShellControlPanel {
      anchorWindow: bar
      shellRoot: root
      shellSettings: shellSettings
      shellConfig: shellConfig
      privacyRefresh: systemStatusService.privacyHandle
      visibilityAction: value => value ? root.openShellMenu(shellConfig.menuIds.controls, "{}") : root.hideShellMenu(shellConfig.menuIds.controls)
      panelOpen: root.controlPanelOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.controls)
      panelHeight: root.menuHeightFor(shellConfig.menuIds.controls)
    }

    OmarchyMenu.Menu {
      id: rootMenu
      shell: root
      menuWidth: root.menuWidthFor(shellConfig.menuIds.rootMenu)
      defaultMenuPath: shellConfig.home + "/.config/quickshell/marcelof/omarchy-menu.jsonc"
      fontFamily: shellTheme.fontFamily
      background: shellTheme.panel
      foreground: shellTheme.text
      border: shellTheme.border
      scrim: Qt.rgba(shellTheme.panel.r, shellTheme.panel.g, shellTheme.panel.b, 0.58)
      selectedBackground: shellTheme.surfaceHigh
      selectedText: shellSettings.primaryColor
      selectedBorder: shellSettings.primaryColor
    }

    ShellSettingsPanel {
      anchorWindow: bar
      shellRoot: root
      shellSettings: shellSettings
      shellConfig: shellConfig
      weatherRefresh: calendarService.weatherRefresh
      visibilityAction: value => value ? root.openShellMenu(shellConfig.menuIds.settings, "{}") : root.hideShellMenu(shellConfig.menuIds.settings)
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
      reminderRefresh: calendarService.reminderRefresh
      visibilityAction: value => value ? root.openShellMenu(shellConfig.menuIds.calendar, "{}") : root.hideShellMenu(shellConfig.menuIds.calendar)
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
      visibilityAction: value => value ? root.openShellMenu(shellConfig.menuIds.workInbox, "{}") : root.hideShellMenu(shellConfig.menuIds.workInbox)
      panelOpen: root.workInboxOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.workInbox)
      panelHeight: root.menuHeightFor(shellConfig.menuIds.workInbox)
    }

    ShellPersonalDashboardPanel {
      anchorWindow: bar
      shellRoot: root
      shellConfig: shellConfig
      refresh: dashboardService.personalDashboardHandle
      visibilityAction: value => value ? root.openShellMenu(shellConfig.menuIds.personalDashboard, "{}") : root.hideShellMenu(shellConfig.menuIds.personalDashboard)
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
      visibilityAction: value => value ? root.openShellMenu(shellConfig.menuIds.notifications, "{}") : root.hideShellMenu(shellConfig.menuIds.notifications)
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
    closeAction: function() { root.hideShellMenu(shellConfig.menuIds.launcher) }
    panelHeight: root.menuHeightFor(shellConfig.menuIds.launcher)
  }

  OmarchyServices.AppLibrary {
    id: appLibraryService
    shellRoot: root
    shellSettings: shellSettings
  }

  ShellLauncherService {
    id: launcherService
    shellRoot: root
    shellConfig: shellConfig
    shellSettings: shellSettings
    launcherPanel: launcher
    launcherModel: launcherModel
    appLibrary: appLibraryService
  }

  ShellClipboardPanel {
    id: clipboardPanel
    shellRoot: root
    clipboardModel: clipboardModel
    closeAction: function() { root.hideShellMenu(shellConfig.menuIds.clipboard) }
    panelOpen: root.clipboardOpen
    refreshRunning: menuDataService.clipboardRunning
    panelWidth: root.menuWidthFor(shellConfig.menuIds.clipboard)
    panelHeight: root.menuHeightFor(shellConfig.menuIds.clipboard)
  }

  ShellPassMenuPanel {
    id: passMenuPanel
    shellRoot: root
    passModel: passModel
    closeAction: function() { root.hideShellMenu(shellConfig.menuIds.passmenu) }
    panelOpen: root.passMenuOpen
    refreshRunning: menuDataService.passRunning
    panelWidth: root.menuWidthFor(shellConfig.menuIds.passmenu)
    panelHeight: root.menuHeightFor(shellConfig.menuIds.passmenu)
  }


    ShellKeybindingsPanel {
      shellRoot: root
      keybindingsModel: keybindingModel
      closeAction: () => root.hideShellMenu(shellConfig.menuIds.keybindings)
      panelOpen: root.keybindingsOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.keybindings)
      panelHeight: root.menuHeightFor(shellConfig.menuIds.keybindings)
    }

    ShellWebSearchPanel {
      id: webSearchPanel
      shellRoot: root
      shellConfig: shellConfig
      closeAction: function() { root.hideShellMenu(shellConfig.menuIds.websearch) }
      panelOpen: root.webSearchOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.websearch)
      panelHeight: root.menuHeightFor(shellConfig.menuIds.websearch)
    }


    ShellPowerMenu {
      anchorWindow: bar
      shellRoot: root
      shellConfig: shellConfig
      visibilityAction: value => value ? root.openShellMenu(shellConfig.menuIds.power, "{}") : root.hideShellMenu(shellConfig.menuIds.power)
      panelOpen: root.powerMenuOpen
      panelHeight: root.menuHeightFor(shellConfig.menuIds.power)
    }

}
