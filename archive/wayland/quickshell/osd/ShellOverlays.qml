import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
  id: overlays

  readonly property QtObject theme: ShellTheme {}

  required property var anchorWindow
  required property var shellRoot

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

  TextMetrics {
    id: osdTextMetrics
    font.family: theme.fontFamily
    font.styleName: theme.fontStyle
    font.pixelSize: theme.fontXl
    text: overlays.osdBodyText
  }

  PopupWindow {
    visible: overlays.osdOpen
    color: theme.transparent
    implicitWidth: Math.min(520, Math.max(280, Math.ceil(osdTextMetrics.advanceWidth) + theme.fontIcon + theme.spacingXl + theme.spacingXxl * 2))
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

}
