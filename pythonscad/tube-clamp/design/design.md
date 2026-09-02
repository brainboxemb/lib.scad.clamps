# Tube clamp — PythonSCAD design

## Purpose

This document explains the PythonSCAD implementation of the same reusable
`tube_clamp` geometry as the OpenSCAD version.

The full implementation lives in `tube_clamp.py`; this document focuses on the
design choices and the few language-specific differences.

The clamp is built in three steps:

1. create a complete cylindrical ring;
2. define a triangular opening cutter;
3. subtract the cutter from the ring.

## Parameters

| Parameter | Default | Meaning |
| --- | ---: | --- |
| `tube_diameter` | 20 mm | Nominal outside diameter of the tube. |
| `clearance` | 0.0 mm | Extra diametral space around the tube. |
| `wall_thickness` | 3 mm | Radial wall thickness of the clamp. |
| `clamp_width` | 16 mm | Clamp width along the tube axis. |
| `opening_angle` | 60° | Angular size of the open section. |

PythonSCAD uses the equivalent global surface setting:

```python
fn = 120
```

## 1. Full ring

The radius calculation is identical to the OpenSCAD version:

```python
inner_r = (tube_diameter + clearance) / 2
outer_r = inner_r + wall_thickness
```

The complete ring is created by subtracting the inner cylinder from the outer
one. `EPS` gives the subtracting cylinder a small overlap beyond both faces.

![Full ring](img/01-ring.png)

## 2. Opening cutter

The opening uses the same triangular construction as OpenSCAD:

```python
cutter_length = outer_r + 10

cutter_half_width = cutter_length * tan(
    radians(opening_angle / 2)
)
```

The `radians()` conversion is the main language-specific difference here:
Python's `tan()` expects radians, while the design parameter is expressed in
degrees.

The cutter is then made from the same three points:

```python
points = [
    [0, 0],
    [cutter_length, -cutter_half_width],
    [cutter_length,  cutter_half_width],
]
```

![Ring with opening cutter](img/02-opening.png)

## 3. Final clamp

The final geometry mirrors the OpenSCAD boolean construction:

```python
return _full_ring(...) - _opening_cutter(...)
```

The reusable public geometry is exposed as `tube_clamp(...)`.

![Final clamp](img/03-final.png)

## Design rendering

`render_tube_clamp(...)` provides the construction views used by the design
documentation. The separate `tube_clamp_render.py` entrypoint selects the
requested view and sets:

```python
fn = 120
```

This keeps the design images consistent with the standalone module preview.
