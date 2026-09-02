import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "marcelof.board-status"

  function openDashboard() {
    var host = bar && bar.shell ? bar.shell : (bar ? bar.barRoot : null)
    if (host && typeof host.toggleShellMenu === "function")
      host.toggleShellMenu("marcelof.board-dashboard", "{}")
    else if (host && typeof host.togglePersonalDashboard === "function")
      host.togglePersonalDashboard()
  }

  Process {
    command: ["env", "BAR_COLOR_FORMAT=quickshell", "board", "--config",
      Quickshell.env("HOME") + "/.config/board/board.toml", "render", "--watch", "--format",
      "quickshell", "--surface", "quickshell-bar"]
    running: true
    stdout: SplitParser {
      splitMarker: "\n"
      onRead: data => status.text = String(data || "").trim()
    }
  }

  implicitWidth: status.implicitWidth
  implicitHeight: bar ? bar.barSize : status.implicitHeight

  Text {
    id: status
    anchors.centerIn: parent
    text: ""
    textFormat: Text.RichText
    color: root.bar ? root.bar.barForeground : Color.foreground
    font.family: root.bar ? root.bar.fontFamily : Style.font.family
    font.pixelSize: Style.font.body
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onEntered: if (root.bar) root.bar.showTooltip(root, "Board status")
    onExited: if (root.bar) root.bar.hideTooltip(root)
    onClicked: root.openDashboard()
  }
}
