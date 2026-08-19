import QtQuick
import qs.Ui as OmarchyUi

OmarchyUi.Button {
  id: root

  readonly property QtObject theme: ShellTheme {}

  property alias icon: root.iconText
  property alias label: root.text
  property alias tooltip: root.tooltipText
  property int minWidth: theme.actionMinWidth
  property var tooltipState
  signal triggered()
  signal secondaryTriggered()

  minimumWidth: minWidth
  minimumHeight: theme.actionHeight
  foreground: theme.text
  background: theme.surfaceRaised
  accent: theme.primary
  fontFamily: theme.fontFamily
  fontSize: theme.fontMd
  iconSize: theme.fontXl
  tooltipForeground: theme.text
  tooltipBackground: theme.surfaceHigh
  tooltipBorder: theme.borderStrong

  onClicked: root.triggered()
  onRightClicked: root.secondaryTriggered()
}
