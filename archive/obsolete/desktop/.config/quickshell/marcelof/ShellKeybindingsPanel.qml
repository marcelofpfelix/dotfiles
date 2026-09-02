import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Ui as OmarchyUi

ShellFloatingPopup {
  id: keybindingsPanel

  readonly property QtObject theme: ShellTheme {}
  required property var keybindingsModel
  readonly property string filterText: search.text.trim().toLowerCase()
  title: "quickshell-keybindings"

  onPanelOpenChanged: {
    if (panelOpen) {
      search.text = ""
      Qt.callLater(() => search.forceActiveFocus())
    }
  }

  ShellPanel {
    anchors.fill: parent
    margin: 14
    gap: 8
      ShellText { Layout.fillWidth: true; role: "title"; text: "Keybindings" }
      OmarchyUi.TextField {
        id: search
        Layout.fillWidth: true
        Layout.preferredHeight: theme.searchHeight
        placeholderText: "Search keybindings"
        foreground: theme.text
        accent: theme.primary
        font.family: theme.fontFamily
        font.styleName: theme.fontStyle
        font.pixelSize: theme.fontInput
        Keys.onEscapePressed: keybindingsPanel.hide()
      }
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
              visible: keybindingsPanel.filterText.length === 0 || (shortcut + " " + action).toLowerCase().indexOf(keybindingsPanel.filterText) >= 0
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
