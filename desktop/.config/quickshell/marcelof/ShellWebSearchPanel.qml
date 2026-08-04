import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

ShellFloatingPopup {
  id: webSearchPanel

  readonly property QtObject theme: ShellTheme {}
  required property var shellConfig
  property int panelWidth: 640
  property int panelHeight: 136
  property alias queryText: webSearchInput.text

  title: "quickshell-websearch"

  function openSearch(site) {
    shellRoot.closeTransientPanels()
    shellRoot.webSearchSite = site && String(site).length > 0 ? String(site) : webSearchPanel.shellConfig.defaultWebSearchSite
    shellRoot.webSearchOpen = true
    webSearchInput.text = ""
    webSearchInput.forceActiveFocus()
  }

  function toggleSearch(site) {
    if (shellRoot.webSearchOpen) {
      shellRoot.webSearchOpen = false
      return
    }
    openSearch(site)
  }

  function runSearch() {
    const query = webSearchInput.text.trim()
    if (query.length === 0)
      return
    const url = shellRoot.webSearchSiteUrl(shellRoot.webSearchSite) + encodeURIComponent(query)
    shellRoot.webSearchOpen = false
    Quickshell.execDetached(webSearchPanel.shellConfig.openUrl(url))
  }
  onFocusCleared: webSearchPanel.shellRoot.webSearchOpen = false

  ShellFrame {
    anchors.fill: parent

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: theme.panelMargin
      spacing: theme.spacingXl

      RowLayout {
        Layout.fillWidth: true
        spacing: theme.spacingLg
        Repeater {
          model: shellRoot.webSearchSites
          Rectangle {
            required property var modelData
            width: Math.max(66, siteLabel.implicitWidth + 22)
            height: theme.chipHeight
            radius: theme.radiusTiny
            color: shellRoot.webSearchSite === modelData.key ? theme.primary : (siteMouse.containsMouse ? theme.surfaceHigh : theme.surface)
            Text { id: siteLabel; anchors.centerIn: parent; color: shellRoot.webSearchSite === modelData.key ? theme.panel : theme.text; font.family: theme.fontFamily; font.pixelSize: theme.fontSm; text: modelData.label }
            MouseArea { id: siteMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { shellRoot.webSearchSite = modelData.key; webSearchInput.forceActiveFocus() } }
          }
        }
      }

      ShellSearchBox {
        id: webSearchInput
        inputHeight: theme.searchHeightLarge
        onEscapePressed: shellRoot.webSearchOpen = false
        onAccepted: webSearchPanel.runSearch()
      }
    }
  }
}
