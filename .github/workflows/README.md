# Workflows

This repository keeps thin GitHub Actions callers. Shared SCAD capability tasks,
runtime/cache planning and production/release lifecycle mechanics are owned by
`tool.scad-project`; this library owns only its visible capabilities,
project-specific source-impact boundaries and OpenSCAD/PythonSCAD consumer
verification.

The current SCAD tool dependency is `tool.scad-project v0.14.2`, locked by the
`tools/tool.scad-project` gitlink and exact reusable Production/Release workflow
SHA. Generic PR-preview cleanup comes from released `tool.git-project v0.2.8`.

## Normal production

`.github/workflows/scad.yml` is intentionally a thin caller of:

```text
brainboxemb/tool.scad-project/.github/workflows/project-production.yml@5712324ea9e3a7c81ba1b79013f2758f52b219cf
```

Normal production resolves exact source/base state and runs one Moon affected
query on the host. A README-only or otherwise unrelated change stops before the
CAD runtime. When SCAD work is affected, the shared planner derives the required
capabilities, runtime and cache policy from repository configuration and executes
or hydrates the required capabilities in at most one CAD runtime.

This canary deliberately configures both OpenSCAD and PythonSCAD, so the planner
must select the full/dual `docker.scad-toolchain v0.5.0` runtime. It explicitly
selects `build_engine.engine: direct`, so normal and Verification SCons cache
restore/save must remain absent.

## Library-specific capability model

The visible capabilities are only:

```text
scad.docs
    generated OpenSCAD + PythonSCAD design documentation

scad.verify
    OpenSCAD + PythonSCAD public-consumer PNG/STL verification
```

Root `moon.yml` selects those inherited capabilities through
`workspace.inheritedTasks.include` and adds only library-specific source-impact
inputs. Shared command/output/cache policy comes from:

```text
.moon/tasks/scad.yml
    -> tools/tool.scad-project/moon/tasks/scad.yml
```

There is no dummy `scad.build` capability because this repository has no normal
configured presentation render/export targets. Migration-004 lifecycle tasks
such as build-index/provenance, `scad.production-impact` and `scad.ci` no longer
belong in this consumer graph.

Verification remains self-contained and still renders/exports the public APIs as:

- OpenSCAD PNG;
- OpenSCAD STL;
- PythonSCAD PNG;
- PythonSCAD STL.

## Publication and retained evidence

After capability materialization, host-side finishing adds current-run index and
provenance information and publishes changed output families:

```text
bld       -> dev/pr-N/build or prod/build
vrf/out   -> dev/pr-N/verification or prod/verification
```

Normal successful production retains compact orchestration evidence rather than
duplicating complete Build/Verification trees as Actions artifacts. Coordinated
releases remain different because their separate Build/Verify/finalize jobs need
exact-source artifact hand-off; release output is published under immutable
`rel/vX.Y.Z/*` branches and attached bundles.

## Version alignment

The active contract is:

```text
project.yml
    dependency ref: v0.14.2

tools/tool.scad-project
    exact gitlink: 5712324ea9e3a7c81ba1b79013f2758f52b219cf

.github/workflows/scad.yml
.github/workflows/release.yml
    exact reusable-workflow commit matching that gitlink

tools/tool.git-project
    exact gitlink: 7c43f37e7b07cfb57638a1d1dad2501de09ba7eb

.github/workflows/pr-cleanup.yml
    generic cleanup workflow v0.2.8
```

The exact pins and capability/runtime/cache contract are qualified by the shared
planner, reusable workflows and PR CI evidence. `scripts/run-verification.sh`
stays focused on the library's public OpenSCAD/PythonSCAD behaviour.
