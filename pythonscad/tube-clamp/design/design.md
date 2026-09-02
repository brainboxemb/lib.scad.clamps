# Tube clamp — PythonSCAD design

## Purpose

This document explains the PythonSCAD implementation of the same `tube_clamp`
geometry used by the OpenSCAD version.

The implementation is split into:

- `tube_clamp.py` — reusable library;
- `tube_clamp_render.py` — design/render entrypoint;
- `design/design.md` — construction explanation;
- `design/img/` — generated construction images.

The library exposes:

```python
tube_clamp(...)
render_tube_clamp(...)
```

Internal construction functions start with `_`.

## Parameters

| Parameter | Default | Meaning |
| --- | ---: | --- |
| `tube_diameter` | 20 mm | Nominal outside diameter of the tube. |
| `clearance` | 0.0 mm | Extra diametral space around the tube. |
| `wall_thickness` | 3 mm | Radial wall thickness of the clamp. |
| `clamp_width` | 16 mm | Clamp width along the tube axis. |
| `opening_angle` | 60° | Angular size of the open section. |
| `EPS` | 0.05 mm | Small overlap used for robust boolean subtraction. |

## Public geometry

The public function builds the same two-part boolean construction as OpenSCAD:

```python
def tube_clamp(
    tube_diameter,
    clearance,
    wall_thickness,
    clamp_width,
    opening_angle,
):
    return (
        _full_ring(
            tube_diameter,
            clearance,
            wall_thickness,
            clamp_width,
        )
        - _opening_cutter(
            tube_diameter,
            clearance,
            wall_thickness,
            clamp_width,
            opening_angle,
        )
    )
```

So the design sequence remains:

1. make a complete cylindrical ring;
2. subtract a triangular opening cutter.

## 1. Full ring

The inner radius is calculated from tube diameter and clearance:

```python
def _clamp_inner_radius(
    tube_diameter,
    clearance,
):
    return (tube_diameter + clearance) / 2
```

The outer radius adds the wall thickness:

```python
def _clamp_outer_radius(
    tube_diameter,
    clearance,
    wall_thickness,
):
    return (
        _clamp_inner_radius(
            tube_diameter,
            clearance,
        )
        + wall_thickness
    )
```

The ring is an outer cylinder minus an inner cylinder:

```python
def _full_ring(
    tube_diameter,
    clearance,
    wall_thickness,
    clamp_width,
):
    inner_r = _clamp_inner_radius(
        tube_diameter,
        clearance,
    )

    outer_r = _clamp_outer_radius(
        tube_diameter,
        clearance,
        wall_thickness,
    )

    return (
        cylinder(
            h=clamp_width,
            r=outer_r,
            fn=120,
        )
        - cylinder(
            h=clamp_width + 2 * EPS,
            r=inner_r,
            fn=120,
        ).translate([0, 0, -EPS])
    )
```

As in OpenSCAD, `EPS` lets the subtracting cylinder extend slightly beyond both
faces of the outer cylinder.

![Full ring](img/01-ring.png)

## 2. Opening cutter

PythonSCAD uses the same simple triangular construction as OpenSCAD.

The point of the triangle is at the center of the clamp. Its far edge extends
beyond the outer radius.

```python
cutter_length = outer_r + 10

cutter_half_width = cutter_length * tan(
    radians(opening_angle / 2)
)

points = [
    [0, 0],
    [cutter_length, -cutter_half_width],
    [cutter_length,  cutter_half_width],
]
```

The only language-specific detail is that Python's `tan()` expects radians, so
`opening_angle / 2` is converted with `radians()`.

The triangle becomes a 3D cutter by extruding it through the clamp width:

```python
return polygon(points).linear_extrude(
    height=clamp_width + 2 * EPS
).translate([0, 0, -EPS])
```

The design image shows both the ring and cutter so the subtraction is directly
visible.

![Ring with opening cutter](img/02-opening.png)

## 3. Final clamp

The final boolean is deliberately kept as close as possible to the OpenSCAD
implementation:

```python
return (
    _full_ring(...)
    - _opening_cutter(...)
)
```

The public `tube_clamp(...)` function wraps this construction and validates its
inputs.

![Final clamp](img/03-final.png)

## Render API

The design workflow does not import or call private helper functions.

Instead it uses:

```python
render_tube_clamp(
    mode="02-opening",
)
```

This public helper exposes the supported construction views while keeping the
private implementation internal.

The separate `tube_clamp_render.py` entrypoint only selects the requested view:

```python
from pythonscad import *

from tube_clamp import render_tube_clamp

design_view = globals().get("design_view", "final")

show(
    render_tube_clamp(
        mode=design_view,
    )
)
```

PythonSCAD receives `-D name=value` values as globals before the script runs, so
the workflow can select a view with:

```bash
pythonscad   --trust-python   -D 'design_view="02-opening"'   tube_clamp_render.py
```

This keeps the reusable library independent of the design workflow while still
using the same public render API as the OpenSCAD implementation.
