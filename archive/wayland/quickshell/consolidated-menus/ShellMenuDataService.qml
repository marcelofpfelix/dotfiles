import Quickshell.Io
import QtQuick

Item {
  id: menuDataService

  required property var shellRoot
  required property var shellConfig

  property alias passRunning: passEntriesRefresh.running

  function refreshLauncherMru() {
    launcherMruRefresh.running = true
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
    id: passEntriesRefresh
    command: menuDataService.shellConfig.passList(menuDataService.shellRoot.passBackend)
    stdout: StdioCollector { onStreamFinished: menuDataService.shellRoot.updatePassEntries(this.text) }
  }
}
