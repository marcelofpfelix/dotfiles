import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "plugins/panels/power" as PowerPlugin
import "plugins/panels/monitor" as MonitorPlugin

PanelWindow {
  id: bar

  required property var barRoot
  required property var barTheme
  required property var barSettings
  required property var barConfig
  required property var notificationHistoryModel

  readonly property string position: "top"
  readonly property bool vertical: false
  readonly property int barSize: barTheme.barHeight
  readonly property color foreground: barTheme.text
  readonly property color barForeground: foreground
  readonly property color urgent: barTheme.error
  readonly property color primary: barTheme.primary
  readonly property color muted: barTheme.textMuted
  readonly property color warning: barTheme.warning
  readonly property string fontFamily: barTheme.fontFamily
  readonly property bool foregroundAnimationEnabled: true
  property var activePopout: null
  property var clickTargets: []

  function registerClickTarget(target) {
    if (!target || clickTargets.indexOf(target) !== -1) return
    clickTargets = clickTargets.concat([target])
  }

  function unregisterClickTarget(target) {
    clickTargets = clickTargets.filter(function(item) { return item !== target })
  }

  function targetBelongsToWindow(target, window) {
    return !!target && !!window && target.QsWindow && target.QsWindow.window === window
  }

  function requestPopout(owner) {
    if (activePopout === owner) return
    if (activePopout) {
      if ("closeForPopoutSwitch" in activePopout) activePopout.closeForPopoutSwitch()
      else if ("close" in activePopout) activePopout.close()
    }
    activePopout = owner
  }

  function releasePopout(owner) {
    if (activePopout === owner) activePopout = null
  }

  function switchPanelFrom(owner, direction) { return false }
  function showTooltip(target, text) { barRoot.showTooltip(target, text) }
  function hideTooltip(target) { barRoot.hideTooltip() }

    screen: barRoot.laptopScreen

    anchors {
      top: true
      left: true
      right: true
    }

    visible: !barRoot.barHidden
    WlrLayershell.layer: WlrLayer.Top
    color: barTheme.surface
    implicitHeight: barTheme.barHeight

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: barTheme.barMargin
      anchors.rightMargin: barTheme.barMargin
      spacing: barTheme.spacingXxl

      RowLayout {
        Layout.alignment: Qt.AlignVCenter
        Layout.maximumWidth: implicitWidth
        spacing: barTheme.spacingXs

        Rectangle {
          Layout.alignment: Qt.AlignVCenter
          width: barTheme.barItemSize
          height: barTheme.barItemSize
          radius: barTheme.radiusTiny
          color: menuMouse.containsMouse || barRoot.rootMenuOpen ? barTheme.surfaceHigh : barTheme.transparent

          Text {
            anchors.centerIn: parent
            color: barTheme.text
            font.family: barTheme.fontFamily
            font.styleName: barTheme.fontStyle
            font.pixelSize: barTheme.fontMd
            text: ""
          }

          MouseArea {
            id: menuMouse
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: barRoot.showTooltip(parent, "Menu")
            onExited: barRoot.hideTooltip()
            onClicked: mouse => {
              if (mouse.button === Qt.RightButton)
                Quickshell.execDetached(barConfig.terminal())
              else
                barRoot.toggleShellMenu("omarchy.menu", "{}")
            }
          }
        }

        Row {
          spacing: barTheme.spacingSm
          Layout.alignment: Qt.AlignVCenter

          Repeater {
            model: Hyprland.workspaces

            Rectangle {
              required property var modelData

              readonly property int windowCount: modelData.toplevels && modelData.toplevels.values ? modelData.toplevels.values.length : 0
              readonly property string workspaceName: String(modelData.name || modelData.id || "")
              readonly property bool specialWorkspace: workspaceName.indexOf("special:") === 0
              readonly property string workspaceLabel: workspaceName

              visible: !specialWorkspace
              width: visible ? barTheme.workspaceWidth : 0
              height: barTheme.workspaceHeight
              radius: barTheme.radiusTiny
              color: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData.id ? barTheme.surfaceHigh : barTheme.transparent

              Text {
                anchors.centerIn: parent
                color: parent.windowCount > 0 ? barTheme.text : barTheme.textSubtle
                font.family: barTheme.fontFamily
                font.styleName: barTheme.fontStyle
                font.pixelSize: barTheme.fontMd
                font.bold: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData.id
                text: parent.workspaceLabel
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: modelData.activate()
              }
            }
          }
        }

        StatusText {
          command: barConfig.hyprStateWatch()
          interval: 30000
          watch: true
        }
      }

      Item { Layout.fillWidth: true }

      Row {
        id: trayRow
        spacing: barTheme.spacingSm
        Layout.alignment: Qt.AlignVCenter

        HoverHandler {
          onHoveredChanged: barRoot.trayExpanded = hovered
        }

        Rectangle {
          width: barTheme.barItemSize
          height: barTheme.barItemSize
          radius: barTheme.radiusTiny
          visible: barRoot.drawerTrayItems.length > 0 || barSettings.hiddenTrayIds.length > 0
          color: barRoot.trayExpanded || barRoot.trayManageOpen ? barTheme.surfaceHigh : barTheme.transparent

          Text {
            anchors.centerIn: parent
            color: barTheme.text
            font.family: barTheme.fontFamily
            font.styleName: barTheme.fontStyle
            font.pixelSize: barTheme.fontMd
            text: barRoot.trayExpanded ? "" : ""
          }

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: barRoot.showTooltip(parent, "Tray drawer")
            onExited: barRoot.hideTooltip()
            onClicked: mouse => {
              if (mouse.button === Qt.RightButton)
                barRoot.trayManageOpen = !barRoot.trayManageOpen
              else
                barRoot.trayExpanded = !barRoot.trayExpanded
            }
          }
        }

        Row {
          spacing: barTheme.spacingSm
          clip: true
          width: barRoot.trayExpanded ? implicitWidth : 0
          height: barTheme.barItemSize
          Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

          Repeater {
            model: barRoot.drawerTrayItems
            ShellTrayButton { shellRoot: barRoot }
          }
        }

        Repeater {
          model: barRoot.pinnedTrayItems
          ShellTrayButton { shellRoot: barRoot }
        }
      }

      StatusText { command: barConfig.boardQuickshellBar(); interval: 1000; rich: true; watch: true }
      Rectangle {
        Layout.alignment: Qt.AlignVCenter
        visible: barRoot.privacyBarText().length > 0
        width: privacyBarLabel.implicitWidth + barTheme.paddingMd
        height: barTheme.barItemSize
        radius: barTheme.radiusTiny
        color: privacyMouse.containsMouse ? barTheme.surfaceHigh : barTheme.transparent
        Text { id: privacyBarLabel; anchors.centerIn: parent; color: barRoot.privacyBarColor(); font.family: barTheme.fontFamily; font.pixelSize: barTheme.fontMd; text: barRoot.privacyBarText() }
        MouseArea { id: privacyMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.LeftButton | Qt.RightButton; cursorShape: Qt.PointingHandCursor; onClicked: mouse => { if (mouse.button === Qt.RightButton) barRoot.toggleDnd(); else barRoot.toggleScreenPanel() } }
      }

      Text {
        Layout.alignment: Qt.AlignVCenter
        color: barRoot.defaultSinkAudio() && barRoot.defaultSinkAudio().muted ? barSettings.primaryColor : barTheme.textMuted
        font.family: barTheme.fontFamily
              font.styleName: barTheme.fontStyle
        font.pixelSize: barTheme.fontMd
        text: {
          const audio = barRoot.defaultSinkAudio()
          if (!audio)
            return " --"

          return (audio.muted ? "󰝟 " : " ") + Math.round(audio.volume * 100) + "%"
        }

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton | Qt.RightButton
          cursorShape: Qt.PointingHandCursor
          onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
              barRoot.toggleMediaPanel()
            else
              barRoot.toggleMute()
          }
          onWheel: wheel => {
            if (wheel.angleDelta.y > 0)
              barRoot.adjustVolume(0.05)
            else if (wheel.angleDelta.y < 0)
              barRoot.adjustVolume(-0.05)
          }
        }
      }

      Rectangle {
        Layout.alignment: Qt.AlignVCenter
        width: barTheme.workspaceHeight
        height: barTheme.barItemSize
        radius: barTheme.radiusTiny
        color: pauseAllMouse.containsMouse ? barTheme.surfaceHigh : barTheme.transparent

        Text {
          anchors.centerIn: parent
          color: barTheme.text
          font.family: barTheme.fontFamily
          font.pixelSize: barTheme.fontMd
          text: barRoot.audioIconText
        }

        MouseArea {
          id: pauseAllMouse
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton | Qt.RightButton
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onEntered: barRoot.showTooltip(parent, "Play/pause audio. Right-click for media")
          onExited: barRoot.hideTooltip()
          onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
              barRoot.toggleMediaPanel()
            else
              barRoot.runAudioctl("play-pause-all")
          }
        }
      }


      MonitorPlugin.Panel { Layout.alignment: Qt.AlignVCenter; bar: bar }
      StatusText { command: barConfig.network("bar"); interval: 10000; leftClickCommand: barConfig.qs(barConfig.menuIds.network); rightClickCommand: barConfig.networkEditor() }

      PowerPlugin.Panel {
        Layout.alignment: Qt.AlignVCenter
        bar: bar
      }

    }

    Row {
      anchors.centerIn: parent
      spacing: barTheme.spacingLg

      Text {
        color: barTheme.textMuted
        font.family: barTheme.fontFamily
        font.styleName: barTheme.fontStyle
        font.pixelSize: barTheme.fontMd
        text: " " + barRoot.lisbonClockText

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: barRoot.toggleCalendar()
        }
      }

      Text {
        color: notificationHistoryModel.count > 0 ? barSettings.primaryColor : barTheme.textMuted
        font.family: barTheme.fontFamily
        font.styleName: barTheme.fontStyle
        font.pixelSize: barTheme.fontMd
        text: notificationHistoryModel.count > 0 ? "󰂚 " + notificationHistoryModel.count : "󰂜"

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: barRoot.toggleNotifications()
        }
      }
    }

    ShellTooltip {
      anchorWindow: bar
      text: barRoot.tooltipText
      anchorX: barRoot.tooltipX
      anchorY: barRoot.tooltipY
    }

    ShellTrayManagePanel {
      anchorWindow: bar
      shellRoot: barRoot
      visibilityAction: value => value ? barRoot.openShellMenu(barConfig.menuIds.tray, "{}") : barRoot.hideShellMenu(barConfig.menuIds.tray)
      panelOpen: barRoot.trayManageOpen
      panelWidth: barRoot.menuWidthFor(barConfig.menuIds.tray)
      panelHeight: barRoot.menuHeightFor(barConfig.menuIds.tray)
    }
  }
