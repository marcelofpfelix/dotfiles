import Quickshell
import QtQuick

QtObject {
  readonly property string home: Quickshell.env("HOME")
  readonly property string binDir: home + "/bin"
  readonly property string boardConfig: home + "/.config/board/board.toml"
  readonly property string stateDir: home + "/.local/state/quickshell/marcelof"
  readonly property string fileUrlPrefix: "file://"
  readonly property string textSeparator: " / "
  readonly property string boardQuickshellSurface: "quickshell-bar"
  readonly property string defaultWallpaperUrl: fileUrlPrefix + home + "/.local/share/backgrounds/bkg2.png"
  readonly property string defaultWebSearchSite: "google"
  readonly property string defaultPassUserKey: "username"
  readonly property string statusAction: "status"
  readonly property string hibernateAction: "hibernate"
  readonly property string networkWifiLabel: "Wi-Fi"
  readonly property string networkUnavailableText: "Network unavailable"
  readonly property string networkWifiToggleAction: "wifi-toggle"
  readonly property var networkTrayKeywords: ["nm-applet", "network"]

  readonly property var notificationToastPolicy: ({
    criticalUrgency: 2,
    importantApps: ["Slack", "Google Chrome", "Brave", "Calendar", "Meet", "Zoom", "desktop-notice", "desktop-reminder"],
    importantActions: ["Accept", "Answer", "Join", "Approve", "Review", "Done"],
    completeActions: ["Done", "Complete", "Completed", "Dismiss", "Archive", "Mark read"],
    importantPatterns: ["urgent", "critical", "failed", "failure", "error", "incident", "meeting", "call", "mention", "review requested"]
  })

  readonly property var batteryPolicy: ({
    hideFull: true,
    fullPercent: 100,
    warningPercent: 30,
    criticalPercent: 15,
    chargingIcon: "󰂄",
    chargingColor: "textMuted",
    fullColor: "textMuted",
    dischargingColor: "primary",
    warningColor: "warning",
    criticalColor: "error",
    icons: [
      { max: 10, icon: "󰁺" },
      { max: 20, icon: "󰁻" },
      { max: 30, icon: "󰁼" },
      { max: 40, icon: "󰁽" },
      { max: 50, icon: "󰁾" },
      { max: 60, icon: "󰁿" },
      { max: 70, icon: "󰂀" },
      { max: 80, icon: "󰂁" },
      { max: 90, icon: "󰂂" },
      { max: 100, icon: "󰁹" }
    ]
  })

  readonly property var states: ({
    hidden: "hidden",
    idle: "idle",
    unknown: "unknown",
    visible: "visible",
    yes: "yes"
  })

  readonly property var actions: ({
    copy: "copy",
    copyPath: "copy-path",
    down: "down",
    edit: "edit",
    openLast: "open-last",
    toggle: "toggle"
  })

  readonly property var labels: ({
    copy: "Copy",
    open: "Open",
    path: "Path"
  })

  readonly property var webSearchSites: [
    { key: defaultWebSearchSite, label: "Google", url: "https://www.google.com/search?q=" },
    { key: "youtube", label: "YouTube", url: "https://www.youtube.com/results?search_query=" },
    { key: "github", label: "GitHub", url: "https://github.com/search?q=org%3Ateam-telnyx+" },
    { key: "jira", label: "Jira", url: "https://telnyx.atlassian.net/secure/QuickSearch.jspa?searchString=" },
    { key: "guru", label: "Guru", url: "https://app.getguru.com/search?q=" },
    { key: "call", label: "Call", url: "http://search-tools.internal.telnyx.com/#!/session-lookup?sip_call_id=" }
  ]

  readonly property var menuIds: ({
    calendar: "calendar",
    clipboard: "clipboard",
    controls: "controls",
    emojis: "emojis",
    keybindings: "keybindings",
    launcher: "launcher",
    media: "media",
    network: "network",
    notifications: "notifications",
    passmenu: "passmenu",
    power: "power",
    screen: "screen",
    settings: "settings",
    tray: "tray",
    wallpaper: "wallpaper",
    wifiQr: "wifiqr",
    websearch: "websearch",
    workInbox: "work-inbox",
    personalDashboard: "personal-dashboard",
    rootMenu: "root-menu"
  })

  readonly property var pluginIds: ({
    wifiQr: "omarchy.wifiqr"
  })

  readonly property var menuAliases: ({
    menu: "root-menu",
    apps: "launcher",
    clip: "clipboard",
    passwords: "passmenu",
    web: "websearch",
    keys: "keybindings",
    "tray-manage": "tray",
    audio: "media",
    wall: "wallpaper",
    clock: "calendar",
    time: "calendar",
    work: "work-inbox",
    workInbox: "work-inbox",
    dashboard: "personal-dashboard",
    personal: "personal-dashboard",
    personalDashboard: "personal-dashboard",
    net: "network",
    session: "power",
    inhibit: "stay-awake"
  })

  readonly property var menuRegistry: ({
    "root-menu": { toggle: "toggleRootMenu", hide: "hideRootMenu" },
    clipboard: { openProperty: "clipboardOpen", toggle: "toggleClipboard" },
    passmenu: { openProperty: "passMenuOpen", toggle: "togglePassmenu" },
    websearch: { openProperty: "webSearchOpen", toggle: "toggleDefaultWebSearch" },
    keybindings: { openProperty: "keybindingsOpen", refresh: "refreshKeybindings" },
    tray: { openProperty: "trayManageOpen" },
    controls: { openProperty: "controlPanelOpen", refresh: "refreshControls" },
    emojis: { toggle: "toggleEmojis", hide: "hideEmojis" },
    screen: { openProperty: "screenPanelOpen", refresh: "refreshScreenState" },
    calendar: { openProperty: "calendarOpen", refresh: "refreshCalendar" },
    "work-inbox": { openProperty: "workInboxOpen", refresh: "refreshWorkInbox" },
    "personal-dashboard": { openProperty: "personalDashboardOpen", refresh: "refreshPersonalDashboard" },
    settings: { openProperty: "settingsOpen" },
    notifications: { openProperty: "notificationCenterOpen" },
    power: { openProperty: "powerMenuOpen", refresh: "refreshPower", hide: "hidePowerMenu" }
  })

  readonly property var actionRegistry: ({
    dnd: "toggleDnd",
    "stay-awake": "toggleIdleInhibit"
  })

  readonly property var menuSizes: ({
    default: { width: 640, height: 560 },
    compact: { width: 640, height: 360 },
    tall: { width: 640, height: 720 },
    work: { width: 640, height: 420 },
    dashboard: { width: 640, height: 460 },
    launcher: { width: 720, height: 726, denseHeight: 672 },
    clipboard: { width: 640, height: 500, denseHeight: 480 },
    passmenu: { width: 640, height: 544, denseHeight: 500 },
    websearch: { width: 640, height: 112 },
    wallpaper: { width: 640, height: 560, compactHeight: 360 },
    screen: { width: 640, height: 460 },
    media: { width: 640, height: 260 },
    controls: { width: 720, height: 960 },
    settings: { width: 640, height: 420 },
    calendar: { width: 640, height: 720 },
    "work-inbox": { width: 640, height: 320 },
    "personal-dashboard": { width: 640, height: 240 },
    "root-menu": { width: 440, height: 780 },
    notifications: { width: 640, height: 420 },
    keybindings: { width: 640, height: 560 },
    network: { width: 640, height: 320 },
    power: { width: 640, height: 360 },
    tray: { width: 640, height: 420 }
  })

  readonly property var controlMenuRows: [
    [
      { icon: "󰀻", label: "Apps", tooltip: "App launcher", action: "apps" },
      { icon: "󰇧", label: "Web", tooltip: "Web search", action: "web" },
      { icon: "󰌌", label: "Keys", tooltip: "Keybindings", action: "keys" },
      { icon: "󰅇", label: "Clip", tooltip: "Clipboard history", action: "clipboard" }
    ],
    [
      { icon: "󰸉", label: "Wall", tooltip: "Wallpaper", action: "wallpaper" },
      { icon: "󰍹", label: "Screen", tooltip: "Screen tools", action: "screen" },
      { icon: "󰕾", label: "Media", tooltip: "Audio and media controls", action: "media" },
      { icon: "󰖩", label: "Net", tooltip: "Network panel", action: "network" }
    ],
    [
      { icon: "󰥔", label: "Time", tooltip: "Calendar and time", action: "calendar" },
      { icon: "󰻞", label: "Work", tooltip: "Unread work inbox", action: "work" },
      { icon: "󰡨", label: "Dash", tooltip: "Personal dashboard", action: "dashboard" },
      { icon: "󰂚", label: "Notes", tooltip: "Notifications", action: "notifications" }
    ],
    [
      { icon: "󰒓", label: "Set", tooltip: "Shell settings", action: "settings" },
      { icon: "󱊖", label: "Tray", tooltip: "Tray manager", action: "tray" },
      { icon: "⏻", label: "System", tooltip: "Session and power actions", action: "power" }
    ]
  ]

  readonly property var primaryColorRows: [
    { label: "Lav", color: "#b4befe" },
    { label: "Blue", color: "#89b4fa" },
    { label: "Green", color: "#a6e3a1" },
    { label: "Rose", color: "#f5c2e7" }
  ]

  readonly property var settingsMenuRows: [
    { icon: "󰀻", label: "Apps", tooltip: "Open app launcher", action: "apps" },
    { icon: "󰂚", label: "Notes", tooltip: "Open notifications", action: "notifications" },
    { icon: "󰒓", label: "Controls", tooltip: "Open controls", action: "controls" }
  ]

  readonly property var sessionActionRows: [
    [
      { icon: "󰅖", label: "Cancel", tooltip: "Close this menu", action: "hide" },
      { icon: "󰌾", label: "Lock", tooltip: "Lock session", action: "lock" },
      { icon: "󰒲", label: "Suspend", tooltip: "Suspend system", action: "suspend" }
    ],
    [
      { icon: "󰒓", label: "Hibernate", tooltip: "Hibernate system", action: hibernateAction },
      { icon: "󰜉", label: "Reboot", tooltip: "Reboot system", action: "reboot" },
      { icon: "⏻", label: "Shutdown", tooltip: "Power off system", action: "poweroff" }
    ]
  ]

  readonly property var exitSessionAction: ({ icon: "󰍃", label: "Exit Hyprland", tooltip: "Exit the current Hyprland session", action: "exit" })
  readonly property var logoutSessionAction: ({ icon: exitSessionAction.icon, label: "Logout", tooltip: "End the current login session", action: "logout" })

  function sessionAction(action) {
    for (let row of sessionActionRows)
      for (let item of row)
        if (item.action === action) return item
    if (logoutSessionAction.action === action) return logoutSessionAction
    if (exitSessionAction.action === action) return exitSessionAction
    return null
  }

  readonly property var personalDashboardSurfaces: [boardQuickshellSurface, "personal.today", "personal.money", "personal.health", "personal.habits"]
  readonly property var calendarWeekdays: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
}
