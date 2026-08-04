import Quickshell.Io
import QtQuick

Item {
  id: audioService

  required property var shellRoot
  required property var shellConfig

  function refreshMixer() {
    audioStreamsRefresh.running = true
  }

  function refreshState() {
    audioStatusRefresh.running = true
    if (audioService.shellRoot.mediaPanelOpen) {
      audioStreamsRefresh.running = true
      mediaNowRefresh.running = true
    }
  }

  function refreshSoon() {
    audioRefreshLater.restart()
  }

  Process {
    id: audioStreamsRefresh
    command: audioService.shellConfig.audioStreams()
    running: false
    stdout: StdioCollector { onStreamFinished: audioService.shellRoot.updateAudioStreams(this.text) }
  }

  Process {
    id: audioStatusRefresh
    command: audioService.shellConfig.audio(audioService.shellConfig.statusAction)
    running: true
    stdout: StdioCollector { onStreamFinished: audioService.shellRoot.updateAudioStatus(this.text) }
  }

  Process {
    id: mediaNowRefresh
    command: audioService.shellConfig.mediaNowPlaying()
    running: true
    stdout: StdioCollector { onStreamFinished: audioService.shellRoot.mediaNowText = this.text.trim() }
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
