from pythonscad import *

from tube_clamp import render_tube_clamp

design_view = globals().get("design_view", "final")

show(
    render_tube_clamp(
        mode=design_view,
    )
)
