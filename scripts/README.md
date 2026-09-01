# Scripts

## Design documentation renders

Run:

```bash
bash ./scripts/render-design-images.sh
```

This regenerates the documentation views for both implementations:

```text
openscad/tube-clamp/design/img/
pythonscad/tube-clamp/design/img/
```

The script is intended to run inside the shared SCAD toolchain container.

### OpenSCAD

The OpenSCAD implementation renders multiple views from the same source file by
passing `design_view` through OpenSCAD's `-D` command-line option.

### PythonSCAD

The PythonSCAD implementation uses the `DESIGN_VIEW` environment variable to
select the equivalent documentation view before PythonSCAD executes the model.

## Compatibility wrapper

`render-openscad-design.sh` is retained as a compatibility wrapper and forwards
to `render-design-images.sh`.

New automation should call `render-design-images.sh` directly.
