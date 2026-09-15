# Changelog

Functional changes to released `lib.scad.clamps` versions.

## Unreleased

### Changed

- Upgrade repository tooling to released `tool.scad-project v0.13.0` and align the tool gitlink plus Production/Release/PR-cleanup reusable workflow pins to its exact source commit.
- Replace separate normal Build and Verify heavy workflows with the common Moon-gated SCAD production lifecycle: lightweight host preflight, at most one SCAD container, and lightweight Build/Verification publication jobs.
- Add a library-specific Moon graph that models the actual producer domains (`scad.docs` and `scad.verify`) without inventing a normal `scad.build` task for a repository that has no configured render/export build targets.
- Keep the existing OpenSCAD and PythonSCAD public-consumer PNG/STL verification content unchanged while moving its orchestration into the shared lifecycle.

## v0.1.2

### Changed

- Complete the repository tooling migration from `tool.scad-project` v0.9.10 through the intermediate v0.9.12 work to released `v0.12.0`.
- Pin `project.yml`, the `tools/tool.scad-project` gitlink, and Build/Verify/Release/PR-cleanup reusable workflows to the exact v0.12.0 source commit.
- Keep pull-request previews isolated under `dev/pr-<number>/build` and `dev/pr-<number>/verification`, with cleanup after PR close.
- Continue to run Build and Verify for pull requests and pushes to `main`, avoiding duplicate feature-branch push runs.
- Preserve the existing clamp API, geometry and self-contained OpenSCAD/PythonSCAD verification behaviour while adopting the current released repository tooling.

## v0.1.1

### Changed

- Upgrade repository tooling from `tool.scad-project` v0.9.8 to v0.9.10.
- Pin `project.yml`, the `tools/tool.scad-project` gitlink, and Build/Verify/Release reusable workflows to the exact v0.9.10 source commit.
- Adopt the layout-independent Build/Verify cache hashing and design-render improvements included in v0.9.10.

## v0.1.0

### Added

- Establish the first immutable release of the reusable clamp library.
- Release the OpenSCAD object-based `tube-clamp` API together with the maintained native PythonSCAD comparison implementation.
- Publish generated design documentation and consumer-level PNG/STL verification evidence.
- Add coordinated versioned release publication with immutable `rel/vX.Y.Z/build` and `rel/vX.Y.Z/verification` snapshots, release bundles and SHA-256 checksums.

### Changed

- Upgrade repository tooling from `tool.scad-project` v0.7.2 to v0.9.8.
- Pin Build, Verify and Release reusable workflows to the exact commit behind v0.9.8.
- Move mutable production output from legacy `build` / `verification` branches to `prod/build` / `prod/verification`; development output remains under `dev/*`.
- Keep OpenSCAD as the primary reusable-library direction while retaining PythonSCAD as a maintained comparison/verification implementation.
- Treat `project.yml`, the tool gitlink and workflow commit pins as the authoritative dependency alignment.
