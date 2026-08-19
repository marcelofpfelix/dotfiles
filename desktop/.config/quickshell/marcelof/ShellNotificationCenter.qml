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
          label: "Clear app"
          minWidth: 108
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
          required property string appIcon
          required property string image
          required property int count
          required property int sourceIndex
          required property string summary
          required property string body
          required property string text
          required property string actionsText
          required property string desktopEntry
          required property string time
          required property bool liveActions

          readonly property int notificationIndex: sourceIndex
          readonly property bool isGroup: kind === "group"
          readonly property bool expanded: !isGroup && notificationCenter.shellRoot.selectedNotificationIndex === notificationIndex
          readonly property string iconSource: notificationCenter.shellRoot.notificationImageSource(isGroup || image.length === 0 ? appIcon : image)
          readonly property int contentHeight: Math.ceil(notificationCard.implicitHeight)
          width: ListView.view.width
          height: isGroup ? 40 : Math.max(expanded ? 112 : 88, contentHeight)
          radius: isGroup ? 0 : theme.radiusSmall
          clip: true
          color: theme.transparent
          border.width: 0

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
            Item {
              Layout.preferredWidth: 24
              Layout.preferredHeight: 24

              Image {
                id: groupIconImage
                anchors.fill: parent
                source: notificationDelegate.iconSource
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
                visible: source.length > 0 && status !== Image.Error
              }

              Text {
                anchors.centerIn: parent
                visible: groupIconImage.status !== Image.Ready
                color: theme.warning
                font.family: theme.fontFamily
                font.pixelSize: theme.fontMd
                text: app.length > 0 ? app.charAt(0).toUpperCase() : "N"
              }
            }
            Text { Layout.fillWidth: true; color: theme.warning; elide: Text.ElideRight; font.family: theme.fontFamily; font.styleName: theme.fontStyle; font.pixelSize: theme.fontMd; text: app }
            ShellText { role: "muted"; text: count + "" }
            ShellActionButton { icon: "󰅖"; label: "Clear"; minWidth: 80; tooltip: "Clear app notifications"; tooltipState: notificationCenter.shellRoot; onTriggered: notificationCenter.shellRoot.clearNotificationsForApp(app) }
          }

          ShellNotificationCard {
            id: notificationCard
            anchors.fill: parent
            visible: !notificationDelegate.isGroup
            app: notificationDelegate.app
            appIcon: notificationDelegate.appIcon
            image: notificationDelegate.image
            summary: notificationDelegate.summary.length > 0 ? notificationDelegate.summary : notificationDelegate.text
            body: notificationDelegate.body
            time: notificationDelegate.time
            actionsText: notificationDelegate.actionsText
            expanded: notificationDelegate.expanded
            liveActions: notificationDelegate.liveActions
            showActions: (notificationDelegate.liveActions && notificationDelegate.actionsText.length > 0) || (notificationDelegate.expanded && (notificationDelegate.desktopEntry.length > 0 || notificationDelegate.app.length > 0))
            selected: notificationDelegate.expanded
            tooltipState: notificationCenter.shellRoot
            onCloseRequested: notificationCenter.shellRoot.dismissNotification(notificationDelegate.notificationIndex)
            onOpenRequested: {
              if (notificationDelegate.expanded)
                notificationCenter.shellRoot.focusNotificationApp(notificationDelegate.notificationIndex)
              else
                notificationCenter.shellRoot.selectedNotificationIndex = notificationDelegate.notificationIndex
            }
            onActionRequested: index => notificationCenter.shellRoot.invokeNotificationAction(notificationDelegate.notificationIndex, index)
          }
        }
      }
    }
  }
}
