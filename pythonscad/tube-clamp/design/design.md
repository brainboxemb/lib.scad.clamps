# Tube clamp — PythonSCAD design

## Purpose

The PythonSCAD implementation follows the same object-based API as OpenSCAD.
One clamp object contains all geometry parameters and is passed to geometry,
rendering and calculation functions.

## API shape

```python
clamp = tube_clamp_create()

tube_clamp_build(clamp)
tube_clamp_render(clamp, mode="02-opening")

inner_r = tube_clamp_inner_radius(clamp)
outer_r = tube_clamp_outer_radius(clamp)
```

The clamp data is represented by an immutable Python dataclass.
`tube_clamp_create(...)` provides the same creation-style API as OpenSCAD.

## 1. Full ring

Calculations receive the object instead of separate values:

```python
def tube_clamp_inner_radius(clamp):
    return (clamp.tube_diameter + clamp.clearance) / 2
```

The ring remains an outer cylinder minus an inner cylinder.

![Full ring](img/01-ring.png)

## 2. Opening cutter

The same triangular construction is used:

```python
cutter_half_width = cutter_length * tan(
    radians(clamp.opening_angle / 2)
)
```

`radians()` is needed because Python's `tan()` expects radians.

![Ring with opening cutter](img/02-opening.png)

## 3. Final clamp

The public geometry call is:

```python
tube_clamp_build(clamp)
```

Internally `_opening_cutter(clamp)` is subtracted from `_full_ring(clamp)`.

![Final clamp](img/03-final.png)

## Rendering

Construction views use:

```python
tube_clamp_render(
    clamp,
    mode="02-opening",
)
```

The render entrypoint creates a default clamp and sets `fn = 120` in its own
render context.
