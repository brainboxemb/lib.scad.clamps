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
│       ├── tube_clamp.scad
│       └── design/
│           ├── design.md
│           └── img/
├── pythonscad/
│   └── tube-clamp/
│       ├── tube_clamp.py
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

## Library and design rendering

Each implementation exposes two public operations:

```text
tube_clamp(...)
tube_clamp_render(...)
```

`tube_clamp(...)` is the reusable geometry API.

`tube_clamp_render(...)` is also part of the public API. It provides the
standard construction/debug views while keeping the private geometry helpers
private.

Internal helpers use a leading underscore:

```text
_clamp_inner_radius(...)
_clamp_outer_radius(...)
_full_ring(...)
_opening_cutter(...)
```

The design workflow does not call these private helpers directly. Its separate
entrypoints only translate `design_view` into a public `tube_clamp_render(...)`
call:

```text
openscad/tube-clamp/tube_clamp_tube_clamp_render.scad
pythonscad/tube-clamp/tube_clamp_tube_clamp_render.py
```

Opening `tube_clamp.scad` directly still shows a useful preview, and its
`design_view` value can be changed through the OpenSCAD Customizer. Projects
using it as a library can use `use <tube_clamp.scad>` so the top-level preview
is ignored.

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

PythonSCAD receives the workflow's `-D name=value` defines as Python
globals before the script executes. The implementation reads `design_view`
from `globals()` and provides `final` as the normal interactive fallback.

The languages still use their natural constructs: OpenSCAD geometry is grouped
in modules, while PythonSCAD geometry is returned from Python functions.

## Implementation comparison

The purpose of maintaining both implementations is not to generate one
language from the other. They implement the same intended geometry independently
so OpenSCAD and PythonSCAD can be compared for readability, parametrization,
development workflow and automated verification.

## Standalone preview behavior

Both implementations deliberately show a default clamp when their library file
is opened directly.

OpenSCAD uses a top-level `tube_clamp_render(...)` call. PythonSCAD uses:

```python
show(tube_clamp_render())
```

This keeps the direct-open behavior conceptually similar between the two
implementations.

The workflow tests both the standalone library file and the separate design
render entrypoint. This is intentional: if PythonSCAD import behavior causes the
library's top-level `show()` to interfere with `design/tube_clamp_render.py`, the design
entrypoint test will expose that immediately.

## Module previews

Each implementation also generates a standard preview of the final module next
to the library source itself:

```text
openscad/tube-clamp/
├── tube_clamp.scad
└── tube_clamp.png

pythonscad/tube-clamp/
├── tube_clamp.py
└── tube_clamp.png
```

These are the normal end-product previews for the module. The separate
construction-step images remain under `design/img/`.

## PythonSCAD design imports

PythonSCAD does not provide `__file__` in the executed design script. The design
entrypoint therefore contains no path-discovery code.

The render/test scripts add the module directory to `PYTHONPATH` before
starting PythonSCAD, after which `design/tube_clamp_render.py` can use a normal public
import:

```python
from tube_clamp import tube_clamp_render
```

## Surface resolution

Surface resolution is not part of the clamp API.

OpenSCAD uses:

```scad
$fn = 120;
```

PythonSCAD uses the equivalent global special variable:

```python
fn = 120
```

This keeps both implementations aligned without passing render quality through
the geometry API.

The standalone library files and the separate render entrypoints each set the
same global resolution in their own execution context, so module previews and
design-step renders use the same surface quality.


## OpenSCAD object requirement

The OpenSCAD implementation uses the experimental `object()` builtin for the
clamp data model. CLI runs explicitly enable the required experimental feature:

```bash
openscad --enable=object-function ...
```

The repository scripts and GitHub Actions do this automatically. When opening
or running the OpenSCAD source outside those scripts, use an OpenSCAD nightly
build with the object feature enabled.

## Object-based clamp API

Both implementations use one clamp object as the public data model:

```text
tube_clamp_create(...)        -> create clamp object
tube_clamp_build(clamp)             -> generate final geometry
tube_clamp_render(clamp, view=...) -> render a design/debug view
tube_clamp_inner_radius(clamp)
tube_clamp_outer_radius(clamp)
```

This keeps future calculations and additional clamp parameters from expanding
every helper function signature.


### PythonSCAD API

PythonSCAD uses a native class API rather than reproducing the OpenSCAD
factory/functions literally:

```python
clamp = TubeClamp(...)
clamp.build()
clamp.render(view=VIEW_OPENING)
clamp.inner_radius
clamp.outer_radius
```

The constructor remains the complete parametric input surface for the model.
