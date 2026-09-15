# Changelog

Functional changes to released `lib.scad.clamps` versions.

## Unreleased

### Changed

- Migrate the library to released `tool.git-project v0.2.8`, `tool.scad-project v0.14.2` and the SCAD toolchain v0.5.0 runtime family.
- Replace the consumer-authored Migration-004 Moon lifecycle graph with inherited `scad.docs` and `scad.verify` capabilities plus library-specific source-impact inputs.
- Make the canary intent explicit with `build_engine.engine: direct` while retaining both OpenSCAD and PythonSCAD configuration, so production selects the full/dual runtime without normal or Verification SCons cache transport.
- Use the Migration-005 thin production caller and generic v0.2.8 PR-preview cleanup; normal CI retains compact orchestration evidence instead of duplicate complete output artifacts.
- Keep functional verification focused on public OpenSCAD/PythonSCAD API behaviour, while shared planner/workflow CI evidence qualifies foundation pins, inherited capabilities and the direct/full-runtime integration contract.

## v0.1.3

### Changed

- Upgrade repository tooling to released `tool.scad-project v0.13.1` and align the tool gitlink plus Production/Release/PR-cleanup reusable workflow pins to its exact source commit.
- Replace separate normal Build and Verify heavy workflows with the common Moon-gated single-host SCAD production lifecycle: lightweight host preflight, at most one explicit SCAD Docker process, host-side validation/staging and same-job Build/Verification publication after the container exits.
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

### Added

- Add the first coordinated library release workflow with immutable Build/Verification snapshots and release bundles.

### Changed

- Align the repository with the current split `project.yml` / `project.scad.yml` tooling model.

## v0.1.0

### Added

- Initial reusable OpenSCAD and PythonSCAD tube-clamp library.
