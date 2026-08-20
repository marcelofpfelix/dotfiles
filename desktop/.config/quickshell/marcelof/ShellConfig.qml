import Quickshell
import QtQuick

QtObject {
  readonly property QtObject configData: ShellConfigData {}
  readonly property string home: configData.home
  readonly property string binDir: configData.binDir
  readonly property string boardConfig: configData.boardConfig
  readonly property string stateDir: configData.stateDir
  readonly property string defaultWallpaperUrl: configData.defaultWallpaperUrl
  readonly property string defaultWebSearchSite: configData.defaultWebSearchSite
  readonly property string defaultPassUserKey: configData.defaultPassUserKey
  readonly property string fileUrlPrefix: configData.fileUrlPrefix
  readonly property string textSeparator: configData.textSeparator
  readonly property string boardQuickshellSurface: configData.boardQuickshellSurface
  readonly property string statusAction: configData.statusAction
  readonly property string hibernateAction: configData.hibernateAction
  readonly property string networkWifiLabel: configData.networkWifiLabel
  readonly property string networkUnavailableText: configData.networkUnavailableText
  readonly property string networkWifiToggleAction: configData.networkWifiToggleAction
  readonly property var networkTrayKeywords: configData.networkTrayKeywords
  readonly property var webSearchSites: configData.webSearchSites
  readonly property var batteryPolicy: configData.batteryPolicy
  readonly property var notificationToastPolicy: configData.notificationToastPolicy
  readonly property var menuIds: configData.menuIds
  readonly property var pluginIds: configData.pluginIds
  readonly property var menuAliases: configData.menuAliases
  readonly property var menuRegistry: configData.menuRegistry
  readonly property var actionRegistry: configData.actionRegistry
  readonly property var labels: configData.labels
  readonly property var actions: configData.actions
  readonly property var states: configData.states

  function bin(name) { return binDir + "/" + name }
  function fileUrl(path) { return fileUrlPrefix + path }
  function cleanEnv(name) { return ["hypr-clean-env", name] }
  function qs(action) { return [bin("qbar"), action] }
  function screenshot(action) { return [bin("screenshot-wayland"), action] }
  function browser(url) { return [bin("chrome-wayland"), url] }
  function audio(action) { return [bin("audioctl"), action] }
  function network(action) { return [bin("network-status"), action] }
  function isWifiStatus(text) { return String(text || "").indexOf(networkWifiLabel) === 0 }
  function isNetworkTrayText(text) {
    const value = String(text || "").toLowerCase()
    for (let i = 0; i < networkTrayKeywords.length; i++) {
      if (value.indexOf(networkTrayKeywords[i]) !== -1)
        return true
    }
    return false
  }
  function wallpaper(action, path) { return path ? [bin("wallpaper-wayland"), action, path] : [bin("wallpaper-wayland"), action] }
  function networkEditor() { return cleanEnv("nm-connection-editor") }
  function volumeMixer() { return cleanEnv("pavucontrol") }
  function shellQuote(value) { return "'" + String(value).replace(/'/g, "'\"'\"'") + "'" }
  function hyprStateWatch() { return [bin("hypr-state"), "watch"] }
  function boardCommand(args) { return ["board", "--config", boardConfig].concat(args) }
  function boardQuickshellBar() { return ["env", "BAR_COLOR_FORMAT=quickshell"].concat(boardCommand(["render", "--watch", "quickshell", boardQuickshellSurface])) }
  function boardText(surface) { return boardCommand(["render", "text", surface]) }
  function boardAction(action) { return boardCommand(["action", action]) }
  function weather(location, mode) { return ["sh", "-c", "WEATHER_LOCATION=" + shellQuote(location) + " " + bin("check-weather") + (mode ? " " + mode : "")] }
  function brightnessPercent() { return ["sh", "-c", "brightnessctl -m 2>/dev/null | awk -F, '{print $4}' || printf -- --"] }
  function portalStatus() { return ["sh", "-c", "printf 'hyprland '; systemctl --user is-active xdg-desktop-portal-hyprland.service 2>/dev/null || printf unavailable; printf ', portal '; systemctl --user is-active xdg-desktop-portal.service 2>/dev/null || printf unavailable"] }
  function launcherMruLoad() { return ["sh", "-c", "cat \"${XDG_CACHE_HOME:-$HOME/.cache}/quickshell/marcelof/launcher-mru.txt\" 2>/dev/null || true"] }
  function launcherMruSave(cache) { return ["sh", "-c", "dir=${XDG_CACHE_HOME:-$HOME/.cache}/quickshell/marcelof; file=$dir/launcher-mru.txt; tmp=$file.tmp; mkdir -p \"$dir\"; printf %s " + shellQuote(cache) + " > \"$tmp\" && mv \"$tmp\" \"$file\""] }
  function cliphistList() { return ["sh", "-c", "cliphist list 2>/dev/null"] }
  function cliphistDecode(entry) { return ["sh", "-c", "printf %s " + shellQuote(entry) + " | cliphist decode | wl-copy"] }
  function passList(backend) { return ["sh", "-c", shellQuote(backend) + " ls --flat 2>/dev/null"] }
  function passAction(mode, userKey, backend, entry) { return ["passmenu-action", mode, userKey, backend, entry] }
  function gtkLaunch(id) {
    return ["sh", "-c", "id=" + shellQuote(id) + "; base=${id##*/}; stem=${base%.desktop}; gtk-launch \"$id\" 2>/dev/null || gtk-launch \"${id%.desktop}\" 2>/dev/null || gtk-launch \"$id.desktop\" 2>/dev/null || gtk-launch \"$base\" 2>/dev/null || gtk-launch \"$stem\" 2>/dev/null || gtk-launch \"$stem.desktop\""]
  }
  function screenRecord(action) { return [bin("screen-record-wayland"), action] }
  function notificationFocus(desktopEntry, app) { return [bin("notification-focus-app"), desktopEntry || "", app || ""] }
  function playerctl(action) { return ["playerctl", "--all-players", action] }
  function pactl(args) { return ["pactl"].concat(args) }
  function sinkInputAction(id, action) {
    if (!id)
      return []
    if (action === "mute")
      return pactl(["set-sink-input-mute", String(id), "toggle"])
    if (action === "up")
      return pactl(["set-sink-input-volume", String(id), "+5%"])
    if (action === "down")
      return pactl(["set-sink-input-volume", String(id), "-5%"])
    return []
  }
  function sinkInputVolume(id, value) { return pactl(["set-sink-input-volume", String(id), Math.round(value * 100) + "%"]) }
  function powerProfile(profile) { return [bin("power-status"), "set-profile", profile] }
  function inhibit(action) { return [bin("desktop-inhibit"), action] }
  function brightness(action) { return [bin("bri"), action] }
  function keyboardBrightness(action) { return [bin("kbd-brightness"), action] }
  function locker() { return ["sh", "-c", "command -v hyprlock >/dev/null 2>&1 && exec hyprlock; command -v swaylock >/dev/null 2>&1 && exec swaylock -f; loginctl lock-session || notify-send Hyprland \"No Wayland locker found\""] }
  function systemctl(action) { return ["systemctl", action] }
  function suspend() { return systemctl("suspend") }
  function hibernate() { return systemctl("hibernate") }
  function hibernateCapability() { return ["busctl", "--system", "call", "org.freedesktop.login1", "/org/freedesktop/login1", "org.freedesktop.login1.Manager", "CanHibernate"] }
  function logout() {
    const session = Quickshell.env("XDG_SESSION_ID")
    return session ? ["loginctl", "terminate-session", session] : exitHyprland()
  }
  function reboot() { return systemctl("reboot") }
  function poweroff() { return systemctl("poweroff") }
  function exitHyprland() { return ["hyprctl", "dispatch", "exit"] }
  function sessionCommand(action) {
    switch (action) {
    case hibernateAction: return hibernate()
    case "logout": return logout()
    case "reboot": return reboot()
    case "poweroff": return poweroff()
    case "exit": return exitHyprland()
    }
    return []
  }
  function ensureStateDir() { return ["mkdir", "-p", stateDir] }
  function openUrl(url) {
    const chrome = shellQuote(bin("chrome-wayland"))
    const target = shellQuote(url)
    return ["sh", "-c", "[ -x " + chrome + " ] && " + chrome + " " + target + " || exec xdg-open " + target]
  }
  function calculator() { return ["sh", "-c", "command -v gnome-calculator >/dev/null 2>&1 && exec gnome-calculator || notify-send Quickshell 'gnome-calculator missing'"] }
  function slack() { return [bin("slack-wayland")] }
  function terminal() { return [bin("hypr-term")] }
  function hyprTermTaskNext() { return [bin("hypr-term"), "task", "next"] }
  function checkTimePanel() { return [bin("check-time-panel")] }
  function checkTodoPanel() { return [bin("check-todo-panel")] }
  function calendarAgendaStatus() { return [bin("calendar-agenda-status")] }
  function pomodoroStatus() { return [bin("pomodoroctl"), statusAction] }
  function pomodoro(action, extra) {
    const command = [bin("pomodoroctl"), action]
    if (extra)
      command.push(extra)
    return command
  }
  function reminderList() { return [bin("reminderctl"), "list"] }
  function reminderClearAll() { return [bin("reminderctl"), "clear", "all"] }
  function workInboxStatus() { return [bin("work-inbox-status")] }
  function screenRecordStatus() { return screenRecord(statusAction) }
  function keyboardBrightnessStatus() { return keyboardBrightness(statusAction) }
  function powerStatus() { return [bin("power-status"), statusAction] }
  function fanStatus() { return [bin("fan-status")] }
  function inhibitStatus() { return inhibit(statusAction) }
  function privacyStatus() { return [bin("desktop-privacy-status"), statusAction] }

function menuSize(id, dense) {
  const sizes = configData.menuSizes
  const fallback = sizes.default
  const size = sizes[id] || fallback
  return {
    width: size.width || fallback.width,
    height: dense && size.denseHeight ? size.denseHeight : (size.height || fallback.height),
    compactHeight: size.compactHeight || (sizes.compact ? sizes.compact.height : fallback.height)
  }
}

  readonly property var menuSizes: configData.menuSizes
  readonly property var controlMenuRows: configData.controlMenuRows
  readonly property var settingsMenuRows: configData.settingsMenuRows
  readonly property var primaryColorRows: configData.primaryColorRows
  readonly property var sessionActionRows: configData.sessionActionRows
  readonly property var exitSessionAction: configData.exitSessionAction
  readonly property var logoutSessionAction: configData.logoutSessionAction
  function sessionAction(action) { return configData.sessionAction(action) }

  readonly property var personalDashboardSurfaces: configData.personalDashboardSurfaces
  readonly property var calendarWeekdays: configData.calendarWeekdays
}
