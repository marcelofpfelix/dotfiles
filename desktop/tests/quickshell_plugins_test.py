import copy
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


def validate(config, plugins):
    installed = {plugin["id"]: plugin for plugin in plugins}
    disabled = set(config.get("disabledPlugins", []))
    widgets = [entry["id"] for entries in config["bar"]["layout"].values()
               for entry in entries]
    referenced = set(widgets) | {entry["id"] for entry in config.get("plugins", [])}
    for plugin_id in referenced - disabled:
        plugin = installed.get(plugin_id)
        assert plugin and plugin["enabled"], f"configured plugin missing/disabled: {plugin_id}"
        if plugin_id in widgets:
            assert plugin.get("widgetRegistered"), f"unregistered widget: {plugin_id}"
            assert plugin.get("widgetCount", 0) > 0, f"uninstantiated widget: {plugin_id}"
    for plugin in plugins:
        if plugin["enabled"] and "service" in plugin["kinds"]:
            assert plugin.get("serviceLoaded"), f"unloaded service: {plugin['id']}"
    return len(referenced - disabled)


class PluginRuntimeTest(unittest.TestCase):
    root = Path(__file__).resolve().parents[2]

    def setUp(self):
        self.config = {"bar": {"layout": {"right": [{"id": "omarchy.media"}]}}}
        self.plugins = [{"id": "omarchy.media", "enabled": True,
                         "kinds": ["service", "bar-widget"], "serviceLoaded": True,
                         "widgetRegistered": True, "widgetCount": 1}]

    def test_loaded_configuration(self):
        self.assertEqual(validate(self.config, self.plugins), 1)

    def test_placeholder_is_not_a_loaded_widget(self):
        plugins = copy.deepcopy(self.plugins)
        plugins[0]["widgetRegistered"] = False
        with self.assertRaisesRegex(AssertionError, "unregistered widget"):
            validate(self.config, plugins)

    def test_missing_service_is_rejected(self):
        self.plugins[0]["serviceLoaded"] = False
        with self.assertRaisesRegex(AssertionError, "unloaded service"):
            validate(self.config, self.plugins)

    def test_emoji_asset_path_has_one_binding(self):
        source = (Path(__file__).resolve().parents[2] /
                  "desktop/.config/quickshell/marcelof/shell.qml").read_text()
        overlay = source.split("EmojiPlugin.Emojis {", 1)[1].split("\n  }", 1)[0]
        self.assertEqual(overlay.count("pluginPath:"), 1)

    def test_runtime_fields_are_inside_plugin_records(self):
        source = (self.root / "desktop/.config/quickshell/marcelof/shell.qml").read_text()
        record = source.split("plugins.push({", 1)[1].split("})", 1)[0]
        for field in ("serviceLoaded:", "widgetRegistered:", "widgetCount:",
                      "sourceType:", "sourcePath:", "sourceUrl:", "clonedFrom:"):
            self.assertIn(field, record)

    def test_bar_widget_enabled_state_follows_layout(self):
        source = (self.root /
                  "desktop/.config/quickshell/marcelof/services/PluginRegistry.qml").read_text()
        enabled = source.split("function isEnabled(id)", 1)[1].split("function supportsKind", 1)[0]
        self.assertIn("manifest.kinds.indexOf(barWidgetKind)", enabled)
        self.assertIn("return findEntryLocation(config, key).found", enabled)

    def test_all_upstream_builtins_are_installed(self):
        expected = {
            "active-window", "agents", "audio", "background", "bar", "battery",
            "bluetooth", "clipboard", "clock", "dev-gallery", "disk-speedtest",
            "dropbox", "emojis", "idle", "image-picker", "indicators",
            "keyboard-layout", "lock", "media", "menu", "microphone", "monitor",
            "network", "nightlight", "notifications", "osd", "polkit", "power",
            "reminders", "spacer", "speedtest", "system-update", "tailscale",
            "tray", "weather", "wifiqr", "workspaces",
        }
        manifests = (self.root / "desktop/.config/quickshell/marcelof/plugins").rglob("*manifest.json")
        installed = set()
        for manifest in manifests:
            plugin_id = json.loads(manifest.read_text()).get("id", "")
            if plugin_id.startswith("omarchy."):
                installed.add(plugin_id.removeprefix("omarchy."))
        self.assertEqual(installed, expected)
        config = json.loads((self.root / "desktop/.config/omarchy/shell.json").read_text())
        optional = {"omarchy." + plugin for plugin in {
            "agents", "battery", "clock", "dev-gallery", "disk-speedtest",
            "dropbox", "reminders", "speedtest", "tailscale", "weather",
        }}
        self.assertTrue(optional.issubset(set(config["disabledPlugins"])))

    def test_plugin_manager_is_portable_and_in_root_menu(self):
        plugin = self.root / "desktop/.config/omarchy/plugins/marcelof.plugin-manager"
        manifest = json.loads((plugin / "manifest.json").read_text())
        self.assertEqual(manifest["id"], "marcelof.plugin-manager")
        self.assertEqual(manifest["entryPoints"]["overlay"], "Overlay.qml")
        config = json.loads((self.root / "desktop/.config/omarchy/shell.json").read_text())
        self.assertIn("marcelof.plugin-manager", {entry["id"] for entry in config["plugins"]})

    def test_plugin_list_prints_all_provenance(self):
        plugins = [
            {"id": "git.test", "enabled": False, "firstParty": False,
             "sourceType": "git", "sourcePath": "/plugins/git.test",
             "sourceUrl": "https://example.test/plugin.git", "kinds": ["overlay"],
             "clonedFrom": "omarchy.test", "name": "Git Test"},
            {"id": "local.test", "enabled": True, "firstParty": False,
             "sourceType": "local", "sourcePath": "/plugins/local.test",
             "sourceUrl": "", "kinds": ["overlay"], "name": "Local Test"},
        ]
        with tempfile.TemporaryDirectory() as directory:
            mock = Path(directory) / "omarchy-shell"
            mock.write_text("#!/bin/sh\nprintf '%s\\n' '" + json.dumps(plugins) + "'\n")
            mock.chmod(0o755)
            result = subprocess.run(
                [str(self.root / "desktop/bin/omarchy-plugin-list")],
                env={**os.environ, "PATH": directory + ":" + os.environ["PATH"]},
                text=True, capture_output=True, check=True,
            )
        for value in ("PATH", "URL", "CLONED FROM", "/plugins/git.test",
                      "https://example.test/plugin.git", "omarchy.test",
                      "/plugins/local.test"):
            self.assertIn(value, result.stdout)


if __name__ == "__main__":
    if sys.argv[1:] == ["--live"]:
        def query(method):
            return json.loads(subprocess.check_output(
                [str(Path.home() / "bin/qbar"), "shell", method], text=True, timeout=5))

        config = query("listPluginConfig")
        disk = json.loads((Path.home() / ".config/omarchy/shell.json").read_text())
        assert config == disk, "running shell config differs from shell.json"
        plugins = query("listPlugins")
        count = validate(config, plugins)
        print(f"plugins={len(plugins)} configured_references={count} all_loaded=true")
    else:
        unittest.main()
