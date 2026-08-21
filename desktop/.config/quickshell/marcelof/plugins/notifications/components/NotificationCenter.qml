import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Ui

PopupWindow {
  id: root

  required property var service
  required property var shell

  readonly property var anchorWindow: shell && shell.bar ? shell.bar.primaryWindow : null
  readonly property string fontFamily: shell && shell.bar ? shell.bar.fontFamily : Style.font.family

  visible: service.historyPanelOpen
  color: "transparent"
  implicitWidth: 700
  implicitHeight: 600

  anchor.window: anchorWindow
  anchor.rect.x: anchorWindow ? Math.max(Style.gapsOut, Math.round((anchorWindow.width - implicitWidth) / 2)) : 0
  anchor.rect.y: anchorWindow ? anchorWindow.height + Style.gapsOut : 0

  function iconSource(value) {
    var icon = String(value || "")
    if (icon.length === 0) return ""
    if (icon.indexOf("file://") === 0 || icon.indexOf("image://") === 0) return icon
    if (icon.charAt(0) === "/") return Util.fileUrl(icon)
    return Quickshell.iconPath(icon, true)
  }

  BorderSurface {
    anchors.fill: parent
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
          text: "Clear all"
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
          text: "No notifications"
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
            required property int count
            required property int originalId
            required property double timestamp
            required property string summary
            required property string body
            required property string image
            required property string glyph
            required property int urgency

            readonly property bool group: kind === "group"
            width: ListView.view ? ListView.view.width : 0
            height: group ? Style.space(38) : card.implicitHeight

            RowLayout {
              anchors.fill: parent
              visible: row.group
              spacing: Style.spacing.md

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
                Layout.fillWidth: true
                text: row.app
                color: Color.accent
                elide: Text.ElideRight
                font.family: root.fontFamily
                font.pixelSize: Style.font.body
                font.bold: true
              }

              Text {
                text: String(row.count)
                color: Color.muted
                font.family: root.fontFamily
                font.pixelSize: Style.font.bodySmall
              }

              Button {
                text: "Clear"
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
              summary: row.summary
              body: row.body
              image: row.image
              glyph: row.glyph
              urgency: row.urgency
              timestamp: row.timestamp
              cornerRadius: Style.cornerRadius
              fontFamily: root.fontFamily
              onCloseRequested: root.service.removeHistoryEntry(row.originalId, row.timestamp, row.app)
              onCardClicked: root.service.focusHistoryEntry(row.originalId, row.timestamp, row.app)
            }
          }
        }
      }
    }
  }
}
