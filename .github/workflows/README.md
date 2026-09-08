# Workflows

This repository keeps only thin GitHub Actions callers. The shared job logic is
owned by `tool.scad-project` and pinned to release `v0.4.4`.

## Build

`design-build.yml` calls:

```text
brainboxemb/tool.scad-project/.github/workflows/project-build.yml@v0.4.4
```

The reusable workflow handles:

- toolchain selection;
- tooling-version alignment;
- configuration, source and design linting;
- OpenSCAD and PythonSCAD design generation;
- configured project builds;
- build artifact upload;
- publication of the mutable `build` branch.

## Verification

`verify.yml` calls:

```text
brainboxemb/tool.scad-project/.github/workflows/project-verify.yml@v0.4.4
```

The reusable workflow first performs generic project verification and then runs
the commands declared in `project.yml`:

```yaml
verification:
  commands:
    - [bash, scripts/run-verification.sh]
    - [bash, scripts/build-verification-index.sh]
  output_root: vrf/out
```

Successful non-PR runs publish `vrf/out` to the `verification` branch.

## Version alignment

These references should all represent the same `tool.scad-project` release:

```text
project.yml
    tooling.tool_scad_project.ref: v0.4.4

tools/tool.scad-project
    gitlink pinned to the commit tagged v0.4.4

GitHub workflow
    @v0.4.4
```

A tooling upgrade is therefore one deliberate repository change rather than an
implicit update to the latest tool version.
