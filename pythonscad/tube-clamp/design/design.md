# Tube clamp — PythonSCAD design

## Purpose

This is the PythonSCAD implementation of the same reusable open tube-clamp
design as the OpenSCAD implementation.

The geometry and public parameters are intentionally kept equivalent so that
the two implementation approaches can be compared without changing the
intended part.

## Functional parameters

| Parameter | Default | Meaning |
| --- | ---: | --- |
| `TUBE_DIAMETER` | 20 mm | Nominal outside diameter of the tube. |
| `CLEARANCE` | 0.0 mm | Diametral extra space around the tube. |
| `WALL_THICKNESS` | 3 mm | Radial thickness of the clamp body. |
| `CLAMP_WIDTH` | 16 mm | Width along the tube axis. |
| `OPENING_ANGLE` | 60° | Angular sector removed from the ring. |

## Construction approach

PythonSCAD treats the solids as Python objects:

1. create the outer and inner cylinder;
2. subtract them to obtain the full ring;
3. generate the opening-sector points in Python;
4. extrude that sector into a cutter;
5. subtract the cutter from the ring.

### 1. Full ring

![Full ring](img/01-ring.png)

### 2. Opening cutter

![Opening cutter](img/02-opening.png)

### 3. Final clamp

![Final clamp](img/03-final.png)

The images above are generated from `tube-clamp.py` by the design workflow.
`DESIGN_VIEW` selects the geometry shown during a documentation render.

## Generated design files

Files under `design/img/` are generated files, but they intentionally remain in
the normal Git repository because they are part of the design documentation.

The GitHub workflow regenerates them using the pinned SCAD toolchain container
and commits them only when their contents changed.

## Verification target

The OpenSCAD and PythonSCAD implementations should ultimately be checked for
equivalent:

- nominal bounding box;
- inner tube diameter;
- outer diameter;
- clamp width;
- opening angle;
- exported mesh volume within a defined tolerance.
