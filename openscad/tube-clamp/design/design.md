# Tube clamp — OpenSCAD design

## Purpose

The clamp API uses one object to represent the complete clamp definition.
This is comparable to passing a `struct` through a C API: creation, geometry,
rendering and calculations all use the same object.

## API shape

```scad
clamp = tube_clamp_create(...);

tube_clamp_build(clamp);
tube_clamp_render(clamp, view = TUBE_CLAMP_VIEW_OPENING);

inner_r = tube_clamp_inner_radius(clamp);
outer_r = tube_clamp_outer_radius(clamp);
```

`tube_clamp_create(...)` contains the defaults and creates the object. This
avoids passing a growing list of geometry parameters through every helper.

## 1. Full ring

Radius calculations take the clamp object directly:

```scad
function tube_clamp_inner_radius(clamp) =
    (clamp.tube_diameter + clamp.clearance) / 2;

function tube_clamp_outer_radius(clamp) =
    tube_clamp_inner_radius(clamp)
    + clamp.wall_thickness;
```

The ring remains an outer cylinder minus an inner cylinder.

![Full ring](img/01-ring.png)

## 2. Opening cutter

The opening remains a simple triangular cutter:

```scad
cutter_length = outer_r + 10;
cutter_half_width =
    cutter_length * tan(clamp.opening_angle / 2);
```

All required dimensions come from the same clamp object.

![Ring with opening cutter](img/02-opening.png)

## 3. Final clamp

The public geometry call is intentionally small:

```scad
tube_clamp_build(clamp);
```

Internally `_opening_cutter(clamp)` is subtracted from `_full_ring(clamp)`.

![Final clamp](img/03-final.png)

## View selection

Render views use enum-style constants instead of string comparisons:

```scad
TUBE_CLAMP_VIEW_FINAL = 0;
TUBE_CLAMP_VIEW_RING = 1;
TUBE_CLAMP_VIEW_OPENING = 2;

TUBE_CLAMP_VIEW_TABLE = [
    [TUBE_CLAMP_VIEW_FINAL,   "Final clamp"],
    [TUBE_CLAMP_VIEW_RING,    "Full ring"],
    [TUBE_CLAMP_VIEW_OPENING, "Opening cutter"]
];
```

The enum value is also the configuration-array index. The label helper checks
that this contract remains valid:

```scad
function tube_clamp_view_label(view) =
    assert(
        TUBE_CLAMP_VIEW_TABLE[view][0] == view,
        "TUBE_CLAMP_VIEW_TABLE index/value mismatch"
    )
    TUBE_CLAMP_VIEW_TABLE[view][1];
```

The Customizer uses the same numeric values:

```scad
design_view = 0; // [0:Final clamp, 1:Full ring, 2:Opening cutter]
```

## Rendering

Construction views use the same object:

```scad
tube_clamp_render(
    clamp,
    view = TUBE_CLAMP_VIEW_OPENING
);
```

The render entrypoint creates a default clamp and sets `$fn = 120` in its own
render context.

## OpenSCAD object feature

The clamp data model uses OpenSCAD's experimental `object()` builtin. CLI
renders therefore explicitly enable the required feature:

```bash
openscad --enable=object-function ...
```

The repository render and test scripts add this flag automatically.
