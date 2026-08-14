import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

ShellFloatingPopup {
  id: launcherPanel

  readonly property QtObject theme: ShellTheme {}
  required property var launcherModel
  property int panelWidth: 720
  property int panelHeight: 720
  property alias searchText: search.text
  property alias currentIndex: appList.currentIndex

  title: "quickshell-launcher"

  function focusSearch() {
    search.forceActiveFocus()
  }

  function positionCurrent() {
    appList.positionCurrent()
  }
  IpcHandler {
    target: "launcher"

    function toggle() { launcherPanel.shellRoot.toggleLauncher() }
    function open() {
      launcherPanel.panelOpen = true
      launcherPanel.searchText = ""
      launcherPanel.shellRoot.rebuildLauncher()
      launcherPanel.focusSearch()
    }
    function show() { open() }
    function hide() { launcherPanel.close() }
    function state(): string { return launcherPanel.panelOpen ? "open" : "closed" }
    function visibleById(entryId: string): string {
      const previousSearch = launcherPanel.searchText
      launcherPanel.searchText = ""
      launcherPanel.shellRoot.rebuildLauncher()
      let visible = false
      for (let i = 0; i < launcherPanel.launcherModel.count; i++) {
        if (String(launcherPanel.launcherModel.get(i).id || "") === String(entryId || "")) {
          visible = true
          break
        }
      }
      launcherPanel.searchText = previousSearch
      if (launcherPanel.visible)
        launcherPanel.shellRoot.rebuildLauncher()
      return visible ? "visible" : "hidden"
    }
    function launchableById(entryId: string): string {
      const values = DesktopEntries.applications.values || []
      for (let i = 0; i < values.length; i++) {
        const entry = values[i]
        if (String(entry && entry.id || "") !== String(entryId || ""))
          continue
        if ((entry.command && entry.command.length > 0) || typeof entry.execute === "function")
          return "launchable"
        return "not-launchable"
      }
      return "missing"
    }
    function hiddenRoundTrip(entryId: string): string {
      const previousSmokeHiddenId = launcherPanel.shellRoot.launcherSmokeHiddenId
      let before = "unknown"
      let hidden = "unknown"
      let after = "unknown"
      try {
        before = visibleById(entryId)
        launcherPanel.shellRoot.launcherSmokeHiddenId = entryId
        hidden = visibleById(entryId)
      } finally {
        launcherPanel.shellRoot.launcherSmokeHiddenId = previousSmokeHiddenId
        after = visibleById(entryId)
      }
      return before + "|" + hidden + "|" + after
    }
  }

  ShellFrame {
    anchors.fill: parent

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: theme.panelMargin
      spacing: theme.spacingXl

      ShellSearchBox {
        id: search
        onTextChanged: launcherPanel.shellRoot.rebuildLauncher()
        onEscapePressed: launcherPanel.shellRoot.hideLauncher()
        onDownPressed: { appList.selectRelative(1) }
        onUpPressed: { appList.selectRelative(-1) }
        onAccepted: launcherPanel.shellRoot.launchCurrentApp()
        onKeyPressed: event => {
          if ((event.modifiers & Qt.AltModifier) && event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
            launcherPanel.shellRoot.launchAppAtIndex(event.key - Qt.Key_1)
            event.accepted = true
          }
        }
      }

      ShellPickerList {
        id: appList
        Layout.bottomMargin: theme.inputInset
        bottomMargin: theme.inputInset
        model: launcherPanel.launcherModel

        delegate: Rectangle {
          required property var modelData
          required property int index
          width: appList.width
          height: theme.launcherRowHeight
          color: ListView.isCurrentItem ? theme.surfaceHigh : theme.transparent
          radius: theme.radiusTiny

          Column {
            anchors.left: parent.left
            anchors.leftMargin: 44
            anchors.right: parent.right
            anchors.rightMargin: 82
            anchors.verticalCenter: parent.verticalCenter
            spacing: theme.spacingXs

            Text {
              width: parent.width
              color: theme.text
              elide: Text.ElideRight
              font.family: theme.fontFamily
              font.styleName: theme.fontStyle
              font.pixelSize: theme.fontXl
              text: modelData.name
            }

            Text {
              width: parent.width
              visible: modelData.subtext.length > 0
              color: theme.textMuted
              elide: Text.ElideRight
              font.family: theme.fontFamily
              font.pixelSize: theme.fontSm
              text: modelData.subtext
            }
          }

          Image {
            anchors.left: parent.left
            anchors.leftMargin: theme.paddingMd
            anchors.verticalCenter: parent.verticalCenter
            width: theme.barItemSize
            height: theme.barItemSize
            source: Quickshell.iconPath(modelData.icon, true)
          }

          Row {
            anchors.right: parent.right
            anchors.rightMargin: theme.paddingSm
            anchors.verticalCenter: parent.verticalCenter
            spacing: theme.spacingMd
            visible: modelData.id.length > 0
            Text { color: modelData.favorite ? theme.warning : theme.textSubtle; font.family: theme.fontFamily; font.pixelSize: theme.fontLg; text: modelData.favorite ? "" : ""; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: mouse => { mouse.accepted = true; launcherPanel.shellRoot.toggleLauncherFavoriteById(modelData.id) } } }
            Text { color: theme.textSubtle; font.family: theme.fontFamily; font.pixelSize: theme.fontLg; text: "󰈉"; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: mouse => { mouse.accepted = true; launcherPanel.shellRoot.hideLauncherById(modelData.id) } } }
          }

          MouseArea {
            anchors.fill: parent
            anchors.rightMargin: modelData.id.length > 0 ? 82 : 0
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            hoverEnabled: true
            onEntered: appList.currentIndex = index
            onClicked: mouse => {
              appList.currentIndex = index
              if (mouse.button === Qt.RightButton && modelData.id.length > 0)
                launcherPanel.shellRoot.toggleLauncherFavoriteById(modelData.id)
              else if (mouse.button === Qt.MiddleButton && modelData.id.length > 0)
                launcherPanel.shellRoot.hideLauncherById(modelData.id)
              else
                launcherPanel.shellRoot.launchAppAtIndex(index)
            }
          }
        }
      }

      ShellStateBox {
        visible: launcherPanel.launcherModel.count === 0
        text: launcherPanel.searchText.length > 0 ? "No matching apps" : "No launcher entries"
      }
    }
  }
}
