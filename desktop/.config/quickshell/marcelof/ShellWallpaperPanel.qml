import Quickshell
import QtQuick
import QtQuick.Layouts

ShellPopup {
  id: wallpaperPanel

  readonly property QtObject theme: ShellTheme {}
  required property var shellRoot
  required property var shellConfig
  required property var wallpapersModel
  property string hoveredPath: ""
  property int compactHeight: 360
  implicitHeight: Math.min(compactHeight, 184 + Math.max(1, wallpapersModel.count) * 39)

  ShellPanel {
    anchors.fill: parent
    gap: 9

      RowLayout {
        Layout.fillWidth: true
        ShellText { Layout.fillWidth: true; role: "title"; text: "Wallpaper" }
        ShellActionButton { icon: "󰈔"; label: ""; minWidth: 34; tooltip: "Open current"; tooltipState: wallpaperPanel.shellRoot; onTriggered: Quickshell.execDetached(wallpaperPanel.shellConfig.wallpaper("open-current")) }
        ShellActionButton { icon: "󰑓"; label: ""; minWidth: 34; tooltip: "Refresh"; tooltipState: wallpaperPanel.shellRoot; onTriggered: wallpaperPanel.shellRoot.refreshWallpapers() }
        ShellActionButton { icon: "󰈔"; label: ""; minWidth: 34; tooltip: "Open folder"; tooltipState: wallpaperPanel.shellRoot; onTriggered: Quickshell.execDetached(wallpaperPanel.shellConfig.wallpaper("open-dir")) }
      }

      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 92
        radius: theme.radiusSmall
        clip: true
        color: theme.surface
        border.color: theme.surfaceHigh

        Image {
          anchors.fill: parent
          source: wallpaperPanel.hoveredPath.length > 0 ? wallpaperPanel.shellConfig.fileUrl(wallpaperPanel.hoveredPath) : wallpaperPanel.shellRoot.wallpaperSource
          fillMode: Image.PreserveAspectCrop
          asynchronous: true
        }

        Rectangle {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          height: 26
          color: theme.surfaceLow
          opacity: 0.92
          ShellText {
            anchors.fill: parent
            anchors.leftMargin: theme.paddingMd
            anchors.rightMargin: theme.paddingMd
            role: "muted"
            elide: Text.ElideRight
            text: wallpaperPanel.hoveredPath.length > 0 ? wallpaperPanel.hoveredPath.split("/").pop() : "Current wallpaper"
          }
        }
      }

      ListView {
        id: wallpaperList
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: theme.spacingSm
        model: wallpaperPanel.wallpapersModel

        delegate: Rectangle {
          required property string name
          required property string path
          required property bool active
          width: wallpaperList.width
          height: 34
          radius: theme.radiusTiny
          color: active ? theme.surfaceHigh : (wallpaperMouse.containsMouse ? theme.surface : theme.transparent)

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 9
            anchors.rightMargin: 9
            spacing: theme.spacingLg
            Text { color: active ? theme.success : theme.textSubtle; font.family: theme.fontFamily; font.pixelSize: theme.fontMd; text: active ? "󰸉" : "󰋩" }
            ShellText { Layout.fillWidth: true; elide: Text.ElideRight; text: name }
          }

          MouseArea {
            id: wallpaperMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: wallpaperPanel.hoveredPath = path
            onExited: if (wallpaperPanel.hoveredPath === path) wallpaperPanel.hoveredPath = ""
            onClicked: wallpaperPanel.shellRoot.setWallpaper(path)
          }
        }
      }
  }
}
