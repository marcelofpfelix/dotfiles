import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui

PanelWindow {
  id: root

  required property var service
  required property var shell

  readonly property var anchorWindow: shell && shell.bar ? shell.bar.primaryWindow : null
  readonly property string fontFamily: shell && shell.bar ? shell.bar.fontFamily : Style.font.family
  readonly property int panelWidth: 700
  readonly property int panelHeight: 600
  readonly property int panelTop: anchorWindow ? anchorWindow.height + Style.gapsOut : Style.gapsOut

  visible: service.historyPanelOpen
  color: "transparent"
  screen: anchorWindow ? anchorWindow.screen : null
  exclusionMode: ExclusionMode.Ignore
  anchors { top: true; bottom: true; left: true; right: true }
  WlrLayershell.namespace: "omarchy-notification-center"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  onVisibleChanged: if (visible) Qt.callLater(function() { searchField.forceActiveFocus() })

  function iconSource(value) {
    var icon = String(value || "")
    if (icon.length === 0) return ""
    if (icon.indexOf("file://") === 0 || icon.indexOf("image://") === 0) return icon
    if (icon.charAt(0) === "/") return Util.fileUrl(icon)
    return Quickshell.iconPath(icon, true)
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.service.closeHistoryPanel()
  }

  BorderSurface {
    width: Math.min(root.panelWidth, root.width - Style.gapsOut * 2)
    height: Math.min(root.panelHeight, root.height - root.panelTop - Style.gapsOut)
    anchors.top: parent.top
    anchors.topMargin: root.panelTop
    anchors.horizontalCenter: parent.horizontalCenter
    color: Color.popups.background
    borderSpec: Border.surfaceSpec("popups", "border", Color.popups.border, Math.max(1, Style.space(2)))
    radius: Style.cornerRadius
    padding: Style.spacing.panelPadding

    ColumnLayout {
      anchors.fill: parent
      anchors.topMargin: parent.contentTopInset
      anchors.rightMargin: parent.contentRightInset
      anchors.bottomMargin: parent.contentBottomInset
      anchors.leftMargin: parent.contentLeftInset
      spacing: Style.spacing.panelGap

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.spacing.md

        Text {
          Layout.fillWidth: true
          text: "Notifications"
          color: Color.foreground
          font.family: root.fontFamily
          font.pixelSize: Style.font.title
          font.bold: true
        }

        Text {
          text: String(root.service.historyEntryCount)
          color: Color.muted
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
        }

        Button {
          text: "Read all"
          fontFamily: root.fontFamily
          bordered: true
          enabled: root.service.historyUnreadCount > 0
          onClicked: root.service.markAllHistoryRead()
        }

        Button {
          text: "Delete all"
          iconText: String.fromCodePoint(0xF0156)
          fontFamily: root.fontFamily
          bordered: true
          enabled: root.service.historyEntryCount > 0
          onClicked: root.service.clearHistoryPanel()
        }

        Button {
          iconText: root.service.doNotDisturb ? String.fromCodePoint(0xF009B) : String.fromCodePoint(0xF009A)
          tooltipText: root.service.doNotDisturb ? "Allow notification popups" : "Silence notification popups"
          fontFamily: root.fontFamily
          selected: root.service.doNotDisturb
          bordered: true
          onClicked: root.service.setDoNotDisturb(!root.service.doNotDisturb)
        }

        Button {
          iconText: String.fromCodePoint(0xF0156)
          tooltipText: "Close"
          fontFamily: root.fontFamily
          bordered: true
          onClicked: root.service.closeHistoryPanel()
        }
      }

      RowLayout {
        Layout.fillWidth: true
        spacing: Style.spacing.md

        TextField {
          id: searchField
          Layout.fillWidth: true
          placeholderText: "Search notifications"
          text: root.service.historySearchText
          onTextChanged: if (text !== root.service.historySearchText) root.service.setHistorySearchText(text)
          onAccepted: root.service.focusFirstHistoryEntry()
          Keys.onEscapePressed: root.service.closeHistoryPanel()
        }

        Button {
          visible: root.service.historyAppFilter.length > 0
          text: root.service.historyAppFilter
          iconText: String.fromCodePoint(0xF0156)
          tooltipText: "Show all applications"
          fontFamily: root.fontFamily
          bordered: true
          onClicked: root.service.setHistoryAppFilter("")
        }

        Repeater {
          model: [
            { value: "all", label: "All" },
            { value: "unread", label: "Unread" },
            { value: "read", label: "Read" }
          ]

          Button {
            required property var modelData
            text: modelData.label
            fontFamily: root.fontFamily
            selected: root.service.historyReadFilter === modelData.value
            bordered: true
            onClicked: root.service.setHistoryReadFilter(modelData.value)
          }
        }
      }

      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Color.popups.border
      }

      Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        Text {
          anchors.centerIn: parent
          visible: root.service.historyPanelLoading
          text: "Loading notifications..."
          color: Color.muted
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
        }

        Text {
          anchors.centerIn: parent
          visible: !root.service.historyPanelLoading && root.service.historyEntryCount === 0
          text: root.service.historySearchText.length > 0 || root.service.historyAppFilter.length > 0 || root.service.historyReadFilter !== "all" ? "No matching notifications" : "No notifications"
          color: Color.muted
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
        }

        ListView {
          id: historyList
          anchors.fill: parent
          visible: !root.service.historyPanelLoading && root.service.historyEntryCount > 0
          clip: true
          spacing: Style.spacing.md
          model: root.service.historyPanelModel

          delegate: Item {
            id: row

            required property string kind
            required property string app
            required property string appIcon
            required property string desktopEntry
            required property int count
            required property int originalId
            required property double timestamp
            required property string summary
            required property string body
            required property string image
            required property string glyph
            required property string exec
            required property bool read
            required property bool collapsed
            required property int unread
            required property int urgency

            readonly property bool group: kind === "group"
            width: ListView.view ? ListView.view.width : 0
            height: group ? Style.space(38) : card.implicitHeight

            RowLayout {
              anchors.fill: parent
              visible: row.group
              spacing: Style.spacing.md

              Button {
                iconText: String.fromCodePoint(row.collapsed ? 0xF0142 : 0xF0140)
                tooltipText: row.collapsed ? "Expand " + row.app : "Collapse " + row.app
                fontFamily: root.fontFamily
                onClicked: root.service.toggleHistoryAppCollapsed(row.app)
              }

              Item {
                Layout.preferredWidth: Style.space(24)
                Layout.preferredHeight: Style.space(24)

                Image {
                  id: appIconImage
                  anchors.fill: parent
                  source: root.iconSource(row.appIcon)
                  fillMode: Image.PreserveAspectFit
                  asynchronous: true
                  smooth: true
                  visible: source.length > 0 && status === Image.Ready
                }

                Text {
                  anchors.centerIn: parent
                  visible: appIconImage.status !== Image.Ready
                  text: row.app.length > 0 ? row.app.charAt(0).toUpperCase() : "N"
                  color: Color.accent
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.body
                  font.bold: true
                }
              }

              Text {
                id: groupName
                Layout.fillWidth: true
                text: row.app
                color: groupScopeArea.containsMouse ? Color.foreground : Color.accent
                elide: Text.ElideRight
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                font.bold: true

                MouseArea {
                  id: groupScopeArea
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.service.setHistoryAppFilter(row.app)
                }
              }

              Text {
                text: row.unread > 0 ? (String(row.unread) + " unread / " + String(row.count)) : String(row.count)
                color: row.unread > 0 ? Color.accent : Color.muted
                font.family: root.fontFamily
                font.pixelSize: Style.font.bodySmall
              }

              Button {
                iconText: String.fromCodePoint(0xF01B4)
                tooltipText: "Delete " + row.app + " notifications"
                fontFamily: root.fontFamily
                onClicked: root.service.clearHistoryApp(row.app)
              }
            }

            NotificationCard {
              id: card
              visible: !row.group
              width: parent.width
              app: row.app
              appIcon: row.appIcon
              desktopEntry: row.desktopEntry
              summary: row.summary
              body: row.body
              image: row.image
              glyph: row.glyph
              urgency: row.urgency
              timestamp: row.timestamp
              cornerRadius: Style.cornerRadius
              fontFamily: root.fontFamily
              historyMode: true
              read: row.read
              onMarkReadRequested: root.service.markHistoryEntryRead(row.originalId, row.timestamp)
              onCloseRequested: root.service.removeHistoryEntry(row.originalId, row.timestamp, row.app)
              onCardClicked: root.service.focusHistoryEntry(row.originalId, row.timestamp, row.app, row.appIcon, row.desktopEntry, row.exec)
            }
          }
        }
      }
    }
  }
}
