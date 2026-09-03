from pythonscad import *

from tube_clamp import tube_clamp_create, tube_clamp_render

fn = 120

design_view = globals().get("design_view", "final")

clamp = tube_clamp_create()

show(
    tube_clamp_render(
        clamp,
        mode=design_view,
    )
)
