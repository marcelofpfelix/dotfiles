import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
TOOL = ROOT / "desktop/tools/omarchy-shell-upstream"


def run(*args, cwd=None):
    return subprocess.run(args, cwd=cwd, text=True, capture_output=True, check=True)


class OmarchyShellUpstreamTest(unittest.TestCase):
    def test_report_prepare_and_apply(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            upstream = root / "upstream"
            upstream.mkdir()
            run("git", "init", "-q", str(upstream))
            run("git", "config", "user.email", "test@example.com", cwd=upstream)
            run("git", "config", "user.name", "Test", cwd=upstream)
            shell = upstream / "shell"
            shell.mkdir()
            (shell / "clean.qml").write_text("old clean\n")
            (shell / "adapted.qml").write_text("top\nbase\nbottom\n")
            (shell / "conflict.qml").write_text("base\n")
            run("git", "add", ".", cwd=upstream)
            run("git", "commit", "-qm", "base", cwd=upstream)
            base = run("git", "rev-parse", "HEAD", cwd=upstream).stdout.strip()
            run("git", "tag", "v1.0.0", cwd=upstream)
            (shell / "clean.qml").write_text("new clean\n")
            (shell / "adapted.qml").write_text("top\nbase\nupstream\nbottom\n")
            (shell / "conflict.qml").write_text("upstream\n")
            (shell / "new.qml").write_text("new plugin\n")
            (shell / "plugins/example").mkdir(parents=True)
            (shell / "plugins/example/Panel.qml").write_text("new panel\n")
            run("git", "add", ".", cwd=upstream)
            run("git", "commit", "-qm", "target", cwd=upstream)
            run("git", "tag", "v1.1.0", cwd=upstream)

            project = root / "project"
            local = project / "desktop/.config/quickshell/marcelof"
            local.mkdir(parents=True)
            (local / "clean.qml").write_text("old clean\n")
            (local / "adapted.qml").write_text("top\nlocal\nbase\nbottom\n")
            (local / "conflict.qml").write_text("local\n")
            (local / "custom.qml").write_text("custom\n")
            lock = project / "desktop/upstream/omarchy-shell.json"
            lock.parent.mkdir(parents=True)
            lock.write_text(json.dumps({"repository": str(upstream), "baseTag": "v1.0.0",
                                        "baseCommit": base, "imports": ["new.qml"],
                                        "importPrefixes": ["plugins/example"]}))
            run("git", "init", "-q", str(project))
            run("git", "config", "user.email", "test@example.com", cwd=project)
            run("git", "config", "user.name", "Test", cwd=project)
            run("git", "add", ".", cwd=project)
            run("git", "commit", "-qm", "local", cwd=project)

            common = [sys.executable, str(TOOL), "--shell-root", str(local),
                      "--lock-file", str(lock), "--upstream-dir", str(upstream)]
            report = run(*common, "report", "v1.1.0").stdout
            self.assertIn("clean=1", report)
            self.assertIn("adapted=2", report)
            self.assertIn("localOnly=1", report)
            self.assertIn("upstreamNew=2", report)
            self.assertIn("selectedNew=2", report)

            candidate = root / "candidate"
            prepared = subprocess.run(
                [*common, "--output", str(candidate), "prepare", "v1.1.0"],
                text=True, capture_output=True,
            )
            self.assertEqual(prepared.returncode, 1)
            self.assertIn("conflicts=conflict.qml", prepared.stderr)
            self.assertEqual((candidate / "clean.qml").read_text(), "new clean\n")
            self.assertEqual((candidate / "adapted.qml").read_text(),
                             "top\nlocal\nbase\nupstream\nbottom\n")
            self.assertEqual((candidate / "new.qml").read_text(), "new plugin\n")
            self.assertEqual((candidate / "plugins/example/Panel.qml").read_text(),
                             "new panel\n")
            (local / "conflict.qml").write_text("base\n")
            run("git", "add", ".", cwd=project)
            run("git", "commit", "-qm", "resolve", cwd=project)

            run(*common, "--output", str(root / "applied"), "apply", "v1.1.0")
            self.assertEqual((local / "clean.qml").read_text(), "new clean\n")
            self.assertEqual((local / "new.qml").read_text(), "new plugin\n")
            self.assertEqual(json.loads(lock.read_text())["baseTag"], "v1.1.0")


if __name__ == "__main__":
    unittest.main()
