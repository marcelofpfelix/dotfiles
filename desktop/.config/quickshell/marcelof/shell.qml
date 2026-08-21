import Quickshell
import Quickshell.Hyprland
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Commons
import "plugins/menu" as OmarchyMenu
import "plugins/bar" as OmarchyBar
import "plugins/emojis" as EmojiPlugin
import "plugins/image-picker" as ImagePickerPlugin
import "plugins/panels/wifiqr" as WifiQrPlugin
import "services" as OmarchyServices

ShellRoot {
  id: root

  readonly property var pluginHost: pluginHostObject
  property var dynamicPluginEntries: []
  property var dynamicBarWidgetEntries: []
  property string openDynamicPluginId: ""
  property string pendingDynamicPluginId: ""
  property string pendingDynamicPluginPayload: ""
  property var dynamicPluginLoaders: ({})
  property string launcherSmokeHiddenId: ""
  readonly property var appLibrary: appLibraryService
  readonly property var notificationService: pluginServiceHost.serviceFor("omarchy.notifications")
  readonly property var backgroundService: pluginServiceHost.serviceFor("omarchy.background")
  readonly property var barConfig: pluginConfig.barConfig
  function firstPartyServiceFor(id) { return pluginServiceHost.serviceFor(id) }
  function summon(id, payloadJson) { return root.openShellMenu(id, payloadJson || "{}") }
  function hide(id) { return root.hideShellMenu(id) }
  function toggle(id, payloadJson) { return root.toggleShellMenu(id, payloadJson || "{}") }
  readonly property alias bar: dynamicBar
  function menuSize(id) { return shellConfig.menuSize(id, shellSettings.denseUi) }
  function menuWidthFor(id) { return root.menuSize(id).width }
  function menuHeightFor(id) { return root.menuSize(id).height }
  function menuCompactHeightFor(id) { return root.menuSize(id).compactHeight }


  function toggleLauncher() {
    if (rootMenu.opened && rootMenu.activeMenu === "apps") rootMenu.close()
    else {
      root.closeTransientPanels()
      menuDataService.refreshLauncherMru()
      rootMenu.open('{"menu":"apps"}')
    }
  }

  function hideLauncher() {
    if (rootMenu.opened && rootMenu.activeMenu === "apps") rootMenu.close()
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

  function showOsd(icon, message, value, maxValue, progressText, duration) {
    const payload = JSON.stringify({
      icon: icon || "",
      message: message || "",
      value: value === undefined ? "" : value,
      max: maxValue === undefined ? 100 : maxValue,
      progressText: progressText || "",
      duration: duration === undefined ? 1200 : duration
    })
    const loader = root.dynamicPluginLoaders["omarchy.osd"]
    if (loader && loader.item) {
      loader.item.open(payload)
      return true
    }
    return root.summonDynamicPlugin("omarchy.osd", payload)
  }

  function showVolumeOsd() {
    const audio = root.defaultSinkAudio()
    if (!audio) return root.showOsd("volume-muted", "Audio unavailable")
    return root.showOsd(audio.muted ? "volume-muted" : "volume", "", Math.round(audio.volume * 100))
  }

  function showBrightnessOsd() {
    root.brightnessOsdPending = true
    systemStatusService.refreshBrightness()
  }

  function showKbdOsd() {
    root.kbdOsdPending = true
    systemStatusService.refreshKbdBrightness()
  }

  function showMicOsd() {
    const source = Pipewire.defaultAudioSource
    const audio = source && source.audio ? source.audio : null
    return root.showOsd(audio && audio.muted ? "microphone-muted" : "microphone", audio && audio.muted ? "Microphone muted" : "Microphone live")
  }

  function finishBrightnessOsd() {
    if (!root.brightnessOsdPending) return
    root.brightnessOsdPending = false
    root.showOsd("brightness", "", root.brightnessValue)
  }

  function finishKbdOsd() {
    if (!root.kbdOsdPending) return
    root.kbdOsdPending = false
    const value = Number(root.kbdBrightnessText.replace("%", ""))
    if (isFinite(value)) root.showOsd("keyboard", "", value)
    else root.showOsd("keyboard", root.kbdBrightnessText || "Keyboard brightness")
  }

  function runWebSearch() {
    webSearchPanel.runSearch()
  }

  function toggleKeybindings() {
    root.closeTransientPanels()
    Quickshell.execDetached(shellConfig.qs("keybindings"))
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

  property var passEntries: []
  property bool passMenuOpen: false
  property string passMode: shellConfig.actions.copy
  property string passUserKey: shellConfig.defaultPassUserKey
  property string passBackend: "gopass"
  readonly property bool rootMenuOpen: rootMenu.opened
  property bool powerMenuOpen: false
  property bool webSearchOpen: false
  property string webSearchSite: shellConfig.defaultWebSearchSite
  readonly property var webSearchSites: shellConfig.webSearchSites

  function updateLauncherMru(output) { appLibraryService.updateMru(output) }
  function rebuildLauncher() { appLibraryService.appsChanged() }
  function toggleLauncherFavoriteById(id) { appLibraryService.toggleFavoriteById(id) }
  function hideLauncherById(id) { appLibraryService.hideById(id) }

  readonly property var laptopScreen: Quickshell.screens.find(screen => screen.name === "eDP-1") || Quickshell.screens[0]

  property alias barHidden: dynamicBar.barHidden
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
  property string brightnessText: "--"
  property real brightnessValue: 0
  property bool brightnessOsdPending: false
  property string kbdBrightnessText: ""
  property bool kbdOsdPending: false
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

  function dynamicPluginKnown(id) {
    return !!pluginRegistry.installedPlugins[String(id || "")]
  }

  function samePluginEntries(left, right) {
    if (left.length !== right.length) return false
    for (var i = 0; i < left.length; i++)
      if (left[i].id !== right[i].id || left[i].sourceUrl !== right[i].sourceUrl
          || left[i].manifest.version !== right[i].manifest.version) return false
    return true
  }

  function refreshDynamicPluginEntries() {
    var overlays = []
    var widgets = []
    for (var id in pluginRegistry.installedPlugins) {
      var manifest = pluginRegistry.installedPlugins[id]
      if (!pluginRegistry.isEnabled(id)) continue
      const panelKind = pluginRegistry.panelEntryKind(id)
      if (panelKind !== "")
        overlays.push({ id: id, manifest: manifest, sourceUrl: pluginRegistry.entryPointUrl(manifest, panelKind), keepLoaded: manifest.keepLoaded === true })
      if (pluginRegistry.supportsKind(id, pluginRegistry.barWidgetKind))
        widgets.push({ id: id, manifest: manifest, sourceUrl: pluginRegistry.entryPointUrl(manifest, "barWidget") })
    }
    overlays.sort(function(left, right) { return left.id.localeCompare(right.id) })
    widgets.sort(function(left, right) { return left.id.localeCompare(right.id) })
    if (!root.samePluginEntries(dynamicPluginEntries, overlays)) dynamicPluginEntries = overlays
    if (!root.samePluginEntries(dynamicBarWidgetEntries, widgets)) dynamicBarWidgetEntries = widgets
  }

  function registerDynamicPluginLoader(id, loader) {
    var next = ({})
    for (var key in dynamicPluginLoaders) next[key] = dynamicPluginLoaders[key]
    next[id] = loader
    dynamicPluginLoaders = next
    root.deliverDynamicPluginPayloads(id)
  }

  function unregisterDynamicPluginLoader(id) {
    var next = ({})
    for (var key in dynamicPluginLoaders) if (key !== id) next[key] = dynamicPluginLoaders[key]
    dynamicPluginLoaders = next
  }

  function callDynamicPlugin(id, method, arg) {
    const resolved = pluginRegistry.resolveEnabledId(id)
    const loader = dynamicPluginLoaders[resolved]
    if (!loader || !loader.item || typeof loader.item[method] !== "function") return "unknown"
    try {
      const result = loader.item[method](arg)
      return result === undefined || result === null ? "ok" : String(result)
    } catch (error) {
      console.warn("plugin " + resolved + " " + method + "() threw:", error)
      return "error"
    }
  }

  function deliverDynamicPluginPayloads(id) {
    var loader = dynamicPluginLoaders[id]
    if (pendingDynamicPluginId !== id || !loader || !loader.item) return
    if (typeof loader.item.open === "function") loader.item.open(pendingDynamicPluginPayload)
    pendingDynamicPluginId = ""
    pendingDynamicPluginPayload = ""
  }

  function dynamicPluginOpen(id) {
    var loader = dynamicPluginLoaders[id]
    if (loader && loader.item && loader.item.opened !== undefined)
      return loader.item.opened === true
    return openDynamicPluginId === id
  }

  function summonDynamicPlugin(id, payloadJson) {
    if (!pluginRegistry.isEnabled(id)) return false
    root.closeTransientPanels()
    openDynamicPluginId = id
    pendingDynamicPluginId = id
    pendingDynamicPluginPayload = payloadJson || ""
    root.deliverDynamicPluginPayloads(id)
    return true
  }

  function hideDynamicPlugin(id) {
    var loader = dynamicPluginLoaders[id]
    if (loader && loader.item && typeof loader.item.close === "function") loader.item.close()
    if (openDynamicPluginId === id) openDynamicPluginId = ""
    if (pendingDynamicPluginId === id) {
      pendingDynamicPluginId = ""
      pendingDynamicPluginPayload = ""
    }
    return true
  }

  function setDynamicPluginEnabled(id, enabled) {
    if (!root.dynamicPluginKnown(id)) return "unknown"
    if (!pluginRegistry.supports(id)) return "unsupported"
    if (!pluginRegistry.setEnabled(id, enabled, {}))
      return pluginRegistry.lastEnableError || "failed"
    return "ok"
  }

  function closeTransientPanels() {
    if (root.notificationService) {
      root.notificationService.clearPopups()
      root.notificationService.closeHistoryPanel()
    }
    root.hideLauncher()
    wifiQrOverlay.close()
    imagePicker.close()
    if (openDynamicPluginId) root.hideDynamicPlugin(openDynamicPluginId)
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
    const raw = String(id || "")
    if (pluginRegistry.supportsPanel(raw)) return root.dynamicPluginOpen(raw)
    const menu = root.shellMenuId(raw)
    if (menu === "bar") return !root.barHidden
    if (menu === "launcher") return rootMenu.opened && rootMenu.activeMenu === "apps"
    if (menu === shellConfig.menuIds.rootMenu) return rootMenu.opened
    if (menu === shellConfig.menuIds.emojis) return emojiOverlay.opened
    if (menu === shellConfig.menuIds.wifiQr) return wifiQrOverlay.opened
    const entry = root.shellMenuEntry(menu)
    return !!(entry && entry.openProperty && root[entry.openProperty])
  }

  function hideShellMenu(id) {
    const raw = String(id || "")
    if (pluginRegistry.supportsPanel(raw)) return root.hideDynamicPlugin(raw)
    const menu = root.shellMenuId(raw)
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
    if (menu === shellConfig.menuIds.wifiQr) {
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
    const raw = String(id || "")
    if (pluginRegistry.supportsPanel(raw))
      return root.dynamicPluginOpen(raw) ? root.hideDynamicPlugin(raw) : root.summonDynamicPlugin(raw, payloadJson)
    const menu = root.shellMenuId(raw)
    if (menu === "bar") {
      root.barHidden = !root.barHidden
      return true
    }
    if (menu === "launcher") {
      root.toggleLauncher()
      return true
    }
    if (menu === shellConfig.menuIds.wifiQr) {
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
    const raw = String(id || "")
    if (pluginRegistry.supportsPanel(raw))
      return root.dynamicPluginOpen(raw) ? true : root.summonDynamicPlugin(raw, payloadJson)
    const menu = root.shellMenuId(raw)
    if (menu === "bar") {
      root.barHidden = false
      return true
    }
    if (root.shellMenuOpen(menu)) return true
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
    case "clipboard": root.toggleShellMenu(shellConfig.pluginIds.clipboard, "{}"); break
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
      selectedImage: root.backgroundService ? root.backgroundService.currentBackground : shellSettings.wallpaperPath,
      showLabels: true,
      filterable: true
    }))
  }

  function setWallpaper(path) {
    if (String(path || "").length === 0) return
    shellSettings.wallpaperPath = path
    if (root.backgroundService) root.backgroundService.setBackground(path, false)
    Quickshell.execDetached(shellConfig.wallpaper("set", path))
  }

  function toggleCalendar() {
    root.toggleTransientPanel("calendarOpen", function() { calendarService.refreshAll() })
  }

  function toggleWorkInbox() {
    root.toggleTransientPanel("workInboxOpen", function() { dashboardService.refreshWorkInbox() })
  }

  function togglePersonalDashboard() {
    const id = shellConfig.pluginIds.boardDashboard
    if (pluginRegistry.isEnabled(id)) {
      if (root.dynamicPluginOpen(id)) root.hideDynamicPlugin(id)
      else root.summonDynamicPlugin(id, "{}")
      return
    }
    root.toggleTransientPanel("personalDashboardOpen", function() { dashboardService.refreshPersonalDashboard() })
  }

  function hidePersonalDashboard() {
    root.personalDashboardOpen = false
    root.hideDynamicPlugin(shellConfig.pluginIds.boardDashboard)
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

  function mutateShellConfig(mutator) { pluginConfig.mutate(mutator) }
  function updateEntryInline(moduleName, settings) {
    return pluginConfig.updateEntryInline(moduleName, settings)
  }


  function toggleDnd() {
    if (!root.notificationService) return
    root.notificationService.setDoNotDisturb(!root.notificationService.doNotDisturb)
  }

  function toggleNotifications() {
    if (root.notificationService) root.notificationService.toggleHistoryPanel()
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

  OmarchyServices.PluginRegistry {
    id: pluginRegistry
    firstPartyDir: shellConfig.home + "/.config/quickshell/marcelof/plugins"
    shellConfigProvider: function() { return pluginConfig.config }
    shellConfigMutator: function(mutate) { pluginConfig.mutate(mutate) }
  }

  OmarchyServices.BarWidgetRegistry { id: barWidgetRegistry }

  OmarchyServices.ShellPluginConfig {
    id: pluginConfig
    path: shellConfig.home + "/.config/omarchy/shell.json"
  }

  OmarchyServices.PluginBarWidgetHost {
    pluginRegistry: pluginRegistry
    barWidgetRegistry: barWidgetRegistry
  }


  OmarchyServices.PluginServiceHost {
    id: pluginServiceHost
    pluginRegistry: pluginRegistry
    barWidgetRegistry: barWidgetRegistry
    shell: root
  }

  Connections {
    target: root.notificationService
    ignoreUnknownSignals: true
    function onDoNotDisturbChanged() {
      shellSettings.doNotDisturb = root.notificationService.doNotDisturb
    }
  }

  onNotificationServiceChanged: {
    if (root.notificationService)
      shellSettings.doNotDisturb = root.notificationService.doNotDisturb
  }

  Connections {
    target: pluginRegistry
    function onPluginsChanged() { root.refreshDynamicPluginEntries() }
  }

  Connections {
    target: shellSettings
    function onEnabledPluginIdsChanged() { root.refreshDynamicPluginEntries() }
  }

  QtObject {
    id: pluginHostObject
    function hide(pluginId) {
      if (String(pluginId) === shellConfig.pluginIds.wifiQr) { wifiQrOverlay.close(); return true }
      return root.hideShellMenu(pluginId)
    }
    function summon(pluginId, payloadJson) {
      if (String(pluginId) === shellConfig.pluginIds.wifiQr) { wifiQrOverlay.open(payloadJson || "{}"); return true }
      return root.openShellMenu(pluginId, payloadJson || "{}")
    }
    function toggle(pluginId, payloadJson) { return root.toggleShellMenu(pluginId, payloadJson || "{}") }
  }

  Instantiator {
    model: root.dynamicPluginEntries

    delegate: QtObject {
      id: dynamicPluginEntry
      required property var modelData
      readonly property string pluginId: modelData.id
      readonly property var manifest: modelData.manifest
      readonly property string sourceUrl: modelData.sourceUrl

      property Loader pluginLoader: Loader {
        source: dynamicPluginEntry.sourceUrl
        active: source !== "" && (dynamicPluginEntry.modelData.keepLoaded
          || root.openDynamicPluginId === dynamicPluginEntry.pluginId)
        asynchronous: true
        onLoaded: {
          if (!item) return
          if ("pluginPath" in item) item.pluginPath = dynamicPluginEntry.manifest.__sourceDir
          if ("targetScreen" in item) item.targetScreen = root.laptopScreen
          if ("shell" in item) item.shell = pluginHostObject
          if ("manifest" in item) item.manifest = dynamicPluginEntry.manifest
          if ("pluginRegistry" in item) item.pluginRegistry = pluginRegistry
          if ("barWidgetRegistry" in item) item.barWidgetRegistry = barWidgetRegistry
          if ("service" in item) item.service = pluginServiceHost.serviceFor(dynamicPluginEntry.pluginId)
          root.registerDynamicPluginLoader(dynamicPluginEntry.pluginId, this)
        }
        onStatusChanged: {
          if (status === Loader.Error) {
            console.warn("overlay plugin " + dynamicPluginEntry.pluginId + " failed to load: " + errorString())
            root.hideDynamicPlugin(dynamicPluginEntry.pluginId)
          }
        }
        Component.onDestruction: root.unregisterDynamicPluginLoader(dynamicPluginEntry.pluginId)
      }
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
    targetScreen: root.laptopScreen
    shell: pluginHostObject
    manifest: ({ id: shellConfig.pluginIds.wifiQr })
  }

  ImagePickerPlugin.ImagePicker {
    id: imagePicker
    targetScreen: root.laptopScreen
    pluginPath: shellConfig.home + "/.config/quickshell/marcelof/plugins/image-picker"
    applyAction: function(path) { root.setWallpaper(path) }
    openCurrentAction: function() { Quickshell.execDetached(shellConfig.wallpaper("open-current")) }
    openFolderAction: function() { Quickshell.execDetached(shellConfig.wallpaper("open-dir")) }
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
    root.showOsd("brightness", "", root.brightnessValue)
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

  component ActionButton: ShellActionButton { tooltipState: root }

  component TrayButton: ShellTrayButton { shellRoot: root }

  IpcHandler {
    target: "shell"

    function ping(): string { return "ok" }
    function listMenus(): string { return JSON.stringify(shellConfig.menuIds) }
    function listPlugins(): string {
      const plugins = []
      for (let id in shellConfig.menuRegistry)
        plugins.push({ id: id, name: id, kinds: ["menu"], enabled: true, active: true, canDisable: false, canEnable: false, firstParty: true, clonedFrom: "" })
      for (let pluginId in pluginRegistry.installedPlugins) {
        const manifest = pluginRegistry.installedPlugins[pluginId]
        const supported = pluginRegistry.supports(pluginId)
        plugins.push({
          id: pluginId,
          name: manifest.name,
          version: manifest.version,
          kinds: manifest.kinds,
          enabled: pluginRegistry.isEnabled(pluginId),
          active: root.dynamicPluginOpen(pluginId),
          canDisable: supported,
          canEnable: supported,
          firstParty: manifest.__isFirstParty === true,
          clonedFrom: ""
        })
      }
      plugins.sort((left, right) => left.id.localeCompare(right.id))
      return JSON.stringify(plugins)
    }
    function rescanPlugins(): string { pluginRegistry.rescan(); return "ok" }
    function setPluginEnabled(id: string, value: string): string {
      const normalized = String(value || "").toLowerCase()
      return root.setDynamicPluginEnabled(id, normalized === "true" || normalized === "1" || normalized === "on" || normalized === "yes")
    }
    function enablePlugin(id: string, placementJson: string): string { return root.setDynamicPluginEnabled(id, true) }
    function disablePlugin(id: string): string { return root.setDynamicPluginEnabled(id, false) }
    function listShellConfig(): string {
      return JSON.stringify({ menus: shellConfig.menuIds, aliases: shellConfig.menuAliases })
    }
    function dndState(): string {
      return root.notificationService && root.notificationService.doNotDisturb ? "on" : "off"
    }
    function isDnd(): string { return dndState() }
    function toggleDnd(): string { root.toggleDnd(); return dndState() }
    function setDnd(value: string): string {
      if (!root.notificationService) return "unavailable"
      const v = String(value || "").toLowerCase()
      root.notificationService.setDoNotDisturb(v === "true" || v === "1" || v === "on" || v === "yes")
      return dndState()
    }
    function toggle(id: string, payloadJson: string): string { return root.toggleShellMenu(id, payloadJson) ? "ok" : "unknown" }
    function hide(id: string): string { return root.hideShellMenu(id) ? "ok" : "unknown" }
    function summon(id: string, payloadJson: string): string { return root.openShellMenu(id, payloadJson) ? "ok" : "unknown" }
    function call(id: string, method: string, arg: string): string { return root.callDynamicPlugin(id, method, arg) }
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

  OmarchyBar.Bar {
    id: dynamicBar
    omarchyPath: shellConfig.home + "/.config/quickshell/marcelof"
    barWidgetRegistry: barWidgetRegistry
    barConfig: root.barConfig
    shell: root
    manifest: pluginRegistry.installedPlugins["omarchy.bar"] || ({ id: "omarchy.bar" })
  }


    ShellScreenPanel {
      anchorWindow: bar.primaryWindow
      shellRoot: root
      shellConfig: shellConfig
      visibilityAction: value => value ? root.openShellMenu(shellConfig.menuIds.screen, "{}") : root.hideShellMenu(shellConfig.menuIds.screen)
      panelOpen: root.screenPanelOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.screen)
      panelHeight: root.menuHeightFor(shellConfig.menuIds.screen)
    }


    ShellControlPanel {
      anchorWindow: bar.primaryWindow
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
      rootRowHeight: 70
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
      anchorWindow: bar.primaryWindow
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
      anchorWindow: bar.primaryWindow
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
      anchorWindow: bar.primaryWindow
      shellRoot: root
      shellSettings: shellSettings
      shellConfig: shellConfig
      refresh: dashboardService.workInboxHandle
      visibilityAction: value => value ? root.openShellMenu(shellConfig.menuIds.workInbox, "{}") : root.hideShellMenu(shellConfig.menuIds.workInbox)
      panelOpen: root.workInboxOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.workInbox)
      panelHeight: root.menuHeightFor(shellConfig.menuIds.workInbox)
    }


    ShellTrayManagePanel {
      anchorWindow: bar.primaryWindow
      shellRoot: root
      visibilityAction: value => value ? root.openShellMenu(shellConfig.menuIds.tray, "{}") : root.hideShellMenu(shellConfig.menuIds.tray)
      panelOpen: root.trayManageOpen
      panelWidth: root.menuWidthFor(shellConfig.menuIds.tray)
      panelHeight: Math.min(root.menuHeightFor(shellConfig.menuIds.tray), 84 + Math.max(1, root.allTrayItems.length) * (shellTheme.launcherRowHeight + shellTheme.spacingMd))
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



  ListModel { id: passModel }

  ShellMenuDataService {
    id: menuDataService
    shellRoot: root
    shellConfig: shellConfig
  }


  OmarchyServices.AppLibrary {
    id: appLibraryService
    shellRoot: root
    shellSettings: shellSettings
    shellConfig: shellConfig
  }

  IpcHandler {
    target: "launcher"

    function toggle() { root.toggleLauncher() }
    function open() { if (!root.shellMenuOpen("launcher")) root.toggleLauncher() }
    function show() { open() }
    function hide() { root.hideLauncher() }
    function state(): string { return root.shellMenuOpen("launcher") ? "open" : "closed" }
    function visibleById(entryId: string): string {
      var entry = appLibraryService.entryById(entryId)
      return entry && !appLibraryService.isHiddenEntry(entry) ? "visible" : "hidden"
    }
    function launchableById(entryId: string): string {
      var entry = appLibraryService.entryById(entryId)
      if (!entry) return "missing"
      return (entry.command && entry.command.length > 0) || typeof entry.execute === "function"
        ? "launchable" : "not-launchable"
    }
    function hiddenRoundTrip(entryId: string): string {
      var previous = root.launcherSmokeHiddenId
      var before = visibleById(entryId)
      root.launcherSmokeHiddenId = entryId
      var hidden = visibleById(entryId)
      root.launcherSmokeHiddenId = previous
      return before + "|" + hidden + "|" + visibleById(entryId)
    }
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
      anchorWindow: bar.primaryWindow
      shellRoot: root
      shellConfig: shellConfig
      visibilityAction: value => value ? root.openShellMenu(shellConfig.menuIds.power, "{}") : root.hideShellMenu(shellConfig.menuIds.power)
      panelOpen: root.powerMenuOpen
      panelHeight: root.menuHeightFor(shellConfig.menuIds.power)
    }

}
