import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import qs.Ui as OmarchyUi

FloatingWindow {
  id: floatingPopup

  readonly property QtObject theme: ShellTheme {}
  property alias controller: panelController

  required property var shellRoot
  property bool panelOpen: false
  property int panelWidth: 720
  property int panelHeight: 560

  property var closeAction: null

  function setOpen(value) {
    if (value) {
      panelOpen = true
      return
    }
    if (closeAction)
      closeAction()
    else
      panelOpen = false
  }
  function open() { panelController.show() }
  function close() { panelController.hide() }
  function show() { panelController.show() }
  function hide() { panelController.hide() }
  function toggle() { panelController.toggle() }

  OmarchyUi.PanelController {
    id: panelController
    open: floatingPopup.panelOpen
    transitionAction: value => floatingPopup.setOpen(value)
  }

  screen: shellRoot.laptopScreen
  visible: panelOpen
  width: panelWidth
  height: panelHeight
  implicitWidth: panelWidth
  implicitHeight: panelHeight
  color: theme.transparent

  HyprlandFocusGrab {
    active: floatingPopup.visible
    windows: [floatingPopup]
    onCleared: floatingPopup.close()
  }
}
