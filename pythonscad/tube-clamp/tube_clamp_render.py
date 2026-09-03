from pythonscad import *

from tube_clamp import TubeClamp

fn = 120

design_view = TubeClamp.View(
    globals().get(
        "design_view",
        TubeClamp.View.FINAL,
    )
)

clamp = TubeClamp()

show(
    clamp.render(
        view=design_view,
    )
)
