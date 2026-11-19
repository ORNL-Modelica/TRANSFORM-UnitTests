#!/usr/bin/env python3
"""OpenModelica load check for the TRANSFORM library.

Loads TRANSFORM in OpenModelica (`loadFile`) and fails on any Warning or Error
that OpenModelica reports in a TRANSFORM file, or on an Error that names no
file. OpenModelica prints such a message for every model a user loads, so the
library should load clean. An example is a package.order file that lists a
package's classes in a different order from its package.mo.

The library's TRANSFORM folder is first copied to a temp folder: loading it
straight from a Windows drive in WSL (/mnt/...) takes minutes.

Exit codes:
  0  loadFile returned true, with no Warning or Error in a TRANSFORM file
  1  loadFile returned false, or a Warning or Error names a TRANSFORM file
  2  setup error (no omc, the Modelica library did not load, the copy failed),
     timeout, omc failed, or no result

Python 3, standard library only.
"""

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

# The rest of a message line after "[<file>": ":l1:c1-l2:c2:writable] Kind: text".
# Matched after the known TRANSFORM folder, so a path may hold any character.
LOCATED_RE = re.compile(r"^:\d+:\d+-\d+:\d+:\w+\] (?P<kind>Warning|Error): (?P<text>.*)$")
# An Error that names no file, e.g. "Error: Failed to load package TRANSFORM".
BARE_ERROR_RE = re.compile(r"^(?:Error|Internal error):? (?P<text>.*)$")
MSL_RE = re.compile(r"^RESULT loadModel=(true|false)\s*$", re.M)
RESULT_RE = re.compile(r"^RESULT loadFile=(true|false)\s*$", re.M)
END = "END check_om_load"


def problems(output, package_dir):
    """Messages printed after the loadFile result line that make the check fail.

    These are Warnings and Errors naming a file under package_dir (whatever
    characters its path holds), and Errors that name no file. Returns (kind,
    path from package_dir's parent or None, text) tuples in the order printed,
    each once.
    """
    root = str(Path(package_dir)).rstrip("/") + "/"
    name = Path(package_dir).name
    m = RESULT_RE.search(output)
    if m:
        output = output[m.end():]
    found = []
    for line in output.splitlines():
        line = line.strip()
        if line.startswith('"'):
            line = line[1:]
        if line.startswith("[" + root):
            rest = line[1 + len(root):]
            # The file name ends at the first ":<digits>:" that LOCATED_RE accepts.
            item = None
            for i in range(len(rest)):
                if rest[i] == ":":
                    lm = LOCATED_RE.match(rest[i:])
                    if lm:
                        item = (lm.group("kind"), name + "/" + rest[:i], lm.group("text"))
                        break
            if item is None:
                continue
        else:
            bm = BARE_ERROR_RE.match(line)
            if not bm:
                continue
            item = ("Error", None, bm.group("text"))
        if item not in found:
            found.append(item)
    return found


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--library", default=str(REPO_ROOT.parent / "TRANSFORM-Library"),
                    help="TRANSFORM-Library checkout (holds TRANSFORM/); default ../TRANSFORM-Library")
    ap.add_argument("--omc", default="omc", help="OpenModelica compiler command (default omc)")
    ap.add_argument("--msl", default="4.0.0",
                    help="Modelica Standard Library version asked for (omc may load a compatible newer one)")
    ap.add_argument("--timeout", type=float, default=600, help="seconds (default 600)")
    args = ap.parse_args(argv)

    src = Path(args.library) / "TRANSFORM"
    if not (src / "package.mo").is_file():
        print(f"setup error: {src}/package.mo not found", file=sys.stderr)
        return 2
    omc = shutil.which(args.omc)
    if omc is None:
        print(f"setup error: {args.omc} not found", file=sys.stderr)
        return 2
    omc = os.path.abspath(omc)

    try:
        with tempfile.TemporaryDirectory(prefix="om-load-") as tmp:
            # omc prints resolved paths; a temp folder behind a symlink must match them.
            tmp = os.path.realpath(tmp)
            pkg = Path(tmp) / "TRANSFORM"
            shutil.copytree(src, pkg)
            mos = Path(tmp) / "load.mos"
            mos.write_text(
                f'okMSL := loadModel(Modelica, {{"{args.msl}"}});\n'
                'print("RESULT loadModel=" + String(okMSL) + "\\n");\n'
                "print(getErrorString());\n"
                f'ok := loadFile("{pkg}/package.mo");\n'
                'print("RESULT loadFile=" + String(ok) + "\\n");\n'
                "print(getErrorString());\n"
                f'print("\\n{END}\\n");\n',
                encoding="utf-8",
            )
            try:
                run = subprocess.run([omc, str(mos)], cwd=tmp, capture_output=True,
                                     text=True, timeout=args.timeout)
            except subprocess.TimeoutExpired:
                print(f"error: omc did not finish in {args.timeout:.0f} s", file=sys.stderr)
                return 2
            output = run.stdout + run.stderr
            found = problems(output, pkg)
    except OSError as e:
        print(f"setup error: {e}", file=sys.stderr)
        return 2

    msl = MSL_RE.search(output)
    result = RESULT_RE.search(output)
    if run.returncode != 0 or END not in output or msl is None or result is None:
        print(f"error: omc exited {run.returncode} without a complete result; it printed:\n"
              + output[-2000:], file=sys.stderr)
        return 2
    if msl.group(1) != "true":
        print(f"setup error: the Modelica library {args.msl} did not load; omc printed:\n"
              + output[:result.start()][-2000:], file=sys.stderr)
        return 2
    for kind, rel, text in found:
        print(f"{kind}: {rel or '(no file)'}: {text}")
    if result.group(1) != "true":
        print("FAIL: loadFile returned false")
        return 1
    if found:
        print(f"FAIL: {len(found)} message(s) in TRANSFORM files")
        return 1
    print("PASS: TRANSFORM loads in OpenModelica with no Warning or Error")
    return 0


if __name__ == "__main__":
    sys.exit(main())
