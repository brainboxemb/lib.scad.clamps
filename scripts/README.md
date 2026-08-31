# Scripts

## OpenSCAD design documentation

Run:

```bash
./scripts/render-openscad-design.sh
```

This regenerates the documentation views referenced from:

`openscad/tube-clamp/design/design.md`

The script renders the same source file with different `design_view` values passed through OpenSCAD's `-D` command-line option.

## PythonSCAD

PythonSCAD rendering automation is intentionally not added yet. The first step is to settle and verify the PythonSCAD command-line environment that will be used locally and in GitHub Actions.
