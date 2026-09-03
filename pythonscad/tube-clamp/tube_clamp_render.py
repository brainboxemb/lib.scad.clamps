from pythonscad import *

from tube_clamp import TubeClamp, VIEW_FINAL

fn = 120

design_view = globals().get("design_view", VIEW_FINAL)

clamp = TubeClamp()

show(
    clamp.render(
        view=design_view,
    )
)
