import QtQuick
// Copied from Omarchy Quattro shell/Ui/PanelController.qml at f32ebbd.
// Adapted with transitionAction so registry-owned panel state keeps its binding.
// Stores the open state for a shell panel. Panel owns the public lifecycle
// methods and IPC wiring; this object only keeps state separate from the
// panel implementation's own properties.
//
// Usage:
//   PanelController { id: panelController }
QtObject {
  id: root

  property bool open: false
  property var transitionAction: null

  function setOpen(value) {
    if (transitionAction)
      transitionAction(value)
    else
      open = value
  }

  function toggle() { setOpen(!open) }
  function show() { if (!open) setOpen(true) }
  function hide() { setOpen(false) }
}
