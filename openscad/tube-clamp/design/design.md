# Tube clamp — OpenSCAD design

## Purpose

This document explains the geometry of the reusable `tube_clamp` component.
The full implementation lives in `tube_clamp.scad`; this document focuses on
the design decisions and the construction steps.

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

Surface quality is controlled separately with:

```scad
$fn = 120;
```

## 1. Full ring

The ring is defined by an inner and outer radius:

```scad
inner_r = (tube_diameter + clearance) / 2;
outer_r = inner_r + wall_thickness;
```

The geometry is a simple outer cylinder with the inner cylinder removed:

```scad
difference() {
    cylinder(h = clamp_width, r = outer_r);

    translate([0, 0, -EPS])
        cylinder(
            h = clamp_width + 2 * EPS,
            r = inner_r
        );
}
```

The small `EPS` overlap avoids coincident surfaces during subtraction.

![Full ring](img/01-ring.png)

## 2. Opening cutter

The snap opening is made with a simple triangular cutter rather than a more
complex circular sector.

```scad
cutter_length = outer_r + 10;
cutter_half_width =
    cutter_length * tan(opening_angle / 2);

polygon(points = [
    [0, 0],
    [cutter_length, -cutter_half_width],
    [cutter_length,  cutter_half_width]
]);
```

The triangle starts at the center of the clamp and extends beyond the outer
radius. The opening angle therefore directly determines the width of the cut.

The design view shows the cutter together with the ring so the intended
subtraction remains visible.

![Ring with opening cutter](img/02-opening.png)

## 3. Final clamp

The final clamp is simply the full ring minus the opening cutter:

```scad
difference() {
    _full_ring(...);
    _opening_cutter(...);
}
```

The reusable public geometry is exposed as `tube_clamp(...)`.

![Final clamp](img/03-final.png)

## Design rendering

`render_tube_clamp(...)` provides the construction views used by the design
documentation. The separate `tube_clamp_render.scad` entrypoint selects the
requested view and sets its own render resolution:

```scad
$fn = 120;
```

This keeps the design images consistent with the standalone module preview.
