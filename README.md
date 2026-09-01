# lib.scad.clamps

Reusable parametric clamp designs with parallel OpenSCAD and PythonSCAD
implementations.

The repository is organized by implementation technology first. Each concrete
clamp keeps its source, design documentation and generated design images
together.

## Project status

Experimental library for developing and comparing reusable clamp designs in OpenSCAD and PythonSCAD. The current focus is the first `tube-clamp` implementation and the supporting design/render workflow.

The model, code and documentation are being developed with the assistance of ChatGPT.

## Structure

```text
lib.scad.clamps/
├── openscad/
│   └── tube-clamp/
│       ├── tube-clamp.scad
│       └── design/
│           ├── design.md
│           └── img/
├── pythonscad/
│   └── tube-clamp/
│       ├── tube-clamp.py
│       └── design/
│           ├── design.md
│           └── img/
├── shared/
├── scripts/
└── .github/workflows/
```

## Tube clamp

The first reference part is a simple open snap-fit tube clamp. The initial
design is deliberately limited to the reusable clamp body; mounting feet and
project-specific attachment features are left out.

Both implementations expose equivalent core parameters:

- tube diameter;
- clearance;
- wall thickness;
- clamp width;
- opening angle.

## SCAD toolchain

Design automation runs in the shared, explicitly versioned SCAD toolchain
container:

```text
ghcr.io/brainboxemb/scad-toolchain:v0.1.2
```

The version is pinned deliberately. A toolchain upgrade is an explicit
repository change so generated CAD output cannot silently change because a
moving `latest` image changed.

The container provides both OpenSCAD and PythonSCAD.

## Toolchain requirement

The design workflow currently pins:

```text
ghcr.io/brainboxemb/scad-toolchain:v0.1.2
```

This version includes Git in the container because the design workflow may
commit changed generated PNG files back to the repository.

## Design documentation convention

Each implementation keeps a `design/design.md` next to its source.

A design document should capture:

- the intent of the part;
- the important parameters;
- the essential geometry/construction steps;
- small code excerpts that explain those steps;
- generated images showing the same steps.

The design document is expected to change together with meaningful geometry
changes. Source code and design documentation should therefore be reviewed as
one change.

Generated PNG files under `design/img/` are refreshed by GitHub Actions and
committed only when their contents change.

## Design documentation

Design documentation is kept next to each implementation.

The generated PNG files under each `design/img/` directory are intentionally
stored in the normal Git repository. They are considered part of the design
documentation rather than disposable build output.

Run both implementations locally when using the SCAD toolchain environment:

```bash
bash ./scripts/render-design-images.sh
```

For OpenSCAD, multiple documentation views are generated from the same `.scad`
source with `design_view` values passed through `-D`.

For PythonSCAD, the same concept uses the `DESIGN_VIEW` environment variable.

## Automatic design image update

The workflow `DSG - Update design images`:

1. runs inside the pinned SCAD toolchain container;
2. renders the OpenSCAD design views;
3. renders the equivalent PythonSCAD design views;
4. checks the tracked `design/img/` directories for changes;
5. commits the images back to `main` only when their contents changed.

Generated-image commits do not trigger another design run because the workflow
path filter watches design sources, documentation, scripts and the workflow
itself, not `design/img/*.png`.

If `main` changes while a render is running, the workflow refuses to push stale
generated output.

## Implementation parity

The OpenSCAD and PythonSCAD implementations use the same geometric construction
and the same parameter flow wherever practical.

Both versions:

- use the same parameter names and defaults;
- use the same `EPS` constant;
- pass design parameters explicitly into geometry modules/functions;
- use the same radius helpers;
- build the same full ring;
- build the opening from the same simple triangular cutter;
- expose the same design views.

The languages still use their natural constructs: OpenSCAD geometry is grouped
in modules, while PythonSCAD geometry is returned from Python functions.

## Implementation comparison

The purpose of maintaining both implementations is not to generate one
language from the other. They implement the same intended geometry independently
so OpenSCAD and PythonSCAD can be compared for readability, parametrization,
development workflow and automated verification.
