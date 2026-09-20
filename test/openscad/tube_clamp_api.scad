$fn = 120;

use <../../openscad/tube-clamp/tube_clamp.scad>

small = tube_clamp_create(
    tube_diameter = 12,
    clearance = 0.2,
    wall_thickness = 2,
    clamp_width = 12,
    opening_angle = 55,
    base_thickness = 3,
    transition_width = 18,
    transition_depth = 5
);

medium = tube_clamp_create();

tension =
    tube_clamp_create(
        tube_diameter = 10,
        tension_diameter = 9.6,
        wall_thickness = 2,
        clamp_width = 16,
        opening_angle = 60,
        base_thickness = 2,
        transition_width = 12,
        transition_depth = 3,
        extra = 0.01
    );

large = tube_clamp_create(
    tube_diameter = 32,
    clearance = 0.4,
    wall_thickness = 4,
    clamp_width = 22,
    opening_angle = 70,
    base_thickness = 5,
    transition_width = 40,
    transition_depth = 10
);

translate([-32, 0, 0])
    tube_clamp_build(small);

tube_clamp_build(medium);

translate([24, 28, 0])
    tube_clamp_build(
        tension,
        use_tension_bore = false,
        high_resolution = false
    );

translate([44, 28, 0])
    tube_clamp_build(
        tension,
        use_tension_bore = true,
        high_resolution = false
    );

translate([42, 0, 0])
    tube_clamp_build(large);

// Functional checks on public derived values.
assert(abs(tube_clamp_inner_radius(small) - 6.1) < 0.001);
assert(abs(tube_clamp_outer_radius(medium) - 13) < 0.001);
assert(abs(tube_clamp_outer_radius(large) - 20.2) < 0.001);

assert(abs(tube_clamp_functional_diameter(tension) - 10) < 0.001);
assert(abs(tube_clamp_tension_diameter(tension) - 9.6) < 0.001);
assert(abs(tube_clamp_bore_diameter(tension, false) - 10) < 0.001);
assert(abs(tube_clamp_bore_diameter(tension, true) - 9.6) < 0.001);
assert(abs(tube_clamp_outer_radius(tension) - 7) < 0.001);
assert(abs(tension.extra - 0.01) < 0.0001);
