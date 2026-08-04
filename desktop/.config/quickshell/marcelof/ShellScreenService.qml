import Quickshell
import Quickshell.Io
import QtQuick

Item {
  id: screenService

  required property var shellRoot
  required property var shellConfig

  function refresh() {
    screenRecordStatus.running = true
    portalStatusRefresh.running = true
  }

  function runRecord(action) {
    Quickshell.execDetached(screenService.shellConfig.screenRecord(action))
    screenRecordStatusLater.restart()
  }

  Process {
    id: screenRecordStatus
    command: screenService.shellConfig.screenRecordStatus()
    stdout: StdioCollector { onStreamFinished: screenService.shellRoot.recordingStatusText = this.text.trim() }
  }

  Timer {
    id: screenRecordStatusLater
    interval: 500
    repeat: false
    onTriggered: screenRecordStatus.running = true
  }

  Process {
    id: portalStatusRefresh
    command: screenService.shellConfig.portalStatus()
    stdout: StdioCollector { onStreamFinished: screenService.shellRoot.portalStatusText = this.text.trim() }
  }
}
