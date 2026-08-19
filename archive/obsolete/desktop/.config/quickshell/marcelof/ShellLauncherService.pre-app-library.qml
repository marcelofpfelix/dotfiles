import Quickshell
import QtQuick

Item {
  id: launcherService

  required property var shellRoot
  required property var shellConfig
  required property var shellSettings
  required property var launcherPanel
  required property var launcherModel

  property var launcherEntries: []
  property var launcherMru: []
  property var launcherCounts: ({})

  function entryId(entry) {
    return String(entry && entry.id || "")
  }

  function listContains(list, value) {
    return list && list.indexOf && list.indexOf(value) !== -1
  }

  function toggleListValue(list, value) {
    const next = list && list.slice ? list.slice() : []
    const index = next.indexOf(value)
    if (index === -1)
      next.push(value)
    else
      next.splice(index, 1)
    return next
  }

  function isFavorite(entry) {
    return listContains(shellSettings.favoriteAppIds, entryId(entry))
  }

  function isHidden(entry) {
    const id = entryId(entry)
    return id === shellRoot.launcherSmokeHiddenId || listContains(shellSettings.hiddenAppIds, id)
  }

  function toggleFavoriteById(id) {
    if (!id)
      return
    shellSettings.favoriteAppIds = toggleListValue(shellSettings.favoriteAppIds, id)
    rebuild()
  }

  function hideById(id) {
    if (!id)
      return
    shellSettings.hiddenAppIds = toggleListValue(shellSettings.hiddenAppIds, id)
    rebuild()
  }

  function webSearchSiteUrl(site) {
    for (let i = 0; i < shellConfig.webSearchSites.length; i++) {
      if (shellConfig.webSearchSites[i].key === site)
        return shellConfig.webSearchSites[i].url
    }
    return shellConfig.webSearchSites[0].url
  }

  function commandEntries(query) {
    const raw = String(query || "").trim()
    if (raw.indexOf(">") !== 0)
      return []
    const arg = raw.slice(1).trim()
    const encoded = encodeURIComponent(arg.replace(/^web\s+/, "").replace(/^yt\s+/, "").replace(/^youtube\s+/, ""))
    const rows = []
    rows.push({ name: "Web search", subtext: arg.length > 0 ? arg : "Open web search", icon: "󰖟", command: arg.length > 0 ? shellConfig.openUrl(webSearchSiteUrl(shellConfig.defaultWebSearchSite) + encoded) : shellConfig.qs(shellConfig.menuIds.websearch) })
    rows.push({ name: "YouTube search", subtext: arg.length > 0 ? arg : "Search YouTube", icon: "", command: arg.length > 0 ? shellConfig.openUrl(webSearchSiteUrl("youtube") + encoded) : shellConfig.qs(shellConfig.menuIds.websearch) })
    rows.push({ name: "Calculator", subtext: "Open calculator", icon: "󰪚", command: shellConfig.calculator() })
    rows.push({ name: "Wallpaper", subtext: "Open wallpaper picker", icon: "󰸉", command: shellConfig.qs(shellConfig.menuIds.wallpaper) })
    rows.push({ name: "Controls", subtext: "Open desktop controls", icon: "󰒓", command: shellConfig.qs(shellConfig.menuIds.controls) })
    rows.push({ name: "Settings", subtext: "Open shell settings", icon: "󰒓", command: shellConfig.qs(shellConfig.menuIds.settings) })
    rows.push({ name: "Notifications", subtext: "Open notification history", icon: "󰂚", command: shellConfig.qs(shellConfig.menuIds.notifications) })
    rows.push({ name: "Toggle DND", subtext: "Silence or allow notification popups", icon: "󰂛", command: shellConfig.qs("dnd") })
    rows.push({ name: "Media", subtext: "Open media controls", icon: "󰕾", command: shellConfig.qs(shellConfig.menuIds.media) })
    rows.push({ name: "Screenshot", subtext: "Select area and edit", icon: "󰹑", command: shellConfig.screenshot(shellConfig.actions.edit) })
    if (arg.length === 0)
      return rows
    return rows.filter(row => (row.name + " " + row.subtext).toLowerCase().indexOf(arg.toLowerCase()) >= 0 || raw.indexOf(">web ") === 0 || raw.indexOf(">yt ") === 0 || raw.indexOf(">youtube ") === 0)
  }

  function entryText(entry) {
    const keywords = entry && entry.keywords && entry.keywords.join ? entry.keywords.join(" ") : ""
    return [entry ? entry.name : "", entry ? entry.genericName : "", entry ? entry.comment : "", entry ? entry.id : "", keywords].join(" ").toLowerCase()
  }

  function acronym(entry) {
    const text = [entry ? entry.name : "", entry ? entry.genericName : "", entry ? entry.id : ""].join(" ").replace(/([a-z0-9])([A-Z])/g, "$1 $2").replace(/[._:/\-]+/g, " ").toLowerCase()
    const parts = text.split(/[^a-z0-9]+/)
    let result = ""
    for (let i = 0; i < parts.length; i++) {
      if (parts[i].length > 0)
        result += parts[i][0]
    }
    return result
  }

  function score(entry, query) {
    const q = query.trim().toLowerCase()
    const name = String(entry && entry.name || "").toLowerCase()
    const id = String(entry && entry.id || "").toLowerCase()
    const haystack = entryText(entry)
    if (q.length === 0)
      return 0

    const terms = q.split(/\s+/)
    for (let i = 0; i < terms.length; i++) {
      const term = terms[i]
      if (term.length === 0)
        continue
      if (haystack.indexOf(term) < 0 && !(term.length <= 5 && acronym(entry).indexOf(term) >= 0))
        return -1
    }

    const nameIndex = name.indexOf(q)
    const idIndex = id.indexOf(q)
    if (nameIndex === 0) return 10000 - name.length
    if (idIndex === 0) return 9500 - id.length
    if (nameIndex > 0) return 8000 - nameIndex * 10 - name.length
    if (idIndex > 0) return 7600 - idIndex * 10 - id.length

    const hayIndex = haystack.indexOf(q)
    if (hayIndex >= 0) return 6000 - hayIndex

    const acronymIndex = acronym(entry).indexOf(q)
    if (acronymIndex === 0) return 5000
    if (acronymIndex > 0) return 4600 - acronymIndex * 10
    return 4000 - name.length
  }

  function mruIndex(entry) {
    const id = String(entry && entry.id || "")
    if (id.length === 0)
      return -1
    for (let i = 0; i < launcherMru.length; i++) {
      if (launcherMru[i] === id)
        return i
    }
    return -1
  }

  function mruBoost(entry) {
    const index = mruIndex(entry)
    return index < 0 ? 0 : 300 - Math.min(index, 49) * 5
  }

  function mfuBoost(entry) {
    const id = String(entry && entry.id || "")
    const count = Number(launcherCounts[id] || 0)
    return Math.min(count, 20) * 10
  }

  function updateMru(output) {
    const lines = String(output || "").split(/\n+/)
    const seen = {}
    const entries = []
    const counts = {}
    for (let i = 0; i < lines.length && entries.length < 50; i++) {
      const fields = lines[i].trim().split(/\t+/)
      const id = fields[0]
      if (id.length === 0 || seen[id])
        continue
      const count = Number(fields[1] || 1)
      seen[id] = true
      entries.push(id)
      counts[id] = count > 0 ? count : 1
    }
    launcherMru = entries
    launcherCounts = counts
    if (launcherPanel.panelOpen)
      rebuild()
  }

  function recordUse(entry) {
    const id = String(entry && entry.id || "")
    if (id.length === 0)
      return
    const next = [id]
    for (let i = 0; i < launcherMru.length && next.length < 50; i++) {
      if (launcherMru[i] !== id)
        next.push(launcherMru[i])
    }
    const counts = Object.assign({}, launcherCounts)
    counts[id] = Number(counts[id] || 0) + 1
    launcherMru = next
    launcherCounts = counts
    let cache = ""
    for (let i = 0; i < next.length; i++)
      cache += next[i] + "\t" + Number(counts[next[i]] || 1) + "\n"
    Quickshell.execDetached(shellConfig.launcherMruSave(cache))
  }

  function entryById(id) {
    const values = DesktopEntries.applications.values || []
    for (let i = 0; i < values.length; i++) {
      if (entryId(values[i]) === String(id || ""))
        return values[i]
    }
    return null
  }

  function rebuild() {
    const values = DesktopEntries.applications.values || []
    const query = launcherPanel.searchText
    const commandRows = commandEntries(query)
    if (query.trim().indexOf(">") === 0) {
      launcherModel.clear()
      launcherEntries = commandRows
      for (let i = 0; i < commandRows.length; i++)
        launcherModel.append({ name: commandRows[i].name, subtext: commandRows[i].subtext, icon: commandRows[i].icon, id: "", favorite: false })
      launcherPanel.currentIndex = launcherModel.count > 0 ? 0 : -1
      return
    }
    const rows = []
    for (let i = 0; i < values.length; i++) {
      const entry = values[i]
      if (!entry || entry.noDisplay || !entry.name || isHidden(entry))
        continue
      const rowScore = score(entry, query)
      if (rowScore < 0)
        continue
      const favorite = isFavorite(entry)
      const boost = mruBoost(entry) + mfuBoost(entry) + (favorite ? 20000 : 0)
      rows.push({ entry: entry, score: rowScore + boost, key: String(entry.name).toLowerCase(), mru: mruIndex(entry), boost: boost, favorite: favorite })
    }

    rows.sort((a, b) => {
      if (query.trim().length > 0 && a.score !== b.score)
        return b.score - a.score
      if (query.trim().length === 0 && a.boost !== b.boost)
        return b.boost - a.boost
      if (query.trim().length === 0 && a.mru !== b.mru)
        return a.mru < 0 ? 1 : (b.mru < 0 ? -1 : a.mru - b.mru)
      return a.key < b.key ? -1 : (a.key > b.key ? 1 : 0)
    })

    launcherModel.clear()
    launcherEntries = []
    const count = Math.min(rows.length, 200)
    for (let i = 0; i < count; i++) {
      const entry = rows[i].entry
      launcherEntries.push(entry)
      launcherModel.append({
        name: String(entry.name || entry.id || "Application"),
        subtext: String(entry.genericName || entry.comment || entry.id || ""),
        icon: String(entry.icon || "application-x-executable"),
        id: entryId(entry),
        favorite: rows[i].favorite
      })
    }

    launcherPanel.currentIndex = launcherModel.count > 0 ? 0 : -1
    Qt.callLater(() => launcherPanel.positionCurrent())
  }

  function launchEntry(entry) {
    if (entry && !entry.id && entry.command) {
      Quickshell.execDetached(entry.command)
      launcherPanel.panelOpen = false
      launcherPanel.searchText = ""
      return
    }
    recordUse(entry)
    if (entry && entry.command && entry.command.length > 0)
      Quickshell.execDetached({ command: entry.command, workingDirectory: entry.workingDirectory || "" })
    else if (entry && typeof entry.execute === "function")
      entry.execute()
    else if (entry && entry.id)
      Quickshell.execDetached(shellConfig.gtkLaunch(entry.id))
    else
      return
    launcherPanel.panelOpen = false
    launcherPanel.searchText = ""
  }

  function launchRow(index) {
    if (index < 0 || index >= launcherModel.count)
      return
    launcherPanel.currentIndex = index
    if (index < launcherEntries.length) {
      const entry = launcherEntries[index]
      launchEntry(entry && entry.id ? (entryById(entry.id) || entry) : entry)
      return
    }
    const row = launcherModel.get(index)
    if (row && row.id)
      launchEntry(entryById(row.id) || row)
  }

  function launchCurrent() {
    launchRow(launcherPanel.currentIndex)
  }

  function launchAtIndex(index) {
    launchRow(index)
  }

  Connections {
    target: DesktopEntries.applications
    function onValuesChanged() { if (launcherPanel.panelOpen) launcherService.rebuild() }
  }
}
