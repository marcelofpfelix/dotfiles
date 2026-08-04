import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ShellPopup {
  id: personalPanel

  readonly property QtObject theme: ShellTheme {}
  required property var shellRoot
  required property var shellConfig
  required property var refresh

  ShellPanel {
    anchors.fill: parent
    margin: 10
    gap: 9

      RowLayout {
        Layout.fillWidth: true
        spacing: theme.spacingLg
        ShellText { Layout.fillWidth: true; role: "heading"; text: "Personal" }
        ShellActionButton { icon: "󰑓"; label: ""; minWidth: 40; tooltip: "Refresh board surface"; tooltipState: personalPanel.shellRoot; onTriggered: personalPanel.refresh.running = true }
        ShellActionButton { icon: "󰑐"; label: "Run"; minWidth: 70; tooltip: "Run board action personal.refresh"; tooltipState: personalPanel.shellRoot; onTriggered: personalPanel.shellRoot.runPersonalDashboardAction("personal.refresh") }
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: theme.spacingButton
        Repeater {
          model: personalPanel.shellRoot.personalDashboardSurfaces
          ShellActionButton { required property string modelData; Layout.fillWidth: true; icon: modelData === personalPanel.shellConfig.boardQuickshellSurface ? "󰒓" : "󰡨"; label: modelData === personalPanel.shellConfig.boardQuickshellSurface ? "system" : modelData.replace("personal.", ""); minWidth: 74; active: personalPanel.shellRoot.personalDashboardSurface === modelData; tooltip: modelData; tooltipState: personalPanel.shellRoot; onTriggered: personalPanel.shellRoot.setPersonalDashboardSurface(modelData) }
        }
      }

      Rectangle { Layout.fillWidth: true; height: 1; color: theme.surfaceHigh }

      ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true

        Text {
          readonly property bool systemSurface: personalPanel.shellRoot.personalDashboardSurface === personalPanel.shellConfig.boardQuickshellSurface
          readonly property string plainText: String(personalPanel.shellRoot.personalDashboardText || "").trim()

          width: parent.width
          color: theme.textSoft
          font.family: theme.fontFamily
          font.pixelSize: systemSurface ? theme.fontMd : theme.fontSm
          lineHeight: 1.15
          wrapMode: systemSurface ? Text.Wrap : Text.NoWrap
          textFormat: systemSurface ? Text.RichText : Text.PlainText
          text: systemSurface ? personalPanel.shellRoot.personalDashboardRichText() : (plainText.length > 0 ? plainText : "No board data")
        }
      }
  }
}
