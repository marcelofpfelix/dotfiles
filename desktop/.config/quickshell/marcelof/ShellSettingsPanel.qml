import Quickshell
import QtQuick
import QtQuick.Layouts

ShellPopup {
  id: settingsPanel

  readonly property QtObject theme: ShellTheme {}
  required property var shellRoot
  required property var shellSettings
  required property var shellConfig
  required property var weatherRefresh

  function triggerMenuAction(action) {
    switch (action) {
    case "apps":
      settingsPanel.shellRoot.closeTransientPanels()
      settingsPanel.shellRoot.toggleLauncher()
      break
    case "notifications":
      settingsPanel.shellRoot.toggleNotifications()
      break
    case "controls":
      settingsPanel.shellRoot.toggleControlPanel()
      break
    }
  }

  ShellPanel {
    anchors.fill: parent
      ShellText { Layout.fillWidth: true; role: "title"; text: "Shell settings" }
      RowLayout { Layout.fillWidth: true; spacing: theme.spacingButton
        ShellActionButton { Layout.fillWidth: true; icon: settingsPanel.shellSettings.doNotDisturb ? "󰂛" : "󰂚"; label: "DND"; active: settingsPanel.shellSettings.doNotDisturb; tooltip: "Toggle notification popups"; tooltipState: settingsPanel.shellRoot; onTriggered: settingsPanel.shellRoot.toggleDnd() }
        ShellActionButton { Layout.fillWidth: true; icon: settingsPanel.shellSettings.nativeTrayMenus ? "󰍜" : "󰍛"; label: "Tray"; active: settingsPanel.shellSettings.nativeTrayMenus; tooltip: "Toggle native tray menus"; tooltipState: settingsPanel.shellRoot; onTriggered: settingsPanel.shellSettings.nativeTrayMenus = !settingsPanel.shellSettings.nativeTrayMenus }
        ShellActionButton { Layout.fillWidth: true; icon: settingsPanel.shellRoot.barHidden ? "󰖰" : "󰖯"; label: "Bar"; active: !settingsPanel.shellRoot.barHidden; tooltip: "Show or hide bar"; tooltipState: settingsPanel.shellRoot; onTriggered: settingsPanel.shellRoot.barHidden = !settingsPanel.shellRoot.barHidden }
      }
      RowLayout { Layout.fillWidth: true; spacing: theme.spacingButton
        ShellActionButton { Layout.fillWidth: true; icon: "󰈙"; label: "Dense"; active: settingsPanel.shellSettings.denseUi; tooltip: "Toggle compact shell spacing"; tooltipState: settingsPanel.shellRoot; onTriggered: settingsPanel.shellSettings.denseUi = !settingsPanel.shellSettings.denseUi }
        ShellActionButton { Layout.fillWidth: true; icon: "󰖐"; label: "Palmela"; active: settingsPanel.shellSettings.weatherLocation === "Palmela, Portugal"; tooltip: "Weather: Palmela"; tooltipState: settingsPanel.shellRoot; onTriggered: { settingsPanel.shellSettings.weatherLocation = "Palmela, Portugal"; settingsPanel.weatherRefresh.running = true } }
        ShellActionButton { Layout.fillWidth: true; icon: "󰖐"; label: "Lisbon"; active: settingsPanel.shellSettings.weatherLocation === "Lisbon"; tooltip: "Weather: Lisbon"; tooltipState: settingsPanel.shellRoot; onTriggered: { settingsPanel.shellSettings.weatherLocation = "Lisbon"; settingsPanel.weatherRefresh.running = true } }
      }
      RowLayout { Layout.fillWidth: true; spacing: theme.spacingButton
        ShellText { Layout.preferredWidth: 88; text: "Primary" }
        Repeater {
          model: settingsPanel.shellConfig.primaryColorRows

          Rectangle {
            required property var modelData
            Layout.fillWidth: true
            Layout.preferredHeight: theme.actionHeight
            radius: theme.radius
            border.width: settingsPanel.shellSettings.primaryColor === modelData.color ? 2 : 1
            border.color: settingsPanel.shellSettings.primaryColor === modelData.color ? modelData.color : theme.border
            color: theme.surfaceHigh

            RowLayout {
              anchors.centerIn: parent
              spacing: theme.spacingSm
              Rectangle { width: 18; height: 18; radius: 4; color: modelData.color }
              ShellText { text: modelData.label }
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: settingsPanel.shellSettings.primaryColor = modelData.color
            }
          }
        }
      }
      RowLayout { Layout.fillWidth: true; spacing: theme.spacingButton
        Repeater {
          model: settingsPanel.shellConfig.settingsMenuRows

          ShellActionButton {
            required property var modelData
            Layout.fillWidth: true
            icon: modelData.icon
            label: modelData.label
            tooltip: modelData.tooltip
            tooltipState: settingsPanel.shellRoot
            onTriggered: settingsPanel.triggerMenuAction(modelData.action)
          }
        }
      }
      Text { Layout.fillWidth: true; color: theme.textSubtle; wrapMode: Text.Wrap; font.family: theme.fontFamily; font.pixelSize: theme.fontSm; text: "Favorites: " + settingsPanel.shellSettings.favoriteAppIds.length + "  Hidden apps: " + settingsPanel.shellSettings.hiddenAppIds.length + "  Weather: " + settingsPanel.shellSettings.weatherLocation }
      ShellActionButton { Layout.fillWidth: true; icon: "󰄬"; label: "Clear Hidden Apps"; active: settingsPanel.shellSettings.hiddenAppIds.length > 0; tooltip: "Clear hidden launcher apps"; tooltipState: settingsPanel.shellRoot; onTriggered: { settingsPanel.shellSettings.hiddenAppIds = []; settingsPanel.shellRoot.rebuildLauncher() } }
  }
}
