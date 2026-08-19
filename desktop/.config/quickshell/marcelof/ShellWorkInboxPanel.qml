import Quickshell
import QtQuick
import QtQuick.Layouts

ShellPopup {
  id: workInboxPanel

  readonly property QtObject theme: ShellTheme {}
  required property var shellRoot
  required property var shellSettings
  required property var shellConfig
  required property var refresh

  ShellPanel {
    anchors.fill: parent
    margin: 10
    gap: 9

      RowLayout {
        Layout.fillWidth: true
        spacing: theme.spacingLg
        ShellText { Layout.fillWidth: true; role: "heading"; text: "Work Inbox" }
        ShellText { role: "muted"; text: workInboxPanel.shellRoot.workInboxSourceText.length > 0 ? workInboxPanel.shellRoot.workInboxSourceText : workInboxPanel.shellConfig.states.idle }
        ShellActionButton { icon: "󰑓"; label: ""; minWidth: 40; tooltip: "Refresh work inbox counts"; tooltipState: workInboxPanel.shellRoot; onTriggered: workInboxPanel.refresh.running = true }
      }

      Rectangle { Layout.fillWidth: true; height: 1; color: theme.surfaceHigh }

      ShellSection {
        minHeight: theme.rowHeightLg

        RowLayout {
          Layout.fillWidth: true
          spacing: theme.spacingXl
          Text { color: workInboxPanel.shellRoot.workInboxSlackAvailable ? workInboxPanel.shellSettings.primaryColor : theme.textSubtle; font.family: theme.fontFamily; font.pixelSize: theme.fontIcon; text: "󰒱" }
          ColumnLayout {
            Layout.fillWidth: true
            spacing: theme.spacingXs
            ShellText { Layout.fillWidth: true; role: "strong"; elide: Text.ElideRight; text: "Slack" }
            Text { Layout.fillWidth: true; color: theme.textSoft; elide: Text.ElideRight; font.family: theme.fontFamily; font.pixelSize: theme.fontMd; text: workInboxPanel.shellRoot.workInboxSlackAvailable ? (workInboxPanel.shellRoot.workInboxSlackUnread + " unread, " + workInboxPanel.shellRoot.workInboxSlackMentions + " mentions") : workInboxPanel.shellRoot.workInboxSlackReason }
          }
          ShellActionButton { icon: "󰍉"; label: workInboxPanel.shellConfig.labels.open; minWidth: 78; tooltip: "Open Slack"; tooltipState: workInboxPanel.shellRoot; onTriggered: Quickshell.execDetached(workInboxPanel.shellConfig.slack()) }
        }
      }

      ShellSection {
        minHeight: theme.rowHeightLg

        RowLayout {
          Layout.fillWidth: true
          spacing: theme.spacingXl
          Text { color: workInboxPanel.shellRoot.workInboxGithubAvailable ? workInboxPanel.shellSettings.primaryColor : theme.textSubtle; font.family: theme.fontFamily; font.pixelSize: theme.fontIcon; text: "󰊤" }
          ColumnLayout {
            Layout.fillWidth: true
            spacing: theme.spacingXs
            ShellText { Layout.fillWidth: true; role: "strong"; elide: Text.ElideRight; text: "GitHub" }
            Text { Layout.fillWidth: true; color: theme.textSoft; elide: Text.ElideRight; font.family: theme.fontFamily; font.pixelSize: theme.fontMd; text: workInboxPanel.shellRoot.workInboxGithubAvailable ? (workInboxPanel.shellRoot.workInboxGithubReviews + " review requests") : workInboxPanel.shellRoot.workInboxGithubReason }
          }
          ShellActionButton { icon: "󰍉"; label: workInboxPanel.shellConfig.labels.open; minWidth: 78; tooltip: "Open GitHub review requests"; tooltipState: workInboxPanel.shellRoot; onTriggered: Quickshell.execDetached(workInboxPanel.shellConfig.browser("https://github.com/pulls/review-requested")) }
        }
      }

      ShellSection {
        minHeight: theme.rowHeightLg

        RowLayout {
          Layout.fillWidth: true
          spacing: theme.spacingXl
          Text { color: workInboxPanel.shellRoot.workInboxLinearAvailable ? workInboxPanel.shellSettings.primaryColor : theme.textSubtle; font.family: theme.fontFamily; font.pixelSize: theme.fontIcon; text: "󰘦" }
          ColumnLayout {
            Layout.fillWidth: true
            spacing: theme.spacingXs
            ShellText { Layout.fillWidth: true; role: "strong"; elide: Text.ElideRight; text: "Linear" }
            Text { Layout.fillWidth: true; color: theme.textSoft; elide: Text.ElideRight; font.family: theme.fontFamily; font.pixelSize: theme.fontMd; text: workInboxPanel.shellRoot.workInboxLinearAvailable ? (workInboxPanel.shellRoot.workInboxLinearNotifications + " notifications") : workInboxPanel.shellRoot.workInboxLinearReason }
          }
          ShellActionButton { icon: "󰍉"; label: workInboxPanel.shellConfig.labels.open; minWidth: 78; tooltip: "Open Linear inbox"; tooltipState: workInboxPanel.shellRoot; onTriggered: Quickshell.execDetached(workInboxPanel.shellConfig.browser("https://linear.app/inbox")) }
        }
      }

      Text { Layout.fillWidth: true; color: theme.textMuted; elide: Text.ElideRight; font.family: theme.fontFamily; font.pixelSize: theme.fontMd; text: workInboxPanel.shellRoot.workInboxUpdatedText.length > 0 ? ("Updated " + workInboxPanel.shellRoot.workInboxUpdatedText) : "Counts load when opened" }
  }
}
