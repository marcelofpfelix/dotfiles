import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.Ui as OmarchyUi

ShellFloatingPopup {
  id: clipboardPanel

  readonly property QtObject theme: ShellTheme {}
  required property var clipboardModel
  property bool refreshRunning: false
  property int panelWidth: 720
  property int panelHeight: 500
  property alias searchText: clipSearch.text
  property alias currentIndex: clipList.currentIndex

  title: "quickshell-clipboard"

  function focusSearch() {
    clipSearch.forceActiveFocus()
  }

  function positionCurrent() {
    clipList.positionCurrent()
  }
  ShellFrame {
    anchors.fill: parent

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: theme.panelMargin
      spacing: theme.spacingXl

      RowLayout {
        Layout.fillWidth: true
        ShellText { Layout.fillWidth: true; role: "title"; text: "Clipboard" }
        Text { color: theme.textMuted; font.family: theme.fontFamily; font.pixelSize: theme.fontMd; text: clipboardPanel.clipboardModel.count + " entries" }
      }

      OmarchyUi.TextField {
        id: clipSearch
        Layout.fillWidth: true
        Layout.preferredHeight: theme.searchHeight
        placeholderText: "Search clipboard"
        foreground: theme.text
        accent: theme.primary
        font.family: theme.fontFamily
        font.styleName: theme.fontStyle
        font.pixelSize: theme.fontInput
        onTextChanged: clipboardPanel.shellRoot.rebuildClipboardModel()
        Keys.onEscapePressed: clipboardPanel.close()
        Keys.onDownPressed: { clipList.selectRelative(1) }
        Keys.onUpPressed: { clipList.selectRelative(-1) }
        onAccepted: clipboardPanel.shellRoot.pasteClipboardEntry()
      }

      ShellPickerList {
        id: clipList
        model: clipboardPanel.clipboardModel

        delegate: ShellSelectableRow {
          id: clipboardRow
          required property string text
          required property string preview
          required property int index
          width: clipList.width
          selected: ListView.isCurrentItem
          onHovered: clipList.currentIndex = index
          onClicked: {
            clipList.currentIndex = index
            clipboardPanel.shellRoot.pasteClipboardEntry()
          }
          Text { anchors.fill: parent; anchors.leftMargin: theme.inputInset; anchors.rightMargin: theme.rowTextRightInset; verticalAlignment: Text.AlignVCenter; color: theme.textSoft; elide: Text.ElideRight; font.family: theme.fontFamily; font.pixelSize: theme.fontXl; text: clipboardRow.preview }
        }
      }

      ShellStateBox {
        visible: clipboardPanel.clipboardModel.count === 0
        text: clipboardPanel.refreshRunning ? "Loading clipboard..." : (clipboardPanel.shellRoot.clipboardEntries.length > 0 ? "No clipboard matches" : "Clipboard history is empty")
      }
    }
  }
}
