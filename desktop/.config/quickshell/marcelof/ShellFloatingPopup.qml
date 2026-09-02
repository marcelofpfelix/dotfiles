import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

FloatingWindow {
  id: floatingPopup

  readonly property QtObject theme: ShellTheme {}

  required property var shellRoot
  property bool panelOpen: false
  property int panelWidth: 720
  property int panelHeight: 560

  property var closeAction: null

  function open() { panelOpen = true }
  function close() {
    if (closeAction)
      closeAction()
    else
      panelOpen = false
  }
  function toggle() { panelOpen ? close() : open() }

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
