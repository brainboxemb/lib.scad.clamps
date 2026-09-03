# ChatGPT project handoff guide

This file is the persistent development context for `lib.scad.clamps`.
Read it before making structural changes. It is a handoff document, not a
conversation transcript.

The model, code and documentation are being developed with the assistance of
ChatGPT.

## Project purpose

`lib.scad.clamps` is a reusable CAD library. The first component is an open
snap-fit tube clamp implemented in parallel in OpenSCAD and PythonSCAD:

```text
openscad/tube-clamp/
pythonscad/tube-clamp/
```

Both implementations must represent the same design, but should use the natural
idioms of their language. Do not force syntax-level symmetry.

## Repository structure

```text
lib.scad.clamps/
├── README.md
├── CHATGPT.md
├── openscad/tube-clamp/
│   ├── tube_clamp.scad
│   ├── tube_clamp_render.scad
│   └── design/
│       ├── design.md
│       └── img/
├── pythonscad/tube-clamp/
│   ├── tube_clamp.py
│   ├── tube_clamp_render.py
│   └── design/
│       ├── design.md
│       └── img/
├── test/
│   ├── openscad/tube_clamp_api.scad
│   └── pythonscad/tube_clamp_api.py
├── vrf/README.md
├── scripts/
└── .github/workflows/
```

Design images may be generated/committed on the normal branch. Functional
verification output is generated and published to the orphan
`verification` branch, not to `main`.

## Toolchain

Pinned container:

```text
ghcr.io/brainboxemb/scad-toolchain:v0.1.2
```

Important commands:

```text
openscad
pythonscad
python3
git
scad-toolchain-info
```

PythonSCAD headless rendering uses:

```bash
xvfb-run -a pythonscad --trust-python ...
```

### OpenSCAD objects

The OpenSCAD implementation uses experimental `object()` support. Every CLI run
that consumes the library must enable:

```bash
openscad --enable=object-function ...
```

The correct feature name is `object-function`.

Do not use the rejected/incorrect variants:

```text
--enable=object
--enable=all
```

unless a new explicit architectural decision is made.

## Tube clamp geometry

Current defaults:

```text
tube diameter          20 mm
clearance               0.0 mm
wall thickness          3 mm
clamp width            16 mm
opening angle          60°
base thickness          4 mm
transition width       30 mm
transition depth        8 mm
BASE_OVERLAP            1.0 mm
EPS                     0.05 mm
```

Construction:

1. build the solid circular outside;
2. add the compact flat base;
3. add the sloped transition, producing one complete outer shape;
4. subtract the tube bore once from that outer shape;
5. subtract the simple triangular snap opening.

The base clip is deliberately mounting-neutral. Its flat base width is exactly
`transition_width`; there is no independent base/mounting-plate width.

Current compact-base parameters are `base_thickness`, `transition_width`, and
`transition_depth`.

The triangular opening cutter remains deliberate. Do not replace it with a
more complicated sector unless the design requires it.

Possible future mounting variants include a single-screw version and an
extended two-screw mounting-plate version. They are not part of the base clip
yet.

## OpenSCAD API

OpenSCAD uses an object in a C-struct-like way.

```scad
clamp = tube_clamp_create(...);

tube_clamp_build(clamp);
tube_clamp_render(clamp, view = TUBE_CLAMP_VIEW_OPENING);

inner_r = tube_clamp_inner_radius(clamp);
outer_r = tube_clamp_outer_radius(clamp);
```

Public lifecycle names:

```text
tube_clamp_create
tube_clamp_build
tube_clamp_render
tube_clamp_inner_radius
tube_clamp_outer_radius
```

`tube_clamp_create(...)` owns the primary parametrical inputs and returns the
OpenSCAD object. Helpers receive that object instead of repeated parameter
lists.

Private implementation helpers use `_`, for example `_full_ring`,
`_opening_cutter`, `_mounting_foot` and `_foot_transition`.

### OpenSCAD global names and views

Global constants must be component-prefixed because OpenSCAD has no proper
namespace for them:

```scad
TUBE_CLAMP_VIEW_FINAL = 0;
TUBE_CLAMP_VIEW_RING = 1;
TUBE_CLAMP_VIEW_OPENING = 2;
TUBE_CLAMP_VIEW_CLIP_BODY = 3;

TUBE_CLAMP_VIEW_TABLE = [
    [TUBE_CLAMP_VIEW_FINAL,     "Final clamp"],
    [TUBE_CLAMP_VIEW_RING,      "Full ring"],
    [TUBE_CLAMP_VIEW_OPENING,   "Opening cutter"],
    [TUBE_CLAMP_VIEW_CLIP_BODY, "Clip body"]
];
```

`TABLE` is intentionally preferred over `CONFIG`.

The enum value intentionally equals the table index. Keep the consistency
check:

```scad
function tube_clamp_view_label(view) =
    assert(
        TUBE_CLAMP_VIEW_TABLE[view][0] == view,
        "TUBE_CLAMP_VIEW_TABLE index/value mismatch"
    )
    TUBE_CLAMP_VIEW_TABLE[view][1];
```

The OpenSCAD Customizer uses the same numeric view values.

## PythonSCAD API

PythonSCAD uses native Python OOP instead of copying the OpenSCAD/C API.

```python
clamp = TubeClamp(
    tube_diameter=20,
    clearance=0.0,
    wall_thickness=3,
    clamp_width=16,
    opening_angle=60,
    foot_length=40,
    foot_thickness=4,
    foot_transition_width=30,
    foot_transition_height=8,
)

clamp.build()
clamp.render(view=TubeClamp.View.OPENING)

clamp.inner_radius
clamp.outer_radius
```

The `TubeClamp(...)` constructor is the complete parametric input surface.
Do not add a redundant `tube_clamp_create()` factory without a real need.

Private construction logic belongs in methods such as:

```text
_full_ring()
_opening_cutter()
_mounting_foot()
_foot_transition()
```

The class is currently an immutable/frozen dataclass.

### PythonSCAD views

Views are scoped to the class and use a `StrEnum`:

```python
class View(StrEnum):
    FINAL = "Final clamp"
    RING = "Full ring"
    OPENING = "Opening cutter"
    CLIP_BODY = "Clip body"
```

The enum value is already the readable label. Do not add duplicate
`VIEW_CONFIG`, `VIEW_LABELS` or `tube_clamp_view_label()` structures in Python.

The render entrypoint must explicitly convert command-line injected values:

```python
design_view = TubeClamp.View(
    globals().get(
        "design_view",
        TubeClamp.View.FINAL,
    )
)
```

The Python render workflow therefore passes strings such as:

```bash
-D 'design_view="Opening cutter"'
```

OpenSCAD intentionally uses numeric CLI view values; PythonSCAD uses the
`StrEnum` string values.

## Surface resolution

Surface resolution is not part of the geometry API.

OpenSCAD:

```scad
$fn = 120;
```

PythonSCAD:

```python
fn = 120
```

Render entrypoints set their own resolution as well.

Do not reintroduce a public `segments` parameter.

Known PythonSCAD observation: some intermediate construction views have shown
rougher OpenCSG/faceting artifacts while final geometry renders correctly.
Current policy is to keep the documented global `fn = 120` approach unless
final renders/exports prove it insufficient.

## Design documentation

### Source comments

Source files should explain non-obvious design intent rather than restating
syntax. In particular, document:

- why Boolean overlaps such as `BASE_OVERLAP` exist;
- the outer-shape-first / cutouts-afterwards construction order;
- why the compact base has no independent width parameter;
- what `transition_width` and `transition_depth` mean geometrically.

Routine expressions do not need line-by-line commentary.


### Generated design image cleanup

Each `design/img/` directory is a generated image set.

`scripts/render-design-images.sh` must maintain an explicit list of expected
PNG filenames for each implementation. Only after all design renders have
succeeded should it remove PNG files that are no longer in that list.

This prevents stale files after design-step renames (for example an old
`03-final.png` remaining beside `03-clip-body.png`) without deleting valid
existing images before a render that might fail.


Each implementation has `design/design.md`. These files are important project
artifacts.

They must contain:

1. concise geometry/design explanation;
2. essential code snippets only;
3. generated design images.

They must not become either:

- only images;
- full source-code walkthroughs.

Current design sequence:

```text
01-outer-ring
02-base
03-transition
04-bore
05-opening
06-final
07-profile
```

Design documentation should make geometry changes visually explicit. When a
construction step adds geometry, keep existing geometry neutral/light gray and
show the newly added material in transparent red where practical. The final
profile view should look directly along the clamp width so mounting-foot and
transition dimensions are easy to judge without perspective.

For step 2, show the complete ring plus the opening cutter as a transparent red
overlay. The ring should be neutral/light gray.

OpenSCAD and PythonSCAD images should be conceptually equivalent even if their
implementation syntax differs.

## Render entrypoints

Dedicated render entrypoints:

```text
openscad/tube-clamp/tube_clamp_render.scad
pythonscad/tube-clamp/tube_clamp_render.py
```

They should:

- translate external view selection;
- create a default clamp;
- invoke the public render API;
- set their own surface resolution.

They should not call private geometry helpers directly.

The primary library files should also produce a useful default/final preview
when opened directly.

Expected module preview names are based on the source filename:

```text
tube_clamp.png
```

not `standalone.png`.

## PythonSCAD imports

Native PythonSCAD `.py` libraries use normal Python imports.

Official reference:
https://www.pythonscad.org/examples/

PythonSCAD shows the normal Python pattern:

```python
import sys
sys.path.append("\\path\\to\\python\\site-packages-dir")
```

The functional consumer test uses the same approach with a repository-relative
path:

```python
import sys
from pathlib import Path

LIB_DIR = Path.cwd() / "pythonscad" / "tube-clamp"
sys.path.append(str(LIB_DIR))

from tube_clamp import TubeClamp
```

`run-verification.sh` changes to the repository root first so this is
deterministic.

Do not use `osuse()` to import `tube_clamp.py`; native Python modules use normal Python imports.

PythonSCAD can consume ordinary OpenSCAD libraries through `osuse()`, but the
current conversion layer cannot transfer OpenSCAD `object()` values across that
boundary. Because this project deliberately prefers object-based OpenSCAD APIs,
direct PythonSCAD consumption of the OpenSCAD implementation is not a supported
project path for now.


## Primary implementation direction

OpenSCAD is the primary implementation direction for future reusable libraries
in this project.

This is a deliberate outcome of the PythonSCAD evaluation.

The preferred OpenSCAD architecture uses `object()` values as struct-like
parametric data models:

```scad
clamp = tube_clamp_create(...);
tube_clamp_build(clamp);
```

That design is considered cleaner and more extensible than flattening every
operation into long scalar parameter lists.

PythonSCAD can consume conventional OpenSCAD geometry modules through
`osuse()`, but its current OpenSCAD/Python conversion layer does not support
OpenSCAD `object()` values. A function returning an OpenSCAD object therefore
does not produce a reusable Python-side value that can later be passed back to
another OpenSCAD function/module.

For this project the conclusion is intentionally strong:

- do not weaken or flatten the OpenSCAD object API to accommodate PythonSCAD;
- do not invest further in PythonSCAD as the default implementation path for
  new reusable libraries;
- keep the existing PythonSCAD `tube-clamp` implementation because this
  repository is also a technology exploration/comparison and that implementation
  remains useful;
- maintain its native PythonSCAD consumer test so the existing implementation
  does not silently regress;
- revisit PythonSCAD only if its object interoperability or overall maturity
  materially changes.

This conclusion is specific to the project's preferred reusable-library
architecture, not a claim that PythonSCAD cannot generate CAD geometry.


## Functional consumer tests

Tests under `test/` exercise the public API as an external consumer.

There are two maintained consumer paths: native OpenSCAD and native PythonSCAD.

They create three clearly different clamps: small, default/medium and large.
They vary several geometric parameters and also assert derived radius values.

The tests must verify:

- external library consumption;
- parametric construction;
- public build API;
- derived calculations;
- PNG rendering;
- STL export.

Do not call private helpers from these consumer tests.

## Verification workflow

`.github/workflows/verify.yml` performs functional verification.

It should:

1. run OpenSCAD consumer tests;
2. run PythonSCAD consumer tests;
3. render PNG output;
4. export STL output;
5. verify calculations;
6. fail on command errors;
7. fail on logged `ERROR:` lines;
8. create an index and build metadata;
9. publish only after all checks pass;
10. publish to orphan branch `verification`.

A failed run must not replace the last successful verification output.

Expected generated structure:

```text
verification branch
├── index.md
├── openscad/
│   ├── tube-clamp-api.png
│   └── tube-clamp-api.stl
├── pythonscad/
│   ├── tube-clamp-api.png
│   └── tube-clamp-api.stl
└── metadata/
    └── build-info.txt
```

### OpenSCAD error handling

OpenSCAD can log `ERROR:` and still exit with status 0. Scripts therefore must
check both:

- actual process status;
- output logs for `ERROR:`.

Do not simplify this back to exit-code-only checking.

### Shell scripts in Actions

Do not rely on Unix executable bits because Windows/ZIP workflows may not
preserve them.

Use:

```yaml
run: bash scripts/run-verification.sh
```

instead of:

```yaml
run: scripts/run-verification.sh
```

Apply the same rule to other repository shell scripts used by Actions.

### Git safe directory

Container workflows may need:

```bash
git config --global --add safe.directory "$GITHUB_WORKSPACE"
```

before Git operations.

## Naming conventions

```text
repository/directory names   kebab-case
code filenames               snake_case
OpenSCAD identifiers         snake_case
Python functions             snake_case
Python classes               PascalCase
OpenSCAD global constants    UPPER_SNAKE_CASE with component prefix
```

Examples:

```text
tube-clamp/
tube_clamp.scad
tube_clamp_render.scad
tube_clamp.py
tube_clamp_render.py
TubeClamp
TUBE_CLAMP_VIEW_OPENING
TUBE_CLAMP_VIEW_TABLE
```

Do not return to hyphenated code filenames.

## Conceptual parity

Keep this conceptual mapping:

```text
OpenSCAD                        PythonSCAD

tube_clamp_create(...)          TubeClamp(...)
tube_clamp_build(clamp)         clamp.build()
tube_clamp_render(clamp, view)  clamp.render(view)
tube_clamp_inner_radius(clamp)  clamp.inner_radius
tube_clamp_outer_radius(clamp)  clamp.outer_radius
```

Equivalent behavior is the goal, not identical language mechanics.

## Explicitly rejected approaches

Also rejected:

- a permanent PythonSCAD/OpenSCAD scalar bridge whose only purpose is to hide
  the missing OpenSCAD `object()` conversion;
- flattening the public OpenSCAD API into scalar convenience wrappers for
  PythonSCAD interoperability.


Do not silently reintroduce these without a new architectural decision:

- public `segments`/resolution parameter propagated through geometry APIs;
- Python `__all__` for this small explicit-import library;
- Python top-level `tube_clamp_create/build/render` functions that mimic C;
- Python numeric `VIEW_CONFIG` tables;
- generic OpenSCAD `VIEW_FINAL`, `VIEW_RING`, etc. without component prefix;
- OpenSCAD `--enable=object` (wrong feature name);
- OpenSCAD `--enable=all` for this library;
- `osuse()` for importing native `tube_clamp.py`;
- design docs containing only images;
- design docs duplicating complete implementation files.

## ZIP delivery rules

When ChatGPT provides a development ZIP:

- provide a complete repository snapshot unless a patch is explicitly requested;
- use a new unique versioned filename;
- never overwrite the previous ZIP;
- do not include generated PNGs;
- do not include generated verification output;
- do not add meaningless `.gitkeep` placeholders merely for generated dirs;
- inspect the produced snapshot before claiming a change exists.

## Change discipline

This project has accumulated deliberate decisions over many iterations.

Before a refactor:

1. inspect the current files;
2. identify the exact concern being changed;
3. preserve unrelated decisions;
4. update relevant design docs together with source;
5. update consumer tests when the public API changes;
6. update render scripts when view/CLI semantics change;
7. update verification workflow when invocation behavior changes.

Prefer focused changes over broad cleanup.

## Current handoff state

At this point:

- OpenSCAD uses an object-based create/build/render API;
- PythonSCAD uses the `TubeClamp` class API;
- OpenSCAD views use prefixed numeric constants plus
  `TUBE_CLAMP_VIEW_TABLE`;
- PythonSCAD views use `TubeClamp.View(StrEnum)`;
- both implementations use global surface resolution 120;
- the tube clamp now includes a flat mounting foot with a sloped transition;
- design docs use explanation + essential snippets + images;
- native functional consumer tests exist for both implementations;
- OpenSCAD is the primary direction for future reusable libraries;
- PythonSCAD is retained only for this comparison implementation and is not
  currently a target for further library expansion;
- verification publishes generated evidence to the orphan `verification`
  branch;
- PythonSCAD consumer imports use the documented `sys.path` approach;
- future work should build on these decisions rather than reconstruct them from
  chat history.
