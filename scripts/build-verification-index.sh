#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${ROOT_DIR}/vrf/out"

cat > "${OUT_DIR}/index.md" <<'EOF'
# lib.scad.clamps verification

This branch contains generated functional verification output for the library.

The verification tests use the public library APIs from separate consumer files
and build three clamps with different dimensions.

## OpenSCAD

![OpenSCAD API verification](openscad/tube-clamp-api.png)

- [STL export](openscad/tube-clamp-api.stl)

## PythonSCAD

![PythonSCAD API verification](pythonscad/tube-clamp-api.png)

- [STL export](pythonscad/tube-clamp-api.stl)


## PythonSCAD consuming OpenSCAD

This test runs in PythonSCAD but loads the OpenSCAD implementation through
`osuse()` and calls its public functions/modules through the returned library
handle.

![PythonSCAD -> OpenSCAD API verification](pythonscad-openscad/tube-clamp-api.png)

- [STL export](pythonscad-openscad/tube-clamp-api.stl)

## What is verified

- the native OpenSCAD and PythonSCAD libraries can be consumed from separate source files;
- PythonSCAD can consume the OpenSCAD library through `osuse()`;
- three independent parametrized clamp instances can be created;
- the public build API produces geometry;
- derived radius calculations return the expected values;
- PNG rendering succeeds;
- STL export succeeds.
EOF
