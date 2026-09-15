# Verification

Functional verification is intentionally separate from generated design/documentation work.

Source tests live under:

```text
test/
├── openscad/
│   └── tube_clamp_api.scad
└── pythonscad/
    └── tube_clamp_api.py
```

Both files act as external consumers of the library. Each creates three clamps with different dimensions and checks derived radius values.

## CI execution and publication

Normal CI uses `.github/workflows/scad.yml`, which calls the released common SCAD production workflow. Moon keeps `scad.verify` as an independent producer task; it does not depend on the design/documentation producer.

When Verify is affected, the host orchestrator starts one explicit SCAD Docker process and runs the existing verification commands from `project.scad.yml` inside that process:

```yaml
verification:
  commands:
    - [bash, scripts/run-verification.sh]
    - [bash, scripts/build-verification-index.sh]
  output_root: vrf/out
```

After the Docker process exits, the same host job validates and stages `vrf/out` and publishes the successful snapshot to `dev/pr-<number>/verification` for pull requests or `prod/verification` for `main`. Publication credentials remain outside the SCAD container. A failed verification therefore does not replace the previous successful production snapshot.

## Shell script execution

GitHub Actions invokes repository shell scripts explicitly with `bash` instead of relying on the executable file mode. This keeps the workflow reliable when the repository is prepared or updated from Windows, where the Unix executable bit is not always preserved.

## PythonSCAD consumer import

The PythonSCAD verification file lives outside the library directory on purpose. It therefore adds `pythonscad/tube-clamp/` to `sys.path` before importing `TubeClamp`.

`run-verification.sh` first changes to the repository root, making that import path deterministic in GitHub Actions and local CLI runs.

## PythonSCAD import reference

The consumer test follows the approach shown in the official PythonSCAD examples:

https://www.pythonscad.org/examples/

```python
import sys
sys.path.append("\\path\\to\\python\\site-packages-dir")
```

In this repository the path is resolved relative to the repository root before `TubeClamp` is imported.

## PythonSCAD evaluation conclusion

PythonSCAD remains part of this repository only for the existing `tube-clamp` comparison implementation.

The interoperability investigation showed that PythonSCAD can consume normal OpenSCAD libraries through `osuse()`, but its current OpenSCAD/Python conversion layer does not support OpenSCAD `object()` values across that boundary.

This project deliberately prefers object-based OpenSCAD APIs for reusable CAD libraries. Therefore:

- OpenSCAD is the primary implementation direction for future reusable libraries;
- the object-based OpenSCAD API will not be flattened merely to accommodate PythonSCAD;
- the existing PythonSCAD `tube-clamp` implementation remains for comparison and consistency;
- no further PythonSCAD library expansion is planned for now;
- this decision can be revisited if PythonSCAD later supports OpenSCAD object conversion.
