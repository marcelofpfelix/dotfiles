import QtQuick
import QtQuick.Layouts

Rectangle {
  id: iconButtonRoot

  readonly property QtObject theme: ShellTheme {}

  property string icon: ""
  property string tooltip: ""
  property var tooltipState
  signal triggered()

  readonly property int pad: theme.iconButtonPadding

  implicitHeight: {
    const h = iconLabel.implicitHeight + pad * 2
    return h % 2 === 0 ? h : h + 1
  }
  implicitWidth: implicitHeight
  Layout.preferredWidth: implicitWidth
  Layout.preferredHeight: implicitHeight
  radius: theme.radiusSmall
  color: iconMouse.containsMouse ? theme.surfaceHigh : theme.transparent

  ShellText {
    id: iconLabel
    anchors.centerIn: parent
    anchors.verticalCenterOffset: 1
    role: "title"
    text: iconButtonRoot.icon
  }

  MouseArea {
    id: iconMouse
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onEntered: if (iconButtonRoot.tooltip.length > 0 && iconButtonRoot.tooltipState) iconButtonRoot.tooltipState.showTooltip(iconButtonRoot, iconButtonRoot.tooltip)
    onExited: if (iconButtonRoot.tooltipState) iconButtonRoot.tooltipState.hideTooltip()
    onClicked: iconButtonRoot.triggered()
  }
}
