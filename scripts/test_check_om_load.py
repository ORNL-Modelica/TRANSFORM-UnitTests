"""Unit tests for check_om_load.py, with a fake omc (no OpenModelica needed).

Run: python3 -m unittest scripts/test_check_om_load.py
"""
import contextlib
import io
import os
import shutil
import stat
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import check_om_load as col  # noqa: E402

PKG = "/tmp/om-load-x/TRANSFORM"
ORDER = ("Warning: Elements in the package.mo-file need to be in the same relative order as "
         "the package.order file. Got element named linearExpansionCoefficient but it was "
         "already added because it was not the next element in the list at that time.")
OUTPUT = f'''RESULT loadModel=true
Error: before loadFile, not counted.
RESULT loadFile=true
"[{PKG}/Media/Solids/Copper/OFHC_RRR200/package.mo:54:15-58:35:writable] {ORDER}
[{PKG}/Media/Solids/Copper/OFHC_RRR200/package.mo:54:15-58:35:writable] {ORDER}
[/usr/lib/omlibrary/SDF 0.4.5/package.mo:1:1-9:9:writable] Warning: not ours.
[{PKG}/Fluid/Pipes/X.mo:3:1-4:4:writable] Error: Class Y not found.
Notification: Automatically loaded package SDF 0.4.5 due to uses annotation from TRANSFORM.
Error: Failed to load package Z.
'''


class Problems(unittest.TestCase):
    def test_keeps_transform_messages_once_and_bare_errors_after_loadfile(self):
        self.assertEqual(col.problems(OUTPUT, PKG), [
            ("Warning", "TRANSFORM/Media/Solids/Copper/OFHC_RRR200/package.mo", ORDER[9:]),
            ("Error", "TRANSFORM/Fluid/Pipes/X.mo", "Class Y not found."),
            ("Error", None, "Failed to load package Z."),
        ])

    def test_clean_output(self):
        clean = "RESULT loadFile=true\nNotification: Automatically loaded package SDF.\n"
        self.assertEqual(col.problems(clean, PKG), [])

    def test_other_folder_with_same_prefix_is_not_ours(self):
        out = f"RESULT loadFile=true\n[{PKG}2/package.mo:1:1-2:2:writable] Warning: elsewhere.\n"
        self.assertEqual(col.problems(out, PKG), [])

    def test_path_with_bracket_and_colon(self):
        pkg = "/tmp/a]b:1:2/TRANSFORM"
        out = f"RESULT loadFile=true\n[{pkg}/x:y.mo:1:1-2:2:writable] Warning: odd path.\n"
        self.assertEqual(col.problems(out, pkg), [("Warning", "TRANSFORM/x:y.mo", "odd path.")])


# A fake omc: prints what FAKE_OMC_MODE asks for. "<pkg>" becomes the loaded package folder.
FAKE = r'''#!/usr/bin/env python3
import os, re, sys
mos = open(sys.argv[1]).read()
pkg = re.search(r'loadFile\("(.*)/package.mo"\)', mos).group(1)
mode = os.environ["FAKE_OMC_MODE"]
msl = "false" if mode == "nomsl" else "true"
print(f"RESULT loadModel={msl}")
if mode == "nomsl":
    print('Error: Failed to load package Modelica (9.9.9)')
print(f"RESULT loadFile={'false' if mode == 'loadfalse' else 'true'}")
if mode == "warn":
    print(f'"[{pkg}/A/package.mo:1:1-2:2:writable] Warning: out of order.')
if mode != "noend":
    print("END check_om_load")
sys.exit(139 if mode == "crash" else 0)
'''


class Main(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp())
        self.addCleanup(shutil.rmtree, self.tmp, True)
        (self.tmp / "lib" / "TRANSFORM").mkdir(parents=True)
        (self.tmp / "lib" / "TRANSFORM" / "package.mo").write_text("package TRANSFORM end TRANSFORM;\n")
        self.omc = self.tmp / "omc"
        self.omc.write_text(FAKE)
        self.omc.chmod(self.omc.stat().st_mode | stat.S_IEXEC)

    def run_check(self, mode, *extra):
        os.environ["FAKE_OMC_MODE"] = mode
        self.addCleanup(os.environ.pop, "FAKE_OMC_MODE", None)
        with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            return col.main(["--library", str(self.tmp / "lib"), "--omc", str(self.omc), *extra])

    def test_exit_codes(self):
        for mode, code in [("clean", 0), ("warn", 1), ("loadfalse", 1), ("nomsl", 2),
                           ("crash", 2), ("noend", 2)]:
            with self.subTest(mode=mode):
                self.assertEqual(self.run_check(mode), code)

    def test_missing_library_is_setup_error(self):
        os.environ["FAKE_OMC_MODE"] = "clean"
        self.addCleanup(os.environ.pop, "FAKE_OMC_MODE", None)
        with contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(col.main(["--library", str(self.tmp / "none"), "--omc", str(self.omc)]), 2)

    def test_temp_folder_behind_symlink_still_fails_on_warning(self):
        real = self.tmp / "real"
        real.mkdir()
        link = self.tmp / "link"
        link.symlink_to(real)
        old = tempfile.tempdir
        tempfile.tempdir = str(link)
        self.addCleanup(setattr, tempfile, "tempdir", old)
        self.assertEqual(self.run_check("warn"), 1)

    def test_relative_omc_path(self):
        cwd = os.getcwd()
        os.chdir(self.tmp)
        self.addCleanup(os.chdir, cwd)
        os.environ["FAKE_OMC_MODE"] = "clean"
        self.addCleanup(os.environ.pop, "FAKE_OMC_MODE", None)
        with contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(col.main(["--library", "lib", "--omc", "./omc"]), 0)


if __name__ == "__main__":
    unittest.main()
