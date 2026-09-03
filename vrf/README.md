# Verification

Functional verification is intentionally separate from the design renders.

Source tests live under:

```text
test/
├── openscad/
│   └── tube_clamp_api.scad
└── pythonscad/
    ├── tube_clamp_api.py
    └── tube_clamp_openscad_api.py
```

Both files act as external consumers of the library. Each creates three clamps
with different dimensions and checks derived radius values.

The workflow `.github/workflows/verify.yml` renders and exports both consumer
tests. Generated output is published to the orphan `verification` branch and is
not committed to `main`.

The last successful verification therefore remains available even when a later
workflow run fails.

## Shell script execution

GitHub Actions invokes repository shell scripts explicitly with `bash` instead
of relying on the executable file mode. This keeps the workflow reliable when
the repository is prepared or updated from Windows, where the Unix executable
bit is not always preserved.


The GitHub Actions workflow invokes the verification scripts explicitly through
`bash`, so it does not depend on the Unix executable bit being preserved by a
Windows checkout or ZIP-based update.

## PythonSCAD consumer import

The PythonSCAD verification file lives outside the library directory on purpose.
It therefore adds `pythonscad/tube-clamp/` to `sys.path` before importing
`TubeClamp`.

`run-verification.sh` first changes to the repository root, making that import
path deterministic in GitHub Actions and local CLI runs.

## PythonSCAD import reference

The consumer test follows the approach shown in the official PythonSCAD
examples:

https://www.pythonscad.org/examples/

```python
import sys
sys.path.append("\\path\\to\\python\\site-packages-dir")
```

In this repository the path is resolved relative to the repository root before
`TubeClamp` is imported.


## PythonSCAD -> OpenSCAD interoperability

`tube_clamp_openscad_api.py` is a third consumer test. It runs under
PythonSCAD, loads `openscad/tube-clamp/tube_clamp.scad` using `osuse()`, and
then calls the OpenSCAD public API through the returned handle.

This verifies that the OpenSCAD implementation is usable not only from
OpenSCAD, but also as an OpenSCAD library consumed by PythonSCAD.
