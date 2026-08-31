# Tube clamp — PythonSCAD design

## Purpose

This is the PythonSCAD implementation of the same reusable open tube-clamp design as the OpenSCAD implementation.

The geometry and public parameters are intentionally kept equivalent so that the two implementation approaches can be compared without changing the intended part.

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

1. create the outer cylinder;
2. subtract the inner cylinder to obtain the full ring;
3. generate the opening sector points in Python;
4. extrude that sector into a cutter;
5. subtract the cutter from the ring.

This mirrors the geometric construction of the OpenSCAD implementation while allowing the implementation style itself to be compared.

## Images

Generated PythonSCAD design images belong in `design/img/`.

The first repository version does not yet automate PythonSCAD PNG generation. That is intentionally separated from the OpenSCAD rendering workflow until the PythonSCAD command-line installation and invocation used in CI has been fixed and verified.

## Verification target

The OpenSCAD and PythonSCAD implementations should ultimately be checked for equivalent:

- nominal bounding box;
- inner tube diameter;
- outer diameter;
- clamp width;
- opening angle;
- exported mesh volume within a defined tolerance.
