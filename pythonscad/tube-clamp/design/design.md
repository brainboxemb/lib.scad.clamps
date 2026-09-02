# Tube clamp — PythonSCAD design

## Purpose

PythonSCAD implementation of the same tube clamp geometry as the OpenSCAD
version.

## Parameters

The model parameters are regular Python variables:

```python
tube_diameter = 20
clearance = 0.0
wall_thickness = 3
clamp_width = 16
opening_angle = 60
```

PythonSCAD makes values supplied with `-D name=value` available as Python
globals before the script executes.

The design view therefore uses the injected value when present and falls back
to `final` when the file is opened without a command-line define:

```python
design_view = globals().get("design_view", "final")
```

## 1. Ring

The base shape is an outer cylinder minus an inner cylinder.

```python
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

The cutter is the same simple triangle used by the OpenSCAD implementation.

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

The triangle is extruded through the clamp width. The design view shows the
ring and cutter together.

![Ring with opening cutter](img/02-opening.png)

## 3. Final clamp

The final clamp subtracts the triangular cutter from the ring.

```python
return full_ring(...) - opening_cutter(...)
```

![Final clamp](img/03-final.png)

## Design views

The render workflow selects the same design view with the same `-D` pattern
used by OpenSCAD:

```bash
pythonscad --trust-python \
  -D 'design_view="02-opening"' \
  tube-clamp.py
```

PythonSCAD injects `design_view` into the Python globals before executing the
script.
