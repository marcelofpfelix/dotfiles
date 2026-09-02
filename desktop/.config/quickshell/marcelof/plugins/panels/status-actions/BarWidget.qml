import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "marcelof.status-actions"

  readonly property string kind: String(setting("kind", "clock"))
  readonly property var host: bar && bar.shell ? bar.shell : null
  readonly property var notificationService: host ? host.notificationService : null
  readonly property int notificationCount: notificationService ? notificationService.notificationCount : 0
  readonly property bool dnd: notificationService ? notificationService.doNotDisturb : false
  readonly property string label: {
    if (!host) return ""
    if (kind === "clock") return String.fromCodePoint(0xF0954) + " " + host.lisbonClockText
    if (kind === "notifications") return dnd ? String.fromCodePoint(0xF009B) : (notificationCount > 0 ? String.fromCodePoint(0xF009A) + " " + notificationCount : String.fromCodePoint(0xF009C))
    if (kind === "privacy") return host.privacyBarText()
    if (kind === "audioctl") return host.audioIconText
    return ""
  }

  function iconSource(value) {
    var icon = String(value || "")
    if (!icon) return ""
    if (icon.indexOf("file://") === 0 || icon.indexOf("image://") === 0) return icon
    if (icon.charAt(0) === "/") return Util.fileUrl(icon)
    return Quickshell.iconPath(icon, true)
  }

  implicitWidth: content.implicitWidth
  implicitHeight: content.implicitHeight
  visible: label.length > 0 || kind === "notifications"

  Row {
    id: content
    spacing: root.kind === "notifications" ? Style.space(4) : 0

    Repeater {
      model: root.kind === "notifications" && root.notificationService
        ? root.notificationService.unreadAppsModel : null

      delegate: WidgetButton {
        id: appButton
        required property string app
        required property string appIcon
        required property int count

        bar: root.bar
        text: ""
        labelVisible: false
        hasVisualContent: true
        fixedWidth: indicator.implicitWidth + Style.space(16)
        tooltipText: app + ": " + count + " unread"

        Row {
          id: indicator
          anchors.centerIn: parent
          spacing: Style.space(4)

          Item {
            width: Style.space(16)
            height: Style.space(16)

            Image {
              id: iconImage
              anchors.fill: parent
              source: root.iconSource(appButton.appIcon)
              fillMode: Image.PreserveAspectFit
              sourceSize.width: width * Screen.devicePixelRatio
              sourceSize.height: height * Screen.devicePixelRatio
            }

            Text {
              anchors.centerIn: parent
              visible: iconImage.status !== Image.Ready
              text: appButton.app.length > 0 ? appButton.app.charAt(0).toUpperCase() : "N"
              color: root.bar ? root.bar.barForeground : Color.foreground
              font.family: root.bar ? root.bar.fontFamily : Style.font.family
              font.pixelSize: Style.font.bodySmall
              font.bold: true
            }
          }

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: String(appButton.count)
            color: Color.accent
            font.family: root.bar ? root.bar.fontFamily : Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }
        }

        onPressed: if (root.notificationService) root.notificationService.openHistoryPanel(app)
      }
    }

    WidgetButton {
      id: button
      bar: root.bar
      text: root.label
      tooltipText: root.kind === "notifications" ? "Notifications" : ""
      foreground: root.kind === "notifications" && root.dnd ? Color.accent : (root.bar ? root.bar.barForeground : Color.foreground)

      onPressed: function(mouseButton) {
        if (!root.host) return
        if (root.kind === "clock") root.host.toggleCalendar()
        else if (root.kind === "notifications") {
          if (mouseButton === Qt.RightButton) root.notificationService.clearAll()
          else root.host.toggleNotifications()
        }
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
}
