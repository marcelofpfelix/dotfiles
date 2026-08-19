import Quickshell.Io
import QtQuick

Item {
  id: wallpaperService

  required property var shellRoot
  required property var shellConfig

  function refreshAll() {
    if (!wallpaperCurrent.running) wallpaperCurrent.running = true
  }

  Process {
    id: wallpaperCurrent
    command: wallpaperService.shellConfig.wallpaper("current")
    running: true
    stdout: StdioCollector { onStreamFinished: wallpaperService.shellRoot.applyWallpaperPath(this.text.trim()) }
  }
}
