import QtQuick
import QtQuick.Layouts

ListView {
  id: pickerList

  readonly property QtObject theme: ShellTheme {}

  Layout.fillWidth: true
  Layout.fillHeight: true
  visible: count > 0
  clip: true
  spacing: theme.spacingSm
  currentIndex: -1

  function selectRelative(delta) {
    if (count <= 0)
      return
    if (currentIndex < 0)
      currentIndex = delta > 0 ? 0 : count - 1
    else
      currentIndex = (currentIndex + delta + count) % count
    positionCurrent()
  }

  function positionCurrent() {
    if (count > 0 && currentIndex >= 0)
      positionViewAtIndex(currentIndex, ListView.Contain)
  }
}
