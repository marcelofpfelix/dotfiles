// Notification service for the omarchy shell.

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.Commons

import "components"
import "NotificationLogic.js" as NotificationLogic

Item {
  id: service

  // Injected by omarchy-shell (the first-party service loader).
  property var shell: null

  property string omarchyPath: Quickshell.env("OMARCHY_PATH")
  readonly property string home: Quickshell.env("HOME")
  // History + DND live under XDG_STATE_HOME: they're persistent user state
  // (the notifications received, the last-set DND preference), not
  // regeneratable cache that a `rm -rf ~/.cache` should wipe.
  readonly property string stateDir: home + "/.local/state/omarchy/"
  readonly property string settingsPath: stateDir + "notifications.json"
  // One file per on-screen popup, so live toasts survive shell restarts.
  // A file exists exactly as long as its popup is showing: written when the
  // toast appears, moved into historyDir when it expires, is dismissed, or is
  // acted upon.
  readonly property string popupStateDir: stateDir + "notifications/"
  // Notifications that already left the screen, one file each. Automatic
  // cleanup is age-based; user deletes remain explicit.
  readonly property string historyDir: popupStateDir + "history/"
  // Copies of the avatars/images persisted entries reference — the sender's
  // originals don't outlive the notification (see persistablePopup). Each
  // copy lives and dies with the JSON file whose stem it carries.
  readonly property string imagesDir: popupStateDir + "images/"
  // Corner radius is shared with the menu and shell panels.
  // It mirrors Hyprland's current decoration:rounding value.
  readonly property int cornerRadius: Style.cornerRadius
  // Toasts are fixed to the top-right corner. They only clear the omarchy bar
  // when the bar occupies the top or right edge, so left/bottom bars do not
  // pull notification popups away from the expected top-right location.
  // Falls back to the bar's default size (26 horizontal / 28 vertical) when
  // shell.bar isn't reachable so the popup never lands on top of the bar.
  readonly property string barPosition: shell && shell.barConfig ? String(shell.barConfig.position || "top") : "top"
  readonly property bool barVertical: barPosition === "left" || barPosition === "right"
  readonly property int defaultBarSize: barVertical ? Style.bar.sizeVertical : Style.bar.sizeHorizontal
  readonly property int liveBarSize: shell && shell.bar && !shell.bar.barHidden ? Math.max(0, shell.bar.barSize) : defaultBarSize
  readonly property int barClearance: liveBarSize + Style.gapsOut

  // Live Notification objects by originalId, kept OUT of the ListModels: a
  // QObject stored in a model role becomes a dangling C++ pointer when the
  // server destroys the notification (sender close, DND untrack, dismiss),
  // and the next read of that role segfaults in QQmlListModel::data. A JS
  // map only holds a wrapper, which degrades to a catchable error instead.
  property var liveRefs: ({})

  // PersistentProperties handles in-process QML reloads. The on-disk
  // notifications.json file is the cross-restart backstop — its `dnd` key
  // is hydrated into persisted.doNotDisturb on startup and written back via
  // a debounced save timer.
  PersistentProperties {
    id: persisted
    reloadableId: "omarchy-notifications"
    property bool doNotDisturb: false
    property int retentionDays: 30
    onDoNotDisturbChanged: {
      if (service._hydrating) return
      service.scheduleSettingsSave()
    }
    onRetentionDaysChanged: {
      if (service._hydrating) return
      service.scheduleSettingsSave()
      service.pruneHistory(function() {
        service.refreshHistoryPanel()
      })
    }
  }

  // Guards onDoNotDisturbChanged while we're hydrating from disk so the
  // hydration assignment doesn't immediately schedule a write-back.
  property bool _hydrating: false

  readonly property alias doNotDisturb: persisted.doNotDisturb
  readonly property alias retentionDays: persisted.retentionDays

  function setDoNotDisturb(value) {
    persisted.doNotDisturb = !!value
  }

  function setRetentionDays(value) {
    persisted.retentionDays = NotificationLogic.normalizedRetentionDays(value, persisted.retentionDays)
  }

  // popupModel feeds the on-screen toast stack — the only model the service
  // keeps. Everything a toast leaves behind lives on disk under historyDir.
  //
  // Aliased as a property so consumers outside this Item's id scope can bind
  // to it. QML ids aren't visible to external consumers without the alias.
  property alias popupModel: popupModel
  ListModel { id: popupModel }

  readonly property int notificationCount: {
    var count = 0
    for (var i = 0; i < popupModel.count; i++) {
      var row = popupModel.get(i)
      if (row && row.originalId >= 0 && !row.read) count++
    }
    return count
  }

  property bool historyPanelOpen: false
  property bool historyPanelLoading: false
  property bool historyPanelRefreshPending: false
  property int historyEntryCount: 0
  property var historyRowsCache: []
  property string historySearchText: ""
  property string historyAppFilter: ""
  property string historyReadFilter: "all"
  property var historyCollapsedApps: ({})
  readonly property int historyUnreadCount: {
    var count = 0
    for (var i = 0; i < historyRowsCache.length; i++)
      if (!historyRowsCache[i].read) count++
    return count
  }
  property alias historyPanelModel: historyPanelModel
  ListModel { id: historyPanelModel }
  property alias unreadAppsModel: unreadAppsModel
  ListModel { id: unreadAppsModel }

  Connections {
    target: popupModel
    function onCountChanged() {
      service.refreshHistoryPanel()
    }
  }

  // Keep the legacy toast replay bounded; stored history itself is age-based.
  readonly property int historyReplayLimit: 50

  readonly property int lowPopupDuration: 5000
  readonly property int normalPopupDuration: 8000
  readonly property int maxPopupDuration: 30000

  function durationFor(urgency, expireTimeout) {
    switch (urgency) {
    case NotificationUrgency.Critical:
      return 0
    case NotificationUrgency.Low:
      return Math.min(maxPopupDuration, Math.max(lowPopupDuration, requestedDuration(expireTimeout)))
    default:
      return Math.min(maxPopupDuration, Math.max(normalPopupDuration, requestedDuration(expireTimeout)))
    }
  }

  function requestedDuration(expireTimeout) {
    // FreeDesktop notification spec (and Quickshell) report expireTimeout in
    // milliseconds, so pass it through directly.
    var ms = Number(expireTimeout || 0)
    if (!isFinite(ms) || ms <= 0) return 0
    return Math.round(ms)
  }

  // DND bypass: only let through notifications we trust to be intentional
  // and rare.
  //   - omarchy-action: a user-action confirmation toast ("Theme changed",
  //     "Screenshot saved"). The user JUST did something — their feedback
  //     should show.
  //   - urgency=critical AND app_name=notify-send: bare-CLI emergency alerts.
  //     Trusted because it's almost always omarchy or system shell scripts —
  //     chat apps set app_name to their brand (Discord/Slack/Vesktop), which
  //     falls outside this rule.
  function shouldBypassDnd(notification) {
    return NotificationLogic.shouldBypassDnd(notification, NotificationUrgency.Critical)
  }

  function snapshotOf(notification) {
    return NotificationLogic.snapshotOf(notification, Date.now())
  }

  // A notification nobody looks back at:
  //   - the freedesktop `transient` hint is set ("popup only, don't store")
  //   - app_name is "notify-send" (the CLI default — means the sender
  //     didn't bother declaring an identity, so it's almost certainly
  //     ephemeral test/feedback noise)
  //   - app_name is "omarchy-action" (Omarchy's own user-action toasts —
  //     the user just triggered them)
  // Their toasts still land in history like any other once they've been on
  // screen; the distinction only decides whether a DND-silenced one is worth
  // recording at all.
  function isEphemeral(notification) {
    var isTransient = false
    try {
      isTransient = !!(notification.hints && notification.hints["transient"])
    } catch (e) { isTransient = false }
    return isTransient || NotificationLogic.isEphemeralApp(String(notification.appName || ""))
  }

  function handleNotification(notification) {
    // Without `tracked = true` the Notification object is destroyed as soon
    // as this signal handler returns, which would null out the `ref` we just
    // captured for the popup card.
    notification.tracked = true
    var snapshot = snapshotOf(notification)
    liveRefs[snapshot.originalId] = notification
    // Guard the delete: a newer notification may have reused this originalId
    // (freedesktop replaces_id) and taken over the map slot.
    notification.closed.connect(function() {
      if (service.liveRefs[snapshot.originalId] === notification)
        delete service.liveRefs[snapshot.originalId]
    })

    // DND bypass rules: chat apps abuse urgency=critical to force
    // visibility, so critical alone isn't enough — we also require the
    // sender to be CLI-style. See shouldBypassDnd().
    if (service.doNotDisturb && !shouldBypassDnd(notification)) {
      // The toast never shows, so the only record a silenced notification
      // can leave is a history entry. Write it straight into history —
      // "what did I miss while silenced" is exactly what history is for.
      if (!isEphemeral(notification)) {
        writeSilenced(notification, snapshot)
        return
      }
      delete liveRefs[snapshot.originalId]
      notification.tracked = false
      return
    }

    persistPopupFile(snapshot)
    watchForUpdates(notification, snapshot)
    // Qt.callLater avoids "QV4::Object::insertMember" crashes when a
    // Repeater is mid-incubation while we mutate its model.
    Qt.callLater(function() {
      removePopupsByOriginalId(snapshot.originalId, NotificationLogic.popupFileName(snapshot))
      popupModel.insert(0, snapshot)
      // An update that arrived while the insert was deferred found no row to
      // write to, and a property that already changed will not change again.
      // Reading the object once the row exists catches up on it.
      service.refreshPopup(notification, snapshot.originalId, snapshot.timestamp)
    })
  }

  // Persist a silenced notification, held tracked until its content is
  // stable: untracking tells the sender its notification closed (Chromium
  // then deletes its avatar file), and a replaces_id update lands on this
  // object without a second onNotification — releasing on a stale snapshot
  // would drop it. Each catch-up write reuses the original file identity.
  function writeSilenced(notification, written) {
    writeHistoryFile(written, function() {
      var updated = null
      try {
        updated = NotificationLogic.replacementSnapshot(notification, written.originalId, written.timestamp)
      } catch (e) {
        // Torn down by the server while the write was queued.
      }
      if (updated && NotificationLogic.popupRowChanged(written, updated)) {
        service.writeSilenced(notification, updated)
        return
      }
      service.releaseSilenced(notification, written.originalId)
    })
  }

  // Let go of a DND-silenced notification once its history write has run.
  // The id may have been reused and the object torn down meanwhile.
  function releaseSilenced(notification, originalId) {
    if (liveRefs[originalId] === notification) delete liveRefs[originalId]
    try {
      notification.tracked = false
    } catch (e) {
      // Object already destroyed by the server — nothing left to release.
    }
  }

  // Everything the card draws. A change to any of these is a client updating
  // the notification in place, which is the only kind of update we ever hear
  // about after the popup exists.
  readonly property var updateSignals: [
    "summaryChanged", "bodyChanged", "appNameChanged", "appIconChanged",
    "imageChanged", "urgencyChanged", "expireTimeoutChanged", "hintsChanged"
  ]

  // A client that updates a notification through replaces_id does not produce
  // a second onNotification: the server writes the new content onto the object
  // we are already holding. The card draws a snapshot copied out of that
  // object — deliberately, since the object itself must stay out of the model
  // — so nothing reaches the screen until we copy it again.
  function watchForUpdates(notification, snapshot) {
    function refresh() {
      service.refreshPopup(notification, snapshot.originalId, snapshot.timestamp)
    }

    for (var i = 0; i < updateSignals.length; i++) {
      var signal = notification[updateSignals[i]]
      if (signal && typeof signal.connect === "function") signal.connect(refresh)
    }
  }

  function refreshPopup(notification, originalId, timestamp) {
    // A newer notification may have taken this id over, and the object may
    // outlive its popup — in both cases there is nothing here to refresh.
    if (service.liveRefs[originalId] !== notification) return

    var updated
    try {
      updated = NotificationLogic.replacementSnapshot(notification, originalId, timestamp)
    } catch (e) {
      // Object torn down by the server while the signal was in flight.
      return
    }

    var roles = NotificationLogic.popupRoles()
    for (var i = 0; i < popupModel.count; i++) {
      var row = popupModel.get(i)
      if (!row || row.originalId !== originalId || row.timestamp !== timestamp) continue
      if (!NotificationLogic.popupRowChanged(row, updated)) return
      for (var r = 0; r < roles.length; r++) popupModel.setProperty(i, roles[r], updated[roles[r]])
      // The file name is the timestamp and id this popup was persisted under,
      // so the rewrite lands on the same file: a restart restores the version
      // last shown, and so does the copy that ends up in history.
      persistPopupFile(updated)
      return
    }
  }

  // A restored row carries an id from the previous server generation, and
  // the new server hands out ids from 1 again — so a fresh notification
  // with the same originalId is a coincidence, not the same notification.
  // The timestamp (via the file name) disambiguates: it travels with the
  // row through every model and file round-trip.
  function isRestoredRow(row) {
    return !!row && !!restoredPopups[NotificationLogic.popupFileName(row)]
  }

  // A notification arriving under an originalId a popup on screen already
  // holds supersedes it, so that row leaves the screen. Its file is deleted
  // rather than archived: the row taking its place archives itself when it
  // goes, and history would otherwise hold two entries for what the sender
  // means as one notification.
  // keepFileName is the replacement's own file: a same-millisecond
  // replacement shares the replaced row's filename, and the new write is
  // already queued — deleting that path here would erase the replacement's
  // only file.
  function removePopupsByOriginalId(originalId, keepFileName) {
    for (var i = popupModel.count - 1; i >= 0; i--) {
      var row = popupModel.get(i)
      if (!row || row.originalId !== originalId) continue
      // Not a replaces_id match — see isRestoredRow. Removing it here
      // would silently kill a restored critical alert on an unrelated ping.
      if (isRestoredRow(row)) continue
      if (NotificationLogic.popupFileName(row) !== keepFileName) deletePopupFileFor(row)
      popupModel.remove(i)
    }
  }

  function dismissPopup(index) {
    removePopup(index, "dismiss")
  }

  function expirePopup(index) {
    removePopup(index, "expire")
  }

  function removePopup(index, reason) {
    if (index < 0 || index >= popupModel.count) return
    var entry = popupModel.get(index)
    var originalId = entry ? entry.originalId : -1
    // A restored row has no live server object, and its old-generation id
    // may meanwhile belong to a fresh notification — resolving liveRefs by
    // id would dismiss that unrelated notification at the server.
    var restored = isRestoredRow(entry)
    var ref = !restored && originalId >= 0 ? liveRefs[originalId] : null
    // The popup is leaving the screen — for any reason — so its file must not
    // survive to the next shell restart. It becomes the newest history entry
    // instead. Rows that never had a file (a history replay, the empty-history
    // placeholder) archive to nothing, which the move tolerates.
    if (entry) {
      archivePopupFileFor(entry)
      if (restored) delete restoredPopups[NotificationLogic.popupFileName(entry)]
    }
    popupModel.remove(index)
    if (ref) {
      try {
        if (ref.tracked) {
          if (reason === "expire" && typeof ref.expire === "function") ref.expire()
          else ref.dismiss()
        }
      } catch (e) {
        // Object already torn down by the server — nothing to dismiss.
      }
    }
  }

  function clearPopups() {
    while (popupModel.count > 0) dismissPopup(0)
  }

  function clearAll() {
    clearPopups()
    clearHistory()
    setHistoryRows([])
    historyPanelModel.clear()
    historySearchText = ""
    historyAppFilter = ""
    historyEntryCount = 0
  }

  // Run the popup's click action, then dismiss. Omarchy's own toasts carry the
  // action as a command in the `exec` role (see execFromHints), which the
  // persistence files preserve, so restored toasts stay clickable. Third-party
  // clients register a libnotify action under the canonical identifier
  // "default" instead; that one only works while the sender is still live.
  function markPopupRead(index) {
    if (index < 0 || index >= popupModel.count) return
    var row = popupModel.get(index)
    if (!row || row.read) return
    popupModel.setProperty(index, "read", true)
    persistPopupFile(popupModel.get(index))
  }

  function invokePopupDefault(index) {
    if (index < 0 || index >= popupModel.count) return
    var entry = popupModel.get(index)
    markPopupRead(index)
    var command = entry ? String(entry.exec || "") : ""
    if (command) {
      // Detached so the launched command outlives the shell process, which the
      // installer toasts depend on: they restart the shell as their first act.
      Util.execDetached(command)
      dismissPopup(index)
      return
    }
    // Restored rows have no live actions, and looking up liveRefs by their
    // old-generation id could fire an unrelated fresh notification's action.
    var ref = entry && !isRestoredRow(entry) ? liveRefs[entry.originalId] : null
    var invoked = false
    try {
      if (ref && ref.actions) {
        for (var i = 0; i < ref.actions.length; i++) {
          var action = ref.actions[i]
          if (action && action.identifier === "default") {
            action.invoke()
            invoked = true
            break
          }
        }
      }
    } catch (e) {
      // Notification already torn down by the server — fall through to focus.
      console.warn("invoke default failed:", e)
    }
    // Chat apps (Slack, Discord, Vesktop, etc.) rarely register a "default"
    // libnotify action — they just expect clicking the notification to
    // focus their window. Fall back to focusing the sending app by class so
    // that click-to-jump actually works.
    if (!invoked) focusApp(entry)
    dismissPopup(index)
  }

  // Try to focus an existing Hyprland window matching the notification's
  // sender. The helper handles case-insensitive class matching.
  function focusApp(entry) {
    if (!entry || !entry.app) return
    focusAppProc.command = [
      service.home + "/bin/notification-focus-app",
      String(entry.desktopEntry || entry.appIcon || ""),
      String(entry.app)
    ]
    focusAppProc.running = true
  }

  Process { id: focusAppProc; running: false }

  Process {
    id: ensureDirsProc
    command: ["mkdir", "-p", service.stateDir, service.popupStateDir, service.historyDir, service.imagesDir]
    running: false
  }

  // ---------------------------------------------------- popup persistence
  //
  // Mirror every on-screen popup to its own file under popupStateDir so
  // toasts survive shell restarts (notably the restart `omarchy-update`
  // performs). Writes, moves and deletes go through one serialized queue: a
  // burst of replaces_id updates must not race a single reused Process, and
  // ordering guarantees a delete issued after a write wins.

  // Popups restored from a previous shell process, keyed by their file
  // name (timestamp-originalId) since ids alone repeat across server
  // generations. The replaces_id handling and liveRefs lookups must not
  // match these rows against fresh notifications.
  property var restoredPopups: ({})

  // Entries are either { command, done } for a file job or { read: true } for
  // a replay's directory read. Queueing the read rather than running it beside
  // the queue is what makes it a barrier: it takes its place in line, so the
  // history it sees is the one that existed when the replay was asked for.
  // Everything queued after it — a clear, an archive, a silenced write — waits
  // for it, and no amount of later traffic can push it back.
  property var popupFileQueue: []

  // Done callback of the job popupFileProc is currently running.
  property var runningPopupFileJobDone: null

  function enqueuePopupFileJob(command, done) {
    popupFileQueue = popupFileQueue.concat([{ command: command, done: done || null }])
    runNextPopupFileJob()
  }

  function enqueueHistoryRead() {
    popupFileQueue = popupFileQueue.concat([{ read: true }])
    runNextPopupFileJob()
  }

  function runNextPopupFileJob() {
    if (readHistoryProc.running || popupFileProc.running) return
    if (popupFileQueue.length === 0) return

    var job = popupFileQueue[0]
    popupFileQueue = popupFileQueue.slice(1)

    if (job.read) {
      startHistoryRead()
      return
    }

    popupFileProc.command = job.command
    service.runningPopupFileJobDone = job.done || null
    popupFileProc.running = true
  }

  Process {
    id: popupFileProc
    running: false
    onExited: {
      var done = service.runningPopupFileJobDone
      service.runningPopupFileJobDone = null
      if (done) {
        try {
          done()
        } catch (e) {
          console.warn("notifications: file job callback failed:", e)
        }
      }
      service.runNextPopupFileJob()
      if (service.popupFileQueue.length === 0 && !readHistoryProc.running)
        service.refreshHistoryPanel()
    }
  }

  // Consumes the remaining args as from/to pairs. Bounded read into a temp
  // file, validated, then renamed into place: the source path is
  // sender-controlled and may grow, block, or become a FIFO mid-copy, and
  // must neither hang the serialized queue nor fill the state dir.
  readonly property string copyImagesScript:
    "while (( $# >= 2 )); do\n" +
    "  if [[ -f $1 ]] && timeout 5 head -c 5242881 -- \"$1\" > \"$2.tmp\" 2>/dev/null &&\n" +
    "     (( $(stat -c%s -- \"$2.tmp\") <= 5242880 )); then mv -f -- \"$2.tmp\" \"$2\"; else rm -f -- \"$2.tmp\"; fi\n" +
    "  shift 2\n" +
    "done\n"

  function persistPopupFile(snapshot) {
    // The JSON travels as an argument, not through shell interpolation, so
    // summaries/bodies with quotes or backticks can't break the command. The
    // mkdir guards notifications that arrive before ensureDirsProc has run.
    // Copies run before the JSON referencing them, while the source exists.
    var persistable = NotificationLogic.persistablePopup(snapshot, imagesDir)
    var command = ["bash", "-c",
      "mkdir -p \"$1\" \"$2\" || exit 0\n" +
      "dir=\"$1\" json=\"$3\" name=\"$4\"\n" +
      "shift 4\n" +
      copyImagesScript +
      "printf '%s\\n' \"$json\" > \"$dir/$name\"", "--",
      popupStateDir,
      imagesDir,
      NotificationLogic.serializePopup(persistable.entry, NotificationUrgency.Normal),
      NotificationLogic.popupFileName(snapshot)]
    for (var i = 0; i < persistable.copies.length; i++)
      command.push(persistable.copies[i].from, persistable.copies[i].to)
    enqueuePopupFileJob(command)
  }

  function deletePopupFileFor(row) {
    if (!row) return
    // History replays and the "no recent notifications" placeholder never
    // had a file — rm -f on the computed paths is a harmless no-op there.
    enqueuePopupFileJob(["bash", "-c",
      "rm -f \"$1/$2.json\" \"$3/$2\"-*", "--",
      popupStateDir, NotificationLogic.imageStem(row), imagesDir])
  }

  // ---------------------------------------------------- history
  //
  // History filenames begin with their millisecond timestamp. Remove only
  // entries older than the configured retention window, together with images.
  // Callers set $hist, $days and $imgs first.
  readonly property string pruneHistoryScript:
    "cutoff=$(( ($(date +%s) - days * 86400) * 1000 ))\n" +
    "for stale in \"$hist\"/*.json; do\n" +
    "  [[ -e $stale ]] || continue\n" +
    "  name=\"${stale##*/}\" ts=\"${name%%-*}\"\n" +
    "  [[ $ts =~ ^[0-9]+$ ]] || continue\n" +
    "  (( ts < cutoff )) && rm -f \"$stale\" \"$imgs/${name%.json}\"-*\n" +
    "done"

  function archivePopupFileFor(row) {
    if (!row) return
    // A history replay or the empty-history placeholder has no file to move;
    // the failed mv leaves the history untouched, cleanup included. Image
    // copies stay put — live and archived entries share imagesDir.
    enqueuePopupFileJob(["bash", "-c",
      "mkdir -p \"$1\" || exit 0\n" +
      "hist=\"$1\" days=\"$2\" imgs=\"$5\"\n" +
      "mv -f \"$4/$3\" \"$1/$3\" 2>/dev/null || exit 0\n" +
      pruneHistoryScript, "--",
      historyDir,
      String(retentionDays),
      NotificationLogic.popupFileName(row),
      popupStateDir,
      imagesDir])
  }

  // Record a notification that never made it to the screen (DND silenced it),
  // straight into history. Same file format as an archived popup, so the
  // replay can't tell the two apart.
  //
  // A silenced notification is untracked the moment it arrives, so the server
  // has nothing left for a later replaces_id to replace and hands the sender a
  // fresh id instead. Every update from a chatty thread is therefore its own
  // notification here, and several can coexist until retention cleanup — there
  // is no id to recognize them by, and guessing from app and summary would
  // merge genuinely separate messages.
  function writeHistoryFile(entry, done) {
    if (!entry) {
      if (done) done()
      return
    }
    var persistable = NotificationLogic.persistablePopup(entry, imagesDir)
    var command = ["bash", "-c",
      "mkdir -p \"$1\" \"$5\" || exit 0\n" +
      "hist=\"$1\" days=\"$2\" name=\"$3\" json=\"$4\" imgs=\"$5\"\n" +
      "shift 5\n" +
      copyImagesScript +
      "printf '%s\\n' \"$json\" > \"$hist/$name\" || exit 0\n" +
      pruneHistoryScript, "--",
      historyDir,
      String(retentionDays),
      NotificationLogic.popupFileName(entry),
      NotificationLogic.serializePopup(persistable.entry, NotificationUrgency.Normal),
      imagesDir]
    for (var i = 0; i < persistable.copies.length; i++)
      command.push(persistable.copies[i].from, persistable.copies[i].to)
    enqueuePopupFileJob(command, done)
  }

  function pruneHistory(done) {
    enqueuePopupFileJob(["bash", "-c",
      "hist=\"$1\" days=\"$2\" imgs=\"$3\"\n" + pruneHistoryScript,
      "--", historyDir, String(retentionDays), imagesDir], done)
  }

  function clearHistory() {
    enqueuePopupFileJob(["bash", "-c",
      "for f in \"$1\"/*.json; do\n" +
      "  [[ -e $f ]] || continue\n" +
      "  stale=\"${f##*/}\"\n" +
      "  rm -f \"$f\" \"$2/${stale%.json}\"-*\n" +
      "done", "--", historyDir, imagesDir])
  }

  // A restart can kill a queued job between its cp and its JSON write,
  // leaving copies no JSON-derived cleanup can name. Swept at startup,
  // through the queue so in-flight copies aren't mistaken for orphans.
  function sweepOrphanImages() {
    enqueuePopupFileJob(["bash", "-c",
      "for img in \"$3\"/*; do\n" +
      "  [[ -e $img ]] || continue\n" +
      "  [[ $img == *.tmp ]] && { rm -f -- \"$img\"; continue; }\n" +
      "  stem=\"${img##*/}\"\n" +
      "  stem=\"${stem%-*}\"\n" +
      "  [[ -e $1/$stem.json || -e $2/$stem.json ]] || rm -f \"$img\"\n" +
      "done", "--", popupStateDir, historyDir, imagesDir])
  }

  Process {
    id: readHistoryProc
    running: false
    // Let the file queue go again, whatever the read did — a failed or empty
    // read must not leave archives and clears parked behind it forever.
    onExited: service.runNextPopupFileJob()
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: service.replayHistory(text)
    }
  }

  // Toasts that were on screen when the replay was asked for. The clear in
  // replayHistory archives them, but the directory read is already in flight
  // by then, so they're handed over in memory instead of being waited for.
  property var replayCarryOver: []

  // Set from the moment a read is queued until it starts, so a second
  // showHistory while one is still waiting its turn doesn't queue another.
  property bool historyReadQueued: false

  // Re-show what's in historyDir as toasts. The read goes through the file
  // queue and its own subprocess, so the replay lands in replayHistory once
  // the work queued ahead of it has finished.
  function showRecentHistory() {
    if (readHistoryProc.running || service.historyReadQueued) return "ok"
    service.replayCarryOver = liveRowsForReplay()
    service.historyReadQueued = true
    enqueueHistoryRead()
    return "ok"
  }

  function startHistoryRead() {
    service.historyReadQueued = false
    readHistoryProc.command = ["bash", "-c",
      "jq -c . \"$1\"/*.json 2>/dev/null || true", "--", historyDir]
    readHistoryProc.running = true
  }

  // Copy the on-screen rows out of the model. The placeholder from an earlier
  // empty replay carries originalId -1 and is not a notification, so it is
  // left behind rather than replayed as one. The replay dismisses these
  // notifications, and senders delete their images on close — so the carried
  // rows point at the persisted copies, like the archived files they join.
  function liveRowsForReplay() {
    var rows = []
    for (var i = 0; i < popupModel.count; i++) {
      var row = popupModel.get(i)
      if (!row || row.originalId < 0) continue
      rows.push(NotificationLogic.persistablePopup({
        id: row.id,
        originalId: row.originalId,
        app: row.app,
        appIcon: row.appIcon,
        desktopEntry: row.desktopEntry || "",
        summary: row.summary,
        body: row.body,
        image: row.image,
        glyph: row.glyph || "",
        exec: row.exec || "",
        read: !!row.read,
        urgency: row.urgency,
        timestamp: row.timestamp
      }, imagesDir).entry)
    }
    return rows
  }

  function panelRow(entry) {
    return {
      kind: "notification",
      app: String(entry.app || "Notification"),
      appIcon: NotificationLogic.resolvedAppIcon(entry.appIcon, entry.desktopEntry, entry.app),
      desktopEntry: String(entry.desktopEntry || ""),
      count: 0,
      originalId: Number(entry.originalId || entry.id || -1),
      timestamp: Number(entry.timestamp || 0),
      summary: String(entry.summary || ""),
      body: String(entry.body || ""),
      image: String(entry.image || ""),
      glyph: String(entry.glyph || ""),
      exec: String(entry.exec || ""),
      read: !!entry.read,
      collapsed: false,
      unread: 0,
      urgency: Number(entry.urgency || NotificationUrgency.Normal)
    }
  }

  function applyHistoryFilter() {
    populateHistoryPanel(NotificationLogic.filterHistoryRows(historyRowsCache, historySearchText, historyAppFilter, historyReadFilter))
  }

  function setHistoryRows(rows) {
    historyRowsCache = rows || []
    unreadAppsModel.clear()
    var apps = NotificationLogic.unreadApps(historyRowsCache)
    for (var i = 0; i < apps.length; i++) unreadAppsModel.append(apps[i])
    if (historyPanelOpen) applyHistoryFilter()
  }

  function setHistorySearchText(value) {
    historySearchText = String(value || "")
    applyHistoryFilter()
  }

  function setHistoryAppFilter(value) {
    historyAppFilter = String(value || "")
    applyHistoryFilter()
  }

  function setHistoryReadFilter(value) {
    var next = String(value || "all")
    historyReadFilter = next === "read" || next === "unread" ? next : "all"
    applyHistoryFilter()
  }

  function historyAppCollapsed(app) {
    return historyCollapsedApps["$" + String(app || "")] === true
  }

  function toggleHistoryAppCollapsed(app) {
    var key = "$" + String(app || "")
    var next = ({})
    for (var existing in historyCollapsedApps) next[existing] = historyCollapsedApps[existing]
    next[key] = !next[key]
    historyCollapsedApps = next
    applyHistoryFilter()
  }

  function populateHistoryPanel(rows) {
    historyPanelModel.clear()
    historyEntryCount = rows.length

    var groups = ({})
    var order = []
    for (var i = 0; i < rows.length; i++) {
      var row = panelRow(rows[i])
      var key = "$" + row.app
      if (!groups[key]) {
        groups[key] = { icon: row.appIcon, rows: [], unread: 0 }
        order.push(row.app)
      } else if (!groups[key].icon && row.appIcon) {
        groups[key].icon = row.appIcon
      }
      groups[key].rows.push(row)
      if (!row.read) groups[key].unread++
    }

    for (var g = 0; g < order.length; g++) {
      var app = order[g]
      var group = groups["$" + app]
      var collapsed = historySearchText.length === 0 && historyAppCollapsed(app)
      historyPanelModel.append({
        kind: "group",
        app: app,
        appIcon: group.icon,
        desktopEntry: "",
        count: group.rows.length,
        originalId: -1,
        timestamp: 0,
        summary: "",
        body: "",
        image: "",
        glyph: "",
        exec: "",
        read: false,
        collapsed: collapsed,
        unread: group.unread,
        urgency: NotificationUrgency.Normal
      })
      if (!collapsed)
        for (var r = 0; r < group.rows.length; r++) historyPanelModel.append(group.rows[r])
    }

    historyPanelLoading = false
  }

  function loadHistoryPanel(raw) {
    var rows = NotificationLogic.historyRows(
      raw, liveRowsForReplay(), NotificationUrgency.Normal, -1)
    setHistoryRows(rows)
  }

  function refreshHistoryPanel() {
    if (panelHistoryProc.running) {
      historyPanelRefreshPending = true
      return
    }
    historyPanelRefreshPending = false
    historyPanelLoading = historyPanelModel.count === 0
    panelHistoryProc.command = ["bash", "-c",
      "jq -c . \"$1\"/*.json 2>/dev/null || true", "--", historyDir]
    panelHistoryProc.running = true
  }

  function openHistoryPanel(app) {
    historySearchText = ""
    historyAppFilter = String(app || "")
    historyReadFilter = "all"
    historyPanelOpen = true
    refreshHistoryPanel()
  }

  function closeHistoryPanel() {
    historyPanelOpen = false
    historyPanelModel.clear()
    historySearchText = ""
    historyAppFilter = ""
    historyReadFilter = "all"
    historyEntryCount = 0
  }

  function toggleHistoryPanel() {
    if (historyPanelOpen) closeHistoryPanel()
    else openHistoryPanel()
  }

  function visiblePanelRows(excludedApp, excludedId, excludedTimestamp) {
    var rows = []
    for (var i = 0; i < historyRowsCache.length; i++) {
      var row = panelRow(historyRowsCache[i])
      if (excludedApp && row.app === excludedApp) continue
      if (excludedId >= 0 && row.originalId === excludedId && row.timestamp === excludedTimestamp) continue
      rows.push(row)
    }
    return rows
  }

  function updateHistoryEntryFile(originalId, timestamp, read) {
    enqueuePopupFileJob(["bash", "-c",
      "for dir in \"$1\" \"$2\"; do\n" +
      "  file=\"$dir/$3.json\" tmp=\"$dir/$3.json.tmp\"\n" +
      "  [[ -f $file ]] || continue\n" +
      "  jq -c --argjson read \"$4\" '.read = $read' \"$file\" > \"$tmp\" && mv -f \"$tmp\" \"$file\"\n" +
      "done", "--", popupStateDir, historyDir,
      NotificationLogic.imageStem({ originalId: originalId, timestamp: timestamp }), read ? "true" : "false"])
  }

  function markHistoryEntryRead(originalId, timestamp) {
    var rows = visiblePanelRows("", -1, 0)
    var changed = false
    for (var i = 0; i < rows.length; i++) {
      if (rows[i].originalId !== originalId || rows[i].timestamp !== timestamp || rows[i].read) continue
      rows[i].read = true
      changed = true
    }
    for (var p = 0; p < popupModel.count; p++) {
      var popup = popupModel.get(p)
      if (popup.originalId !== originalId || popup.timestamp !== timestamp || popup.read) continue
      popupModel.setProperty(p, "read", true)
      changed = true
    }
    if (!changed) return
    updateHistoryEntryFile(originalId, timestamp, true)
    setHistoryRows(rows)
  }

  function markAllHistoryRead() {
    if (historyUnreadCount === 0) return
    var rows = visiblePanelRows("", -1, 0)
    for (var i = 0; i < rows.length; i++) rows[i].read = true
    for (var p = 0; p < popupModel.count; p++) popupModel.setProperty(p, "read", true)
    enqueuePopupFileJob(["bash", "-c",
      "for dir in \"$1\" \"$2\"; do\n" +
      "  for file in \"$dir\"/*.json; do\n" +
      "    [[ -f $file ]] || continue\n" +
      "    tmp=\"$file.tmp\"\n" +
      "    jq -c '.read = true' \"$file\" > \"$tmp\" && mv -f \"$tmp\" \"$file\"\n" +
      "  done\n" +
      "done", "--", popupStateDir, historyDir])
    setHistoryRows(rows)
  }

  function deleteHistoryEntryFile(originalId, timestamp) {
    var row = { originalId: originalId, timestamp: timestamp }
    enqueuePopupFileJob(["bash", "-c",
      "rm -f \"$1/$2.json\" \"$3/$2\"-*", "--",
      historyDir, NotificationLogic.imageStem(row), imagesDir])
  }

  function deleteHistoryAppFiles(app) {
    enqueuePopupFileJob(["bash", "-c",
      "for file in \"$1\"/*.json; do\n" +
      "  [[ -e $file ]] || continue\n" +
      "  jq -e --arg app \"$3\" '.app == $app' \"$file\" >/dev/null 2>&1 || continue\n" +
      "  name=\"${file##*/}\"\n" +
      "  rm -f \"$file\" \"$2/${name%.json}\"-*\n" +
      "done", "--", historyDir, imagesDir, app])
  }

  function clearHistoryApp(app) {
    var target = String(app || "")
    if (!target) return
    for (var i = popupModel.count - 1; i >= 0; i--) {
      var popup = popupModel.get(i)
      if (popup && String(popup.app || "Notification") === target)
        dismissPopup(i)
    }
    deleteHistoryAppFiles(target)
    setHistoryRows(visiblePanelRows(target, -1, 0))
  }

  function removeHistoryEntry(originalId, timestamp, app) {
    for (var i = popupModel.count - 1; i >= 0; i--) {
      var popup = popupModel.get(i)
      if (popup && popup.originalId === originalId && popup.timestamp === timestamp)
        dismissPopup(i)
    }
    deleteHistoryEntryFile(originalId, timestamp)
    setHistoryRows(visiblePanelRows("", originalId, timestamp))
  }

  function focusFirstHistoryEntry() {
    for (var i = 0; i < historyPanelModel.count; i++) {
      var row = historyPanelModel.get(i)
      if (!row || row.kind !== "notification") continue
      focusHistoryEntry(row.originalId, row.timestamp, row.app, row.appIcon, row.desktopEntry, row.exec)
      return
    }
  }

  function focusHistoryEntry(originalId, timestamp, app, appIcon, desktopEntry, exec) {
    markHistoryEntryRead(originalId, timestamp)
    var command = String(exec || "")
    if (command) Util.execDetached(command)
    else focusApp({ app: app, appIcon: appIcon, desktopEntry: desktopEntry })
    closeHistoryPanel()
  }

  function clearHistoryPanel() {
    clearAll()
  }

  function replayHistory(raw) {
    var rows = NotificationLogic.historyRows(
      raw, service.replayCarryOver, NotificationUrgency.Normal, service.historyReplayLimit)
    service.replayCarryOver = []

    // Replaying nothing at all looks like a dead keybinding, so say so.
    if (rows.length === 0) {
      popupModel.insert(0, {
        id: -1,
        originalId: -1,
        app: "omarchy-action",
        appIcon: "",
        desktopEntry: "",
        summary: "No recent notifications",
        body: "",
        image: "",
        glyph: "󰂚",
        exec: "",
        urgency: NotificationUrgency.Low,
        expireTimeout: 0,
        timestamp: Date.now()
      })
      return
    }

    clearPopups()
    // Rows arrive newest-first, and index 0 is the top of the toast stack.
    for (var i = 0; i < rows.length; i++) {
      // Replayed rows are restored rows: their notification died with the
      // sender long ago, so they must never resolve to a live server object
      // that has since been handed their old id.
      service.restoredPopups[NotificationLogic.popupFileName(rows[i])] = true
      popupModel.append(rows[i])
    }
  }

  Process {
    id: panelHistoryProc
    running: false
    onExited: {
      if (service.historyPanelRefreshPending)
        service.refreshHistoryPanel()
    }
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: service.loadHistoryPanel(text)
    }
  }

  Process {
    id: restorePopupsProc
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: service.restorePopups(text)
    }
  }

  function restorePopups(raw) {
    var entries = NotificationLogic.parsePopupFiles(raw, NotificationUrgency.Normal)
    var now = Date.now()
    var live = []
    for (var i = 0; i < entries.length; i++) {
      var entry = entries[i]
      var duration = durationFor(entry.urgency, entry.expireTimeout)
      if (NotificationLogic.popupExpired(entry, duration, now)) {
        // It would have expired on screen had the shell kept running, so it
        // gets archived exactly like an expiry that happened while it did.
        archivePopupFileFor(entry)
        continue
      }
      // Survivors restart with a full lifetime on purpose: shell restarts
      // are rare, and a full look after the restart flicker beats resuming
      // a toast with a second left on its clock. The reset is persisted as
      // an absolute deadline so a second restart while the toast is still
      // on screen judges it by the reset clock, not the original timestamp.
      if (duration > 0) {
        entry.deadline = now + duration
        persistPopupFile(entry)
        // deadline is persistence metadata, not a model role — fresh rows
        // never carry it, and ListModel roles must stay consistent.
        delete entry.deadline
      }
      live.push(entry)
    }
    if (live.length === 0) return

    Qt.callLater(function() {
      for (var j = 0; j < live.length; j++) {
        var restored = live[j]
        // A notification received while the restore was reading the dir can
        // already occupy this originalId with the same timestamp — then it
        // IS this entry, live with its own file, and must be left alone. A
        // different timestamp is indistinguishable between a genuine
        // cross-restart replaces_id and a new-generation id coincidence, so
        // show both: a briefly duplicated toast beats silently dropping a
        // restored critical alert.
        var duplicate = false
        for (var k = 0; k < popupModel.count; k++) {
          var row = popupModel.get(k)
          if (row && row.originalId === restored.originalId && row.timestamp === restored.timestamp) {
            duplicate = true
            break
          }
        }
        if (duplicate) continue
        // Append (entries are newest-first) so restored toasts stack in
        // their original order below anything that just arrived. Restored
        // popups have no liveRefs entry — the server object died with the
        // old shell — so dismissal and action fallbacks degrade gracefully.
        service.restoredPopups[NotificationLogic.popupFileName(restored)] = true
        popupModel.append(restored)
      }
    })
  }

  // ---------------------------------------------------- settings persistence

  FileView {
    id: settingsFile
    path: service.settingsPath
    watchChanges: false
    atomicWrites: true
    printErrors: false
    onLoaded: service.loadSettings(text())
    // First-run: the file doesn't exist yet. Without this branch,
    // `settingsLoaded` stays false forever and `scheduleSettingsSave` becomes
    // a no-op — so the file is never created and the DND preference vanishes
    // on shell restart.
    onLoadFailed: service.loadSettings("")
  }

  Timer {
    id: settingsSaveTimer
    interval: 200
    repeat: false
    onTriggered: service.flushSettings()
  }

  function scheduleSettingsSave() {
    if (!service.settingsLoaded) return
    settingsSaveTimer.restart()
  }

  property bool settingsLoaded: false

  function loadSettings(raw) {
    // FileView can fire onLoaded more than once during startup — the implicit
    // preload when `path` resolves, plus the explicit `settingsFile.reload()`
    // in Component.onCompleted can both end up calling here.
    if (service.settingsLoaded) return

    var parsed = NotificationLogic.parseSettings(raw)
    if (parsed.error) console.warn("notifications: settings parse failed:", parsed.errorMessage || "")

    service._hydrating = true
    if (parsed.dnd !== null) persisted.doNotDisturb = parsed.dnd
    if (parsed.retentionDays !== null) persisted.retentionDays = parsed.retentionDays
    service._hydrating = false

    service.settingsLoaded = true
    service.pruneHistory(function() { service.refreshHistoryPanel() })
    // Versions before the history moved into its own directory kept every
    // notification in here. Rewrite once so that dead payload doesn't sit in
    // the file until the next DND toggle happens to clear it.
    if (parsed.legacy || parsed.retentionDays === null) service.scheduleSettingsSave()
  }

  function flushSettings() {
    settingsFile.setText(JSON.stringify({
      version: 4,
      dnd: persisted.doNotDisturb,
      retentionDays: persisted.retentionDays
    }, null, 2) + "\n")
  }

  Component.onCompleted: {
    ensureDirsProc.running = true
    // Once mkdir has had a tick, load the existing settings file. FileView
    // surfaces an empty string when the file doesn't exist; loadSettings
    // handles that path.
    Qt.callLater(function() {
      settingsFile.reload()
      // Re-show popups that were on screen when the previous shell died.
      // The glob-through-bash tolerates a missing/empty dir (first run).
      // Normalize each file independently so compact and legacy pretty JSON both load;
      // malformed files are skipped without affecting their neighbors.
      restorePopupsProc.command = ["bash", "-c",
        "jq -c . \"$1\"/*.json 2>/dev/null || true", "--", service.popupStateDir]
      restorePopupsProc.running = true
      // Safe beside the restore read: it only re-persists entries whose
      // JSON exists, exactly the images the sweep keeps.
      service.sweepOrphanImages()
    })
  }

  // ---------------------------------------------------- IPC

  IpcHandler {
    target: "notifications"

    function dndState(): string {
      return service.doNotDisturb ? "on" : "off"
    }

    function toggleDnd(): string {
      service.setDoNotDisturb(!service.doNotDisturb)
      return dndState()
    }

    function setDnd(value: string): string {
      var v = String(value || "").toLowerCase()
      var on = v === "true" || v === "1" || v === "on" || v === "yes"
      service.setDoNotDisturb(on)
      return dndState()
    }

    function isDnd(): string {
      return dndState()
    }

    // Replay the notifications that have been moved into the history dir.
    function showHistory(): string {
      return service.showRecentHistory()
    }

    function toggleHistory(): string {
      service.toggleHistoryPanel()
      return service.historyPanelOpen ? "open" : "closed"
    }

    function openHistory(): string {
      service.openHistoryPanel()
      return "open"
    }

    function closeHistory(): string {
      service.closeHistoryPanel()
      return "closed"
    }

    function historyState(): string {
      return service.historyPanelOpen ? "open" : "closed"
    }

    function panelCount(): string {
      return String(service.historyEntryCount)
    }

    function panelRows(): string {
      return String(service.historyPanelModel.count)
    }

    function search(query: string): string {
      service.setHistorySearchText(query)
      return String(service.historyEntryCount)
    }

    function scope(app: string): string {
      service.setHistoryAppFilter(app)
      return String(service.historyEntryCount)
    }

    function filterRead(state: string): string {
      service.setHistoryReadFilter(state)
      return String(service.historyEntryCount)
    }

    function toggleAppCollapsed(app: string): string {
      service.toggleHistoryAppCollapsed(app)
      return service.historyAppCollapsed(app) ? "collapsed" : "expanded"
    }

    function openApp(app: string): string {
      service.openHistoryPanel(app)
      return "open"
    }

    function retention(): string {
      return String(service.retentionDays)
    }

    function setRetention(days: string): string {
      service.setRetentionDays(Number(days))
      return String(service.retentionDays)
    }

    function markRead(key: string): string {
      var parts = String(key || "").split(":")
      if (parts.length !== 2) return "invalid"
      service.markHistoryEntryRead(Number(parts[1]), Number(parts[0]))
      return "ok"
    }

    function markAllRead(): string {
      service.markAllHistoryRead()
      return "ok"
    }

    function clearApp(app: string): string {
      service.clearHistoryApp(app)
      return "ok"
    }

    // `clear` forgets the recorded history; the toasts on screen stay put.
    function clear(): string {
      service.clearHistory()
      return "ok"
    }

    function dismissAll(): string {
      service.clearPopups()
      return "ok"
    }

    function clearAll(): string {
      service.clearAll()
      return "ok"
    }

    function count(): string {
      return String(service.notificationCount)
    }

    function unreadApps(): string {
      var rows = []
      for (var i = 0; i < service.unreadAppsModel.count; i++) rows.push(service.unreadAppsModel.get(i))
      return JSON.stringify(rows)
    }

    // Dismiss the most recent popup.
    function dismissOne(): string {
      if (popupModel.count === 0) return "none"
      service.dismissPopup(0)
      return "ok"
    }

    // Fire the default action on the most recent popup, then dismiss it.
    function invokeLast(): string {
      if (popupModel.count === 0) return "none"
      service.invokePopupDefault(0)
      return "ok"
    }

    // Take a toast off the screen by summary substring, used by the
    // first-run notifications once their action has been clicked.
    function dismiss(summary: string): string {
      var needle = String(summary || "")
      if (!needle) return "none"
      var hit = false
      for (var i = popupModel.count - 1; i >= 0; i--) {
        var row = popupModel.get(i)
        if (row && String(row.summary || "").indexOf(needle) !== -1) {
          service.dismissPopup(i)
          hit = true
        }
      }
      return hit ? "ok" : "none"
    }

    function ping(): string { return "ok" }
  }

  // ---------------------------------------------------- server

  NotificationServer {
    id: server
    keepOnReload: false
    imageSupported: true
    actionsSupported: true
    bodyMarkupSupported: true
    bodyHyperlinksSupported: true
    persistenceSupported: true

    onNotification: function(notification) {
      service.handleNotification(notification)
    }
  }

  NotificationCenter {
    service: service
    shell: service.shell
  }

  // -------------------------------------------------------------- popup UI
  //
  // One PanelWindow per output (Variants on Quickshell.screens) holding the
  // stacked toast cards. Layer is Overlay, exclusionMode Ignore, no
  // keyboard focus — popups are passive surfaces and must never steal input
  // from the focused application.

  Variants {
    model: service.shell && service.shell.laptopScreen ? [service.shell.laptopScreen] : Quickshell.screens

    PanelWindow {
      id: popupWindow
      required property var modelData
      screen: modelData
      visible: popupModel.count > 0

      WlrLayershell.namespace: "omarchy-notifications"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      exclusionMode: ExclusionMode.Ignore
      color: "transparent"

      readonly property var popupPlacement: NotificationLogic.popupPlacement(
        service.barPosition, service.barClearance, Style.gapsOut)

      // Full-screen, fixed-size surface (like the OSD overlay). Adding or
      // removing a toast changes only the content inside; the Wayland surface
      // never resizes, so the compositor can't briefly scale a stale buffer --
      // which is what stretched/squished the cards during count changes.
      anchors { top: true; bottom: true; left: true; right: true }

      // Keep the surface click-through except over the toast column, so the
      // rest of the (invisible) full-screen overlay never eats input.
      mask: Region { item: popupColumn }

      ColumnLayout {
        id: popupColumn
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: popupWindow.popupPlacement.margins.top
        anchors.rightMargin: popupWindow.popupPlacement.margins.right
        spacing: Style.space(8)

        Repeater {
          model: popupModel

          // The delegate is a slot Item that owns lifetime timer state. The
          // actual visuals live in NotificationCard, which the history panel
          // also reuses.
          delegate: Item {
            id: cardSlot
            required property int index
            required property string app
            required property string appIcon
            required property string desktopEntry
            required property string summary
            required property string body
            required property string image
            required property string glyph
            required property int urgency
            required property double expireTimeout
            required property double timestamp

            // Each card sizes itself based on mode (text vs media); the slot
            // tracks the card so the column auto-fits to whichever is widest.
            Layout.preferredWidth: card.implicitWidth
            Layout.alignment: Qt.AlignRight
            implicitHeight: card.implicitHeight

            readonly property real lifetime: service.durationFor(cardSlot.urgency, cardSlot.expireTimeout)
            property real remainingLifetime: 1.0
            readonly property bool ticking: cardSlot.lifetime > 0 && !card.hovered

            // A client updating this notification in place rewrites the row
            // under the card (see refreshPopup). New text deserves a full look,
            // so the countdown starts over instead of running out the clock the
            // superseded text was already most of the way through. Delegates
            // keep their own row as the model changes around them, so only a
            // real content change lands here.
            onSummaryChanged: cardSlot.remainingLifetime = 1.0
            onBodyChanged: cardSlot.remainingLifetime = 1.0
            onImageChanged: cardSlot.remainingLifetime = 1.0

            Timer {
              interval: 50
              repeat: true
              running: cardSlot.ticking
              onTriggered: {
                if (cardSlot.lifetime <= 0) return
                cardSlot.remainingLifetime -= 50.0 / cardSlot.lifetime
                if (cardSlot.remainingLifetime <= 0) {
                  cardSlot.remainingLifetime = 0
                  service.expirePopup(cardSlot.index)
                }
              }
            }

            NotificationCard {
              id: card
              anchors.right: parent.right
              app: cardSlot.app
              appIcon: cardSlot.appIcon
              desktopEntry: cardSlot.desktopEntry
              summary: cardSlot.summary
              body: cardSlot.body
              image: cardSlot.image
              urgency: cardSlot.urgency
              timestamp: cardSlot.timestamp
              cornerRadius: service.cornerRadius
              fontFamily: service.shell && service.shell.bar ? service.shell.bar.fontFamily : ""
              glyph: cardSlot.glyph

              onCloseRequested: service.dismissPopup(cardSlot.index)
              onCardClicked: service.invokePopupDefault(cardSlot.index)
            }
          }
        }
      }
    }
  }
}
