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

Tests are discovered directly from the library's `UnitTests` components and
`test_spec.json` — no generated script files. Progress is shown live in
`<work_dir>/dashboard.html`, which becomes the final report after comparison.
See the DSTF repo for the full CLI, comparison modes, and configuration
reference.
