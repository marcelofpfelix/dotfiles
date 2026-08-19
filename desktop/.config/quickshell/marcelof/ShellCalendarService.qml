import Quickshell.Io
import QtQuick

Item {
  id: calendarService

  required property var shellRoot
  required property var shellConfig
  required property var shellSettings
  property alias agendaRefresh: agendaPanelRefresh
  property alias reminderRefresh: reminderPanelRefresh
  property alias weatherRefresh: weatherPanelRefresh

  function refreshAll() {
    timePanelRefresh.running = true
    todoPanelRefresh.running = true
    agendaPanelRefresh.running = true
    reminderPanelRefresh.running = true
    weatherPanelRefresh.running = true
    pomodoroRefresh.running = true
  }

  function refreshPomodoroSoon() {
    pomodoroRefreshLater.restart()
  }

  Process {
    id: timePanelRefresh
    command: calendarService.shellConfig.checkTimePanel()
    running: true
    stdout: StdioCollector { onStreamFinished: calendarService.shellRoot.timePanelText = this.text.trim() }
  }

  Process {
    id: todoPanelRefresh
    command: calendarService.shellConfig.checkTodoPanel()
    running: true
    stdout: StdioCollector { onStreamFinished: calendarService.shellRoot.todoPanelText = this.text.trim() }
  }

  Process {
    id: agendaPanelRefresh
    command: calendarService.shellConfig.calendarAgendaStatus()
    running: true
    stdout: StdioCollector { onStreamFinished: calendarService.shellRoot.agendaPanelText = this.text.trim() }
  }

  Process {
    id: reminderPanelRefresh
    command: calendarService.shellConfig.reminderList()
    running: true
    stdout: StdioCollector { onStreamFinished: calendarService.shellRoot.reminderPanelText = this.text.trim() }
  }

  Process {
    id: weatherPanelRefresh
    command: calendarService.shellConfig.weather(calendarService.shellSettings.weatherLocation, "panel")
    running: true
    stdout: StdioCollector { onStreamFinished: calendarService.shellRoot.weatherPanelText = this.text.trim() }
  }

  Process {
    id: pomodoroRefresh
    command: calendarService.shellConfig.pomodoroStatus()
    running: true
    stdout: StdioCollector { onStreamFinished: calendarService.shellRoot.updatePomodoro(this.text) }
  }

  Timer {
    id: pomodoroRefreshLater
    interval: 300
    repeat: false
    onTriggered: pomodoroRefresh.running = true
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: timePanelRefresh.running = calendarService.shellRoot.calendarOpen
  }

  Timer {
    interval: 60000
    running: true
    repeat: true
    onTriggered: todoPanelRefresh.running = calendarService.shellRoot.calendarOpen
  }

  Timer {
    interval: 60000
    running: true
    repeat: true
    onTriggered: agendaPanelRefresh.running = calendarService.shellRoot.calendarOpen
  }

  Timer {
    interval: 60000
    running: true
    repeat: true
    onTriggered: reminderPanelRefresh.running = calendarService.shellRoot.calendarOpen
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: pomodoroRefresh.running = calendarService.shellRoot.calendarOpen
  }
}
