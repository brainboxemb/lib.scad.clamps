# Verification

Functional verification is intentionally separate from the design renders.

Source tests live under:

```text
test/
├── openscad/
│   └── tube_clamp_api.scad
└── pythonscad/
    └── tube_clamp_api.py
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
