import Quickshell
import QtQuick
import QtQuick.Layouts

ShellPopup {
  id: screenPanel

  readonly property QtObject theme: ShellTheme {}
  required property var shellRoot
  required property var shellConfig

  ShellPanel {
    anchors.fill: parent

      RowLayout {
        Layout.fillWidth: true
        ShellText { Layout.fillWidth: true; role: "title"; text: "Screen" }
        Text { color: screenPanel.shellRoot.recordingStatusText.indexOf("recording") === 0 ? theme.warning : theme.textSubtle; font.family: theme.fontFamily; font.pixelSize: theme.fontSm; text: screenPanel.shellRoot.recordingStatusText.length > 0 ? screenPanel.shellRoot.recordingStatusText : "--" }
      }

      ShellText { Layout.fillWidth: true; role: "section"; text: "Screenshot" }

      RowLayout {
        Layout.fillWidth: true
        spacing: theme.spacingButton
        ShellActionButton { icon: "󰹑"; label: "Edit"; tooltip: "Select area and edit"; tooltipState: screenPanel.shellRoot; onTriggered: Quickshell.execDetached(screenPanel.shellConfig.screenshot(screenPanel.shellConfig.actions.edit)) }
        ShellActionButton { icon: "󰅇"; label: screenPanel.shellConfig.labels.copy; tooltip: "Copy selected area"; tooltipState: screenPanel.shellRoot; onTriggered: Quickshell.execDetached(screenPanel.shellConfig.screenshot(screenPanel.shellConfig.actions.copy)) }
        ShellActionButton { icon: "󰆞"; label: "Save"; tooltip: "Save selected area"; tooltipState: screenPanel.shellRoot; onTriggered: Quickshell.execDetached(screenPanel.shellConfig.screenshot("save")) }
        ShellActionButton { icon: "󰍹"; label: "Full"; tooltip: "Save full screen"; tooltipState: screenPanel.shellRoot; onTriggered: Quickshell.execDetached(screenPanel.shellConfig.screenshot("full")) }
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: theme.spacingButton
        ShellActionButton { icon: "󰆧"; label: "Window"; tooltip: "Save active window"; tooltipState: screenPanel.shellRoot; onTriggered: Quickshell.execDetached(screenPanel.shellConfig.screenshot("active")) }
        ShellActionButton { icon: "󰭹"; label: "OCR"; tooltip: "OCR selected area to clipboard"; tooltipState: screenPanel.shellRoot; onTriggered: Quickshell.execDetached(screenPanel.shellConfig.screenshot("ocr")) }
        ShellActionButton { icon: "󰈔"; label: screenPanel.shellConfig.labels.open; tooltip: "Open last screenshot"; tooltipState: screenPanel.shellRoot; onTriggered: Quickshell.execDetached(screenPanel.shellConfig.screenshot(screenPanel.shellConfig.actions.openLast)) }
        ShellActionButton { icon: "󰅇"; label: screenPanel.shellConfig.labels.path; tooltip: "Copy last screenshot path"; tooltipState: screenPanel.shellRoot; onTriggered: Quickshell.execDetached(screenPanel.shellConfig.screenshot(screenPanel.shellConfig.actions.copyPath)) }
      }

      ShellText { Layout.fillWidth: true; role: "section"; text: "Recording" }

      RowLayout {
        Layout.fillWidth: true
        spacing: theme.spacingButton
        ShellActionButton { icon: screenPanel.shellRoot.recordingStatusText.indexOf("recording") === 0 ? "󰓛" : "󰐊"; label: screenPanel.shellRoot.recordingStatusText.indexOf("recording") === 0 ? "Stop" : "Start"; tooltip: "Start or stop area recording"; tooltipState: screenPanel.shellRoot; onTriggered: screenPanel.shellRoot.runScreenRecord(screenPanel.shellConfig.actions.toggle) }
        ShellActionButton { icon: "󰈔"; label: screenPanel.shellConfig.labels.open; tooltip: "Open last recording"; tooltipState: screenPanel.shellRoot; onTriggered: screenPanel.shellRoot.runScreenRecord(screenPanel.shellConfig.actions.openLast) }
        ShellActionButton { icon: "󰅇"; label: screenPanel.shellConfig.labels.path; tooltip: "Copy last recording path"; tooltipState: screenPanel.shellRoot; onTriggered: screenPanel.shellRoot.runScreenRecord(screenPanel.shellConfig.actions.copyPath) }
        ShellActionButton { icon: "󰑓"; label: ""; minWidth: 40; tooltip: "Refresh status"; tooltipState: screenPanel.shellRoot; onTriggered: screenPanel.shellRoot.refreshScreenState() }
      }

      Text { Layout.fillWidth: true; color: theme.textSubtle; wrapMode: Text.Wrap; font.family: theme.fontFamily; font.pixelSize: theme.fontSm; text: screenPanel.shellRoot.portalStatusText.length > 0 ? "Portal: " + screenPanel.shellRoot.portalStatusText : "Portal: --" }
      Text { Layout.fillWidth: true; color: theme.warning; wrapMode: Text.Wrap; font.family: theme.fontFamily; font.pixelSize: theme.fontSm; text: screenPanel.shellRoot.privacyStatusText.length > 0 ? screenPanel.shellRoot.privacyStatusText : "mic inactive\ncamera inactive\nshare inactive" }
  }
}
