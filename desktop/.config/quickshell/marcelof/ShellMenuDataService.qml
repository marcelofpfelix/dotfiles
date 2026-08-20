import Quickshell.Io
import QtQuick

Item {
  id: menuDataService

  required property var shellRoot
  required property var shellConfig

  property alias clipboardRunning: clipboardRefresh.running
  property alias passRunning: passEntriesRefresh.running

  function refreshLauncherMru() {
    launcherMruRefresh.running = true
  }

  function refreshClipboard() {
    clipboardRefresh.running = true
  }

  function refreshPassEntries() {
    passEntriesRefresh.command = menuDataService.shellConfig.passList(menuDataService.shellRoot.passBackend)
    passEntriesRefresh.running = true
  }

  Process {
    id: launcherMruRefresh
    command: menuDataService.shellConfig.launcherMruLoad()
    running: true
    stdout: StdioCollector { onStreamFinished: menuDataService.shellRoot.updateLauncherMru(this.text) }
  }

  Process {
    id: clipboardRefresh
    command: menuDataService.shellConfig.cliphistList()
    stdout: StdioCollector { onStreamFinished: menuDataService.shellRoot.updateClipboardEntries(this.text) }
  }

  Process {
    id: passEntriesRefresh
    command: menuDataService.shellConfig.passList(menuDataService.shellRoot.passBackend)
    stdout: StdioCollector { onStreamFinished: menuDataService.shellRoot.updatePassEntries(this.text) }
  }
}
