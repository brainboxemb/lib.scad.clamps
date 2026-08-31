# lib.scad.clamps

Reusable parametric clamp designs with parallel OpenSCAD and PythonSCAD implementations.

The repository is organized by implementation technology first. Each concrete clamp keeps its implementation-specific source, design documentation and generated design images together.

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
├── shared/
├── scripts/
└── .github/workflows/
```

## Tube clamp

The first reference part is a simple open snap-fit tube clamp. The initial design is deliberately limited to the reusable clamp body; mounting feet and project-specific attachment features are left out.

Both implementations expose equivalent core parameters:

- tube diameter;
- clearance;
- wall thickness;
- clamp width;
- opening angle.

## Design documentation

Design documentation is kept next to each implementation. For OpenSCAD, documentation views are generated from the same `.scad` source by passing a `design_view` value with the command-line `-D` option.

Run locally with:

```bash
./scripts/render-openscad-design.sh
```

The GitHub workflow `DSG - OpenSCAD design images` performs the same render and uploads the generated images as an artifact.

## Implementation comparison

The purpose of maintaining both implementations is not to generate one language from the other. They implement the same intended geometry independently so that OpenSCAD and PythonSCAD can be compared for readability, parametrization, development workflow and automated verification.
