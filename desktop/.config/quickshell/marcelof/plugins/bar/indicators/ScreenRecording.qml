import QtQuick
import qs.Ui

BarIndicator {
  id: root

  property bool recording: !!root.bar && !!root.bar.shell && String(root.bar.shell.recordingStatusText || "").indexOf("recording") === 0

  active: recording
  activeText: "󰻂"
  inactiveText: "󰻂"
  activeTooltipText: "Stop recording"
  inactiveTooltipText: "Screen Recording"

  function refresh() {
    if (root.bar && root.bar.shell) root.bar.shell.refreshScreenState()
  }

  onBarChanged: refresh()
  Component.onCompleted: refresh()

  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() { root.refresh() }
  }

  onPressed: function() {
    if (root.bar) {
      root.recording ? root.bar.shell.runScreenRecord("stop") : root.bar.shell.toggleScreenPanel()
    }
  }
}
