# lib.scad.clamps design

## Repository architecture

The first reusable component exists in two implementation workspaces:

```text
openscad/tube-clamp/
pythonscad/tube-clamp/
```

Each keeps detailed visual construction in its own `design/design.md`.
Those documents remain the detailed design authority.

## Construction model

Both implementations follow the same physical construction sequence:

1. create one continuous outer body;
2. subtract the selected tube bore once;
3. subtract the snap opening.

The compact base is part of the clamp body but is not a mounting plate.

## OpenSCAD

OpenSCAD uses an `object()` value as the public parametric state. Public build
and render modules consume that object; private helpers remain implementation
details.

## PythonSCAD

PythonSCAD models the same clamp using a native `TubeClamp` class. It is kept
as a maintained technology comparison and independent regression path, not as a
constraint on OpenSCAD API design.

## Generated design documentation

The component-local Markdown is source. Shared design tooling renders its
embedded views and publishes readable generated documentation under Build
output. Generated images are not committed to main.
