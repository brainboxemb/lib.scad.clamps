# Tube clamp — PythonSCAD design

## Purpose

The PythonSCAD implementation uses Python's native class model rather than
copying the OpenSCAD/C-style API literally.

The model remains fully parametric: all geometry inputs are constructor
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

## 1. Full ring

Derived dimensions are exposed as properties:

```python
@property
def inner_radius(self):
    return (self.tube_diameter + self.clearance) / 2
```

The ring remains an outer cylinder minus an inner cylinder.

![Full ring](img/01-ring.png)

## 2. Opening cutter

The same triangular construction is used:

```python
cutter_half_width = cutter_length * tan(
    radians(self.opening_angle / 2)
)
```

The opening design view returns the ring and cutter as two separate objects.
The ring is explicitly light gray and the cutter remains transparent red.

![Ring with opening cutter](img/02-opening.png)

## 3. Final clamp

The public geometry API is an instance method:

```python
clamp.build()
```

![Final clamp](img/03-final.png)

## View selection

Views are part of the `TubeClamp` class and use a Python `StrEnum`:

```python
class View(StrEnum):
    FINAL = "Final clamp"
    RING = "Full ring"
    OPENING = "Opening cutter"
```

The enum value is already the readable label, so no separate view constants,
configuration table or label lookup function are needed.

Use:

```python
clamp.render(
    view=TubeClamp.View.OPENING,
)
```

`render()` converts the supplied value through `TubeClamp.View(...)`, so invalid
view values are rejected by the enum itself.

## Rendering

The separate render entrypoint creates a default `TubeClamp`, selects the
requested view and sets `fn = 120` in its own render context.
