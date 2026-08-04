import Quickshell
import QtQuick

PopupWindow {
  readonly property QtObject theme: ShellTheme {}

  required property var anchorWindow
  property bool panelOpen: false
  property int panelWidth: 640
  property int panelHeight: 560
  property int edgeMargin: 8
  property int rightOffset: 10
  property int topOffset: 6

  visible: panelOpen
  color: theme.transparent
  implicitWidth: panelWidth
  implicitHeight: panelHeight
  anchor.window: anchorWindow
  anchor.rect.x: Math.max(edgeMargin, anchorWindow.width - implicitWidth - rightOffset)
  anchor.rect.y: anchorWindow.height + topOffset
}
