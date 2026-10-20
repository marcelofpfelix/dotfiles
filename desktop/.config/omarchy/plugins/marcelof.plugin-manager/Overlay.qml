import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui

Item {
  id: root

  property var targetScreen: null
  property var shell: null
  property var manifest: null
  property var pluginRegistry: null
  property bool opened: false
  property string query: ""
  property var rows: []

  function sourceLabel(plugin) {
    if (plugin.__sourceType === "git") return plugin.__sourceUrl || "Git plugin"
    if (plugin.__sourceType === "built-in") return "Omarchy built-in"
    return plugin.__sourceDir || "Local plugin"
  }

  function rebuild() {
    var next = []
    if (pluginRegistry) {
      for (var id in pluginRegistry.installedPlugins) {
        var plugin = pluginRegistry.installedPlugins[id]
        var haystack = (id + " " + (plugin.name || "") + " " + root.sourceLabel(plugin)).toLowerCase()
        if (root.query && haystack.indexOf(root.query.toLowerCase()) === -1) continue
        next.push({
          id: id,
          name: plugin.name || id,
          kinds: (plugin.kinds || []).join(", "),
          source: root.sourceLabel(plugin),
          sourceUrl: plugin.__sourceUrl || "",
          enabled: pluginRegistry.isEnabled(id),
          manageable: pluginRegistry.supports(id) && id !== "marcelof.plugin-manager"
        })
      }
    }
    next.sort(function(left, right) { return left.name.localeCompare(right.name) })
    rows = next
  }

  function open(payloadJson) {
    opened = true
    rebuild()
    Qt.callLater(function() { search.forceActiveFocus() })
  }

  function close() { opened = false }

  function dismiss() {
    close()
    if (shell && typeof shell.hide === "function")
      shell.hide((manifest && manifest.id) || "marcelof.plugin-manager")
  }

  function togglePlugin(row) {
    if (!pluginRegistry || !row.manageable) return
    pluginRegistry.setEnabled(row.id, !row.enabled, {})
    rebuild()
  }

  Connections {
    target: root.pluginRegistry
    function onPluginsChanged() { root.rebuild() }
  }

  PanelWindow {
    id: panel
    screen: root.targetScreen
    visible: root.opened
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "marcelof-plugin-manager"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    Rectangle { anchors.fill: parent; color: Color.menu.scrim }
    MouseArea { anchors.fill: parent; onClicked: root.dismiss() }

    BorderSurface {
      id: card
      width: Math.min(Style.space(760), panel.width - Style.gapsOut * 2)
      height: Math.min(Style.space(620), panel.height - Style.gapsOut * 2)
      anchors.centerIn: parent
      color: Color.menu.background
      borderSpec: Border.surfaceSpec("menu", "border", Color.menu.border, Math.max(1, Style.normalBorderWidth))
      radius: Style.cornerRadius
      padding: Style.spacing.panelPadding

      MouseArea { anchors.fill: parent; onClicked: {} }

      ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: card.contentTopInset
        anchors.rightMargin: card.contentRightInset
        anchors.bottomMargin: card.contentBottomInset
        anchors.leftMargin: card.contentLeftInset
        spacing: Style.spacing.panelGap

        RowLayout {
          Layout.fillWidth: true
          Text {
            Layout.fillWidth: true
            text: "Plugins"
            color: Color.menu.text
            font.family: Style.font.family
            font.pixelSize: Style.font.title
            font.bold: true
          }
          Button {
            iconText: "󰇧"
            text: "Browse"
            bordered: true
            foreground: Color.menu.text
            onClicked: Quickshell.execDetached(["xdg-open", "https://plugins.omarchy.org/"])
          }
          Button {
            iconText: "󰑐"
            tooltipText: "Rescan plugins"
            bordered: true
            foreground: Color.menu.text
            onClicked: if (root.pluginRegistry) root.pluginRegistry.rescan()
          }
          Button {
            iconText: "󰅖"
            tooltipText: "Close"
            bordered: true
            foreground: Color.menu.text
            onClicked: root.dismiss()
          }
        }

        TextField {
          id: search
          Layout.fillWidth: true
          placeholderText: "Search name, ID, or source"
          onTextChanged: { root.query = text; root.rebuild() }
          Keys.onEscapePressed: root.dismiss()
        }

        Text {
          Layout.fillWidth: true
          text: root.rows.length + " installed"
          color: Color.muted
          font.family: Style.font.family
          font.pixelSize: Style.font.caption
        }

        ListView {
          Layout.fillWidth: true
          Layout.fillHeight: true
          model: root.rows
          spacing: Style.spacing.controlGap
          clip: true
          boundsBehavior: Flickable.StopAtBounds

          delegate: BorderSurface {
            required property var modelData
            width: ListView.view.width
            height: content.implicitHeight + Style.spacing.panelPadding * 2
            color: Style.normalFillFor(Color.menu.text, Color.accent)
            borderSpec: Border.controlSpec("normal", Color.menu.text, Color.accent)
            radius: Style.cornerRadius
            padding: Style.spacing.panelPadding

            RowLayout {
              id: content
              anchors.fill: parent
              anchors.topMargin: parent.contentTopInset
              anchors.rightMargin: parent.contentRightInset
              anchors.bottomMargin: parent.contentBottomInset
              anchors.leftMargin: parent.contentLeftInset
              spacing: Style.spacing.controlGap

              ColumnLayout {
                Layout.fillWidth: true
                spacing: Style.space(2)
                Text {
                  Layout.fillWidth: true
                  text: modelData.name
                  color: Color.menu.text
                  font.family: Style.font.family
                  font.pixelSize: Style.font.body
                  font.bold: true
                  elide: Text.ElideRight
                }
                Text {
                  Layout.fillWidth: true
                  text: modelData.id + " · " + modelData.kinds
                  color: Color.muted
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  elide: Text.ElideRight
                }
                Text {
                  Layout.fillWidth: true
                  text: modelData.source
                  color: Color.muted
                  font.family: Style.font.family
                  font.pixelSize: Style.font.caption
                  elide: Text.ElideMiddle
                }
              }

              Button {
                visible: modelData.sourceUrl !== ""
                iconText: "󰏌"
                tooltipText: "Open source"
                foreground: Color.menu.text
                onClicked: Quickshell.execDetached(["xdg-open", modelData.sourceUrl])
              }

              ToggleSwitch {
                checked: modelData.enabled
                busy: !modelData.manageable
                foreground: Color.menu.text
                onToggled: root.togglePlugin(modelData)
              }
            }
          }
        }
      }
    }
  }
}
