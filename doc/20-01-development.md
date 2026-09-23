# lib.scad.clamps development manual

## Start

1. read [../AGENTS.md](../AGENTS.md);
2. read [10-00-plan.md](10-00-plan.md);
3. inspect the affected component-local design document before changing geometry;
4. use [50-00-verification.md](50-00-verification.md) for the qualification/evidence contract.

## Repository entrypoints

Managed root repository entrypoints are:

```text
bootstrap.ps1 / bootstrap.sh
update.ps1 / update.sh
```

`project.yml` selects the released SCAD tooling ref and committed gitlinks record
exact revisions.

Repository-owned workflows are:

```text
.github/workflows/self-ci.yml
.github/workflows/self-release.yml
.github/workflows/self-pr-cleanup.yml
```

They are thin repository entrypoints over the released reusable tooling APIs.

## Edit and verify

OpenSCAD is the primary reusable-library direction. PythonSCAD remains a
maintained comparison implementation.

When shared behavior changes, verify both public API consumers where the current
dual implementation is affected. Generated verification evidence belongs under
`vrf/out`; generated design/build output belongs under `bld/`.

## Release

Release only an exact qualified main commit through `self-release.yml`.
Inspect exact-main CI and generated-output provenance before creating the
release request.
