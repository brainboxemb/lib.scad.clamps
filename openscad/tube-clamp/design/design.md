# Tube clamp — OpenSCAD design

## Purpose

Reusable open tube clamp built from a cylindrical ring with an angular opening.

## Shared conventions

Both implementations use the same parameter names, helper names and small
constants where the languages allow it. For example, both use:

```text
tube_diameter
clearance
wall_thickness
clamp_width
opening_angle
EPS
clamp_inner_radius
clamp_outer_radius
full_ring
opening_cutter
tube_clamp
```

The language syntax itself is not forced to match: OpenSCAD geometry is built
with modules, while PythonSCAD geometry is returned from Python functions.

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

The opening does not need a curved sector model. A triangular wedge is enough:
its two long edges define the opening angle and its outer points extend beyond
the clamp radius.

```scad
half_angle = opening_angle / 2;

polygon(points = [
    [0, 0],
    [cutter_r * cos(-half_angle), cutter_r * sin(-half_angle)],
    [cutter_r * cos( half_angle), cutter_r * sin( half_angle)]
]);
```

That triangle is extruded through the clamp width and used as the cutter.

The design view shows the ring together with the opening cutter so the subtraction is visible directly.

![Ring with opening cutter](img/02-opening.png)

## 3. Final clamp

The final clamp is the ring minus the opening wedge.

```scad
difference() {
    full_ring();
    opening_cutter();
}
```

![Final clamp](img/03-final.png)

## Design views

The documentation images come from the same `tube-clamp.scad` file.

The render script selects the required view with `design_view`:

```bash
openscad -D 'design_view="02-opening"' ...
```

Available views are `01-ring`, `02-opening` and `final`.
