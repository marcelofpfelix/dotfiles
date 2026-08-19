import Quickshell
import QtQuick
import qs.Ui as OmarchyUi

PopupWindow {
  id: popupWindow

  readonly property QtObject theme: ShellTheme {}
  property alias controller: panelController

  required property var anchorWindow
  property bool panelOpen: false
  property int panelWidth: 640
  property int panelHeight: 560
  property int edgeMargin: 8
  property int rightOffset: 10
  property int topOffset: 6
  property var visibilityAction: null

  function setOpen(value) {
    if (visibilityAction)
      visibilityAction(value)
    else
      panelOpen = value
  }
  function open() { panelController.show() }
  function show() { panelController.show() }
  function close() { panelController.hide() }
  function hide() { panelController.hide() }
  function toggle() { panelController.toggle() }

  OmarchyUi.PanelController {
    id: panelController
    open: popupWindow.panelOpen
    transitionAction: value => popupWindow.setOpen(value)
  }

  visible: panelOpen
  color: theme.transparent
  implicitWidth: panelWidth
  implicitHeight: panelHeight
  anchor.window: anchorWindow
  anchor.rect.x: Math.max(edgeMargin, anchorWindow.width - implicitWidth - rightOffset)
  anchor.rect.y: anchorWindow.height + topOffset
}
