import Quickshell
import QtQuick
import QtQuick.Layouts

ShellPopup {
  id: notificationCenter

  readonly property QtObject theme: ShellTheme {}
  required property var shellRoot
  required property var shellSettings
  required property var historyModel
  required property var inboxModel
  implicitWidth: historyModel.count === 0 ? 360 : panelWidth
  implicitHeight: historyModel.count === 0 ? 104 : panelHeight

  ShellFrame {
    anchors.fill: parent

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: theme.paddingMd
      spacing: theme.spacingLg

      RowLayout {
        Layout.fillWidth: true
        spacing: theme.spacingLg
        ShellText { Layout.fillWidth: true; role: "heading"; text: "Notifications" }
        ShellText { role: "muted"; text: notificationCenter.historyModel.count + "" }
        ShellActionButton {
          visible: notificationCenter.shellRoot.selectedNotificationIndex >= 0
          icon: "󰅖"
          label: "App"
          minWidth: 76
          tooltip: "Clear selected app notifications"
          tooltipState: notificationCenter.shellRoot
          onTriggered: notificationCenter.shellRoot.clearNotificationsForApp(notificationCenter.shellRoot.notificationAppAt(notificationCenter.shellRoot.selectedNotificationIndex))
        }
        ShellActionButton {
          icon: "󰅖"
          label: "All"
          minWidth: 76
          tooltip: "Clear all notifications"
          tooltipState: notificationCenter.shellRoot
          onTriggered: notificationCenter.shellRoot.clearNotifications()
        }
        ShellActionButton { icon: notificationCenter.shellSettings.doNotDisturb ? "󰂛" : "󰂚"; label: ""; minWidth: 40; active: notificationCenter.shellSettings.doNotDisturb; tooltip: notificationCenter.shellSettings.doNotDisturb ? "Allow popups" : "Silence popups"; tooltipState: notificationCenter.shellRoot; onTriggered: notificationCenter.shellRoot.toggleDnd() }
      }

      ShellStateBox {
        visible: notificationCenter.historyModel.count === 0
        minHeight: 72
        text: "No notifications"
      }

      ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: theme.spacingLg
        model: notificationCenter.inboxModel

        delegate: Rectangle {
          id: notificationDelegate

          required property string kind
          required property string app
          required property int count
          required property int sourceIndex
          required property string summary
          required property string body
          required property string text
          required property string actionsText
          required property string desktopEntry
          required property string time

          readonly property int notificationIndex: sourceIndex
          readonly property bool isGroup: kind === "group"
          readonly property bool expanded: !isGroup && notificationCenter.shellRoot.selectedNotificationIndex === notificationIndex
          width: ListView.view.width
          height: isGroup ? 40 : (expanded ? Math.max(132, detailColumn.implicitHeight + theme.paddingMd * 2) : 76)
          radius: isGroup ? 0 : theme.radiusSmall
          clip: true
          color: isGroup ? theme.transparent : (expanded ? theme.surfaceRaised : theme.surface)
          border.color: expanded ? notificationCenter.shellSettings.primaryColor : theme.transparent
          border.width: expanded ? 1 : 0

          Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            enabled: !notificationDelegate.isGroup
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
              if (notificationDelegate.expanded)
                notificationCenter.shellRoot.focusNotificationApp(notificationDelegate.notificationIndex)
              else
                notificationCenter.shellRoot.selectedNotificationIndex = notificationDelegate.notificationIndex
            }
          }

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 2
            anchors.rightMargin: 2
            visible: notificationDelegate.isGroup
            spacing: theme.spacingLg
            Text { Layout.fillWidth: true; color: theme.warning; elide: Text.ElideRight; font.family: theme.fontFamily; font.styleName: theme.fontStyle; font.pixelSize: theme.fontMd; text: app }
            ShellText { role: "muted"; text: count + "" }
            ShellActionButton { icon: "󰅖"; label: "App"; minWidth: 58; tooltip: "Clear app notifications"; tooltipState: notificationCenter.shellRoot; onTriggered: notificationCenter.shellRoot.clearNotificationsForApp(app) }
          }

          ColumnLayout {
            id: detailColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: theme.paddingMd
            visible: !notificationDelegate.isGroup
            spacing: theme.spacingSm

            RowLayout {
              Layout.fillWidth: true
              spacing: theme.spacingLg
              ShellText { Layout.fillWidth: true; role: "strong"; elide: Text.ElideRight; text: summary.length > 0 ? summary : text }
              ShellText { role: "subtle"; text: time }
              Rectangle {
                width: theme.barItemSize
                height: theme.barItemSize
                radius: theme.radiusTiny
                color: dismissMouse.containsMouse ? theme.border : theme.transparent
                Text { anchors.centerIn: parent; color: theme.textSoft; font.family: theme.fontFamily; font.pixelSize: theme.fontSm; text: "󰅖" }
                MouseArea { id: dismissMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: mouse => { mouse.accepted = true; notificationCenter.shellRoot.dismissNotification(notificationDelegate.notificationIndex) } }
              }
            }

            Text {
              Layout.fillWidth: true
              visible: !notificationDelegate.expanded && body.length > 0
              color: theme.textSoft
              elide: Text.ElideRight
              font.family: theme.fontFamily
              font.pixelSize: theme.fontSm
              maximumLineCount: 1
              wrapMode: Text.NoWrap
              text: body
            }

            Text {
              Layout.fillWidth: true
              visible: notificationDelegate.expanded && body.length > 0
              color: theme.textSoft
              elide: notificationDelegate.expanded ? Text.ElideNone : Text.ElideRight
              font.family: theme.fontFamily
              font.pixelSize: theme.fontSm
              maximumLineCount: notificationDelegate.expanded ? 8 : 1
              wrapMode: notificationDelegate.expanded ? Text.Wrap : Text.NoWrap
              text: notificationDelegate.expanded ? (body.length > 0 ? body : text) : body
            }

            RowLayout {
              Layout.fillWidth: true
              visible: notificationDelegate.expanded && (actionsText.length > 0 || desktopEntry.length > 0 || app.length > 0)
              spacing: theme.spacingMd

              ShellActionButton { icon: "󰍉"; label: "Open"; minWidth: 58; tooltip: "Focus source app"; tooltipState: notificationCenter.shellRoot; onTriggered: notificationCenter.shellRoot.focusNotificationApp(notificationDelegate.notificationIndex) }

              Repeater {
                model: notificationCenter.shellRoot.notificationActionLabels(notificationDelegate.notificationIndex)

                delegate: Rectangle {
                  required property string modelData
                  required property int index

                  Layout.fillWidth: true
                  Layout.minimumWidth: 54
                  Layout.preferredHeight: 24
                  Layout.preferredWidth: Math.min(128, Math.max(64, actionLabel.implicitWidth + theme.actionHorizontalPadding))
                  Layout.maximumWidth: 128
                  radius: theme.radiusTiny
                  clip: true
                  color: actionMouse.containsMouse ? theme.border : theme.surfaceHigh

                  Text {
                    id: actionLabel
                    anchors.fill: parent
                    anchors.leftMargin: theme.paddingSm
                    anchors.rightMargin: theme.paddingSm
                    color: theme.text
                    elide: Text.ElideRight
                    font.family: theme.fontFamily
                    font.pixelSize: theme.fontSm
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: modelData
                  }

                  MouseArea {
                    id: actionMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                      mouse.accepted = true
                      notificationCenter.shellRoot.invokeNotificationAction(notificationDelegate.notificationIndex, index)
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
