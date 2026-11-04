#!/usr/bin/env python3
"""Conversion guard for the TRANSFORM library.

Checks, with Dymola's checkConversion, that the current TRANSFORM library still
declares how to upgrade models written for its last release (a git tag). Run it
by hand before merging library PRs.

Exit codes:
  0  checkConversion returned true
  1  checkConversion returned false, or the library version was not bumped
     since the tag (so there is nothing to check)
  2  setup error, timeout, the library failed to open, or no result

Python 3, standard library only.
"""

import argparse
import html
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

# Top-level `version="..."` of the package annotation. Anchored at line start
# so the `Modelica(version="4.0.0")` entries inside uses(...) do not match.
VERSION_RE = re.compile(r'^\s*version\s*=\s*"([^"]+)"', re.M)
RESULT_RE = re.compile(r"^RESULT (openModel|checkConversion)=(true|false)\s*$", re.M)


class SetupError(Exception):
    pass


def run_git(repo, *args):
    p = subprocess.run(["git", "-C", str(repo), *args],
                       capture_output=True, text=True)
    if p.returncode != 0:
        raise SetupError("git %s failed: %s" % (" ".join(args), p.stderr.strip()))
    return p.stdout.strip()


def read_version(package_mo):
    if not package_mo.is_file():
        raise SetupError("not found: %s" % package_mo)
    m = VERSION_RE.search(package_mo.read_text(encoding="utf-8", errors="replace"))
    if not m:
        raise SetupError('no top-level version="..." in %s' % package_mo)
    return m.group(1)


def mo_str(s):
    """Quote a string for a Modelica script."""
    return '"%s"' % str(s).replace("\\", "/").replace('"', '\\"')


def export_tag(repo, tag, dest):
    if dest.exists():
        shutil.rmtree(dest)  # a reused --work must not mix in files from an earlier tag
    dest.mkdir(parents=True)
    archive = subprocess.Popen(["git", "-C", str(repo), "archive", tag, "TRANSFORM"],
                               stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    untar = subprocess.run(["tar", "-x", "-C", str(dest)], stdin=archive.stdout,
                           capture_output=True)
    archive.stdout.close()
    err = archive.stderr.read().decode(errors="replace").strip()
    archive.wait()
    if archive.returncode != 0:
        raise SetupError("git archive %s failed: %s" % (tag, err))
    if untar.returncode != 0:
        raise SetupError("tar failed: %s" % untar.stderr.decode(errors="replace").strip())


def report_rows(report):
    """Return the report's non-header lines and table rows as plain text."""
    if not report.is_file():
        return ["(report not written)"]
    text = report.read_text(encoding="utf-8", errors="replace")
    out = []
    pre = text.split("<table", 1)[0]
    for line in re.sub(r"<[^>]+>", " ", pre).splitlines():
        line = " ".join(html.unescape(line).split())
        if line:
            out.append(line)
    for row in re.findall(r"<tr[^>]*>(.*?)</tr>", text, re.S | re.I):
        if re.search(r"<th", row, re.I):
            continue
        cells = [" ".join(html.unescape(re.sub(r"<[^>]+>", " ", c)).split())
                 for c in re.findall(r"<td[^>]*>(.*?)</td>", row, re.S | re.I)]
        out.append(" | ".join(cells))
    return out


def tail(path, n=20):
    if not path.is_file():
        return ["(no log at %s)" % path]
    return path.read_text(encoding="utf-8", errors="replace").splitlines()[-n:]


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[1],
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--library", default=str(REPO_ROOT.parent / "TRANSFORM-Library"),
                    help="folder holding TRANSFORM/package.mo (default: %(default)s)")
    ap.add_argument("--repo", help="git repo to read the release tag from (default: --library)")
    ap.add_argument("--tag", help="release tag (default: newest v* tag reachable from HEAD)")
    ap.add_argument("--dymola", default="dymola", help="Dymola command (default: %(default)s)")
    ap.add_argument("--timeout", type=float, default=900,
                    help="seconds before Dymola is killed (default: %(default)s)")
    ap.add_argument("--work", help="work folder (default: a new temp folder, deleted after a PASS or "
                    "NOT BUMPED result, kept otherwise; a --work folder is always kept)")
    ap.add_argument("--keep", action="store_true", help="keep the temp work folder in every case")
    ap.add_argument("--report", help="checkConversion HTML report (default: <work>/conversion_report.html)")
    a = ap.parse_args(argv)

    work = None
    # A temp folder holds an 85 MB export of the old release. Delete it when there is
    # nothing to inspect: kept, the folders filled a 32 GB RAM-backed /tmp (2026-11-04).
    remove_work = not a.work and not a.keep
    try:
        library = Path(a.library).resolve()
        repo = Path(a.repo).resolve() if a.repo else library
        cur_pkg = library / "TRANSFORM" / "package.mo"
        cur_ver = read_version(cur_pkg)
        tag = a.tag or run_git(repo, "describe", "--tags", "--abbrev=0", "--match", "v*", "HEAD")

        work = Path(a.work).resolve() if a.work else Path(tempfile.mkdtemp(prefix="transform_conv_"))
        work.mkdir(parents=True, exist_ok=True)
        report = Path(a.report).resolve() if a.report else work / "conversion_report.html"

        old_root = work / "old"
        export_tag(repo, tag, old_root)
        old_pkg = old_root / "TRANSFORM" / "package.mo"
        old_ver = read_version(old_pkg)
    except (SetupError, OSError) as e:
        print("SETUP ERROR: %s" % e)
        if work:
            print("work folder: %s" % work)
        return 2

    def summary(verdict):
        print("current %s | tag %s | old %s | verdict: %s" % (cur_ver, tag, old_ver, verdict))
        print("work folder: %s" % work)

    if cur_ver == old_ver:
        summary("NOT BUMPED")
        print("The library version was not bumped since %s (both say %s), so "
              "checkConversion has nothing to check." % (tag, cur_ver))
        if remove_work:
            shutil.rmtree(work, ignore_errors=True)
            print("work folder removed (--keep or --work keeps it)")
        return 1

    log = work / "dymola.log"
    # Each step also prints to its own file: if a command errors, Dymola -nowindow
    # stops the script but stays open, so savelog never runs and only this file
    # shows how far it got.
    progress = work / "progress.txt"
    for f in (log, report, progress):
        if f.exists():
            f.unlink()
    mos = work / "run.mos"
    mos.write_text("\n".join([
        "Advanced.TranslationInCommandLog := true;",
        "ok := openModel(%s, changeDirectory=false);" % mo_str(cur_pkg),
        'Modelica.Utilities.Streams.print("RESULT openModel=" + String(ok), %s);' % mo_str(progress),
        'r := checkConversion("TRANSFORM", %s, {%s}, reportPath=%s);'
        % (mo_str(old_ver), mo_str(old_pkg), mo_str(report)),
        'Modelica.Utilities.Streams.print("RESULT checkConversion=" + String(r), %s);' % mo_str(progress),
        "savelog(%s);" % mo_str(log),
        "exit();",
        "",
    ]), encoding="utf-8")

    try:
        subprocess.run([a.dymola, "-nowindow", str(mos)], cwd=str(work), timeout=a.timeout,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except FileNotFoundError:
        summary("ERROR")
        print("SETUP ERROR: Dymola command not found: %s (use --dymola)" % a.dymola)
        return 2
    except PermissionError:
        summary("ERROR")
        print("SETUP ERROR: Dymola command not executable: %s (use --dymola)" % a.dymola)
        return 2
    except subprocess.TimeoutExpired:
        summary("TIMEOUT")
        print("Dymola did not finish within %g s. A script command probably failed; "
              "steps completed:" % a.timeout)
        print("\n".join(tail(progress)))
        return 2

    results = dict(RESULT_RE.findall(progress.read_text(encoding="utf-8", errors="replace"))
                   if progress.is_file() else [])
    if results.get("openModel") != "true":
        summary("ERROR")
        print("Dymola could not open %s. Last log lines:" % cur_pkg)
        print("\n".join(tail(log)))
        return 2
    if "checkConversion" not in results:
        summary("ERROR")
        print("No checkConversion result in %s. Last log lines:" % progress)
        print("\n".join(tail(log)))
        return 2

    if results["checkConversion"] == "true":
        summary("PASS")
        if remove_work:
            shutil.rmtree(work, ignore_errors=True)
            print("work folder removed (--keep or --work keeps it)")
        if report.exists():
            print("report: %s" % report)
        return 0
    summary("FAIL")
    print("checkConversion returned false: the library does not fully declare how to "
          "upgrade models written for %s (%s)." % (tag, old_ver))
    print("report: %s" % report)
    for row in report_rows(report):
        print("  " + row)
    return 1


if __name__ == "__main__":
    sys.exit(main())
