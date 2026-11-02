#!/usr/bin/env python3
"""Conversion guard for the TRANSFORM library.

Checks, with Dymola's checkConversion, that the current TRANSFORM library still
declares how to upgrade models written for its last release (a git tag). Run it
by hand before merging library PRs.

Exit codes:
  0  checkConversion returned true
  1  checkConversion returned false, or the library version was not bumped
     since the tag (so there is nothing to check)
  2  setup error, timeout, missing log, or no RESULT line in the log

Python 3, standard library only.
"""

import argparse
import html
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

# Top-level `version="..."` of the package annotation. Anchored at line start
# so the `Modelica(version="4.0.0")` entries inside uses(...) do not match.
VERSION_RE = re.compile(r'^\s*version\s*=\s*"([^"]+)"', re.M)
RESULT_RE = re.compile(r"^RESULT checkConversion=(true|false)\s*$", re.M)


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
    dest.mkdir(parents=True, exist_ok=True)
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
    ap.add_argument("--work", help="work folder (default: a new temp folder, kept)")
    ap.add_argument("--report", help="checkConversion HTML report (default: <work>/conversion_report.html)")
    a = ap.parse_args(argv)

    work = None
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
    except SetupError as e:
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
        return 1

    log = work / "dymola.log"
    if log.exists():
        log.unlink()
    if report.exists():
        report.unlink()
    mos = work / "run.mos"
    mos.write_text("\n".join([
        "Advanced.TranslationInCommandLog := true;",
        "ok := openModel(%s, changeDirectory=false);" % mo_str(cur_pkg),
        'Modelica.Utilities.Streams.print("RESULT openModel=" + String(ok));',
        'r := checkConversion("TRANSFORM", %s, {%s}, reportPath=%s);'
        % (mo_str(old_ver), mo_str(old_pkg), mo_str(report)),
        'Modelica.Utilities.Streams.print("RESULT checkConversion=" + String(r));',
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
        print("Dymola did not finish within %g s. Last log lines:" % a.timeout)
        print("\n".join(tail(log)))
        return 2

    if not log.is_file():
        summary("ERROR")
        print("Dymola wrote no log at %s." % log)
        return 2
    m = RESULT_RE.findall(log.read_text(encoding="utf-8", errors="replace"))
    if not m:
        summary("ERROR")
        print("No 'RESULT checkConversion=' line in %s. Last log lines:" % log)
        print("\n".join(tail(log)))
        return 2

    if m[-1] == "true":
        summary("PASS")
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
