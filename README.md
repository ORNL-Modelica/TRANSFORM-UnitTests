# TRANSFORM-UnitTests

This repository holds the reference ("gold") result files for regression
testing of the Modelica library **TRANSFORM**
(`TRANSFORM-Library/TRANSFORM`).

These used to live in the TRANSFORM-Library `Resources` folder but now reside
here to reduce library bloat and avoid file-path-length issues.

## Regression testing (DSTF)

Testing is driven by [DSTF](../DynamicSystemsTestingFramework) (Dynamic
Systems Testing Framework). Everything lives under `ReferenceResults/`:

- `ReferenceResults/testing.json` — configuration (source library, simulators,
  reference root).
- `ReferenceResults/test_spec.json` — test definitions.
- `ReferenceResults/<Backend>/<os>/ref_NNNN.json` — reference baselines,
  partitioned by simulator backend and OS (solvers produce platform-specific
  results). Numeric IDs are stable and never reused.

Install DSTF once (`uv tool install dstf`, or `pipx install dstf`), then:

```bash
# Run + compare against the stored baselines
dstf --config ReferenceResults/testing.json run

# Re-compare the last run's results without re-simulating
dstf --config ReferenceResults/testing.json compare

# Accept results as new baselines — after a run, or from the last run
# without re-simulating:
dstf --config ReferenceResults/testing.json run --accept
dstf --config ReferenceResults/testing.json compare --accept

# Parallel run + per-test interactive HTML reports
dstf --config ReferenceResults/testing.json run --parallel 4 --report
```

OpenModelica runs load the libraries named in TRANSFORM's `uses` annotation
from OpenModelica's own library folder. The look-up table tests
(`Groeneveld2006LUT`, `Groeneveld2006LUT_withKs`,
`Groeneveld2001LUT_FilmBoilingCoefficient`,
`check_Alphas_TwoPhase_3Region_CHFtransition_F1D`) need SDF there; install it
once with `omc` running `installPackage(SDF, "0.4.5")`. Dymola
2026x ships SDF.

Tests are discovered directly from the library's `UnitTests` components and
`test_spec.json` — no generated script files. Progress is shown live in
`<work_dir>/dashboard.html`, which becomes the final report after comparison.
See the DSTF repo for the full CLI, comparison modes, and configuration
reference.

## TRANSFORMTest: tests beyond the examples

`TRANSFORMTest/` is a second Modelica library, for tests that are not teaching
examples. It is not shipped with TRANSFORM. TRANSFORM's own examples stay in
TRANSFORM and remain tests; only new tests go here. Its package tree mirrors
TRANSFORM's (a test of `TRANSFORM.Media.Solids` sits in
`TRANSFORMTest.Media.Solids`). Its `uses` annotation carries the version string
of the TRANSFORM it tests; it has no releases of its own. Its DSTF config and
baselines are in `TRANSFORMTest/Resources/ReferenceResults/`; the config loads
TRANSFORM from `../TRANSFORM-Library/TRANSFORM`.

```bash
dstf --config TRANSFORMTest/Resources/ReferenceResults/testing.json run
```

What earns a test, in either library:

1. Every finished example in TRANSFORM is a test. Not: examples in InProgress
   or obsolete packages, or a close copy whose failures always coincide with
   another test's.
2. Every public function runs in at least one test, directly or inside a
   model. An uncovered function gets a small `check_` model only if users call
   it; one used only internally is covered through its caller.
3. Track what would change if the physics broke: for each key component a
   state (temperature, pressure, level) and a flow (heat, mass flow). Not
   inputs, constants or aliases of each other. Aim for 2–6 variables.
4. A new test needs a reason: a fixed bug (regression test), an uncovered
   public class, or a model option users rely on that no test turns on.
5. No test duplicates another's failure signal, and none exists only to raise
   the count.

A TRANSFORM change still comes as two PRs: one in TRANSFORM-Library, one here
with any new `TRANSFORMTest` test and the baseline updates. Before merging,
run the affected tests of both suites and the conversion guard; run both
suites in full at milestones. `TRANSFORMTest` has no CHANGELOG: TRANSFORM's
CHANGELOG names a new test by its path.

## Conversion guard

`scripts/check_conversion.py` checks that the current TRANSFORM library still
says how to upgrade models written for its last release. It exports the
release tag's `TRANSFORM/` folder (by default the nearest `v*` tag reachable
from the library's HEAD, found with `git describe`) and runs Dymola's `checkConversion` against it. Run it
by hand before merging any library PR that changes `TRANSFORM/` (needs
Dymola, git, tar and Python 3):

```bash
python3 scripts/check_conversion.py                     # library at ../TRANSFORM-Library
python3 scripts/check_conversion.py --library PATH --tag v1.0 --dymola dymola
```

Exit codes: `0` pass; `1` checkConversion failed (the printed rows name the
classes, e.g. "Old class is missing, without conversion") or the library
`version` was not bumped since the tag, so there is nothing to check; `2` setup
error, Dymola timeout (`--timeout`, default 900 s; a failing script command
shows up as a timeout, and `progress.txt` shows how far it got), the library
failed to open, or no result.
The work folder holds `run.mos`, `progress.txt`, `dymola.log`,
`conversion_report.html` and the exported old release (about 85 MB). By default
it is a new temp folder, deleted after a pass or a "not bumped" result and kept
after a failure, error or timeout; `--keep` keeps it always, and a folder given
with `--work` is never deleted.
