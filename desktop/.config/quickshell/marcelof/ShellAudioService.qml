import Quickshell.Io
import QtQuick

Item {
  id: audioService

  required property var shellRoot
  required property var shellConfig

  function refreshState() {
    if (!audioStatusRefresh.running) audioStatusRefresh.running = true
  }

  function refreshSoon() {
    audioRefreshLater.restart()
  }

  Process {
    id: audioStatusRefresh
    command: audioService.shellConfig.audio(audioService.shellConfig.statusAction)
    running: true
    stdout: StdioCollector { onStreamFinished: audioService.shellRoot.updateAudioStatus(this.text) }
  }

  Timer {
    id: audioRefreshLater
    interval: 350
    repeat: false
    onTriggered: audioService.refreshState()
  }

  Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: audioService.refreshState()
  }
}
