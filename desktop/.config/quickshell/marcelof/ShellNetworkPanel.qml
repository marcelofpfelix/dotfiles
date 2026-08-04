import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ShellPopup {
  id: networkPanel

  readonly property QtObject theme: ShellTheme {}
  required property var shellRoot
  required property var shellConfig
  required property var statusRefresh
  onPanelOpenChanged: if (panelOpen) networkRefresh.running = true

  IpcHandler {
    target: "network"
    function toggle() { networkPanel.shellRoot.toggleNetworkPanel() }
    function hide() { networkPanel.shellRoot.networkPanelOpen = false }
  }

  ShellPanel {
    anchors.fill: parent
    margin: 16

      RowLayout {
        Layout.fillWidth: true
        spacing: theme.spacingLg
        ShellText { Layout.fillWidth: true; role: "title"; text: "Network" }
        ShellActionButton { icon: "󰑓"; label: ""; minWidth: 34; tooltip: "Refresh"; tooltipState: networkPanel.shellRoot; onTriggered: { networkPanel.statusRefresh.running = true; networkRefresh.running = true } }
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: theme.spacingXl
        ShellText { role: "softStrong"; text: networkPanel.shellConfig.isWifiStatus(networkPanel.shellRoot.networkStatusText) ? "󰖩" : "󰈀" }
        ShellText { Layout.fillWidth: true; role: "soft"; elide: Text.ElideRight; text: networkPanel.shellRoot.networkStatusText.length > 0 ? networkPanel.shellRoot.networkStatusText : networkPanel.shellConfig.networkUnavailableText }
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: theme.spacingLg
        ShellActionButton { Layout.fillWidth: true; icon: "󰖩"; label: networkPanel.shellConfig.networkWifiLabel; tooltip: "Toggle Wi-Fi"; tooltipState: networkPanel.shellRoot; onTriggered: networkPanel.shellRoot.runNetwork(networkPanel.shellConfig.networkWifiToggleAction) }
        ShellActionButton { Layout.fillWidth: true; icon: "󰍜"; label: "Settings"; tooltip: "Open network settings"; tooltipState: networkPanel.shellRoot; onTriggered: Quickshell.execDetached(networkPanel.shellConfig.networkEditor()) }
      }

      ShellSection {
        fillHeight: true
        bordered: true

        Text {
          id: networkText
          Layout.fillWidth: true
          Layout.fillHeight: true
          color: theme.textSoft
          elide: Text.ElideRight
          font.family: theme.fontFamily
          font.styleName: theme.fontStyle
          font.pixelSize: theme.fontMd
          maximumLineCount: 10
          wrapMode: Text.NoWrap
          text: ""
        }
      }
  }

  Process {
    id: networkRefresh
    command: networkPanel.shellConfig.network("devices")
    stdout: StdioCollector { onStreamFinished: networkText.text = this.text.trim() }
  }
}
