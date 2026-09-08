# Workflows

## DSG - Build design documentation

`design-build.yml` uses the project-pinned `tool.scad-project` checkout to
generate design documentation for both implementations:

```text
OpenSCAD
PythonSCAD
```

Both implementations use the same Markdown render model:

```text
scad-render-defaults
scad-render
```

Generated images and generated Markdown are written only to `bld/` and are
published to the mutable orphan `build` branch. They are not committed to
`main`.

The workflow runs in:

```text
ghcr.io/brainboxemb/scad-toolchain:v0.3.0
```

`tool.scad-project` is a pinned Git submodule under:

```text
tools/tool.scad-project
```

## VRF - Functional verification

`verify.yml` keeps the independent consumer-level API verification.

Generated functional verification evidence is published to:

```text
verification
```

This is deliberately separate from the generated design/build branch:

```text
build
    generated design documentation

verification
    consumer-level API verification evidence
```
