import Quickshell.Io
import QtQuick

Item {
  id: systemStatusService

  required property var shellRoot
  required property var shellConfig

  property alias privacyHandle: privacyStatusRefresh
  property alias networkHandle: networkStatusRefresh

  function refreshControls() {
    refreshBrightness()
    refreshKbdBrightness()
    refreshNetwork()
    refreshPower()
    refreshFan()
    refreshInhibit()
    refreshPrivacy()
  }

  function refreshBrightness() { brightnessRefresh.running = true }
  function refreshKbdBrightness() { kbdBrightnessRefresh.running = true }
  function refreshNetwork() { networkStatusRefresh.running = true }
  function refreshPower() { powerStatusRefresh.running = true }
  function refreshFan() { fanStatusRefresh.running = true }
  function refreshInhibit() { inhibitStatusRefresh.running = true }
  function refreshPrivacy() { privacyStatusRefresh.running = true }

  function refreshBrightnessSoon() { brightnessRefreshLater.restart() }
  function refreshKbdBrightnessSoon() { kbdBrightnessRefreshLater.restart() }
  function refreshNetworkSoon() { networkStatusRefreshLater.restart() }
  function refreshPowerSoon() { powerStatusRefreshLater.restart() }
  function refreshInhibitSoon() { inhibitStatusRefreshLater.restart() }

  Process {
    id: brightnessRefresh
    command: systemStatusService.shellConfig.brightnessPercent()
    stdout: StdioCollector {
      onStreamFinished: {
        systemStatusService.shellRoot.brightnessText = this.text.trim()
        systemStatusService.shellRoot.brightnessValue = Number(systemStatusService.shellRoot.brightnessText.replace("%", "")) || 0
      }
    }
  }

  Timer {
    id: brightnessRefreshLater
    interval: 250
    repeat: false
    onTriggered: brightnessRefresh.running = true
  }

  Process {
    id: kbdBrightnessRefresh
    command: systemStatusService.shellConfig.keyboardBrightnessStatus()
    running: true
    stdout: StdioCollector { onStreamFinished: systemStatusService.shellRoot.kbdBrightnessText = this.text.trim() }
  }

  Timer {
    id: kbdBrightnessRefreshLater
    interval: 250
    repeat: false
    onTriggered: kbdBrightnessRefresh.running = true
  }

  Process {
    id: networkStatusRefresh
    command: systemStatusService.shellConfig.network("details-local")
    running: true
    stdout: StdioCollector { onStreamFinished: systemStatusService.shellRoot.networkStatusText = this.text.trim() }
  }

  Timer {
    id: networkStatusRefreshLater
    interval: 500
    repeat: false
    onTriggered: networkStatusRefresh.running = true
  }

  Process {
    id: powerStatusRefresh
    command: systemStatusService.shellConfig.powerStatus()
    running: true
    stdout: StdioCollector { onStreamFinished: systemStatusService.shellRoot.powerStatusText = this.text.trim() }
  }

  Process {
    id: fanStatusRefresh
    command: systemStatusService.shellConfig.fanStatus()
    stdout: StdioCollector { onStreamFinished: systemStatusService.shellRoot.fanStatusText = this.text.trim().length > 0 ? this.text.trim() : "Fan --" }
  }

  Process {
    id: inhibitStatusRefresh
    command: systemStatusService.shellConfig.inhibitStatus()
    running: true
    stdout: StdioCollector { onStreamFinished: systemStatusService.shellRoot.inhibitStatusText = this.text.trim() }
  }

  Timer {
    id: powerStatusRefreshLater
    interval: 500
    repeat: false
    onTriggered: powerStatusRefresh.running = true
  }

  Timer {
    id: inhibitStatusRefreshLater
    interval: 500
    repeat: false
    onTriggered: inhibitStatusRefresh.running = true
  }

  Process {
    id: privacyStatusRefresh
    command: systemStatusService.shellConfig.privacyStatus()
    running: true
    stdout: StdioCollector { onStreamFinished: systemStatusService.shellRoot.privacyStatusText = this.text.trim() }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: privacyStatusRefresh.running = true
  }


}
