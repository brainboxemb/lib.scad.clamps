import sys
from pathlib import Path

from pythonscad import *

LIB_DIR = Path.cwd() / "pythonscad" / "tube-clamp"
sys.path.insert(0, str(LIB_DIR))

from tube_clamp import TubeClamp

fn = 120

small = TubeClamp(
    tube_diameter=12,
    clearance=0.2,
    wall_thickness=2,
    clamp_width=12,
    opening_angle=55,
    foot_length=28,
    foot_thickness=3,
    foot_transition_width=22,
    foot_transition_height=5,
)

medium = TubeClamp()

large = TubeClamp(
    tube_diameter=32,
    clearance=0.4,
    wall_thickness=4,
    clamp_width=22,
    opening_angle=70,
    foot_length=54,
    foot_thickness=5,
    foot_transition_width=42,
    foot_transition_height=10,
)

assert abs(small.inner_radius - 6.1) < 0.001
assert abs(medium.outer_radius - 13) < 0.001
assert abs(large.outer_radius - 20.2) < 0.001

show([
    small.build().translate([-32, 0, 0]),
    medium.build(),
    large.build().translate([42, 0, 0]),
])
