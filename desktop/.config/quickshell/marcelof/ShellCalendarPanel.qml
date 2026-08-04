import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ShellPopup {
  id: calendarPanel

  readonly property QtObject theme: ShellTheme {}
  required property var shellRoot
  required property var shellSettings
  required property var shellConfig
  required property var clock
  required property var agendaRefresh
  rightOffset: 72

  function calendarDayAt(index) {
    const date = calendarPanel.clock.date
    const year = date.getFullYear()
    const month = date.getMonth()
    const firstWeekday = (new Date(year, month, 1).getDay() + 6) % 7
    const day = index - firstWeekday + 1
    const daysInMonth = new Date(year, month + 1, 0).getDate()
    return day >= 1 && day <= daysInMonth ? day : 0
  }

  function calendarCellCount() {
    const date = calendarPanel.clock.date
    const year = date.getFullYear()
    const month = date.getMonth()
    const firstWeekday = (new Date(year, month, 1).getDay() + 6) % 7
    const daysInMonth = new Date(year, month + 1, 0).getDate()
    return firstWeekday + daysInMonth > 35 ? 42 : 35
  }

  function isCalendarToday(day) {
    return day === calendarPanel.clock.date.getDate()
  }

  ShellPanel {
    anchors.fill: parent
    margin: 10
    gap: 8

      RowLayout {
        Layout.fillWidth: true
        spacing: theme.spacingLg
        ShellText { Layout.fillWidth: true; role: "heading"; text: "Calendar" }
        ShellText { role: "muted"; text: "Europe/Lisbon" }
      }

      Text {
        Layout.fillWidth: true
        color: theme.textSoft
        font.family: theme.fontFamily
        font.styleName: theme.fontStyle
        font.pixelSize: theme.fontClock
        horizontalAlignment: Text.AlignHCenter
        text: Qt.formatDateTime(calendarPanel.clock.date, "dd MMMM yyyy")
      }

      Text {
        Layout.fillWidth: true
        color: theme.warning
        font.family: theme.fontFamily
        font.pixelSize: theme.fontLg
        horizontalAlignment: Text.AlignHCenter
        text: calendarPanel.shellRoot.weatherPanelText.length > 0 ? calendarPanel.shellRoot.weatherPanelText : "Weather --"
      }

      GridLayout {
        Layout.fillWidth: true
        columns: 7
        rowSpacing: 2
        columnSpacing: 4

        Repeater {
          model: calendarPanel.shellConfig.calendarWeekdays
          Text {
            required property string modelData
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            color: theme.textMuted
            font.family: theme.fontFamily
            font.pixelSize: theme.fontSm
            text: modelData
          }
        }

        Repeater {
          model: calendarPanel.calendarCellCount()
          Rectangle {
            required property int index
            readonly property int day: calendarPanel.calendarDayAt(index)
            Layout.fillWidth: true
            implicitHeight: 22
            radius: theme.radiusTiny
            color: day > 0 && calendarPanel.isCalendarToday(day) ? calendarPanel.shellSettings.primaryColor : theme.transparent

            Text {
              anchors.centerIn: parent
              color: parent.day > 0 && calendarPanel.isCalendarToday(parent.day) ? theme.panel : (parent.day > 0 ? theme.textSoft : theme.transparent)
              font.family: theme.fontFamily
              font.pixelSize: theme.fontMd
              text: parent.day > 0 ? parent.day : ""
            }
          }
        }
      }

      ShellSection {
        minHeight: 100
        gap: theme.spacingButton


          RowLayout {
            Layout.fillWidth: true
            spacing: theme.spacingLg
            Text { color: calendarPanel.shellRoot.pomodoroRunning ? calendarPanel.shellSettings.primaryColor : theme.textSubtle; font.family: theme.fontFamily; font.pixelSize: theme.fontIcon; text: calendarPanel.shellRoot.pomodoroPaused ? "󰏤" : "󰐊" }
            ColumnLayout {
              Layout.fillWidth: true
              spacing: theme.spacingXs
              ShellText { Layout.fillWidth: true; role: "strong"; elide: Text.ElideRight; text: calendarPanel.shellRoot.pomodoroStatusText() }
              Text { Layout.fillWidth: true; color: theme.textMuted; elide: Text.ElideRight; font.family: theme.fontFamily; font.pixelSize: theme.fontSm; text: calendarPanel.shellRoot.pomodoroLabelText.length > 0 ? calendarPanel.shellRoot.pomodoroLabelText + calendarPanel.shellConfig.textSeparator + calendarPanel.shellRoot.pomodoroTimewText : calendarPanel.shellRoot.pomodoroTimewText }
            }
          }

          RowLayout {
            Layout.fillWidth: true
            spacing: theme.spacingButton
            ShellActionButton { Layout.fillWidth: true; icon: "󰐊"; label: "Start"; minWidth: 68; active: calendarPanel.shellRoot.pomodoroModeText === "focus" && calendarPanel.shellRoot.pomodoroRunning; tooltip: "Start focus timer"; tooltipState: calendarPanel.shellRoot; onTriggered: calendarPanel.shellRoot.runPomodoro("start") }
            ShellActionButton { Layout.fillWidth: true; icon: calendarPanel.shellRoot.pomodoroPaused ? "󰐊" : "󰏤"; label: calendarPanel.shellRoot.pomodoroPaused ? "Resume" : "Pause"; minWidth: 68; active: calendarPanel.shellRoot.pomodoroRunning && !calendarPanel.shellRoot.pomodoroPaused; tooltip: calendarPanel.shellRoot.pomodoroPaused ? "Resume timer" : "Pause timer"; tooltipState: calendarPanel.shellRoot; onTriggered: calendarPanel.shellRoot.runPomodoro(calendarPanel.shellRoot.pomodoroPaused ? "resume" : "pause") }
            ShellActionButton { Layout.fillWidth: true; icon: "󰓛"; label: "Stop"; minWidth: 62; tooltip: "Stop timer"; tooltipState: calendarPanel.shellRoot; onTriggered: calendarPanel.shellRoot.runPomodoro("stop") }
            ShellActionButton { Layout.fillWidth: true; icon: "󰔛"; label: "5m"; minWidth: 54; active: calendarPanel.shellRoot.pomodoroModeText === "short-break" && calendarPanel.shellRoot.pomodoroRunning; tooltip: "Start short break"; tooltipState: calendarPanel.shellRoot; onTriggered: calendarPanel.shellRoot.runPomodoro("break") }
            ShellActionButton { Layout.fillWidth: true; icon: "󰔛"; label: "15m"; minWidth: 54; active: calendarPanel.shellRoot.pomodoroModeText === "long-break" && calendarPanel.shellRoot.pomodoroRunning; tooltip: "Start long break"; tooltipState: calendarPanel.shellRoot; onTriggered: calendarPanel.shellRoot.runPomodoro("break", "long") }
          }
      }

      ScrollView {
        Layout.fillWidth: true
        Layout.preferredHeight: 124
        clip: true

        Text {
          width: parent.width
          color: theme.textSoft
          font.family: theme.fontFamily
          font.pixelSize: theme.fontMd
          lineHeight: 1.2
          wrapMode: Text.Wrap
          text: calendarPanel.shellRoot.timePanelText.length > 0 ? calendarPanel.shellRoot.timePanelText : "Loading time data..."
        }
      }

      Rectangle { Layout.fillWidth: true; height: 1; color: theme.surfaceHigh }

      RowLayout {
        Layout.fillWidth: true
        spacing: theme.spacingLg
        ShellText { Layout.fillWidth: true; role: "heading"; text: "Agenda" }
        ShellActionButton { icon: "󰑓"; label: ""; minWidth: 40; tooltip: "Refresh agenda"; tooltipState: calendarPanel.shellRoot; onTriggered: calendarPanel.agendaRefresh.running = true }
      }

      Text {
        Layout.fillWidth: true
        color: theme.textSoft
        font.family: theme.fontFamily
        font.pixelSize: theme.fontMd
        maximumLineCount: 3
        elide: Text.ElideRight
        wrapMode: Text.Wrap
        text: calendarPanel.shellRoot.agendaPanelText.length > 0 ? calendarPanel.shellRoot.agendaPanelText : "Agenda
  loading..."
      }

      Rectangle { Layout.fillWidth: true; height: 1; color: theme.surfaceHigh }

      RowLayout {
        Layout.fillWidth: true
        spacing: theme.spacingLg
        ShellText { Layout.fillWidth: true; role: "heading"; text: "Ready tasks" }
        ShellActionButton {
          icon: "󰄬"
          label: "Task"
          minWidth: 72
          tooltip: "Open next task"
          tooltipState: calendarPanel.shellRoot
          onTriggered: Quickshell.execDetached(calendarPanel.shellConfig.hyprTermTaskNext())
        }
      }

      Text {
        Layout.fillWidth: true
        color: theme.textSoft
        font.family: theme.fontFamily
        font.pixelSize: theme.fontMd
        maximumLineCount: 1
        elide: Text.ElideRight
        wrapMode: Text.Wrap
        text: calendarPanel.shellRoot.todoPanelText.length > 0 ? calendarPanel.shellRoot.todoPanelText : "No todo data"
      }
  }
}
