import Quickshell
import QtQuick
import QtQuick.Layouts

ShellPopup {
  id: trayManagePanel

  readonly property QtObject theme: ShellTheme {}
  required property var shellRoot

  ShellPanel {
    anchors.fill: parent

      RowLayout {
        Layout.fillWidth: true
        ShellText { Layout.fillWidth: true; role: "title"; text: "Tray items" }
        ShellText { role: "muted"; text: trayManagePanel.shellRoot.allTrayItems.length + "" }
      }

      ShellStateBox {
        visible: trayManagePanel.shellRoot.allTrayItems.length === 0
        minHeight: 72
        text: "No tray items"
      }

      ListView {
        id: trayManageList
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: theme.spacingMd
        model: trayManagePanel.shellRoot.allTrayItems

        delegate: Rectangle {
          required property var modelData
          width: trayManageList.width
          height: theme.launcherRowHeight
          radius: theme.radius
          color: trayManagePanel.shellRoot.isTrayHidden(modelData) ? theme.surfaceLow : theme.surface
          border.color: theme.surfaceHigh
          border.width: 1

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 9
            anchors.rightMargin: 9
            spacing: theme.spacingLg

            Image { source: modelData.icon; Layout.preferredWidth: 18; Layout.preferredHeight: 18 }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 1

              Text {
                Layout.fillWidth: true
                color: trayManagePanel.shellRoot.isTrayHidden(modelData) ? theme.textDim : theme.textSoft
                elide: Text.ElideRight
                font.family: theme.fontFamily
                font.styleName: theme.fontStyle
                font.pixelSize: theme.fontMd
                text: trayManagePanel.shellRoot.trayItemText(modelData)
              }

              ShellText { Layout.fillWidth: true; role: "muted"; elide: Text.ElideRight; text: trayManagePanel.shellRoot.trayItemStatus(modelData) }
            }

            ShellActionButton { icon: "󰐊"; label: ""; minWidth: 40; tooltip: "Activate tray item"; tooltipState: trayManagePanel.shellRoot; onTriggered: modelData.activate() }
            ShellActionButton { active: modelData.hasMenu || trayManagePanel.shellRoot.trayDirectCommand(modelData).length > 0; icon: "󰍜"; label: ""; minWidth: 40; tooltip: "Open tray menu or action"; tooltipState: trayManagePanel.shellRoot; onTriggered: trayManagePanel.shellRoot.openTrayContext(modelData) }
            ShellActionButton { active: trayManagePanel.shellRoot.isTrayPinned(modelData); icon: "󰐃"; label: ""; minWidth: 40; tooltip: "Pin tray item"; tooltipState: trayManagePanel.shellRoot; onTriggered: trayManagePanel.shellRoot.toggleTrayPin(modelData) }
            ShellActionButton { active: trayManagePanel.shellRoot.isTrayHidden(modelData); icon: "󰖭"; label: ""; minWidth: 40; tooltip: "Hide tray item"; tooltipState: trayManagePanel.shellRoot; onTriggered: trayManagePanel.shellRoot.toggleTrayHide(modelData) }
          }
        }
      }
  }
}
