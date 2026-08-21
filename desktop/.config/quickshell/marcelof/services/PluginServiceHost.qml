import QtQuick

Item {
  id: host
  visible: false

  required property var pluginRegistry
  required property var shell
  property var barWidgetRegistry: null
  property var services: ({})

  function serviceFor(pluginId) {
    return services[String(pluginId || "")] || null
  }

  function ensure(pluginId) {
    const id = String(pluginId || "")
    if (services[id]) return services[id]
    const manifest = pluginRegistry.installedPlugins[id]
    if (!manifest || !manifest.kinds || manifest.kinds.indexOf("service") === -1)
      return null
    const source = pluginRegistry.entryPointUrl(manifest, "service")
    if (!source) return null

    const component = Qt.createComponent(source, Component.PreferSynchronous)
    if (component.status !== Component.Ready) {
      console.warn("service plugin load failed for " + id + ": " + component.errorString())
      return null
    }
    const instance = component.createObject(host)
    if (!instance) return null
    if ("shell" in instance) instance.shell = shell
    if ("manifest" in instance) instance.manifest = manifest
    if ("pluginRegistry" in instance) instance.pluginRegistry = pluginRegistry
    if ("barWidgetRegistry" in instance) instance.barWidgetRegistry = barWidgetRegistry

    const next = Object.assign({}, services)
    next[id] = instance
    services = next
    return instance
  }

  function sync() {
    const installed = pluginRegistry.installedPlugins
    for (const id in installed) {
      const manifest = installed[id]
      if (manifest && manifest.kinds && manifest.kinds.indexOf("service") !== -1
          && pluginRegistry.isEnabled(id))
        ensure(id)
    }

    for (const id in services) {
      if (installed[id] && pluginRegistry.isEnabled(id)) continue
      services[id].destroy()
      const next = Object.assign({}, services)
      delete next[id]
      services = next
    }
  }

  Connections {
    target: host.pluginRegistry
    function onPluginsChanged() { host.sync() }
  }

  Component.onCompleted: sync()
}
