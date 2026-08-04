import Quickshell
import QtQuick

PopupWindow {
  id: tooltipWindow

  readonly property QtObject theme: ShellTheme {}

  required property var anchorWindow
  property string text: ""
  property real anchorX: 0
  property real anchorY: 0

  visible: text.length > 0
  color: theme.transparent
  implicitWidth: tooltipBubble.implicitWidth
  implicitHeight: tooltipBubble.implicitHeight
  anchor.window: anchorWindow
  anchor.rect.x: anchorX
  anchor.rect.y: anchorY

  Rectangle {
    id: tooltipBubble
    radius: theme.radiusSmall
    color: theme.surfaceHigh
    border.color: theme.borderStrong
    border.width: 1
    implicitWidth: tooltipLabel.implicitWidth + theme.tooltipPaddingX * 2
    implicitHeight: tooltipLabel.implicitHeight + theme.tooltipPaddingY * 2

    ShellText {
      id: tooltipLabel
      anchors.centerIn: parent
      role: "title"
      text: tooltipWindow.text
    }
  }
}
