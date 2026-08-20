import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

Item {
  id: root

  property var targetScreen: null
  property var shell: null
  property var manifest: null
  property bool opened: false
  property string audioStatus: ""
  property bool noiseRunning: false
  property bool musicRunning: false
  property bool audioPaused: false
  property string savedNoise: "none"
  property string savedMusic: "none"

  readonly property var activePlayer: mediaService.activePlayer
  readonly property var sourcePlayers: mediaService.sourcePlayers
  readonly property color background: Color.menu.background
  readonly property color foreground: Color.menu.text
  readonly property color subtle: Color.muted
  readonly property color scrim: Color.menu.scrim
  readonly property int cardWidth: Math.min(Style.space(560), panel.width - Style.gapsOut * 2)
  readonly property int cardHeight: Math.min(Style.space(460), panel.height - Style.gapsOut * 2)

  function open(payloadJson) {
    opened = true
    refreshAudioStatus()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() {
    opened = false
  }

  function dismiss() {
    close()
    if (shell && typeof shell.hide === "function")
      shell.hide((manifest && manifest.id) || "marcelof.media-controls")
  }

  function lineValue(prefix) {
    var lines = audioStatus.split("\n")
    for (var i = 0; i < lines.length; i++)
      if (lines[i].indexOf(prefix) === 0) return lines[i].slice(prefix.length)
    return ""
  }

  function updateAudioStatus(text) {
    audioStatus = String(text || "").trim()
    noiseRunning = audioStatus.indexOf("brown-noise: running") !== -1
    musicRunning = audioStatus.indexOf("music: running") !== -1
    audioPaused = audioStatus.indexOf("state: paused") !== -1
    savedNoise = lineValue("saved-noise: ") || "none"
    savedMusic = lineValue("saved-music: ") || "none"
  }

  function refreshAudioStatus() {
    if (!statusProc.running) statusProc.running = true
  }

  function runAudioctl(action) {
    if (audioAction.running) return
    audioAction.command = ["audioctl", action]
    audioAction.running = true
  }

  function runPlayerAction(action) {
    mediaService.runAction(action, false,
      activePlayer ? mediaService.playerKey(activePlayer) : "")
  }

  MediaService {
    id: mediaService
    shell: root.shell
  }

  Process {
    id: statusProc
    command: ["audioctl", "status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.updateAudioStatus(this.text)
    }
  }

  Process {
    id: audioAction
    onExited: root.refreshAudioStatus()
  }

  PanelWindow {
    id: panel
    screen: root.targetScreen
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "marcelof-media-controls"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismiss()
    }

    BorderSurface {
      id: card
      width: root.cardWidth
      height: root.cardHeight
      anchors.centerIn: parent
      radius: Style.cornerRadius
      color: root.background
      borderSpec: Border.surfaceSpec("menu", "border", Color.menu.border, Math.max(1, Style.normalBorderWidth))
      padding: Style.spacing.panelPadding

      MouseArea { anchors.fill: parent; onClicked: {} }

      Item {
        id: keyCatcher
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.dismiss()
      }

      ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: Style.spacing.panelGap

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.spacing.panelGap

          BorderSurface {
            Layout.preferredWidth: Style.space(72)
            Layout.preferredHeight: Style.space(72)
            radius: Style.cornerRadius
            color: Style.normalFillFor(root.foreground, Color.accent)
            borderSpec: Border.controlSpec("normal", root.foreground, Color.accent)

            Image {
              anchors.fill: parent
              anchors.margins: Style.space(2)
              fillMode: Image.PreserveAspectCrop
              asynchronous: true
              source: root.activePlayer && root.activePlayer.trackArtUrl ? root.activePlayer.trackArtUrl : ""
              visible: source !== ""
            }

            Text {
              anchors.centerIn: parent
              visible: !root.activePlayer || !root.activePlayer.trackArtUrl
              text: "󰝚"
              color: root.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.displayLarge
            }
          }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.space(4)

            Text {
              Layout.fillWidth: true
              text: root.activePlayer ? (root.activePlayer.trackTitle || root.activePlayer.identity || "Media") : "Nothing playing"
              color: root.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.subtitle
              font.bold: true
              elide: Text.ElideRight
            }

            Text {
              Layout.fillWidth: true
              text: root.activePlayer ? (root.activePlayer.trackArtist || root.activePlayer.trackAlbum || "") : ""
              color: root.subtle
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              elide: Text.ElideRight
            }
          }
        }

        RowLayout {
          Layout.alignment: Qt.AlignHCenter
          spacing: Style.spacing.controlGap

          Button {
            iconText: "󰒮"
            tooltipText: "Previous"
            foreground: root.foreground
            enabled: root.activePlayer && root.activePlayer.canGoPrevious
            onClicked: root.runPlayerAction("previous")
          }
          Button {
            iconText: root.activePlayer && root.activePlayer.isPlaying ? "󰏤" : "󰐊"
            tooltipText: root.activePlayer && root.activePlayer.isPlaying ? "Pause" : "Play"
            foreground: root.foreground
            enabled: !!root.activePlayer
            onClicked: root.runPlayerAction("playPause")
          }
          Button {
            iconText: "󰒭"
            tooltipText: "Next"
            foreground: root.foreground
            enabled: root.activePlayer && root.activePlayer.canGoNext
            onClicked: root.runPlayerAction("next")
          }
        }

        ColumnLayout {
          Layout.fillWidth: true
          Layout.maximumHeight: Style.space(150)
          spacing: Style.spacing.controlGap
          visible: root.sourcePlayers.length > 1

          Text {
            text: "Players"
            color: root.subtle
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }

          Repeater {
            model: root.sourcePlayers

            Button {
              required property var modelData
              Layout.fillWidth: true
              text: modelData.trackTitle || modelData.identity || modelData.desktopEntry || "Media player"
              leftAlign: true
              selected: root.activePlayer && mediaService.playerKey(modelData) === mediaService.playerKey(root.activePlayer)
              foreground: root.foreground
              onClicked: mediaService.selectPlayer(mediaService.playerKey(modelData))
            }
          }
        }

        PanelSeparator {
          Layout.fillWidth: true
          foreground: root.foreground
        }

        Text {
          text: "Saved audio"
          color: root.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.subtitle
          font.bold: true
        }

        Text {
          Layout.fillWidth: true
          text: (root.audioPaused ? "Paused" : (root.noiseRunning || root.musicRunning ? "Playing" : "Stopped"))
            + "  ·  Noise: " + (root.noiseRunning ? "on" : root.savedNoise)
            + "\nMusic: " + (root.musicRunning ? "playing" : root.savedMusic)
          color: root.subtle
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
          wrapMode: Text.Wrap
          elide: Text.ElideMiddle
          maximumLineCount: 3
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.spacing.controlGap

          Button {
            Layout.fillWidth: true
            iconText: root.audioPaused ? "󰐊" : "󰏤"
            text: root.audioPaused ? "Resume" : "Pause"
            foreground: root.foreground
            enabled: !audioAction.running
            onClicked: root.runAudioctl("play-pause-all")
          }
          Button {
            Layout.fillWidth: true
            iconText: "󰑐"
            text: "Restore"
            foreground: root.foreground
            enabled: !audioAction.running
            onClicked: root.runAudioctl("restore")
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.spacing.controlGap

          Button {
            Layout.fillWidth: true
            iconText: "󰜗"
            text: root.noiseRunning ? "Noise off" : "Noise on"
            foreground: root.foreground
            selected: root.noiseRunning
            enabled: !audioAction.running
            onClicked: root.runAudioctl("noise-toggle")
          }
          Button {
            Layout.fillWidth: true
            iconText: ""
            text: root.musicRunning ? "Music off" : "Music on"
            foreground: root.foreground
            selected: root.musicRunning
            enabled: !audioAction.running
            onClicked: root.runAudioctl("music-toggle")
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: Style.spacing.controlGap

          Button {
            Layout.fillWidth: true
            iconText: "󰓛"
            text: "Stop"
            foreground: root.foreground
            enabled: !audioAction.running
            onClicked: root.runAudioctl("stop-all")
          }
          Button {
            Layout.fillWidth: true
            iconText: "󰗼"
            text: "Force stop"
            foreground: Color.urgent
            enabled: !audioAction.running
            onClicked: root.runAudioctl("force-stop")
          }
          Button {
            iconText: "󰑐"
            tooltipText: "Refresh status"
            foreground: root.foreground
            enabled: !statusProc.running
            onClicked: root.refreshAudioStatus()
          }
        }

      }
    }
  }
}
