# Changelog

## Unreleased

### Changed

- Refresh root `update-repo.sh` and `update-repo.ps1` to the canonical `tool.scad-project v0.15.6` consumer wrappers so future repository updates use the released Migration 009 path.

- Adopt released `tool.scad-project v0.15.6` with exact tool gitlink `8ea81a0c3483770bedda75ccf80fb72797097c0a` for Migration 009, preserving existing clamp geometry/API while correcting production-run concurrency.
- Requalify exact main `2cb73a1a4f3b5a75ac5c3f606a37f1a91ccfd835` through production run `35728856721`; both `prod/bld` and `prod/vrf` identify the v0.15.6 stack.

Functional changes to released `lib.scad.clamps` versions.

## v0.1.8

### Changed

- Keep the configured tube-clamp wall thickness constant when tension geometry
  is selected by shrinking the outside radius together with the tension bore.
- Keep the ring centre on the functional/nominal datum, so switching between
  functional and tension geometry does not move the intended tube centre.

## v0.1.7

### Added

- Add an optional explicit `tension_diameter` for tube clamps and public
  functional/tension/selected bore accessors.
- Add `use_tension_bore` to the OpenSCAD and PythonSCAD build/render paths so
  the same clamp can show the nominal tube bore or produce the smaller
  clamping-print bore.
- Add OpenSCAD `high_resolution` build/render control, retaining 120 fragments
  for normal output and using 48 for faster interactive assembly work.
- Add public `extra = 0.01` Boolean tolerance for robust unions/differences.

### Changed

- Stop moving the complete circular clamp body 1 mm into the compact base.
  Nominal circle placement is now independent of Boolean overlap; `extra`
  supplies only the tiny local overlap/extension needed for robust geometry.
- Keep the outside ring envelope based on the functional/nominal bore plus wall
  thickness even when a smaller tension bore is selected.

## v0.1.6

### Changed

- Align the library with released `tool.scad-project v0.14.9` and exact tool gitlink `a140b22858ac1899e7f2fa71b679639a70d819c3`.
- Normalize persistent generated-output publication to the canonical technical `bld` / `vrf` namespaces: `dev/pr-N/{bld,vrf}`, `prod/{bld,vrf}` and `rel/vX.Y.Z/{bld,vrf}` while retaining human-facing Build/Verification terminology.
- Requalify the full/dual direct-engine library on affected PR run `35122513993` and merged-main run `35122676804` without changing clamp API, geometry, functional verification or SCons policy.

## v0.1.5

### Changed

- Align the final Migration-005 consumer baseline to released `tool.scad-project v0.14.8` with exact tool gitlink `85781a6b21a0f6a06d37be154fd9eb475ecaa2a4`.
- Use semantic `v0.14.8` Production and thin split Release callers while retaining the existing full/dual runtime and `build_engine.engine: direct` policy with no SCons cache transport.
- Requalify the affected PR (`35101169850`), merged main (`35101626924`) and README-only zero-runtime (`35101816174`) paths without changing clamp API, geometry or functional verification behaviour.

## v0.1.4

### Changed

- Migrate the library to released `tool.git-project v0.2.8`, `tool.scad-project v0.14.3` and the SCAD toolchain v0.5.0 runtime family.
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
