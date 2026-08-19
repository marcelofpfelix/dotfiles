import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.Ui as OmarchyUi

ShellFloatingPopup {
  id: passMenuPanel

  readonly property QtObject theme: ShellTheme {}
  required property var passModel
  property bool refreshRunning: false
  property int panelWidth: 720
  property int panelHeight: 520
  property alias searchText: passSearch.text
  property alias currentIndex: passList.currentIndex

  title: "quickshell-passmenu"

  function focusSearch() {
    passSearch.forceActiveFocus()
  }

  function positionCurrent() {
    passList.positionCurrent()
  }
  IpcHandler {
    target: "passmenu"
    function open(mode: string, userKey: string, backend: string) { passMenuPanel.shellRoot.openPassmenu(mode, userKey, backend) }
    function hide() { passMenuPanel.close() }
  }

  ShellFrame {
    anchors.fill: parent

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: theme.panelMargin
      spacing: theme.spacingXl

      RowLayout {
        Layout.fillWidth: true
        ShellText { Layout.fillWidth: true; role: "title"; text: "Passwords" }
        Text { color: theme.textMuted; font.family: theme.fontFamily; font.pixelSize: theme.fontMd; text: passMenuPanel.shellRoot.passModeLabel() }
      }

      OmarchyUi.TextField {
        id: passSearch
        Layout.fillWidth: true
        Layout.preferredHeight: theme.searchHeight
        placeholderText: "Search passwords"
        foreground: theme.text
        accent: theme.primary
        font.family: theme.fontFamily
        font.styleName: theme.fontStyle
        font.pixelSize: theme.fontInput
        onTextChanged: passMenuPanel.shellRoot.rebuildPassModel()
        Keys.onEscapePressed: passMenuPanel.close()
        Keys.onDownPressed: { passList.selectRelative(1) }
        Keys.onUpPressed: { passList.selectRelative(-1) }
        onAccepted: passMenuPanel.shellRoot.runPassEntry()
      }

      ShellPickerList {
        id: passList
        model: passMenuPanel.passModel

        delegate: ShellSelectableRow {
          id: passRow
          required property string path
          required property int index
          width: passList.width
          selected: ListView.isCurrentItem
          onHovered: passList.currentIndex = index
          onClicked: {
            passList.currentIndex = index
            passMenuPanel.shellRoot.runPassEntry()
          }
          Text { anchors.fill: parent; anchors.leftMargin: theme.inputInset; anchors.rightMargin: theme.rowTextRightInset; verticalAlignment: Text.AlignVCenter; color: theme.text; elide: Text.ElideRight; font.family: theme.fontFamily; font.pixelSize: theme.fontLg; text: passRow.path }
        }
      }

      ShellStateBox {
        visible: passMenuPanel.passModel.count === 0
        text: passMenuPanel.refreshRunning ? "Loading passwords..." : "No password entries"
      }
    }
  }
}
