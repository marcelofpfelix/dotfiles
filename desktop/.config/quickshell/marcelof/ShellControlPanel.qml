import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ShellPopup {
  id: controlPanel

  readonly property QtObject theme: ShellTheme {}
  required property var shellRoot
  required property var shellSettings
  required property var shellConfig
  required property var privacyRefresh

  readonly property var menuActionRows: shellConfig.controlMenuRows

  function triggerMenuAction(action) {
    controlPanel.shellRoot.runMenuAction(action)
  }

  ShellScrollPanel {
    anchors.fill: parent

        ShellText { Layout.fillWidth: true; role: "section"; text: "Keyboard" }

        RowLayout {
          Layout.fillWidth: true
          visible: controlPanel.shellRoot.kbdBrightnessText.length > 0
          spacing: theme.spacingXl
          ShellText { role: "softStrong"; text: "󰌌" }
          Text { Layout.fillWidth: true; color: theme.textSoft; font.family: theme.fontFamily; font.pixelSize: theme.fontMd; text: controlPanel.shellRoot.kbdBrightnessText }
          ShellActionButton { icon: "-"; label: ""; minWidth: 34; tooltip: "Keyboard brightness down"; tooltipState: controlPanel.shellRoot; onTriggered: controlPanel.shellRoot.runKbdBrightness(controlPanel.shellConfig.actions.down) }
          ShellActionButton { icon: "+"; label: ""; minWidth: 34; tooltip: "Keyboard brightness up"; tooltipState: controlPanel.shellRoot; onTriggered: controlPanel.shellRoot.runKbdBrightness("up") }
        }

        ShellText { Layout.fillWidth: true; role: "section"; text: "Quick actions" }

        RowLayout {
          Layout.fillWidth: true
          spacing: theme.spacingButton
          ShellActionButton { icon: "󰹑"; label: "Screen"; tooltip: "Screen tools"; tooltipState: controlPanel.shellRoot; onTriggered: controlPanel.shellRoot.toggleScreenPanel() }
          ShellActionButton { icon: "󰅇"; label: controlPanel.shellConfig.labels.copy; tooltip: "Copy screenshot area"; tooltipState: controlPanel.shellRoot; onTriggered: Quickshell.execDetached(controlPanel.shellConfig.screenshot(controlPanel.shellConfig.actions.copy)) }
          ShellActionButton { icon: "󰌾"; label: "Lock"; tooltip: "Lock session"; tooltipState: controlPanel.shellRoot; onTriggered: controlPanel.shellRoot.lockSession() }
          ShellActionButton { icon: controlPanel.shellSettings.doNotDisturb ? "󰂛" : "󰂚"; label: "DND"; active: controlPanel.shellSettings.doNotDisturb; tooltip: controlPanel.shellSettings.doNotDisturb ? "Allow notification popups" : "Silence notification popups"; tooltipState: controlPanel.shellRoot; onTriggered: controlPanel.shellRoot.toggleDnd() }
        }

        ShellText { Layout.fillWidth: true; role: "section"; text: "Privacy" }

        ShellSection {
          padding: theme.paddingSm
          gap: theme.spacingSm
            RowLayout {
              Layout.fillWidth: true
              spacing: theme.spacingLg
              Text { color: controlPanel.shellRoot.privacyBarColor(); font.family: theme.fontFamily; font.pixelSize: theme.fontInput; text: controlPanel.shellRoot.privacyBarText().length > 0 ? controlPanel.shellRoot.privacyBarText() : "󰍬" }
              ShellText { Layout.fillWidth: true; role: "strong"; elide: Text.ElideRight; text: controlPanel.shellRoot.privacySummaryText() }
              ShellActionButton { icon: "󰑓"; label: ""; minWidth: 40; tooltip: "Refresh privacy state"; tooltipState: controlPanel.shellRoot; onTriggered: controlPanel.privacyRefresh.running = true }
              ShellActionButton { icon: "󰍹"; label: ""; minWidth: 40; tooltip: "Open screen and capture details"; tooltipState: controlPanel.shellRoot; onTriggered: controlPanel.shellRoot.toggleScreenPanel() }
            }
            Text { Layout.fillWidth: true; color: theme.textMuted; wrapMode: Text.Wrap; font.family: theme.fontFamily; font.pixelSize: theme.fontSm; maximumLineCount: 4; text: controlPanel.shellRoot.privacyStatusText.length > 0 ? controlPanel.shellRoot.privacyStatusText : "mic inactive\ncamera inactive\nshare inactive" }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: theme.spacingButton
          ShellActionButton { icon: controlPanel.shellRoot.idleInhibitActive() ? "󰒳" : "󰒲"; label: "Awake"; active: controlPanel.shellRoot.idleInhibitActive(); tooltip: controlPanel.shellRoot.idleInhibitActive() ? "Allow idle and sleep" : "Prevent idle and sleep"; tooltipState: controlPanel.shellRoot; onTriggered: controlPanel.shellRoot.toggleIdleInhibit() }
          ShellActionButton { icon: "󰒲"; label: "Sleep"; tooltip: "Suspend system"; tooltipState: controlPanel.shellRoot; onTriggered: controlPanel.shellRoot.suspendSession() }
          ShellActionButton { icon: "󰜉"; label: "Reboot"; tooltip: "Reboot system"; tooltipState: controlPanel.shellRoot; onTriggered: controlPanel.shellRoot.openSessionConfirm("Reboot", "󰜉", controlPanel.shellConfig.reboot()) }
          ShellActionButton { icon: "⏻"; label: "Power"; tooltip: "Power menu"; tooltipState: controlPanel.shellRoot; onTriggered: controlPanel.shellRoot.togglePowerMenu() }
        }

        ShellText { Layout.fillWidth: true; role: "section"; text: "Menus" }

        Repeater {
          model: controlPanel.menuActionRows

          delegate: RowLayout {
            required property var modelData

            Layout.fillWidth: true
            spacing: theme.spacingButton

            Repeater {
              model: parent.modelData

              delegate: ShellActionButton {
                required property var modelData

                Layout.fillWidth: true
                icon: modelData.icon
                label: modelData.label
                minWidth: theme.controlMenuButtonMinWidth
                tooltip: modelData.tooltip
                tooltipState: controlPanel.shellRoot
                onTriggered: controlPanel.triggerMenuAction(modelData.action)
              }
            }
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: theme.spacingXl
          ShellText { role: "softStrong"; text: controlPanel.shellRoot.bluetoothAdapter && controlPanel.shellRoot.bluetoothAdapter.enabled ? "󰂯" : "󰂲" }
          ShellText { Layout.fillWidth: true; role: "soft"; elide: Text.ElideRight; text: controlPanel.shellRoot.bluetoothStatusText() }
          ShellActionButton { icon: controlPanel.shellRoot.bluetoothAdapter && controlPanel.shellRoot.bluetoothAdapter.enabled ? "󰂲" : "󰂯"; label: controlPanel.shellRoot.bluetoothAdapter && controlPanel.shellRoot.bluetoothAdapter.enabled ? "Off" : "On"; tooltip: "Toggle Bluetooth"; tooltipState: controlPanel.shellRoot; onTriggered: controlPanel.shellRoot.toggleBluetooth() }
          ShellActionButton { icon: controlPanel.shellRoot.bluetoothAdapter && controlPanel.shellRoot.bluetoothAdapter.discovering ? "󰑓" : "󰐊"; label: "Scan"; tooltip: "Toggle Bluetooth discovery"; tooltipState: controlPanel.shellRoot; onTriggered: controlPanel.shellRoot.toggleBluetoothScan() }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: theme.spacingXl
          ShellText { role: "softStrong"; text: controlPanel.shellConfig.isWifiStatus(controlPanel.shellRoot.networkStatusText) ? "󰖩" : "󰈀" }
          ShellText { Layout.fillWidth: true; role: "soft"; elide: Text.ElideRight; text: controlPanel.shellRoot.networkStatusText.length > 0 ? controlPanel.shellRoot.networkStatusText : controlPanel.shellConfig.networkUnavailableText }
          ShellActionButton { icon: "󰖩"; label: controlPanel.shellConfig.networkWifiLabel; tooltip: "Toggle Wi-Fi"; tooltipState: controlPanel.shellRoot; onTriggered: controlPanel.shellRoot.runNetwork(controlPanel.shellConfig.networkWifiToggleAction) }
          ShellActionButton { icon: "󰍜"; label: controlPanel.shellConfig.labels.open; tooltip: "Open network settings"; tooltipState: controlPanel.shellRoot; onTriggered: Quickshell.execDetached(controlPanel.shellConfig.networkEditor()) }
        }

        RowLayout {
          Layout.fillWidth: true
          visible: controlPanel.shellRoot.powerStatusText.length > 0
          spacing: theme.spacingXl
          ShellText { role: "softStrong"; text: "󰁹" }
          ShellText { Layout.fillWidth: true; role: "soft"; elide: Text.ElideRight; text: controlPanel.shellRoot.powerStatusText }
          ShellActionButton { icon: "󰾅"; label: "Save"; active: controlPanel.shellRoot.powerStatusText.indexOf("power-saver") === 0; tooltip: "Power saver"; tooltipState: controlPanel.shellRoot; onTriggered: controlPanel.shellRoot.setPowerProfile("power-saver") }
          ShellActionButton { icon: "󰾆"; label: "Bal"; active: controlPanel.shellRoot.powerStatusText.indexOf("balanced") === 0; tooltip: "Balanced"; tooltipState: controlPanel.shellRoot; onTriggered: controlPanel.shellRoot.setPowerProfile("balanced") }
          ShellActionButton { icon: "󰓅"; label: "Perf"; active: controlPanel.shellRoot.powerStatusText.indexOf("performance") === 0; tooltip: "Performance"; tooltipState: controlPanel.shellRoot; onTriggered: controlPanel.shellRoot.setPowerProfile("performance") }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: theme.spacingXl
          ShellText { role: "softStrong"; text: "󰈐" }
          ShellText { Layout.fillWidth: true; role: "soft"; elide: Text.ElideRight; text: controlPanel.shellRoot.fanStatusText }
        }

        Item { Layout.fillWidth: true; implicitHeight: 12 }
  }
}
