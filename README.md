# lib.scad.clamps

Reusable parametric clamp designs. OpenSCAD is the primary implementation
direction; the existing PythonSCAD implementation remains a maintained
comparison and consumer-verification path.

## Start here

- [Plan](doc/00-plan.md)
- [Specification](doc/10-specification.md)
- [Design](doc/20-design.md)
- [Verification](doc/30-verification.md)
- [OpenSCAD tube-clamp design](openscad/tube-clamp/design/design.md)
- [PythonSCAD tube-clamp design](pythonscad/tube-clamp/design/design.md)
- [Generated design documentation](../../blob/prod/bld/design/README.md)
- [Latest Verification](../../tree/prod/vrf)
- [Changelog](CHANGELOG.md)

## Public API direction

OpenSCAD uses an object-based public API:

```scad
clamp = tube_clamp_create(...);
tube_clamp_build(clamp);
tube_clamp_render(clamp, view = TUBE_CLAMP_VIEW_OPENING);
```

PythonSCAD uses native Python OOP:

```python
clamp = TubeClamp(...)
clamp.build()
clamp.render(view=TubeClamp.View.OPENING)
```

Equivalent design behavior is the goal; syntax-level symmetry is not.

Current tool/runtime versions are intentionally not copied here. Use
`project.yml`, committed gitlinks, live Actions and publication provenance for
exact current state.
