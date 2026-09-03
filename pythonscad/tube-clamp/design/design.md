# Tube clamp — PythonSCAD design

## Purpose

The PythonSCAD implementation follows the same model concepts as OpenSCAD, but
uses Python's native class model instead of copying the OpenSCAD/C-style API.

The clamp remains fully parametric: all geometry inputs are constructor
parameters of `TubeClamp`.

## Constructor

```python
clamp = TubeClamp(
    tube_diameter=20,
    clearance=0.0,
    wall_thickness=3,
    clamp_width=16,
    opening_angle=60,
)
```

This is the Python equivalent of creating the OpenSCAD clamp object.

## 1. Full ring

Derived dimensions are exposed as properties:

```python
@property
def inner_radius(self):
    return (self.tube_diameter + self.clearance) / 2

@property
def outer_radius(self):
    return self.inner_radius + self.wall_thickness
```

The ring itself remains an outer cylinder minus an inner cylinder.

![Full ring](img/01-ring.png)

## 2. Opening cutter

The same triangular construction is used:

```python
cutter_half_width = cutter_length * tan(
    radians(self.opening_angle / 2)
)
```

The opening design view returns the ring and cutter as two separate objects so
the cutter remains a transparent visualization overlay.

![Ring with opening cutter](img/02-opening.png)

## 3. Final clamp

The public geometry API is now an instance method:

```python
clamp.build()
```

Private construction helpers are methods on the same object.

![Final clamp](img/03-final.png)

## View selection

PythonSCAD keeps the same numeric view constants and configuration table as the
OpenSCAD implementation:

```python
VIEW_FINAL = 0
VIEW_RING = 1
VIEW_OPENING = 2
```

## Rendering

Construction views are rendered with:

```python
clamp.render(
    view=VIEW_OPENING,
)
```

The separate render entrypoint creates a default `TubeClamp`, selects the
requested view and sets `fn = 120` in its own render context.
