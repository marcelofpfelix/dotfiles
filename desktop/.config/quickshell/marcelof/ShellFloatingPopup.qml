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

  signal focusCleared()

  screen: shellRoot.laptopScreen
  visible: panelOpen
  implicitWidth: panelWidth
  implicitHeight: panelHeight
  color: theme.transparent

  HyprlandFocusGrab {
    active: floatingPopup.visible
    windows: [floatingPopup]
    onCleared: floatingPopup.focusCleared()
  }
}
