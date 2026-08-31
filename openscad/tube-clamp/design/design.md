# Tube clamp — OpenSCAD design

## Purpose

This implementation is the OpenSCAD reference implementation of a simple, printable open tube clamp.

The first design deliberately focuses on the clamp body only. Mounting feet, screw lugs and project-specific attachment geometry are excluded so that the core clamp geometry can be reused by later clamp types.

## Functional design

The clamp is an extruded annular body with a sector removed to create a snap opening.

The design is controlled by five parameters:

| Parameter | Default | Meaning |
| --- | ---: | --- |
| `tube_diameter` | 20 mm | Nominal outside diameter of the tube. |
| `clearance` | 0.0 mm | Diametral extra space around the tube. |
| `wall_thickness` | 3 mm | Radial thickness of the clamp body. |
| `clamp_width` | 16 mm | Width of the clamp along the tube axis. |
| `opening_angle` | 60° | Angular sector removed from the ring. |

The initial geometry intentionally does **not** define material-specific snap behaviour. Clearance and opening angle are exposed because they will need physical verification for different materials, printers and tube surfaces.

## Construction

### 1. Full ring

The base is a cylindrical ring using the nominal tube diameter plus optional clearance for the inner diameter.

![Full ring](img/01-ring.png)

### 2. Opening sector

A radial sector is used as the cutting volume. Keeping this as a separate construction primitive makes the design intent visible and makes the opening angle directly controllable.

![Opening sector](img/02-opening.png)

### 3. Final clamp

The sector is subtracted from the full ring to create the open snap clamp.

![Final clamp](img/03-final.png)

## Design views

The same `tube-clamp.scad` file is used for both the production geometry and design documentation. The variable `design_view` selects the requested view and can be overridden from the OpenSCAD command line with `-D`.

Supported values:

- `final`
- `01-ring`
- `02-opening`

This avoids separate `.scad` files for documentation renders.

## Current design boundaries

This first part intentionally excludes:

- mounting holes;
- mounting feet;
- screw-tightened split geometry;
- ribs or local reinforcement;
- chamfers and lead-in features;
- empirical compensation for print material or process.

Those features should be added only when they are part of the reusable clamp design, or implemented as a separate clamp type when they change the functional concept.
