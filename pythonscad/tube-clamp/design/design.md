# Tube clamp — PythonSCAD design

## Purpose

PythonSCAD implementation of the same reusable open tube clamp as the OpenSCAD
version.

The source structure intentionally mirrors the OpenSCAD implementation so both
versions can be compared directly.

## Shared conventions

Both implementations use the same parameter names, helper names and small
constants where the languages allow it. For example, both use:

```text
tube_diameter
clearance
wall_thickness
clamp_width
opening_angle
EPS
clamp_inner_radius
clamp_outer_radius
full_ring
opening_cutter
tube_clamp
```

The language syntax itself is not forced to match: OpenSCAD geometry is built
with modules, while PythonSCAD geometry is returned from Python functions.

## Parameters

| Parameter | Default | Meaning |
| --- | ---: | --- |
| `tube_diameter` | 20 mm | Nominal outside diameter of the tube. |
| `clearance` | 0.0 mm | Extra diametral space around the tube. |
| `wall_thickness` | 3 mm | Radial thickness of the clamp. |
| `clamp_width` | 16 mm | Width along the tube axis. |
| `opening_angle` | 60° | Angle of the clamp opening. |

## 1. Ring

The base shape is an outer cylinder minus an inner cylinder.

```python
def full_ring():
    inner_r = clamp_inner_radius()
    outer_r = clamp_outer_radius()

    return (
        cylinder(h=clamp_width, r=outer_r, fn=120)
        - cylinder(
            h=clamp_width + 2 * EPS,
            r=inner_r,
            fn=120,
        ).translate([0, 0, -EPS])
    )
```

![Full ring](img/01-ring.png)

## 2. Opening

The opening uses the same triangular wedge construction as the OpenSCAD
implementation.

```python
def opening_cutter():
    outer_r = clamp_outer_radius()
    cutter_r = outer_r + 2 * wall_thickness + 1
    half_angle = opening_angle / 2

    points = [
        [0, 0],
        [cutter_r * cos(-half_angle * pi / 180),
         cutter_r * sin(-half_angle * pi / 180)],
        [cutter_r * cos( half_angle * pi / 180),
         cutter_r * sin( half_angle * pi / 180)],
    ]

    return polygon(points).linear_extrude(
        height=clamp_width + 2 * EPS
    ).translate([0, 0, -EPS])
```

![Opening cutter](img/02-opening.png)

## 3. Final clamp

The final clamp mirrors the OpenSCAD boolean operation directly.

```python
def tube_clamp():
    return full_ring() - opening_cutter()
```

![Final clamp](img/03-final.png)

## Design views

The same source file generates the documentation views:

```python
if design_view == "01-ring":
    show(full_ring())
elif design_view == "02-opening":
    show(opening_cutter())
else:
    show(tube_clamp())
```

The render workflow supplies `DESIGN_VIEW`.
