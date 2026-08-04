import QtQuick

Item {
  id: trayButtonRoot

  required property var modelData
  required property var shellRoot
  readonly property QtObject theme: ShellTheme {}
  property string label: shellRoot.trayItemText(modelData)

  width: theme.barItemSize
  height: theme.barItemSize

  Image {
    anchors.centerIn: parent
    width: theme.barIconSize
    height: theme.barIconSize
    source: trayButtonRoot.modelData.icon
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onEntered: trayButtonRoot.shellRoot.showTooltip(trayButtonRoot, trayButtonRoot.label)
    onExited: trayButtonRoot.shellRoot.hideTooltip()
    onPressed: mouse => {
      trayButtonRoot.shellRoot.showTooltip(trayButtonRoot, trayButtonRoot.label)

      if (mouse.button === Qt.MiddleButton) {
        trayButtonRoot.shellRoot.toggleTrayPin(trayButtonRoot.modelData)
      } else if (mouse.button === Qt.RightButton || trayButtonRoot.modelData.onlyMenu || trayButtonRoot.shellRoot.isNetworkTrayItem(trayButtonRoot.modelData)) {
        if (trayButtonRoot.shellRoot.runTrayDirectAction(trayButtonRoot.modelData))
          return

        if (!trayButtonRoot.shellRoot.showTrayMenu(trayButtonRoot.modelData, trayButtonRoot, mouse))
          trayButtonRoot.modelData.activate()
      } else {
        trayButtonRoot.modelData.activate()
      }
    }
    onWheel: wheel => trayButtonRoot.modelData.scroll(wheel.angleDelta.y, false)
  }
}
