import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
  id: rootMenu

  readonly property QtObject theme: ShellTheme {}
  required property var anchorWindow
  required property var shellRoot
  required property var shellConfig
  property bool panelOpen: false
  property int panelWidth: 360
  property int panelHeight: 620
  readonly property var menuItems: {
    const items = []
    const rows = shellConfig.controlMenuRows || []
    for (let row = 0; row < rows.length; row++)
      for (let item = 0; item < rows[row].length; item++)
        items.push(rows[row][item])
    return items
  }

  function close() {
    shellRoot.hideShellMenu("root-menu")
  }

  function selectRelative(delta) {
    if (menuList.count > 0)
      menuList.currentIndex = (menuList.currentIndex + delta + menuList.count) % menuList.count
  }

  function activateCurrent() {
    if (menuList.currentIndex < 0 || menuList.currentIndex >= menuItems.length)
      return
    shellRoot.runMenuAction(menuItems[menuList.currentIndex].action)
  }

  screen: shellRoot.laptopScreen
  visible: panelOpen
  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }
  color: theme.transparent
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.namespace: "quickshell-root-menu"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  onPanelOpenChanged: {
    if (panelOpen) {
      menuList.currentIndex = 0
      Qt.callLater(() => keyCatcher.forceActiveFocus())
    }
  }

  Rectangle {
    anchors.fill: parent
    color: theme.panel
    opacity: 0.58
  }

  MouseArea {
    anchors.fill: parent
    onClicked: rootMenu.close()
  }

  ShellFrame {
    id: card

    anchors.centerIn: parent
    width: Math.min(rootMenu.panelWidth, rootMenu.width - theme.spacingXxl * 2)
    height: Math.min(rootMenu.panelHeight, rootMenu.height - theme.spacingXxl * 2)

    MouseArea {
      anchors.fill: parent
      onClicked: mouse => mouse.accepted = true
    }

    Item {
      id: keyCatcher
      anchors.fill: parent
      focus: true
      Keys.onEscapePressed: rootMenu.close()
      Keys.onUpPressed: rootMenu.selectRelative(-1)
      Keys.onDownPressed: rootMenu.selectRelative(1)
      Keys.onReturnPressed: rootMenu.activateCurrent()
      Keys.onEnterPressed: rootMenu.activateCurrent()
    }

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: theme.panelMargin
      spacing: theme.spacingMd

      Text {
        Layout.fillWidth: true
        Layout.preferredHeight: theme.searchHeight
        verticalAlignment: Text.AlignVCenter
        color: theme.textMuted
        elide: Text.ElideRight
        font.family: theme.fontFamily
        font.styleName: theme.fontStyle
        font.pixelSize: theme.fontTitle
        text: "Go…"
      }

      ListView {
        id: menuList

        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: theme.spacingSm
        model: rootMenu.menuItems
        currentIndex: 0
        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
          id: menuRow
          readonly property bool selected: ListView.isCurrentItem
          required property var modelData
          required property int index

          width: menuList.width
          height: theme.searchHeight
          radius: theme.radius
          color: menuRow.selected ? theme.surfaceHigh : theme.transparent

          Text {
            width: 38
            anchors.left: parent.left
            anchors.leftMargin: theme.paddingSm
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            color: menuRow.selected ? theme.primary : theme.text
            font.family: theme.fontFamily
            font.pixelSize: theme.fontIcon
            text: modelData.icon
          }

          Text {
            anchors.left: parent.left
            anchors.leftMargin: 54
            anchors.right: trail.left
            anchors.rightMargin: theme.spacingMd
            anchors.verticalCenter: parent.verticalCenter
            color: theme.text
            elide: Text.ElideRight
            font.family: theme.fontFamily
            font.styleName: theme.fontStyle
            font.pixelSize: theme.fontXl
            text: modelData.label
          }

          Text {
            id: trail
            anchors.right: parent.right
            anchors.rightMargin: theme.paddingMd
            anchors.verticalCenter: parent.verticalCenter
            color: theme.textSubtle
            font.family: theme.fontFamily
            font.pixelSize: theme.fontXl
            text: "›"
          }

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: menuList.currentIndex = index
            onClicked: {
              menuList.currentIndex = index
              rootMenu.activateCurrent()
            }
          }
        }
      }
    }
  }
}
