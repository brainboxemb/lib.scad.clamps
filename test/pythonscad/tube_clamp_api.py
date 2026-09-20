import sys
from pathlib import Path

from pythonscad import *

# Verification runs from the repository root.
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
    base_thickness=3,
    transition_width=18,
    transition_depth=5,
)

medium = TubeClamp()

tension = TubeClamp(
    tube_diameter=10,
    tension_diameter=9.6,
    wall_thickness=2,
    clamp_width=16,
    opening_angle=60,
    base_thickness=2,
    transition_width=12,
    transition_depth=3,
    extra=0.01,
)

large = TubeClamp(
    tube_diameter=32,
    clearance=0.4,
    wall_thickness=4,
    clamp_width=22,
    opening_angle=70,
    base_thickness=5,
    transition_width=40,
    transition_depth=10,
)

assert abs(small.inner_radius - 6.1) < 0.001
assert abs(medium.outer_radius - 13) < 0.001
assert abs(large.outer_radius - 20.2) < 0.001

assert abs(tension.functional_diameter - 10) < 0.001
assert abs(tension.resolved_tension_diameter - 9.6) < 0.001
assert abs(tension.bore_diameter(False) - 10) < 0.001
assert abs(tension.bore_diameter(True) - 9.6) < 0.001
assert abs(tension.outer_radius - 7) < 0.001
assert abs(tension.extra - 0.01) < 0.0001

show([
    small.build().translate([-32, 0, 0]),
    medium.build(),
    tension.build(
        use_tension_bore=False
    ).translate([24, 28, 0]),
    tension.build(
        use_tension_bore=True
    ).translate([44, 28, 0]),
    large.build().translate([42, 0, 0]),
])
