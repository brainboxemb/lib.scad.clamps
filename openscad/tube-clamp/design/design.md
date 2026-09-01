# Tube clamp — OpenSCAD design

## Purpose

Reusable open tube clamp built from a cylindrical ring with a triangular cutter.

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

![Full ring](img/01-ring.png)

## 2. Opening

The cutter starts as a simple triangle with its point at the center of the ring.

```scad
cutter_length = outer_r + 10;
cutter_half_width = cutter_length * tan(opening_angle / 2);

polygon(points = [
    [0, 0],
    [cutter_length, -cutter_half_width],
    [cutter_length,  cutter_half_width]
]);
```

The triangle is extruded through the clamp width. The design view shows the
ring and cutter together.

![Ring with opening cutter](img/02-opening.png)

## 3. Final clamp

The final clamp subtracts the triangular cutter from the ring.

```scad
difference() {
    full_ring(...);
    opening_cutter(...);
}
```

![Final clamp](img/03-final.png)
