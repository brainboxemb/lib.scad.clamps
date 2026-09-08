"""Design-render entrypoint for the PythonSCAD tube clamp.

tool.scad-project injects ``design_view`` through PythonSCAD ``-D`` arguments.
The entrypoint converts that value to the library's native ``TubeClamp.View``
enum and then calls the public render API.
"""

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
