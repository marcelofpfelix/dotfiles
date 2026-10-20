import copy
import json
from pathlib import Path
import subprocess
import sys
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
