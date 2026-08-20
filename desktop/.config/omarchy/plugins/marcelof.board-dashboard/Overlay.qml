import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

Item {
  id: root
  property var targetScreen: null
  property var shell: null
  property var manifest: null
  property bool opened: false
  property string surface: "personal.today"
  property string output: ""
  readonly property var surfaces: ["quickshell-bar", "personal.today", "personal.money", "personal.health", "personal.habits"]
  readonly property string boardConfig: Quickshell.env("HOME") + "/.config/board/board.toml"

  function command(args) { return ["board", "--config", boardConfig].concat(args) }
  function open(payloadJson) { opened = true; refresh(); Qt.callLater(function() { keys.forceActiveFocus() }) }
  function close() { opened = false }
  function dismiss() {
    close()
    if (shell && typeof shell.hide === "function") shell.hide((manifest && manifest.id) || "marcelof.board-dashboard")
  }
  function refresh() {
    if (!render.running) {
      render.command = command(["render", "text", surface])
      render.running = true
    }
  }
  function selectSurface(value) { surface = value; refresh() }

  Process {
    id: render
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.output = String(this.text || "").trim()
    }
  }
  Process {
    id: action
    command: root.command(["action", "personal.refresh"])
    onExited: root.refresh()
  }

  PanelWindow {
    id: panel
    screen: root.targetScreen
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "marcelof-board-dashboard"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Rectangle { anchors.fill: parent; color: Color.menu.scrim }
    MouseArea { anchors.fill: parent; onClicked: root.dismiss() }

    BorderSurface {
      id: card
      width: Math.min(Style.space(680), panel.width - Style.gapsOut * 2)
      height: Math.min(Style.space(520), panel.height - Style.gapsOut * 2)
      anchors.centerIn: parent
      radius: Style.cornerRadius
      color: Color.menu.background
      borderSpec: Border.surfaceSpec("menu", "border", Color.menu.border, Math.max(1, Style.normalBorderWidth))
      padding: Style.spacing.panelPadding

      MouseArea { anchors.fill: parent; onClicked: {} }
      Item { id: keys; anchors.fill: parent; focus: true; Keys.onEscapePressed: root.dismiss() }

      ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: Style.spacing.panelGap

        RowLayout {
          Layout.fillWidth: true
          Text { Layout.fillWidth: true; text: "Personal dashboard"; color: Color.menu.text; font.family: Style.font.family; font.pixelSize: Style.font.title; font.bold: true }
          Button { iconText: "󰑓"; tooltipText: "Refresh"; foreground: Color.menu.text; enabled: !render.running; onClicked: root.refresh() }
          Button { iconText: "󰑐"; text: "Run"; foreground: Color.menu.text; enabled: !action.running; onClicked: action.running = true }
        }
        RowLayout {
          Layout.fillWidth: true
          spacing: Style.spacing.controlGap
          Repeater {
            model: root.surfaces
            Button {
              required property string modelData
              Layout.fillWidth: true
              text: modelData === "quickshell-bar" ? "System" : modelData.replace("personal.", "")
              foreground: Color.menu.text
              selected: root.surface === modelData
              onClicked: root.selectSurface(modelData)
            }
          }
        }
        PanelSeparator { Layout.fillWidth: true; foreground: Color.menu.text }
        Flickable {
          Layout.fillWidth: true
          Layout.fillHeight: true
          contentWidth: width
          contentHeight: content.implicitHeight
          clip: true
          boundsBehavior: Flickable.StopAtBounds
          Text {
            id: content
            width: parent.width
            text: root.output || (render.running ? "Loading..." : "No board data")
            color: Color.muted
            font.family: Style.font.family
            font.pixelSize: root.surface === "quickshell-bar" ? Style.font.body : Style.font.bodySmall
            textFormat: root.surface === "quickshell-bar" ? Text.RichText : Text.PlainText
            wrapMode: root.surface === "quickshell-bar" ? Text.Wrap : Text.NoWrap
          }
        }
      }
    }
  }
}
