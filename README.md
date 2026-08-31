# lib.scad.clamps

Reusable clamp designs with parallel OpenSCAD and PythonSCAD implementations.

The library is organized by implementation technology first. Each concrete clamp part keeps its implementation and implementation-specific design documentation together.

## Structure

```text
lib.scad.clamps/
├── openscad/
│   └── tube-clamp/
│       ├── tube-clamp.scad
│       └── design/
│           ├── design.md
│           └── img/
├── pythonscad/
│   └── tube-clamp/
│       ├── tube-clamp.py
│       └── design/
│           ├── design.md
│           └── img/
├── scripts/
└── .github/workflows/
```

## Initial part

- `tube-clamp` — first reference part, implemented independently in OpenSCAD and PythonSCAD.

## Design principle

The OpenSCAD and PythonSCAD versions should implement the same intended part, while their implementation-specific design documents may describe different construction approaches and development views.
