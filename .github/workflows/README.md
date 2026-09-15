# Workflows

This repository keeps thin GitHub Actions callers. Shared SCAD workflow mechanics
are owned by `tool.scad-project`; this library owns its Moon task graph and its
OpenSCAD/PythonSCAD consumer verification.

The current SCAD tool dependency is `tool.scad-project v0.13.1`, locked by the
`tools/tool.scad-project` gitlink and exact reusable-workflow SHA.

## Normal production

`.github/workflows/scad.yml` calls the released common production workflow:

```text
brainboxemb/tool.scad-project/.github/workflows/project-production.yml@<exact-v0.13.1-commit>
```

Normal CI is no longer split into separate heavy Build and Verify jobs. Instead
one GitHub-hosted orchestrator job owns the lifecycle:

```text
host Moon preflight
    |
    +-- unaffected -> stop before image pull / SCAD container
    |
    `-- affected
          -> restore caches on the host
          -> pull the immutable SCAD image
          -> one explicit SCAD Docker process
               - generated design/documentation producer
               - OpenSCAD + PythonSCAD consumer verification producer
               - publication-ready aggregate
          -> validate and stage after the container exits
          -> publish Build from the same host job
          -> publish Verification from the same host job
```

`moon.yml` keeps the source-impact gate (`scad.production-impact`) separate from
the publication-ready execution aggregate (`scad.ci`). CI-context inputs used by
index/provenance tasks therefore do not force the SCAD runtime for a README-only
change.

## Library-specific graph

This library deliberately does **not** define a dummy `scad.build` task. It has no
normal configured render/export targets; its Build-side generated product is the
design/documentation tree plus index/provenance.

The real producer domains are:

- `scad.docs` — generated OpenSCAD and PythonSCAD design documentation;
- `scad.verify` — public-consumer verification for both implementations.

Verification remains self-contained and still renders/exports the public APIs as:

- OpenSCAD PNG;
- OpenSCAD STL;
- PythonSCAD PNG;
- PythonSCAD STL.

The shared orchestration changes where these producers run, not what the library
accepts as verification.

## Publication

The explicit SCAD Docker process never receives generated-output write credentials.
After it exits, the same host job validates and stages the prepared trees and then
publishes them through the released `tool.git-project` same-job publisher:

```text
bld       -> dev/pr-N/build or prod/build
vrf/out   -> dev/pr-N/verification or prod/verification
```

Release publication remains owned by `project-release.yml` and keeps immutable
`rel/vX.Y.Z/build` and `rel/vX.Y.Z/verification` snapshots.

## Version alignment

These representations must resolve to the same `tool.scad-project` release:

```text
project.yml
    dependency ref: v0.13.1

tools/tool.scad-project
    exact gitlink behind v0.13.1

.github/workflows/scad.yml
.github/workflows/release.yml
.github/workflows/pr-cleanup.yml
    exact reusable-workflow commit matching that gitlink
```

`scripts/run-verification.sh` checks this ownership/alignment contract in addition
to the library's public-API tests. A tooling upgrade is therefore one deliberate
repository change rather than an implicit move to a newer tool version.
