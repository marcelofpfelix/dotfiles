import Quickshell.Io
import QtQuick

Item {
  id: wallpaperService

  required property var shellRoot
  required property var shellConfig

  function refreshAll() {
    wallpaperCurrent.running = true
    wallpaperListRefresh.running = true
  }

  function refreshListSoon() {
    wallpaperListRefreshLater.restart()
  }

  Process {
    id: wallpaperCurrent
    command: wallpaperService.shellConfig.wallpaper("current")
    running: true
    stdout: StdioCollector { onStreamFinished: wallpaperService.shellRoot.wallpaperSource = wallpaperService.shellConfig.fileUrl(this.text.trim()) }
  }

  Process {
    id: wallpaperListRefresh
    command: wallpaperService.shellConfig.wallpaper("list")
    stdout: StdioCollector { onStreamFinished: wallpaperService.shellRoot.updateWallpaperRows(this.text) }
  }

  Timer {
    id: wallpaperListRefreshLater
    interval: 250
    repeat: false
    onTriggered: wallpaperListRefresh.running = true
  }
}
