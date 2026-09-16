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

Functional verification stays focused on those library behaviours. Repository/tooling alignment—dependency refs, exact gitlinks, reusable-workflow pins, inherited Moon capabilities and runtime/cache selection—is qualified by the shared tooling and PR CI evidence instead of being reimplemented as configuration-string checks in the product verification script.

Successful functional evidence is published separately to `prod/verification`. A failed verification must not replace the previous successful snapshot.

A version release reruns Build-side design/documentation production and Verify against the exact release source and publishes immutable snapshots under:

```text
rel/vX.Y.Z/build
rel/vX.Y.Z/verification
```

The release also creates an annotated source tag, deterministic bundles and SHA-256 checksums.

## Normal CI orchestration

Normal pull-request and `main` production uses the released Migration-005 lifecycle from `tool.scad-project v0.14.3`.

The library exposes only two real capabilities:

```text
scad.docs
    generated OpenSCAD + PythonSCAD design documentation

scad.verify
    OpenSCAD + PythonSCAD public-consumer PNG/STL verification
```

Root `moon.yml` selects those capabilities and contains only project-specific source-impact inputs. Shared task implementation comes from `.moon/tasks/scad.yml`, which extends the exact-pinned `tool.scad-project` policy. Consumer-authored build-index/provenance tasks and the old `scad.production-impact` / `scad.ci` lifecycle roots are gone.

One host-side Moon affected query decides whether CAD work is needed. README-only or unrelated changes can therefore stop before the CAD runtime. When one or both capabilities are affected, the shared planner chooses the runtime and cache policy from `project.scad.yml` and materializes the required output in at most one CAD process.

This repository deliberately keeps both OpenSCAD and PythonSCAD configuration, so it is the Migration-005 **full/dual runtime** canary. It also explicitly selects:

```yaml
build_engine:
  engine: direct
```

so no normal or Verification SCons cache transport should occur. Moon still provides coarse capability impact and whole-capability reuse; there is simply no SCons layer inside these direct capabilities.

Normal successful CI publishes the changed Build/Verification families and retains compact orchestration evidence instead of uploading another full copy of those trees as Actions artifacts.

## Implementation direction

OpenSCAD is the primary direction for new reusable clamp-library work. The object-based API is intentionally preferred over long scalar parameter lists.

PythonSCAD remains useful here as a technology comparison and as an independently maintained implementation. Its consumer test must continue to run, but new reusable components do not need a parallel PythonSCAD implementation unless there is a specific reason.

## Project tooling

Repository-level Git/dependency policy and SCAD-specific policy are intentionally separated:

```text
project.yml
    generic project/profile/dependency policy

project.scad.yml
    SCAD paths, engines, verification and publication policy

moon.yml
    visible capabilities + library-specific source-impact boundaries

.moon/tasks/scad.yml
    inherited shared SCAD capability implementation
```

The direct tooling layout is:

```text
tools/tool.git-project
    generic bootstrap and Moon/VCS engine, pinned directly by the parent gitlink

tools/tool.scad-project
    SCAD tooling and reusable production/release workflows, declared in project.yml
```

`tool.git-project` is not recursively listed in `project.yml` because it must exist before that configuration can be processed. `tool.scad-project` is declared in `project.yml`, locked by its gitlink and matched by the exact reusable Production/Release workflow commit pins. PR preview cleanup is supplied by released `tool.git-project v0.2.8`. Keep those representations aligned.

Bootstrap and dependency updates remain simple from the consumer repository:

```powershell
.\bootstrap.ps1
.\update-repo.ps1
```

or:

```bash
bash ./bootstrap.sh
bash ./update-repo.sh
```

The root bootstrap launchers are canonical copies from `tool.git-project`. The root update launchers are thin SCAD wrappers from `tool.scad-project`; generic Git/ref handling still belongs to `tool.git-project`, while the SCAD wrapper additionally aligns SCAD reusable-workflow refs to the exact SCAD-tool gitlink.

Normal checkout initializes direct dependencies only. When this library is consumed as a submodule, the parent project does not recursively initialize this library's own development-tooling submodules.

Repository-specific agent guidance is in [`AGENTS.md`](AGENTS.md). Workflow-specific notes are in [`.github/workflows/README.md`](.github/workflows/README.md).

The model, code and documentation were developed with the assistance of ChatGPT.

<!-- Migration 005 qualification probe: README-only change; close this PR without merge. -->
