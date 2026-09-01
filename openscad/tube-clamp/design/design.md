# Tube clamp — OpenSCAD design

## Purpose

This is the OpenSCAD implementation of the reusable open tube-clamp design.

The part starts as a cylindrical ring around the target tube and removes an
angular sector to create the snap opening. The implementation is intentionally
small so the geometry can be compared directly with the PythonSCAD version.

## Functional parameters

| Parameter | Default | Meaning |
| --- | ---: | --- |
| `tube_diameter` | 20 mm | Nominal outside diameter of the tube. |
| `clearance` | 0.0 mm | Diametral extra space around the tube. |
| `wall_thickness` | 3 mm | Radial thickness of the clamp body. |
| `clamp_width` | 16 mm | Width along the tube axis. |
| `opening_angle` | 60° | Angular sector removed from the ring. |

## Geometry construction

The implementation is built from three essential operations:

```text
full ring
   ↓
opening cutter
   ↓
ring - cutter
   ↓
final tube clamp
```

The code excerpts below intentionally show only the essential construction.
The complete implementation remains in [`tube-clamp.scad`](../tube-clamp.scad).

## 1. Full ring

The clamp body starts as the difference between an outer cylinder and an inner
cylinder.

The inner radius is derived from the tube diameter and clearance. The outer
radius adds the required wall thickness.

```scad
module full_ring() {
    difference() {
        cylinder(h = clamp_width, r = outer_radius);

        translate([0, 0, -0.05])
            cylinder(
                h = clamp_width + 0.1,
                r = inner_radius
            );
    }
}
```

The slight Z extension on the inner cylinder prevents coincident faces during
the subtraction.

![Full ring](img/01-ring.png)

## 2. Opening cutter

A sector-shaped solid is used to remove the opening from the ring.

Conceptually:

```scad
module opening_cutter() {
    linear_extrude(height = clamp_width + 0.1)
        polygon(opening_sector_points(...));
}
```

The sector angle is controlled by `opening_angle`. Keeping the opening as a
separate cutter makes the intent explicit and allows this construction step to
be rendered independently for the design documentation.

![Opening cutter](img/02-opening.png)

## 3. Final clamp

The final clamp is simply the ring minus the opening cutter:

```scad
module tube_clamp() {
    difference() {
        full_ring();
        opening_cutter();
    }
}
```

This is the core design relationship. Future mounting features should be added
around this reusable clamp body rather than changing the meaning of the basic
ring/opening construction.

![Final clamp](img/03-final.png)

## Design views

The same OpenSCAD source file is also used to generate the documentation
images.

The render workflow passes a `design_view` value through `-D`, for example:

```bash
openscad   -D 'design_view="01-ring"'   -o design/img/01-ring.png   tube-clamp.scad
```

Supported documentation views are:

```text
01-ring
02-opening
final
```

This avoids maintaining separate `.scad` files purely for documentation.

## Keeping design and code in sync

`design.md` is part of the design, not an after-the-fact description.

For every meaningful geometry change:

1. update `tube-clamp.scad`;
2. update the relevant construction explanation and code excerpt in this file;
3. regenerate the design images;
4. review source, documentation and image changes together.

The GitHub design workflow regenerates the PNG files automatically and commits
them only when their contents changed. The Markdown design explanation remains
an intentional source change and should be updated together with the code.

## Verification target

The OpenSCAD and PythonSCAD implementations should ultimately be verified for
equivalent:

- nominal bounding box;
- inner tube diameter;
- outer diameter;
- clamp width;
- opening angle;
- exported mesh volume within a defined tolerance.
