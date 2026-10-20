import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
QBAR = ROOT / "desktop/bin/qbar"


class QbarRuntimeTest(unittest.TestCase):
    def test_hyprland_autostart_uses_runtime_owner(self):
        source = (ROOT / "desktop/.config/hypr/profiles/common.lua").read_text()
        startup = source.split("function M.quickshell_cmd(home)", 1)[1].split("\nend", 1)[0]
        self.assertIn('return home .. "/bin/qbar start"', startup)
        self.assertNotIn("dotfiles-nix/desktop/bin/quickshell", startup)

    def test_ipc_resolves_path_and_keeps_current_display(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            binary = home / "bin"
            binary.mkdir()
            qs = binary / "qs"
            qs.write_text(
                f"#!{sys.executable}\nimport json,os,sys\n"
                "print(json.dumps({'args':sys.argv[1:],"
                "'data':os.environ['XDG_DATA_DIRS'],"
                "'display':os.environ['WAYLAND_DISPLAY']}))\n"
            )
            qs.chmod(0o755)
            profile = home / ".nix-profile/bin"
            profile.mkdir(parents=True)
            (profile / "qs").symlink_to(qs)
            stale = home / ".local/share/dotfiles-nix/desktop/bin"
            stale.mkdir(parents=True)
            stale_qs = stale / "qs"
            stale_qs.write_text('#!/bin/sh\nprintf "stale-desktop-runtime\\n"\n')
            stale_qs.chmod(0o755)
            timeout = binary / "timeout"
            timeout.write_text('#!/bin/sh\nshift; shift; exec "$@"\n')
            timeout.chmod(0o755)
            env = {**os.environ, "HOME": directory, "WAYLAND_DISPLAY": "wayland-test",
                   "XDG_DATA_DIRS": "/existing/share"}
            env.pop("QS_BIN", None)
            result = subprocess.run(["bash", str(QBAR), "shell", "ping"],
                                    env=env, text=True, capture_output=True, timeout=5)
            self.assertEqual(result.returncode, 0, result.stderr)
            data = json.loads(result.stdout)
            self.assertEqual(data["args"][-3:], ["call", "shell", "ping"])
            self.assertNotIn("--any-display", data["args"])
            self.assertEqual(data["display"], "wayland-test")
            self.assertIn("/var/lib/snapd/desktop", data["data"].split(":"))
            self.assertIn("/existing/share", data["data"].split(":"))

    def test_lock_uses_session_helper_without_locking(self):
        with tempfile.TemporaryDirectory() as directory:
            binary = Path(directory) / "bin"
            binary.mkdir()
            helper = binary / "lock-session"
            helper.write_text('#!/bin/sh\nprintf "lock-helper-called\\n"\n')
            helper.chmod(0o755)
            result = subprocess.run(["bash", str(QBAR), "lock"],
                                    env={**os.environ, "HOME": directory},
                                    text=True, capture_output=True, timeout=5)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(result.stdout, "lock-helper-called\n")

    def test_start_recovers_wayland_before_launching(self):
        source = QBAR.read_text()
        recover = source.split("recover_wayland_display()", 1)[1].split("\n}", 1)[0]
        start = source.split("start()", 1)[1].split("\n}", 1)[0]
        self.assertIn('QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-wayland}"', recover)
        self.assertIn("recover_wayland_display", start)


if __name__ == "__main__":
    unittest.main()
