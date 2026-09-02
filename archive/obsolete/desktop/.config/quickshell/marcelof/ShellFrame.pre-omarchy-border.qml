import QtQuick

Rectangle {
  readonly property QtObject theme: ShellTheme {}

  radius: theme.radius
  color: theme.panel
  border.color: theme.border
  border.width: 1
}
