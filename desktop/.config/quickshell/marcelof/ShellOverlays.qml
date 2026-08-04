import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
  id: overlays

  readonly property QtObject theme: ShellTheme {}

  required property var anchorWindow
  required property var shellRoot
  required property var shellSettings

  property bool osdOpen: false
  property string osdIconText: ""
  property string osdBodyText: ""
  property string osdPendingKind: ""

  function show(icon, text) {
    overlays.osdIconText = icon
    overlays.osdBodyText = text
    overlays.osdOpen = true
    osdTimer.restart()
  }

  function showVolume(audio) {
    if (!audio) {
      overlays.show("", "Audio unavailable")
      return
    }
    overlays.show(audio.muted ? "󰝟" : "", (audio.muted ? "Muted " : "Volume ") + Math.round(audio.volume * 100) + "%")
  }

  function showBrightnessSoon() {
    overlays.osdPendingKind = "brightness"
    osdRefreshLater.restart()
  }

  function showKbdSoon() {
    overlays.osdPendingKind = "kbd"
    osdRefreshLater.restart()
  }

  Timer {
    id: osdTimer
    interval: 1300
    repeat: false
    onTriggered: overlays.osdOpen = false
  }

  Timer {
    id: osdRefreshLater
    interval: 180
    repeat: false
    onTriggered: {
      if (overlays.osdPendingKind === "brightness")
        overlays.show("󰃠", "Brightness " + overlays.shellRoot.brightnessText)
      else if (overlays.osdPendingKind === "kbd")
        overlays.show("󰌌", overlays.shellRoot.kbdBrightnessText.length > 0 ? overlays.shellRoot.kbdBrightnessText : "Keyboard brightness")
      overlays.osdPendingKind = ""
    }
  }

  PopupWindow {
    visible: overlays.osdOpen
    color: theme.transparent
    implicitWidth: 280
    implicitHeight: 68
    anchor.window: overlays.anchorWindow
    anchor.rect.x: Math.max(8, Math.round((overlays.anchorWindow.width - implicitWidth) / 2))
    anchor.rect.y: overlays.anchorWindow.height + 18
    Rectangle {
      anchors.fill: parent
      radius: theme.radius
      color: theme.surface
      border.color: theme.primary
      border.width: 1
      RowLayout {
        anchors.fill: parent
        anchors.margins: theme.spacingXxl
        spacing: theme.spacingXl
        Text { color: theme.warning; font.family: theme.fontFamily; font.pixelSize: theme.fontIcon; text: overlays.osdIconText }
        Text { Layout.fillWidth: true; color: theme.text; elide: Text.ElideRight; font.family: theme.fontFamily; font.styleName: theme.fontStyle; font.pixelSize: theme.fontXl; text: overlays.osdBodyText }
      }
    }
  }

  function restartToastTimer() {
    notificationToastTimer.restart()
  }

  Timer {
    id: notificationToastTimer
    interval: 5000
    repeat: false
    onTriggered: overlays.shellRoot.notificationToastOpen = false
  }


  PopupWindow {
    visible: overlays.shellRoot.notificationToastOpen && !overlays.shellRoot.notificationCenterOpen && !overlays.shellSettings.doNotDisturb
    color: theme.transparent
    implicitWidth: 380
    implicitHeight: toastCard.implicitHeight
    anchor.window: overlays.anchorWindow
    anchor.rect.x: Math.max(8, overlays.anchorWindow.width - implicitWidth - 10)
    anchor.rect.y: overlays.anchorWindow.height + 6

    Rectangle {
      id: toastCard
      width: parent.width
      implicitHeight: Math.max(96, toastColumn.implicitHeight + 20)
      radius: theme.radius
      color: theme.surface
      border.color: theme.primary
      border.width: 1

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          overlays.shellRoot.notificationToastOpen = false
          overlays.shellRoot.notificationCenterOpen = true
        }
      }

      ColumnLayout {
        id: toastColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: theme.paddingMd
        spacing: theme.spacingSm

        RowLayout {
          Layout.fillWidth: true
          spacing: theme.spacingLg
          Text { color: theme.warning; font.family: theme.fontFamily; font.pixelSize: theme.fontXl; text: "󰂚" }
          ShellText { Layout.fillWidth: true; role: "strong"; elide: Text.ElideRight; text: overlays.shellRoot.notificationToastApp }
          ShellText { role: "subtle"; text: "now" }
        }

        Text {
          Layout.fillWidth: true
          color: theme.text
          elide: Text.ElideNone
          font.family: theme.fontFamily
          font.styleName: theme.fontStyle
          font.pixelSize: theme.fontLg
          maximumLineCount: 2
          wrapMode: Text.Wrap
          text: overlays.shellRoot.notificationToastSummary
        }

        Text {
          Layout.fillWidth: true
          visible: overlays.shellRoot.notificationToastBody.length > 0
          color: theme.textSoft
          elide: Text.ElideNone
          font.family: theme.fontFamily
          font.pixelSize: theme.fontMd
          maximumLineCount: 4
          wrapMode: Text.Wrap
          text: overlays.shellRoot.notificationToastBody
        }
      }
    }
  }
}
