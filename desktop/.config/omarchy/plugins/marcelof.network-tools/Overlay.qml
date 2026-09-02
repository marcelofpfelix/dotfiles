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
  property bool reconnectArmed: false
  property string details: "Loading network details…"

  readonly property color background: Color.menu.background
  readonly property color foreground: Color.menu.text
  readonly property color subtle: Color.muted
  readonly property color scrim: Color.menu.scrim
  readonly property int cardWidth: Math.min(Style.space(560), panel.width - Style.gapsOut * 2)
  readonly property int cardHeight: Math.min(Style.space(440), panel.height - Style.gapsOut * 2)

  function open(payloadJson) {
    opened = true
    reconnectArmed = false
    refresh()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    opened = false
    reconnectArmed = false
  }

  function dismiss() {
    close()
    if (shell && typeof shell.hide === "function")
      shell.hide((manifest && manifest.id) || "marcelof.network-tools")
  }

  function refresh(includePublicIp) {
    if (detailsProc.running) return
    detailsProc.command = ["network-status", includePublicIp === true ? "details" : "details-local"]
    detailsProc.running = true
  }

  function reconnect() {
    if (!reconnectArmed) {
      reconnectArmed = true
      confirmTimer.restart()
      return
    }
    reconnectArmed = false
    reconnectProc.running = true
  }

  Process {
    id: detailsProc
    command: ["network-status", "details-local"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.details = String(this.text || "").trim() || "Network details unavailable"
    }
  }

  Process {
    id: reconnectProc
    command: ["network-status", "reconnect"]
    onExited: root.refresh()
  }

  Timer {
    id: confirmTimer
    interval: 5000
    onTriggered: root.reconnectArmed = false
  }

  PanelWindow {
    id: panel
    screen: root.targetScreen
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "marcelof-network-tools"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Rectangle { anchors.fill: parent; color: root.scrim }
    MouseArea { anchors.fill: parent; onClicked: root.dismiss() }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      anchors.centerIn: parent
      radius: Style.cornerRadius
      color: root.background
      borderSpec: Border.surfaceSpec("menu", "border", Color.menu.border, Math.max(1, Style.normalBorderWidth))
      padding: Style.spacing.panelPadding

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.dismiss()
        Keys.onPressed: function(event) {
          if (event.key === Qt.Key_R && event.modifiers === Qt.NoModifier) {
            root.refresh()
            event.accepted = true
          }
        }
      }

      ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: Style.spacing.panelGap

        RowLayout {
          Layout.fillWidth: true

          Text {
            Layout.fillWidth: true
            text: "Network details"
            color: root.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            font.bold: true
          }

          Button {
            iconText: "󰑐"
            tooltipText: "Refresh"
            foreground: root.foreground
            enabled: !detailsProc.running
            onClicked: root.refresh()
          }

          Button {
            iconText: "󰩟"
            tooltipText: "Fetch public IP"
            foreground: root.foreground
            enabled: !detailsProc.running
            onClicked: root.refresh(true)
          }
        }

        BorderSurface {
          Layout.fillWidth: true
          Layout.fillHeight: true
          color: Style.normalFillFor(root.foreground, Color.accent)
          borderSpec: Border.controlSpec("normal", root.foreground, Color.accent)
          radius: Style.cornerRadius
          padding: Style.spacing.panelPadding

          Text {
            anchors.fill: parent
            anchors.topMargin: parent.contentTopInset
            anchors.rightMargin: parent.contentRightInset
            anchors.bottomMargin: parent.contentBottomInset
            anchors.leftMargin: parent.contentLeftInset
            text: root.details
            color: root.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.body
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            maximumLineCount: 16
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.spacing.controlGap

          Button {
            Layout.fillWidth: true
            iconText: "󰍜"
            text: "Settings"
            foreground: root.foreground
            onClicked: {
              root.dismiss()
              Quickshell.execDetached(["nm-connection-editor"])
            }
          }

          Button {
            Layout.fillWidth: true
            iconText: root.reconnectArmed ? "󰄬" : "󰑓"
            text: root.reconnectArmed ? "Confirm reconnect" : "Reconnect"
            foreground: root.reconnectArmed ? Color.urgent : root.foreground
            enabled: !reconnectProc.running
            onClicked: root.reconnect()
          }
        }

        Text {
          Layout.fillWidth: true
          visible: root.reconnectArmed
          text: "Reconnect briefly interrupts the active network."
          color: Color.urgent
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
          horizontalAlignment: Text.AlignHCenter
        }
      }
    }
  }
}
