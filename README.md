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
The work folder (kept; `--work` to choose it) holds `run.mos`, `progress.txt`,
`dymola.log` and `conversion_report.html`.
