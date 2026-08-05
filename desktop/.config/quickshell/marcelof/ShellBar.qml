import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

PanelWindow {
  id: bar

  required property var barRoot
  required property var barTheme
  required property var barSettings
  required property var barConfig
  required property var notificationHistoryModel

    function batteryPolicy() {
      return barConfig.batteryPolicy
    }

    function batteryPercent(device) {
      return Math.round(device.percentage * 100)
    }

    function batteryCharging(device) {
      return device.state === UPowerDeviceState.Charging || device.state === UPowerDeviceState.PendingCharge || device.changeRate > 0
    }

    function batteryDischarging(device) {
      return UPower.onBattery || device.state === UPowerDeviceState.Discharging || device.state === UPowerDeviceState.PendingDischarge || device.changeRate < 0
    }

    function batteryFull(device) {
      return device.state === UPowerDeviceState.FullyCharged || batteryPercent(device) >= batteryPolicy().fullPercent
    }

    function batteryVisible(device) {
      return device.ready && !(batteryPolicy().hideFull && batteryFull(device))
    }

    function batteryIcon(device) {
      const policy = batteryPolicy()
      if (batteryCharging(device))
        return policy.chargingIcon
      const pct = batteryPercent(device)
      for (let i = 0; i < policy.icons.length; i++) {
        if (pct <= policy.icons[i].max)
          return policy.icons[i].icon
      }
      return policy.icons[policy.icons.length - 1].icon
    }

    function batteryThemeColor(role) {
      if (role === "primary")
        return barTheme.primary
      if (role === "warning")
        return barTheme.warning
      if (role === "error")
        return barTheme.error
      return barTheme.textMuted
    }

    function batteryColor(device) {
      const pct = batteryPercent(device)
      const policy = batteryPolicy()
      if (batteryDischarging(device) && pct <= policy.criticalPercent)
        return batteryThemeColor(policy.criticalColor)
      if (batteryDischarging(device) && pct <= policy.warningPercent)
        return batteryThemeColor(policy.warningColor)
      if (batteryCharging(device))
        return batteryThemeColor(policy.chargingColor)
      if (batteryDischarging(device))
        return batteryThemeColor(policy.dischargingColor)
      return batteryThemeColor(policy.fullColor)
    }

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
        Layout.maximumWidth: 620
        spacing: barTheme.spacingLg

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


      ShellIconButton { tooltipState: barRoot; icon: "󰒓"; tooltip: "Controls"; onTriggered: barRoot.toggleControlPanel() }
      StatusText { command: barConfig.weather(barSettings.weatherLocation); interval: 900000 }
      StatusText { visible: text.length > 0 && text.indexOf("100%") < 0; command: barConfig.brightnessBar(); interval: 5000; leftClickCommand: barConfig.qs(barConfig.menuIds.controls); rightClickCommand: barConfig.qs(barConfig.menuIds.controls); wheelUpCommand: barConfig.brightnessSet("+5%"); wheelDownCommand: barConfig.brightnessSet("5%-") }
      StatusText { command: barConfig.network("bar"); interval: 10000; leftClickCommand: barConfig.networkEditor(); rightClickCommand: barConfig.networkEditor() }

      Text {
        Layout.alignment: Qt.AlignVCenter
        visible: bar.batteryVisible(UPower.displayDevice)
        color: bar.batteryColor(UPower.displayDevice)
        font.family: barTheme.fontFamily
              font.styleName: barTheme.fontStyle
        font.pixelSize: barTheme.fontMd
        text: UPower.displayDevice.ready ? bar.batteryIcon(UPower.displayDevice) + " " + bar.batteryPercent(UPower.displayDevice) + "%" : ""
      }

      Text {
        Layout.alignment: Qt.AlignVCenter
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
        Layout.alignment: Qt.AlignVCenter
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
      panelOpen: barRoot.trayManageOpen
      panelWidth: barRoot.menuWidthFor(barConfig.menuIds.tray)
      panelHeight: barRoot.menuHeightFor(barConfig.menuIds.tray)
    }
  }
