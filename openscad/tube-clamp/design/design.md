# Tube clamp — OpenSCAD design

## Purpose

This document explains how the reusable `tube_clamp` geometry is constructed
in OpenSCAD.

The implementation is split into:

- `tube_clamp.scad` — reusable library;
- `tube_clamp_render.scad` — design/render entrypoint;
- `design/design.md` — construction explanation;
- `design/img/` — generated construction images.

The library exposes two public modules:

```scad
tube_clamp(...)
render_tube_clamp(...)
```

Internal construction helpers start with `_` and are not intended as part of
the public API.

## Parameters

| Parameter | Default | Meaning |
| --- | ---: | --- |
| `tube_diameter` | 20 mm | Nominal outside diameter of the tube. |
| `clearance` | 0.0 mm | Extra diametral space around the tube. |
| `wall_thickness` | 3 mm | Radial wall thickness of the clamp. |
| `clamp_width` | 16 mm | Clamp width along the tube axis. |
| `opening_angle` | 60° | Angular size of the open section. |
| `EPS` | 0.05 mm | Small overlap used for robust boolean subtraction. |

## Surface resolution

OpenSCAD uses a normal global render setting:

```scad
$fn = 120;
```

The resolution is intentionally not part of the `tube_clamp(...)` API. A
consumer can override `$fn` in its own OpenSCAD context when a different render
quality is desired.

The render entrypoint also sets the same resolution in its own render context:

```scad
$fn = 120;
```

This is necessary because `use <tube_clamp.scad>` exposes modules and functions,
but does not apply the library file's top-level `$fn` assignment to the render
entrypoint.

## Public geometry

The final clamp is exposed through:

```scad
module tube_clamp(
    tube_diameter,
    clearance,
    wall_thickness,
    clamp_width,
    opening_angle
) {
    difference() {
        _full_ring(
            tube_diameter,
            clearance,
            wall_thickness,
            clamp_width
        );

        _opening_cutter(
            tube_diameter,
            clearance,
            wall_thickness,
            clamp_width,
            opening_angle
        );
    }
}
```

The construction therefore consists of two simple parts:

1. make a complete cylindrical ring;
2. subtract a triangular opening cutter.

## 1. Full ring

The inner radius follows directly from the tube diameter and clearance:

```scad
function _clamp_inner_radius(
    tube_diameter,
    clearance
) =
    (tube_diameter + clearance) / 2;
```

The outer radius adds the clamp wall:

```scad
function _clamp_outer_radius(
    tube_diameter,
    clearance,
    wall_thickness
) =
    _clamp_inner_radius(
        tube_diameter,
        clearance
    ) + wall_thickness;
```

The ring itself is an outer cylinder minus an inner cylinder:

```scad
module _full_ring(
    tube_diameter,
    clearance,
    wall_thickness,
    clamp_width
) {
    inner_r = _clamp_inner_radius(
        tube_diameter,
        clearance
    );

    outer_r = _clamp_outer_radius(
        tube_diameter,
        clearance,
        wall_thickness
    );

    difference() {
        cylinder(
            h = clamp_width,
            r = outer_r,
            $fn = 120
        );

        translate([0, 0, -EPS])
            cylinder(
                h = clamp_width + 2 * EPS,
                r = inner_r
            );
    }
}
```

`EPS` lets the subtracting cylinder extend slightly beyond both faces of the
outer cylinder. This avoids coincident surfaces in the boolean operation.

![Full ring](img/01-ring.png)

## 2. Opening cutter

The opening does not need a curved sector. A simple triangle is sufficient.

Its point starts at the center of the clamp. The other two points are placed
far enough outside the outer radius that the complete ring is cut through.

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

The `tan()` relation converts half of the desired opening angle into the
half-width of the triangle at `cutter_length`.

The 2D triangle is then extruded through the full clamp width:

```scad
translate([0, 0, -EPS])
    linear_extrude(
        height = clamp_width + 2 * EPS
    )
        polygon(points = [
            [0, 0],
            [cutter_length, -cutter_half_width],
            [cutter_length,  cutter_half_width]
        ]);
```

The design view deliberately shows the ring and cutter together so the boolean
operation is visually obvious.

![Ring with opening cutter](img/02-opening.png)

## 3. Final clamp

The final geometry is simply:

```scad
difference() {
    _full_ring(...);
    _opening_cutter(...);
}
```

This is wrapped by the public `tube_clamp(...)` module, which also validates the
input values.

![Final clamp](img/03-final.png)

## Render API

The design workflow does not call private helpers directly. Instead it uses the
public `render_tube_clamp(...)` module:

```scad
render_tube_clamp(
    mode = "02-opening"
);
```

The render module exposes the supported construction views while keeping
`_full_ring(...)` and `_opening_cutter(...)` private to the library.

The separate `tube_clamp_render.scad` entrypoint only translates the externally
supplied `design_view` into that public render API:

```scad
use <tube_clamp.scad>

design_view = is_undef(design_view) ? "final" : design_view;

render_tube_clamp(
    mode = design_view
);
```

The render workflow can therefore select a view with:

```bash
openscad   -D 'design_view="02-opening"'   tube_clamp_render.scad
```
