# Tube clamp — PythonSCAD design

## Purpose

The PythonSCAD implementation remains as the parallel comparison implementation
for this existing library.

The geometry now follows the same next design step as OpenSCAD: the C-shaped
clip gets a flat mounting foot and a simple sloped transition. No screw holes
or mounting-head variants are added yet.

## Constructor

```python
clamp = TubeClamp(
    tube_diameter=20,
    clearance=0.0,
    wall_thickness=3,
    clamp_width=16,
    opening_angle=60,
    foot_length=40,
    foot_thickness=4,
    foot_transition_width=30,
    foot_transition_height=8,
)
```

## 1. Full ring

Derived tube dimensions remain normal class properties:

```python
@property
def inner_radius(self):
    return (self.tube_diameter + self.clearance) / 2
```

The ring is moved in front of the mounting foot while keeping a small physical
overlap:

```python
@property
def _center_x(self):
    return (
        self.foot_thickness
        + self.outer_radius
        - FOOT_OVERLAP
    )
```

![Full ring](img/01-ring.png)

## 2. Opening cutter

The same triangular opening construction is retained:

```python
cutter_half_width = cutter_length * tan(
    radians(self.opening_angle / 2)
)
```

The construction view shows the complete ring in light gray and the cutter in
transparent red.

![Ring with opening cutter](img/02-opening.png)

## 3. Clip body

The original C-shaped geometry remains available as a separate design view:

```python
def _clip_body(self):
    return (
        self._full_ring()
        - self._opening_cutter()
    )
```

![Clip body](img/03-clip-body.png)

## 4. Flat mounting foot

The foot is a rectangular mounting body plus an extruded trapezoidal
transition:

```python
points = [
    [self.foot_thickness, -base_half_width],
    [self.foot_thickness, base_half_width],
    [attach_x, attach_y],
    [attach_x, -attach_y],
]
```

The final model first unions the outer ring and mounting foot. The bore and
opening are then cut from the complete body:

```python
outer_body = (
    self._outer_ring_solid()
    | self._mounting_foot()
)

return (
    outer_body
    - self._inner_bore_cutter()
    - self._opening_cutter()
)
```

This leaves the tube path open while turning the transition into two sloped
side supports.

![Final clamp with flat foot](img/04-final.png)

## View selection

```python
class View(StrEnum):
    FINAL = "Final clamp"
    RING = "Full ring"
    OPENING = "Opening cutter"
    CLIP_BODY = "Clip body"
```

The languages keep equivalent design stages while using their own natural API
style.
