import QtQuick
import QtQuick.Layouts
import qs.Commons as OmarchyCommons
import qs.Ui as OmarchyUi

OmarchyUi.BorderSurface {
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
  borderSpec: OmarchyCommons.Border.flat(theme.surfaceHigh, theme.dividerHeight)

  ShellText {
    anchors.centerIn: parent
    width: Math.max(0, parent.width - theme.paddingMd * 2)
    horizontalAlignment: Text.AlignHCenter
    wrapMode: Text.Wrap
    role: stateBox.role
    text: stateBox.text
  }
}
