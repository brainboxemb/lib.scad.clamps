import sys
from pathlib import Path

from pythonscad import *

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from tube_clamp import render_tube_clamp

design_view = globals().get("design_view", "final")

show(
    render_tube_clamp(
        mode=design_view,
    )
)
