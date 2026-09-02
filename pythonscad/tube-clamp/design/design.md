# Tube clamp — PythonSCAD design

## API

The library exposes:

```python
tube_clamp(...)
render_tube_clamp(mode="final", ...)
```

Private construction functions start with `_`.

The design renderer imports only the public render API:

```python
from tube_clamp import render_tube_clamp

show(
    render_tube_clamp(
        mode=design_view,
    )
)
```

## 1. Ring

`render_tube_clamp(mode="01-ring")`

![Full ring](img/01-ring.png)

## 2. Opening

`render_tube_clamp(mode="02-opening")`

![Ring with opening cutter](img/02-opening.png)

## 3. Final clamp

`render_tube_clamp(mode="final")`

![Final clamp](img/03-final.png)


## Standalone preview

Opening the library file itself in PythonSCAD renders the default public view:

```python
show(render_tube_clamp())
```

The separate `design/tube_clamp_render.py` entrypoint is still used by the documentation
workflow for selecting specific design views.
