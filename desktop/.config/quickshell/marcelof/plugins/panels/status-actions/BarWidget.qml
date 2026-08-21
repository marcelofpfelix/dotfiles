import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "marcelof.status-actions"

  readonly property string kind: String(setting("kind", "clock"))
  readonly property var host: bar && bar.shell ? bar.shell : null
  readonly property int notificationCount: host && host.notificationService ? host.notificationService.popupModel.count : 0
  readonly property bool dnd: host && host.notificationService ? host.notificationService.doNotDisturb : false
  readonly property string label: {
    if (!host) return ""
    if (kind === "clock") return String.fromCodePoint(0xF0954) + " " + host.lisbonClockText
    if (kind === "notifications") return dnd ? String.fromCodePoint(0xF009B) : (notificationCount > 0 ? String.fromCodePoint(0xF009A) + " " + notificationCount : String.fromCodePoint(0xF009C))
    if (kind === "privacy") return host.privacyBarText()
    if (kind === "audioctl") return host.audioIconText
    return ""
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight
  visible: label.length > 0 || kind === "notifications"

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.label
    foreground: root.kind === "notifications" && root.dnd ? Color.accent : (root.bar ? root.bar.barForeground : Color.foreground)

    onPressed: function(mouseButton) {
      if (!root.host) return
      if (root.kind === "clock") root.host.toggleCalendar()
      else if (root.kind === "notifications") root.host.toggleNotifications()
      else if (root.kind === "privacy") {
        if (mouseButton === Qt.RightButton) root.host.toggleDnd()
        else root.host.toggleScreenPanel()
      } else if (root.kind === "audioctl") {
        if (mouseButton === Qt.RightButton) root.host.toggleShellMenu("marcelof.media-controls", "{}")
        else root.host.runAudioctl("play-pause-all")
      }
    }
  }
}
