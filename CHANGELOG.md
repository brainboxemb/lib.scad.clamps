# Changelog

Functional changes to released `lib.scad.clamps` versions.

## Unreleased

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
