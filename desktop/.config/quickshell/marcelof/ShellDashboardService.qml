import Quickshell.Io
import QtQuick

Item {
  id: dashboardService

  required property var shellRoot
  required property var shellConfig
  property alias workInboxHandle: workInboxRefresh
  property alias personalDashboardHandle: personalDashboardRefresh
  property string personalDashboardActionName: "personal.refresh"

  function refreshWorkInbox() {
    workInboxRefresh.running = true
  }

  function refreshPersonalDashboard() {
    personalDashboardRefresh.running = true
  }

  function runPersonalDashboardAction(actionName) {
    dashboardService.personalDashboardActionName = actionName
    personalDashboardAction.running = true
  }

  Process {
    id: workInboxRefresh
    command: dashboardService.shellConfig.workInboxStatus()
    running: false
    stdout: StdioCollector { onStreamFinished: dashboardService.shellRoot.updateWorkInbox(this.text) }
  }

  Process {
    id: personalDashboardRefresh
    command: dashboardService.shellConfig.boardText(dashboardService.shellRoot.personalDashboardSurface)
    running: false
    stdout: StdioCollector { onStreamFinished: dashboardService.shellRoot.personalDashboardText = this.text.trim() }
  }

  Process {
    id: personalDashboardAction
    command: dashboardService.shellConfig.boardAction(dashboardService.personalDashboardActionName)
    running: false
    onExited: dashboardService.refreshPersonalDashboard()
  }
}
