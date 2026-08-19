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

  readonly property var sessionActionRows: shellConfig.sessionActionRows
  readonly property var exitSessionAction: shellConfig.exitSessionAction

  function triggerSessionAction(action) {
    switch (action.action) {
    case "hide":
      powerMenu.shellRoot.hidePowerMenu()
      break
    case "lock":
      powerMenu.shellRoot.lockSession()
      break
    case "suspend":
      powerMenu.shellRoot.suspendSession()
      break
    default:
      powerMenu.shellRoot.setSessionConfirm(action.label, action.icon, powerMenu.shellConfig.sessionCommand(action.action))
      break
    }
  }

  IpcHandler {
    target: "session"
    function confirmExit() { powerMenu.shellRoot.togglePowerMenu() }
    function power() { powerMenu.shellRoot.togglePowerMenu() }
    function confirmReboot() { powerMenu.shellRoot.openSessionConfirm("Reboot", "󰜉", powerMenu.shellConfig.reboot()) }
    function hide() { powerMenu.hide() }
  }

  ShellPanel {
    anchors.fill: parent
    margin: 16

      ShellText { Layout.fillWidth: true; role: "title"; text: "Session" }
      Text { Layout.fillWidth: true; color: theme.textSoft; wrapMode: Text.Wrap; font.family: theme.fontFamily; font.pixelSize: theme.fontMd; text: powerMenu.shellRoot.powerStatusText.length > 0 ? powerMenu.shellRoot.powerStatusText : "Power status --" }
      ShellText { Layout.fillWidth: true; role: "section"; text: "Choose a session action" }

      Repeater {
        model: powerMenu.sessionActionRows

        RowLayout {
          required property var modelData

          Layout.fillWidth: true
          spacing: theme.spacingLg

          Repeater {
            model: parent.modelData

            ShellActionButton {
              required property var modelData

              Layout.fillWidth: true
              icon: modelData.icon
              label: modelData.label
              tooltip: modelData.tooltip
              tooltipState: powerMenu.shellRoot
              onTriggered: powerMenu.triggerSessionAction(modelData)
            }
          }
        }
      }

      Text { Layout.fillWidth: true; visible: powerMenu.shellRoot.sessionConfirmLabel.length > 0; color: theme.warning; font.family: theme.fontFamily; font.pixelSize: theme.fontMd; text: "Confirm " + powerMenu.shellRoot.sessionConfirmLabel + "?" }

      RowLayout {
        Layout.fillWidth: true
        visible: powerMenu.shellRoot.sessionConfirmLabel.length > 0
        spacing: theme.spacingLg
        ShellActionButton { Layout.fillWidth: true; icon: "󰅖"; label: "Cancel"; tooltip: "Cancel pending session action"; tooltipState: powerMenu.shellRoot; onTriggered: powerMenu.shellRoot.clearSessionConfirm() }
        ShellActionButton { Layout.fillWidth: true; active: true; icon: powerMenu.shellRoot.sessionConfirmIcon; label: "Confirm"; tooltip: "Run " + powerMenu.shellRoot.sessionConfirmLabel; tooltipState: powerMenu.shellRoot; onTriggered: powerMenu.shellRoot.runSessionConfirm() }
      }

      ShellActionButton {
        Layout.preferredWidth: 180
        icon: powerMenu.exitSessionAction.icon
        label: powerMenu.exitSessionAction.label
        tooltip: powerMenu.exitSessionAction.tooltip
        tooltipState: powerMenu.shellRoot
        onTriggered: powerMenu.triggerSessionAction(powerMenu.exitSessionAction)
      }
  }
}
