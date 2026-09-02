# Tube clamp — OpenSCAD design

## API

The library exposes:

```scad
tube_clamp(...);
render_tube_clamp(mode = "final", ...);
```

Private construction modules/functions start with `_`.

The design renderer calls only the public render API:

```scad
use <../tube-clamp.scad>

render_tube_clamp(
    mode = design_view
);
```

## 1. Ring

`render_tube_clamp(mode = "01-ring")`

![Full ring](img/01-ring.png)

## 2. Opening

`render_tube_clamp(mode = "02-opening")`

![Ring with opening cutter](img/02-opening.png)

## 3. Final clamp

`render_tube_clamp(mode = "final")`

![Final clamp](img/03-final.png)
