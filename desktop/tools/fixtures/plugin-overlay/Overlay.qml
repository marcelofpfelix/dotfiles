import QtQuick
import Quickshell
import Quickshell.Wayland

Item {
  id: root

  property var targetScreen: null
  property var shell: null
  property var manifest: null
  property bool opened: false

  function open(payloadJson) { opened = true }
  function close() { opened = false }
  function dismiss() {
    close()
    if (shell) shell.hide(manifest.id)
  }

  PanelWindow {
    screen: root.targetScreen
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "local-overlay-smoke"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Rectangle {
      anchors.fill: parent
      color: "#66000000"
      MouseArea { anchors.fill: parent; onClicked: root.dismiss() }
    }

    Rectangle {
      width: 320
      height: 120
      anchors.centerIn: parent
      radius: 6
      color: "#1e1e2e"
      border.color: "#b4befe"

      Text {
        anchors.centerIn: parent
        text: "Overlay plugin loaded"
        color: "#cdd6f4"
        font.pixelSize: 18
      }

      MouseArea { anchors.fill: parent; onClicked: {} }
    }
  }
}
