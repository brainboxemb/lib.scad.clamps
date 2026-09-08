# lib.scad.clamps

Reusable parametric clamp designs with parallel OpenSCAD and PythonSCAD
implementations.

## Quick links

- [Generated build output](../../tree/build)
- [Generated design documentation](../../blob/build/design/README.md)
- [Functional verification](../../tree/verification)

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

The first reference part is an open snap-fit tube clamp with a compact flat
base.

The base is deliberately **not** a mounting plate. Its width is derived from
the transition width, so it cannot extend beyond the lower edge of the sloped
transition. A consuming project or later library variant can add screw or
mounting-plate geometry.

Both implementations expose equivalent parameters for:

- tube diameter;
- clearance;
- wall thickness;
- clamp width;
- opening angle;
- compact base thickness;
- transition width;
- transition depth.

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

OpenSCAD uses the object-based public API:

```scad
clamp = tube_clamp_create(...);
tube_clamp_build(clamp);
tube_clamp_render(clamp, view = TUBE_CLAMP_VIEW_OPENING);
```

PythonSCAD keeps the equivalent native class API:

```python
clamp = TubeClamp(...)
clamp.build()
clamp.render(view=TubeClamp.View.OPENING)
```

Dedicated render entrypoints translate the external `design_view` selection and
call these public APIs. They do not call private geometry helpers directly.

Opening either implementation directly still produces the default final clamp.

## Implementation parity

The OpenSCAD and PythonSCAD implementations use the same geometric construction
and the same parameter flow wherever practical.

Both versions:

- use the same geometric parameter names and defaults;
- use the same `EPS` and foot-overlap values;
- calculate the same tube radii;
- build the same full ring;
- build the opening from the same simple triangular cutter;
- add the same flat foot and sloped transition;
- expose the same design stages.

PythonSCAD receives the workflow's `-D name=value` defines as Python
globals before the script executes. The render entrypoint reads `design_view`
from `globals()` and uses `TubeClamp.View.FINAL` as the normal fallback.

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

OpenSCAD uses a top-level `tube_clamp_render(...)` call. PythonSCAD creates a
default `TubeClamp` and uses:

```python
show(clamp.render())
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

The PythonSCAD render entrypoint lives next to `tube_clamp.py`, so it can use a
normal sibling import:

```python
from tube_clamp import TubeClamp
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

PythonSCAD uses a native class API:

```python
clamp = TubeClamp(...)
clamp.build()
clamp.render(view=TubeClamp.View.OPENING)
clamp.inner_radius
clamp.outer_radius
```

Render views are represented by the nested `TubeClamp.View` `StrEnum`; its
values are the readable labels, so no separate view configuration table is
required.

## Functional verification

The repository contains consumer-level API tests under `test/`.

Both the OpenSCAD and PythonSCAD tests create three clamps with different
dimensions, verify calculated radii, render the result and export STL geometry.

Generated functional verification output is not stored on `main`. The
`VRF - Functional verification` workflow publishes successful output to the
orphan `verification` branch.

This separates:

```text
main          source, design documentation and tests
verification generated functional verification evidence
```



## Visual design documentation

The `tube-clamp` design documentation is intentionally built as a visual
construction sequence rather than only showing the final model.

For both implementations the generated images are:

```text
01-outer-ring.png
02-base.png
03-transition.png
04-bore.png
05-opening.png
06-final.png
07-profile.png
```

The construction views highlight newly added geometry or material to be
removed in transparent red. The sequence first creates the complete outside and
only then shows the tube bore and snap opening as subtractive operations. The
profile view looks directly along the clamp width so the compact base and
transition can be judged without perspective distortion.

Design images are generated by `tool.scad-project design-build`. They are
written below `bld/design` and published on the generated `build` branch. No
generated design PNG files are committed to `main`.

## Implementation direction

OpenSCAD is the primary implementation direction for future reusable clamp
libraries.

This project deliberately uses OpenSCAD `object()` values as a struct-like
public data model. PythonSCAD currently cannot transfer those object values
across the `osuse()` boundary, so adapting the OpenSCAD API around that
limitation would compromise the preferred library design.

The PythonSCAD `tube-clamp` implementation is retained because this repository
also serves as a technology comparison and the implementation itself remains
useful. For now, however, no further PythonSCAD expansion is planned beyond
maintaining this existing implementation and its native consumer test.

## PythonSCAD module imports

PythonSCAD uses normal Python module imports. Its official examples show adding
an external Python module location to `sys.path` before importing:

Source: https://www.pythonscad.org/examples/

```python
import sys
sys.path.append("\\path\\to\\python\\site-packages-dir")
```

The functional verification test uses the same mechanism, but keeps the path
relative to this repository:

```python
import sys
from pathlib import Path

LIB_DIR = Path.cwd() / "pythonscad" / "tube-clamp"
sys.path.append(str(LIB_DIR))

from tube_clamp import TubeClamp
```

`run-verification.sh` changes to the repository root before invoking
PythonSCAD, so the relative module path is deterministic in both local and
GitHub Actions runs.

## Development guide

Repository architecture, workflow rules and persistent ChatGPT handoff
context are documented in [`CHATGPT.md`](CHATGPT.md).
## Shared project workflow

This repository pins `tool.scad-project` release `v0.4.4` for both local
tooling and GitHub Actions.

The intended alignment is:

```text
project.yml
    v0.4.4

tools/tool.scad-project
    gitlink -> commit tagged v0.4.4

GitHub reusable workflows
    @v0.4.4
```

The repository's own GitHub Actions YAML files are deliberately thin callers.
The common build and verification steps live in `tool.scad-project`.

Build output is published to:

```text
build
```

Functional verification evidence is published separately to:

```text
verification
```

## Repository dependency update

### Direct dependency behavior

When this repository is cloned standalone, bootstrap initializes its direct
`tools/tool.scad-project` dependency.

When `lib.scad.clamps` is consumed as a submodule of another project, the
parent project's normal checkout does not recursively initialize this library's
own tooling submodule. Consumers therefore receive the CAD source without
pulling the library's development tooling tree.



`project.yml` is the dependency-policy source. For this library the project
tooling is pinned as:

```yaml
tooling:
  tool_scad_project:
    type: git-submodule
    url: https://github.com/brainboxemb/tool.scad-project.git
    path: tools/tool.scad-project
    ref: v0.4.4
```

After bootstrap, the normal intentional dependency update command is:

```powershell
.\update-repo.ps1
```

or:

```bash
bash ./update-repo.sh
```

The command resolves the configured refs, updates submodule gitlinks and keeps
the thin GitHub workflow references aligned. It deliberately leaves all changes
uncommitted for review.

The repository updater is intentionally Python-free; on Windows it only requires Git and PowerShell.

Useful direct commands are:

```powershell
.\tools\tool.scad-project\scad-project.ps1 repo-status
.\tools\tool.scad-project\scad-project.ps1 repo-sync
.\tools\tool.scad-project\scad-project.ps1 repo-update
```

`repo-sync` restores the commits already locked by the parent repository.
`repo-update` intentionally resolves the configured refs again.

## Generated design documentation

The source branch contains only the maintained design source:

```text
openscad/tube-clamp/design/design.md
pythonscad/tube-clamp/design/design.md
```

Both documents use `scad-render-defaults` and `scad-render`.

OpenSCAD design rendering uses:

```text
engine: openscad
source: tube_clamp_render.scad
module: tube_clamp_design
```

PythonSCAD design rendering uses:

```text
engine: pythonscad
source: tube_clamp_render.py
```

The reusable `tool.scad-project` build workflow generates:

```text
bld/design/
├── project/
│   ├── openscad/...
│   └── pythonscad/...
└── README.md
```

Successful non-PR runs publish the generated output to the mutable orphan
`build` branch.

The normal `main` branch therefore remains free of generated design PNGs.

## Project tooling

This repository pins `tool.scad-project` as a Git submodule:

```text
tools/tool.scad-project
```

Bootstrap requires only Git plus PowerShell/bash:

```powershell
.\bootstrap.ps1
```

or:

```bash
bash ./bootstrap.sh
```

After bootstrap the common design commands are:

```powershell
.\tools\tool.scad-project\scad-project.ps1 config-lint
.\tools\tool.scad-project\scad-project.ps1 design-lint
.\tools\tool.scad-project\scad-project.ps1 design-build
```

The model, code and documentation are being developed with the assistance of ChatGPT.

