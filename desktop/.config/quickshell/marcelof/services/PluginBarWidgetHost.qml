import QtQuick

Item {
  id: host
  visible: false

  required property var pluginRegistry
  required property var barWidgetRegistry
  property var components: ({})

  function setComponent(id, entry) {
    const next = Object.assign({}, components)
    if (entry) next[id] = entry
    else delete next[id]
    components = next
  }

  function load(id, url, metadata) {
    setComponent(id, { url: url, component: null })
    const component = Qt.createComponent(url, Component.Asynchronous)
    function finish() {
      if (component.status === Component.Ready) {
        barWidgetRegistry.register(id, component, metadata)
        host.setComponent(id, { url: url, component: component })
      } else if (component.status === Component.Error) {
        console.warn("bar widget " + id + " failed: " + component.errorString())
        host.setComponent(id, null)
        pluginRegistry.pluginLoadFailed(id, component.errorString())
      }
    }
    if (component.status === Component.Loading) component.statusChanged.connect(finish)
    else finish()
  }

  function sync() {
    const seen = ({})
    const installed = pluginRegistry.installedPlugins
    for (const pluginId in installed) {
      const manifest = installed[pluginId]
      if (!manifest || !manifest.kinds || manifest.kinds.indexOf("bar-widget") === -1
          || !pluginRegistry.isEnabled(pluginId))
        continue

      const id = String(manifest.id)
      const url = pluginRegistry.entryPointUrl(manifest, "barWidget")
      if (!url) continue
      seen[id] = true
      const previous = components[id]
      const widget = manifest.barWidget || {}
      const metadata = {
        displayName: widget.displayName || manifest.name,
        description: widget.description || manifest.description,
        category: widget.category || "Plugin",
        allowMultiple: widget.allowMultiple === true,
        defaults: widget.defaults || {},
        settingsForm: widget.settingsForm || "",
        schema: widget.schema || [],
        pluginId: id,
        sourceDir: manifest.__sourceDir || "",
        source: "plugin"
      }

      if (previous && previous.url === url && !previous.component) continue
      if (previous && previous.url === url && barWidgetRegistry.has(id)) {
        barWidgetRegistry.register(id, previous.component, metadata)
        continue
      }
      load(id, url, metadata)
    }

    for (const id of barWidgetRegistry.availableIds()) {
      if (!components[id] || seen[id]) continue
      barWidgetRegistry.unregister(id)
      setComponent(id, null)
    }
  }

  Connections {
    target: host.pluginRegistry
    function onPluginsChanged() { host.sync() }
  }

  Component.onCompleted: sync()
}
