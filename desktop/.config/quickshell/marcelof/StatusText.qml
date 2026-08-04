import Quickshell
import Quickshell.Io
import QtQuick

ShellText {
  id: root

  readonly property QtObject theme: ShellTheme {}

  required property var command
  property int interval: 5000
  property bool rich: false
  property bool watch: false
  property var leftClickCommand: []
  property var rightClickCommand: []
  property var middleClickCommand: []
  property var wheelUpCommand: []
  property var wheelDownCommand: []

  role: "large"
  color: theme.textMuted
  font.styleName: theme.fontStyle
  text: ""
  textFormat: root.rich ? Text.RichText : Text.PlainText

  function runCommand(command) {
    if (command && command.length > 0)
      Quickshell.execDetached(command)
  }

  Process {
    id: proc
    command: root.command
    running: !root.watch

    stdout: StdioCollector {
      onStreamFinished: root.text = this.text.trim()
    }
  }

  Process {
    id: watchProc
    command: root.command
    running: root.watch

    stdout: SplitParser {
      splitMarker: "
"
      onRead: data => root.text = String(data).trim()
    }
  }

  Timer {
    interval: root.interval
    running: !root.watch
    repeat: true
    onTriggered: proc.running = true
  }

  Timer {
    interval: Math.max(root.interval, 30000)
    running: root.watch
    repeat: true
    onTriggered: if (!watchProc.running) watchProc.running = true
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    enabled: root.leftClickCommand.length > 0 || root.rightClickCommand.length > 0 || root.middleClickCommand.length > 0 || root.wheelUpCommand.length > 0 || root.wheelDownCommand.length > 0
    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

    onClicked: mouse => {
      if (mouse.button === Qt.RightButton)
        root.runCommand(root.rightClickCommand)
      else if (mouse.button === Qt.MiddleButton)
        root.runCommand(root.middleClickCommand)
      else
        root.runCommand(root.leftClickCommand)
    }

    onWheel: wheel => {
      if (wheel.angleDelta.y > 0)
        root.runCommand(root.wheelUpCommand)
      else if (wheel.angleDelta.y < 0)
        root.runCommand(root.wheelDownCommand)
    }
  }
}
