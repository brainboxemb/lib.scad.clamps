# Verification source

Repository-level verification strategy and current acceptance are documented in
[../doc/30-verification.md](../doc/30-verification.md).

Executable consumer tests live under:

```text
test/
├── openscad/
│   └── tube_clamp_api.scad
└── pythonscad/
    └── tube_clamp_api.py
```

The verification commands are configured in `project.scad.yml` and write
generated evidence to `vrf/out`. Successful publication uses
`dev/pr-N/vrf`, `prod/vrf` and release `rel/vX.Y.Z/vrf` namespaces.

The PythonSCAD test resolves its library path from the repository root; the
existing PythonSCAD implementation remains a maintained comparison and
regression target.
