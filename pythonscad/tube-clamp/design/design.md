# Tube clamp — PythonSCAD design

<!-- scad-render-defaults
engine: pythonscad
source: tube_clamp_render.py
vpr: [65, 0, 35]
-->

## Scope

This is the retained PythonSCAD comparison implementation of the same reusable
base clip.

The flat back is deliberately compact. Its width is exactly
`transition_width`; it is not an extended mounting plate.

The fit model now distinguishes the nominal/visual functional bore from an
optional smaller printed tension bore:

```python
tube_diameter: float = 10
clearance: float = 0.0
tension_diameter: float | None = 9.6
extra: float = 0.01
```

`extra` is Boolean tolerance only. It replaces the old strategy of moving the
complete circular body into the base and therefore does not shift the nominal
circle datum.

```python
base_thickness: float = 4
transition_width: float = 30
transition_depth: float = 8
```

The Boolean construction order matches the OpenSCAD implementation:

```text
complete outside shape
        ↓
tube bore
        ↓
snap opening
        ↓
final clip
```

## 1. Solid circular outside

The design starts with a solid outside cylinder. The tube cavity is not cut yet.

<!-- scad-render
view: Outer ring
-->

## 2. Compact base

The new base is transparent red. Its width comes directly from
`transition_width`.

```python
def _flat_base(self):
    return cube([
        self.base_thickness + self.extra,
        self.transition_width,
        self.clamp_width,
    ])
```

<!-- scad-render
view: Compact base
-->

## 3. Sloped transition

The transition joins the flat back to the circular outside. At the end of this
step the model is one complete solid outside shape.

```python
def _outer_shape(self):
    return (
        self._outer_ring_solid()
        | self._flat_base()
        | self._base_transition()
    )
```

<!-- scad-render
view: Base transition
-->

## 4. Tube bore

The tube cavity is removed once from the completed outside.

```python
self._outer_shape() - self._inner_bore_cutter(use_tension_bore)
```

<!-- scad-render
view: Tube bore
-->

## 5. Snap opening

The triangular snap-opening cutter is applied after the tube cavity.

<!-- scad-render
view: Snap opening
-->

## 6. Final base clip

```python
def build(self, use_tension_bore=True):
    return (
        self._outer_shape()
        - self._inner_bore_cutter(use_tension_bore)
        - self._opening_cutter()
    )
```

<!-- scad-render
view: Final clamp
-->

## 7. Profile view

This view removes perspective and is intended for judging the base and
transition geometry. The OpenSCAD implementation additionally exposes a
`high_resolution` build/render switch for interactive performance; PythonSCAD
remains the retained comparison implementation at its existing render
resolution.

<!-- scad-render
view: Profile view
vpr: [0, 0, 0]
-->

## Possible later variants

The base clip remains mounting-neutral. A later variant may add one screw
below the tube or extend the base into a two-hole mounting plate.

No mounting variants are implemented in this step.

OpenSCAD remains the primary implementation direction for future reusable
libraries; this PythonSCAD version remains only as the existing comparison
implementation.
