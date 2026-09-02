import QtQuick
// Local adaptation: registry-owned panels delegate transitions instead of
// breaking their externally-owned open-state binding.
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
