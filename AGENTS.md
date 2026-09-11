# Repository agent guidance

Persistent guidance for automated coding agents working in `lib.scad.clamps`.

## Generic workflow policy

Before branch, pull-request, publication or release work, read the pinned
`tools/tool.scad-project/AGENTS.md`. Its pull-request-first change workflow and
publication lifecycle are authoritative for this consumer.

This root file adds library-specific guidance only. It must not contradict or
copy changing generic workflow rules from the pinned tool policy.

## Project purpose

`lib.scad.clamps` is a reusable CAD library. Its first component is an open
snap-fit tube clamp implemented in both OpenSCAD and PythonSCAD.

Both implementations represent the same design, but should use the natural
idioms of their language. Equivalent behavior is the goal; syntax-level symmetry
is not.

## Sources of truth

Use:

```text
component source + design documentation     geometry/API intent
project.yml                                 tooling/dependency policy
.gitlinks / .gitmodules                     resolved dependency state
verification tests                          public-consumer behavior
```

Do not duplicate volatile toolchain or `tool.scad-project` versions in this
file. Read the active values from `project.yml`, workflow refs and runtime
metadata.

## Repository structure

Keep implementation families separate:

```text
openscad/tube-clamp/
pythonscad/tube-clamp/
test/
vrf/
```

Generated design/build/verification output belongs under generated output paths
and publication branches, never on `main` beside source documentation.

## OpenSCAD direction

OpenSCAD is the primary implementation direction for future reusable libraries
in this repository.

Use object-based public APIs:

```scad
clamp = tube_clamp_create(...);
tube_clamp_build(clamp);
tube_clamp_render(clamp, view);
```

Do not flatten the public API into long scalar wrappers merely to accommodate
PythonSCAD interoperability limitations.

Private implementation helpers always use a leading underscore, including
nested helpers. Global constants use a component prefix because OpenSCAD has no
real namespace.

Surface resolution is render concern, not part of the public geometry API. Do
not reintroduce a public `segments` parameter.

## PythonSCAD direction

PythonSCAD uses native Python OOP rather than copying the OpenSCAD/C-like API:

```python
clamp = TubeClamp(...)
clamp.build()
clamp.render(view=...)
```

Keep its existing implementation and consumer tests as a technology comparison
and regression target, but do not make PythonSCAD the default direction for new
reusable library work unless its maturity/interoperability materially changes.

Native Python modules use normal Python imports. Do not use `osuse()` to import
`tube_clamp.py`.

## Interoperability conclusion

Current PythonSCAD interoperability does not transfer OpenSCAD `object()` values
as reusable Python-side objects. This is an architectural limitation worth
preserving as evidence, not something to hide with scalar bridge wrappers.

Do not weaken the OpenSCAD API to work around this limitation.

## Geometry discipline

Preserve the established construction order for the base clamp:

1. create the complete outside body;
2. subtract the tube bore once;
3. subtract the snap opening.

The compact base remains mounting-neutral. Do not reintroduce a separate
mounting-plate width into the base component without a new design decision.

Boolean overlap constants exist to make operations robust and should be
explained where non-obvious rather than removed as "redundant" geometry.

## Views and render entrypoints

Dedicated render entrypoints translate external view selection, construct a
default component and call the public render API. They must not call private
geometry helpers directly.

OpenSCAD uses component-prefixed numeric view constants/table entries;
PythonSCAD uses its scoped enum/string model. Do not add duplicate view mapping
structures just to make the languages look identical.

## Design documentation

Source `design.md` files explain the physical design, not merely the code or a
catalogue of render views.

For each meaningful step:

1. explain the physical feature first;
2. explain the geometric operation;
3. show an image that makes the change visible;
4. show concise source excerpts only where they improve understanding.

Generated design images belong under `bld/design`. Do not recreate committed
`design/img/` output on `main`.

## Consumer verification

Tests under `test/` act as external consumers and must exercise public APIs only.
Maintain both native OpenSCAD and native PythonSCAD paths while the PythonSCAD
implementation exists.

Verification should cover:

- external library consumption;
- parametric construction;
- public build/render API;
- derived calculations;
- PNG rendering;
- STL export.

Do not call private helpers from consumer tests.

OpenSCAD output must be checked for logged geometry errors/warnings as defined by
shared tool policy, not only process exit status.

## Tooling and CI

Pin `tool.scad-project` through `project.yml` and the gitlink. Use direct-only
submodule checkout and thin reusable workflow callers. Generic branch naming,
PR preview publication and cleanup are governed by the pinned tool policy.

Shell scripts invoked from Actions must be called explicitly with `bash`; do not
rely on executable-bit preservation across Windows/ZIP workflows.

Root bootstrap/update scripts are canonical copies from `tool.scad-project` and
must remain Python-free during bootstrap.

## Naming

```text
repository/directory names   kebab-case
code filenames               snake_case
OpenSCAD identifiers         snake_case
Python functions             snake_case
Python classes               PascalCase
OpenSCAD global constants    component-prefixed UPPER_SNAKE_CASE
private OpenSCAD symbols     leading underscore
```

The model, code and documentation are developed with the assistance of ChatGPT.
