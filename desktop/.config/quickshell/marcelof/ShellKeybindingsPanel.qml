import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ShellPopup {
  id: keybindingsPanel

  readonly property QtObject theme: ShellTheme {}
  required property var keybindingsModel

  ShellPanel {
    anchors.fill: parent
    margin: 14
    gap: 8
      ShellText { Layout.fillWidth: true; role: "title"; text: "Keybindings" }
      ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        ColumnLayout {
          width: parent.width
          spacing: theme.spacingButton
          Repeater {
            model: keybindingsPanel.keybindingsModel
            RowLayout {
              required property string shortcut
              required property string action
              Layout.fillWidth: true
              spacing: theme.spacingXl
              Text { width: 190; color: theme.primary; font.family: theme.fontFamily; font.pixelSize: theme.fontLg; text: shortcut }
              Text { Layout.fillWidth: true; color: theme.text; font.family: theme.fontFamily; font.pixelSize: theme.fontLg; text: action }
            }
          }
          Item { Layout.fillWidth: true; implicitHeight: 14 }
        }
      }
  }
}
