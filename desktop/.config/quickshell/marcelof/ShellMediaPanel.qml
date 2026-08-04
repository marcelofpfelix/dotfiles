import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ShellPopup {
  id: mediaPanel

  readonly property QtObject theme: ShellTheme {}
  required property var shellRoot
  required property var shellConfig
  required property var audioStreamsModel

  ShellScrollPanel {
    anchors.fill: parent

        RowLayout {
          Layout.fillWidth: true
          spacing: theme.spacingLg
          ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            ShellText { Layout.fillWidth: true; role: "heading"; text: "Media" }
            Text { Layout.fillWidth: true; color: theme.textSubtle; elide: Text.ElideRight; font.family: theme.fontFamily; font.pixelSize: theme.fontSm; text: mediaPanel.shellRoot.mediaNowText.length > 0 ? mediaPanel.shellRoot.mediaNowText : (mediaPanel.shellRoot.audioDisplayText.length > 0 ? mediaPanel.shellRoot.audioDisplayText : "No active playback") }
          }
          ShellActionButton { icon: "󰕾"; label: "Output"; minWidth: 92; tooltip: "Open volume mixer"; tooltipState: mediaPanel.shellRoot; onTriggered: Quickshell.execDetached(mediaPanel.shellConfig.volumeMixer()) }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: theme.spacingButton
          ShellActionButton { Layout.fillWidth: true; icon: "󰒮"; label: "Prev"; tooltip: "Previous track"; tooltipState: mediaPanel.shellRoot; onTriggered: mediaPanel.shellRoot.runPlayerctl("previous") }
          ShellActionButton { Layout.fillWidth: true; active: mediaPanel.shellRoot.audioPlaybackActive(); icon: mediaPanel.shellRoot.audioIconText; label: mediaPanel.shellRoot.audioPlaybackActive() ? "Pause" : "Play"; tooltip: mediaPanel.shellRoot.audioPlaybackActive() ? "Pause saved music and noise" : "Start saved music and noise"; tooltipState: mediaPanel.shellRoot; onTriggered: mediaPanel.shellRoot.runAudioctl("play-pause-all") }
          ShellActionButton { Layout.fillWidth: true; icon: "󰒭"; label: "Next"; tooltip: "Next track"; tooltipState: mediaPanel.shellRoot; onTriggered: mediaPanel.shellRoot.runPlayerctl("next") }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: theme.spacingButton
          ShellActionButton { Layout.fillWidth: true; active: mediaPanel.shellRoot.audioNoiseRunning(); icon: "󰜗"; label: mediaPanel.shellRoot.audioNoiseRunning() ? "Noise Off" : "Noise On"; tooltip: mediaPanel.shellRoot.audioNoiseRunning() ? "Stop brown noise" : "Start brown noise"; tooltipState: mediaPanel.shellRoot; onTriggered: mediaPanel.shellRoot.runAudioctl("noise-toggle") }
          ShellActionButton { Layout.fillWidth: true; active: mediaPanel.shellRoot.audioMusicRunning(); icon: ""; label: mediaPanel.shellRoot.audioMusicRunning() ? "Music Off" : "Music On"; tooltip: mediaPanel.shellRoot.audioMusicRunning() ? "Stop saved music" : "Start saved music"; tooltipState: mediaPanel.shellRoot; onTriggered: mediaPanel.shellRoot.runAudioctl("music-toggle") }
          ShellActionButton { Layout.fillWidth: true; icon: "󰓛"; label: "Stop"; tooltip: "Stop saved music and noise. Right-click: force kill"; tooltipState: mediaPanel.shellRoot; onTriggered: mediaPanel.shellRoot.runAudioctl("stop-all"); onSecondaryTriggered: mediaPanel.shellRoot.runAudioctl("force-stop") }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: theme.spacingXl
          ShellText { role: "softStrong"; text: mediaPanel.shellRoot.defaultSinkAudio() && !mediaPanel.shellRoot.defaultSinkAudio().muted ? "" : "󰝟" }
          Slider { Layout.fillWidth: true; from: 0; to: 1.5; value: mediaPanel.shellRoot.defaultSinkAudio() ? mediaPanel.shellRoot.defaultSinkAudio().volume : 0; onMoved: if (mediaPanel.shellRoot.defaultSinkAudio()) mediaPanel.shellRoot.defaultSinkAudio().volume = value }
          ShellText { role: "soft"; text: mediaPanel.shellRoot.defaultSinkAudio() ? Math.round(mediaPanel.shellRoot.defaultSinkAudio().volume * 100) + "%" : "--" }
          ShellActionButton { icon: "󰝟"; label: ""; minWidth: 40; tooltip: "Mute output"; tooltipState: mediaPanel.shellRoot; onTriggered: mediaPanel.shellRoot.toggleMute() }
        }

        ShellText { Layout.fillWidth: true; role: "section"; text: mediaPanel.audioStreamsModel.count > 0 ? "Streams" : "No streams" }

        Repeater {
          model: mediaPanel.audioStreamsModel

          ShellSection {
            required property string id
            required property string app
            required property string media
            required property string volume
            required property string muted

            padding: theme.spacingButton
            gap: theme.spacingXs
            bordered: true

              RowLayout {
                Layout.fillWidth: true
                spacing: theme.spacingLg
                Text { color: muted === mediaPanel.shellConfig.states.yes ? theme.error : theme.success; font.family: theme.fontFamily; font.pixelSize: theme.fontLg; text: muted === mediaPanel.shellConfig.states.yes ? "󰝟" : "" }
                ColumnLayout {
                  Layout.fillWidth: true
                  spacing: 0
                  ShellText { Layout.fillWidth: true; elide: Text.ElideRight; text: media }
                  Text { Layout.fillWidth: true; color: theme.textSubtle; elide: Text.ElideRight; font.family: theme.fontFamily; font.pixelSize: theme.fontXs; text: app }
                }
                ShellText { role: "muted"; text: volume }
                ShellActionButton { icon: muted === mediaPanel.shellConfig.states.yes ? "󰕾" : "󰝟"; label: ""; minWidth: 40; tooltip: "Mute this stream"; tooltipState: mediaPanel.shellRoot; onTriggered: mediaPanel.shellRoot.runSinkInputAction(id, "mute") }
              }

              Slider {
                Layout.fillWidth: true
                from: 0
                to: 1.5
                enabled: muted !== mediaPanel.shellConfig.states.yes
                value: Math.max(0, Number(volume.replace("%", "")) / 100)
                onMoved: mediaPanel.shellRoot.setSinkInputVolume(id, value)
              }
          }
        }
  }
}
