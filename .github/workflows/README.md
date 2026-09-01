# Workflows

## DSG - Update design images

`dsg-openscad.yml` updates implementation-specific design images for both
OpenSCAD and PythonSCAD.

The job runs inside the pinned shared toolchain container:

```text
ghcr.io/brainboxemb/scad-toolchain:v0.1.1
```

The version is intentionally explicit. Toolchain upgrades should be deliberate
repository changes so geometry or render differences can be reviewed.

The workflow:

1. checks out the repository;
2. shows the active SCAD toolchain versions;
3. regenerates OpenSCAD and PythonSCAD design images;
4. checks only the tracked `design/img/` paths for changes;
5. commits generated design images back to `main` only when they changed.

Generated PNG commits do not trigger another workflow run because `design/img`
is not part of the path trigger.

If `main` changes while rendering is in progress, the workflow refuses to push
stale generated output.
