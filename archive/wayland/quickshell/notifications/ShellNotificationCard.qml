import Quickshell
import QtQuick
import QtQuick.Layouts

// Adapted from Omarchy Quattro's presentational NotificationCard idea:
// one card component reused by toast and history, with local theme/widgets.
Rectangle {
  id: card

  readonly property QtObject theme: ShellTheme {}

  property string app: ""
  property string appIcon: ""
  property string image: ""
  property string summary: ""
  property string body: ""
  property string fallbackIcon: "󰂚"
  property string time: ""
  property string actionsText: ""
  property bool expanded: false
  property bool liveActions: false
  property bool showActions: false
  property bool selected: false
  property int urgency: 1
  property var tooltipState

  signal closeRequested()
  signal openRequested()
  signal actionRequested(int index)

  function imageSource(value) {
    const source = String(value || "")
    if (source.length === 0)
      return ""
    if (source.indexOf("file://") === 0 || source.indexOf("image://") === 0)
      return source
    if (source.charAt(0) === "/")
      return "file://" + source
    return Quickshell.iconPath(source, true)
  }

  readonly property string resolvedIcon: imageSource(image.length > 0 ? image : appIcon)
  readonly property string titleText: summary.length > 0 ? summary : (app.length > 0 ? app : "Notification")
  readonly property int minCardHeight: expanded ? 112 : 88

  implicitHeight: Math.max(minCardHeight, content.implicitHeight + theme.paddingMd * 2)
  radius: theme.radiusSmall
  clip: true
  color: selected ? theme.surfaceRaised : theme.surface
  border.color: selected ? theme.primary : theme.transparent
  border.width: selected ? 1 : 0

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor
    onClicked: mouse => {
      if (mouse.button === Qt.RightButton)
        card.closeRequested()
      else
        card.openRequested()
    }
  }

  ColumnLayout {
    id: content
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.margins: theme.paddingMd
    spacing: theme.spacingSm

    RowLayout {
      Layout.fillWidth: true
      spacing: theme.spacingLg

      Item {
        Layout.preferredWidth: 34
        Layout.preferredHeight: 34

        Image {
          id: iconImage
          anchors.fill: parent
          source: card.resolvedIcon
          sourceSize.width: 34 * Screen.devicePixelRatio
          sourceSize.height: 34 * Screen.devicePixelRatio
          fillMode: Image.PreserveAspectFit
          asynchronous: true
          smooth: true
          visible: source.length > 0 && status !== Image.Error
        }

        ShellText {
          anchors.centerIn: parent
          role: "icon"
          visible: iconImage.status !== Image.Ready
          color: card.urgency >= 2 ? theme.error : theme.warning
          text: card.fallbackIcon
        }
      }

      ShellText {
        Layout.fillWidth: true
        role: "strong"
        elide: Text.ElideRight
        maximumLineCount: 2
        wrapMode: Text.WordWrap
        text: card.titleText
      }

      ShellText {
        visible: card.time.length > 0
        role: "subtle"
        text: card.time
      }

      Rectangle {
        width: theme.barItemSize
        height: theme.barItemSize
        radius: theme.radiusTiny
        color: closeMouse.containsMouse ? theme.border : theme.transparent

        ShellText {
          anchors.centerIn: parent
          role: "subtle"
          text: "󰅖"
        }

        MouseArea {
          id: closeMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: mouse => {
            mouse.accepted = true
            card.closeRequested()
          }
        }
      }
    }

    Text {
      Layout.fillWidth: true
      visible: card.body.length > 0
      color: theme.textSoft
      elide: card.expanded ? Text.ElideNone : Text.ElideRight
      font.family: theme.fontFamily
      font.pixelSize: card.expanded ? theme.fontSm : theme.fontMd
      maximumLineCount: card.expanded ? 8 : 2
      wrapMode: card.expanded ? Text.Wrap : Text.WordWrap
      text: card.body
    }

    Image {
      Layout.preferredWidth: 96
      Layout.preferredHeight: 64
      Layout.maximumWidth: 96
      Layout.maximumHeight: 64
      visible: card.expanded && card.image.length > 0 && status !== Image.Error
      source: card.imageSource(card.image)
      fillMode: Image.PreserveAspectFit
      asynchronous: true
      smooth: true
    }

    RowLayout {
      Layout.fillWidth: true
      visible: card.showActions
      spacing: theme.spacingMd

      ShellActionButton {
        icon: "󰍉"
        label: "Open app"
        minWidth: 100
        tooltip: "Focus source app"
        tooltipState: card.tooltipState
        onTriggered: card.openRequested()
      }

      Repeater {
        model: card.liveActions && card.actionsText.length > 0 ? card.actionsText.split(" | ") : []

        delegate: ShellActionButton {
          required property string modelData
          required property int index

          icon: "󰐊"
          label: modelData
          minWidth: 88
          Layout.maximumWidth: 150
          tooltip: "Run notification action: " + modelData
          tooltipState: card.tooltipState
          onTriggered: card.actionRequested(index)
        }
      }
    }
  }
}
