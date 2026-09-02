import QtQuick
import QtQuick.Layouts

Rectangle {
  id: actionButtonRoot

  readonly property QtObject theme: ShellTheme {}

  property string icon: ""
  property string label: ""
  property string tooltip: ""
  property int minWidth: theme.actionMinWidth
  property bool active: false
  property var tooltipState
  signal triggered()
  signal secondaryTriggered()

  implicitHeight: theme.actionHeight
  implicitWidth: Math.max(minWidth, actionRow.implicitWidth + theme.actionHorizontalPadding)
  Layout.minimumHeight: implicitHeight
  Layout.preferredHeight: implicitHeight
  radius: theme.radius
  clip: true
  color: actionMouse.containsMouse ? (active ? theme.borderStrong : theme.border) : (active ? theme.surfaceActive : theme.surfaceHigh)

  RowLayout {
    id: actionRow
    anchors.centerIn: parent
    spacing: theme.spacingMd

    ShellText { id: actionIcon; role: "icon"; text: actionButtonRoot.icon }
    ShellText { Layout.maximumWidth: Math.max(0, actionButtonRoot.width - actionIcon.implicitWidth - 30); elide: Text.ElideRight; text: actionButtonRoot.label }
  }

  MouseArea {
    id: actionMouse
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onEntered: if (actionButtonRoot.tooltip.length > 0 && actionButtonRoot.tooltipState) actionButtonRoot.tooltipState.showTooltip(actionButtonRoot, actionButtonRoot.tooltip)
    onExited: if (actionButtonRoot.tooltipState) actionButtonRoot.tooltipState.hideTooltip()
    onClicked: mouse => {
      if (mouse.button === Qt.RightButton)
        actionButtonRoot.secondaryTriggered()
      else
        actionButtonRoot.triggered()
    }
  }
}
