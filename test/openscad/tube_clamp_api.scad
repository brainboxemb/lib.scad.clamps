$fn = 120;

use <../../openscad/tube-clamp/tube_clamp.scad>

small = tube_clamp_create(
    tube_diameter = 12,
    clearance = 0.2,
    wall_thickness = 2,
    clamp_width = 12,
    opening_angle = 55
);

medium = tube_clamp_create();

large = tube_clamp_create(
    tube_diameter = 32,
    clearance = 0.4,
    wall_thickness = 4,
    clamp_width = 22,
    opening_angle = 70
);

translate([-32, 0, 0])
    tube_clamp_build(small);

tube_clamp_build(medium);

translate([42, 0, 0])
    tube_clamp_build(large);

// Functional checks on calculated values.
assert(abs(tube_clamp_inner_radius(small) - 6.1) < 0.001);
assert(abs(tube_clamp_outer_radius(medium) - 13) < 0.001);
assert(abs(tube_clamp_outer_radius(large) - 20.2) < 0.001);
