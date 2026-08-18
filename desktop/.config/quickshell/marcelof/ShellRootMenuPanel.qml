import QtQuick
import QtQuick.Layouts

ShellPopup {
  id: rootMenu

  readonly property QtObject theme: ShellTheme {}
  required property var shellRoot
  required property var shellConfig

  rightOffset: anchorWindow ? Math.max(edgeMargin, anchorWindow.width - panelWidth - edgeMargin) : edgeMargin

  ShellPanel {
    anchors.fill: parent

    ShellText { Layout.fillWidth: true; role: "section"; text: "Go" }

    Repeater {
      model: rootMenu.shellConfig.controlMenuRows

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
            tooltipState: rootMenu.shellRoot
            onTriggered: rootMenu.shellRoot.runMenuAction(modelData.action)
          }
        }
      }
    }
  }
}
