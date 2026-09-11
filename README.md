# lib.scad.clamps

Reusable parametric clamp designs. OpenSCAD is the primary library implementation; the existing PythonSCAD implementation is retained as a maintained comparison and consumer test.

## Quick links

- [OpenSCAD tube clamp design source](openscad/tube-clamp/design/design.md)
- [PythonSCAD tube clamp design source](pythonscad/tube-clamp/design/design.md)
- [Latest generated build](../../tree/prod/build)
- [Generated design documentation](../../blob/prod/build/design/README.md)
- [Functional verification](../../tree/prod/verification)
- [Changelog](CHANGELOG.md)

## Tube clamp

The first reusable part is an open snap-fit tube clamp with a compact flat base. The base is deliberately mounting-neutral: consuming projects can add their own screw or mounting-plate geometry without changing the core clamp.

Important parameters include tube diameter, clearance, wall thickness, clamp width, opening angle, base thickness, transition width and transition depth.

### OpenSCAD API

OpenSCAD uses an object as the public parametric data model:

```scad
clamp = tube_clamp_create(...);

tube_clamp_build(clamp);
tube_clamp_render(clamp, view = TUBE_CLAMP_VIEW_OPENING);

tube_clamp_inner_radius(clamp);
tube_clamp_outer_radius(clamp);
```

Private implementation helpers use a leading `_`, including nested helpers. Global constants are component-prefixed because OpenSCAD has no proper namespace for them.

The implementation requires:

```text
--enable=object-function
```

Surface resolution is deliberately not part of the public geometry API.

### PythonSCAD comparison API

The maintained PythonSCAD implementation uses native Python OOP rather than copying the OpenSCAD/C-style surface:

```python
clamp = TubeClamp(...)
clamp.build()
clamp.render(view=TubeClamp.View.OPENING)
clamp.inner_radius
clamp.outer_radius
```

Equivalent design behaviour is the goal, not syntax-level symmetry. Do not flatten the OpenSCAD object API merely to work around PythonSCAD/OpenSCAD object-interoperability limits.

## Design documentation

Source design documentation lives beside each implementation:

```text
openscad/tube-clamp/design/design.md
pythonscad/tube-clamp/design/design.md
```

Both use the shared `scad-render-defaults` / `scad-render` authoring model. `tool.scad-project design-build` produces the generated readable tree below `bld/design`; generated PNGs are not committed to `main`.

Successful production builds publish generated design documentation to `prod/build`.

Design documentation should explain the physical feature first, then the geometric operation, then use an image and source excerpt as supporting evidence. It should remain understandable to a reader who does not know OpenSCAD or PythonSCAD.

## Verification

Consumer-level tests under `test/` exercise the public OpenSCAD and native PythonSCAD APIs. They create multiple parameter sets, verify derived calculations, render PNG evidence and export STL geometry.

Successful functional evidence is published separately to `prod/verification`. A failed verification must not replace the previous successful snapshot.

A version release reruns Build and Verify against the exact release source and publishes immutable snapshots under:

```text
rel/vX.Y.Z/build
rel/vX.Y.Z/verification
```

The release also creates an annotated source tag, deterministic bundles and SHA-256 checksums.

## Implementation direction

OpenSCAD is the primary direction for new reusable clamp-library work. The object-based API is intentionally preferred over long scalar parameter lists.

PythonSCAD remains useful here as a technology comparison and as an independently maintained implementation. Its consumer test must continue to run, but new reusable components do not need a parallel PythonSCAD implementation unless there is a specific reason.

## Project tooling

The current `tool.scad-project` dependency is declared in `project.yml`, locked by the `tools/tool.scad-project` gitlink and matched by the reusable workflow commit pins. Keep those three representations aligned.

Bootstrap and dependency updates are Python-free:

```powershell
.\bootstrap.ps1
.\update-repo.ps1
```

or:

```bash
bash ./bootstrap.sh
bash ./update-repo.sh
```

Normal checkout initializes direct dependencies only. When this library is consumed as a submodule, the parent project does not recursively initialize this library's own development-tooling submodule.

Repository-specific agent guidance is in [`AGENTS.md`](AGENTS.md).

The model, code and documentation were developed with the assistance of ChatGPT.
