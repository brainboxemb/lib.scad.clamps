# lib.scad.clamps plan

## Purpose

This is the operational source for future work in the reusable clamp library.
Completed functional history belongs in [../CHANGELOG.md](../CHANGELOG.md).

## Current position

The current tube-clamp baseline is established. OpenSCAD is the primary
direction for future reusable clamp work; the PythonSCAD implementation remains a
maintained comparison and regression target.

There is no active feature issue or pull request at the time of this migration.
New work should start from a concrete reusable clamp problem rather than
extending the repository speculatively.

## Working method

1. inspect current source, open issues/PRs, live CI and generated evidence;
2. read the affected component-local `design/design.md`;
3. preserve public API behavior unless the scoped change explicitly changes it;
4. verify OpenSCAD consumer behavior and PythonSCAD comparison behavior where
   the existing dual implementation is affected;
5. inspect generated design/evidence when the question is visual.

## Information sources

| Question | Authority |
| --- | --- |
| Current/future library work | this plan |
| Shared working conventions | `brainboxemb.meta/AGENTS.md` |
| Library purpose/contracts | [10-specification.md](10-specification.md) |
| Repository architecture | [20-design.md](20-design.md) |
| Detailed clamp construction | component-local `design/design.md` |
| Verification strategy/status | [30-verification.md](30-verification.md) |
| Exact tooling/runtime state | config, gitlinks, live Actions and provenance |
| Completed history | [../CHANGELOG.md](../CHANGELOG.md) |
