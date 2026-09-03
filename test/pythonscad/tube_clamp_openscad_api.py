from pathlib import Path

from pythonscad import *

fn = 120

LIBRARY = Path.cwd() / "openscad" / "tube-clamp" / "tube_clamp.scad"
tube_clamp = osuse(str(LIBRARY))

small = tube_clamp.tube_clamp_create(
    tube_diameter=12,
    clearance=0.2,
    wall_thickness=2,
    clamp_width=12,
    opening_angle=55,
)

medium = tube_clamp.tube_clamp_create()

large = tube_clamp.tube_clamp_create(
    tube_diameter=32,
    clearance=0.4,
    wall_thickness=4,
    clamp_width=22,
    opening_angle=70,
)

assert abs(tube_clamp.tube_clamp_inner_radius(small) - 6.1) < 0.001
assert abs(tube_clamp.tube_clamp_outer_radius(medium) - 13) < 0.001
assert abs(tube_clamp.tube_clamp_outer_radius(large) - 20.2) < 0.001

show([
    tube_clamp.tube_clamp_build(small).translate([-32, 0, 0]),
    tube_clamp.tube_clamp_build(medium),
    tube_clamp.tube_clamp_build(large).translate([42, 0, 0]),
])
