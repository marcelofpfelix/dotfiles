import QtQuick
import QtQuick.Layouts

Rectangle {
  id: stateBox

  readonly property QtObject theme: ShellTheme {}
  property string text: ""
  property string role: "subtle"
  property int minHeight: 96

  Layout.fillWidth: true
  Layout.fillHeight: true
  implicitHeight: minHeight
  radius: theme.radius
  color: theme.surface
  border.color: theme.surfaceHigh
  border.width: 1

  ShellText {
    anchors.centerIn: parent
    width: Math.max(0, parent.width - theme.paddingMd * 2)
    horizontalAlignment: Text.AlignHCenter
    wrapMode: Text.Wrap
    role: stateBox.role
    text: stateBox.text
  }
}
