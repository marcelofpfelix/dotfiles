import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ShellPopup {
  id: powerMenu

  readonly property QtObject theme: ShellTheme {}
  required property var shellRoot
  required property var shellConfig
  implicitWidth: 460


  IpcHandler {
    target: "session"
    function confirmExit() { powerMenu.shellRoot.togglePowerMenu() }
    function power() { powerMenu.shellRoot.togglePowerMenu() }
    function request(action: string): string { return powerMenu.shellRoot.requestSessionAction(action) ? "ok" : "unknown" }
    function confirmReboot() { powerMenu.shellRoot.openSessionConfirm("Reboot", "󰜉", powerMenu.shellConfig.reboot()) }
    function hide() { powerMenu.hide() }
  }


  ShellPanel {
    anchors.fill: parent
    margin: 16

      ShellText { Layout.fillWidth: true; role: "title"; text: "Confirm session action" }

      Text { Layout.fillWidth: true; visible: powerMenu.shellRoot.sessionConfirmLabel.length > 0; color: theme.warning; font.family: theme.fontFamily; font.pixelSize: theme.fontMd; text: "Confirm " + powerMenu.shellRoot.sessionConfirmLabel + "?" }

      RowLayout {
        Layout.fillWidth: true
        visible: powerMenu.shellRoot.sessionConfirmLabel.length > 0
        spacing: theme.spacingLg
        ShellActionButton { Layout.fillWidth: true; icon: "󰅖"; label: "Cancel"; tooltip: "Cancel pending session action"; tooltipState: powerMenu.shellRoot; onTriggered: powerMenu.shellRoot.hidePowerMenu() }
        ShellActionButton { Layout.fillWidth: true; active: true; icon: powerMenu.shellRoot.sessionConfirmIcon; label: "Confirm"; tooltip: "Run " + powerMenu.shellRoot.sessionConfirmLabel; tooltipState: powerMenu.shellRoot; onTriggered: powerMenu.shellRoot.runSessionConfirm() }
      }

  }
}
