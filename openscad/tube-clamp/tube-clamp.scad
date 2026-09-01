// lib.scad.clamps - tube-clamp
// OpenSCAD implementation

/* [Tube clamp] */
tube_diameter = 20;      // [4:0.5:100]
wall_thickness = 3;      // [1:0.25:10]
clamp_width = 16;        // [2:1:60]
opening_angle = 60;      // [10:1:140]
clearance = 0.0;         // [0:0.05:2]

/* [Design view] */
design_view = "final";  // [final,01-ring,02-opening]

/* [Quality] */
$fn = 120;

EPS = 0.05;

function clamp_inner_radius() = (tube_diameter + clearance) / 2;
function clamp_outer_radius() = clamp_inner_radius() + wall_thickness;

module full_ring(
    tube_diameter = tube_diameter,
    wall_thickness = wall_thickness,
    clamp_width = clamp_width,
    clearance = clearance
) {
    inner_r = clamp_inner_radius(tube_diameter, clearance);
    outer_r = clamp_outer_radius(tube_diameter, clearance, wall_thickness);

    difference() {
        cylinder(h = clamp_width, r = outer_r);
        translate([0, 0, -EPS])
            cylinder(h = clamp_width + 2 * EPS, r = inner_r);
    }
}

module opening_cutter(
    tube_diameter = tube_diameter,
    wall_thickness = wall_thickness,
    clamp_width = clamp_width,
    opening_angle = opening_angle,
    clearance = clearance
) {
    outer_r = clamp_outer_radius(tube_diameter, clearance, wall_thickness);
    cutter_r = outer_r + 2 * wall_thickness + 1;
    half_angle = opening_angle / 2;

    translate([0, 0, -EPS])
        linear_extrude(height = clamp_width + 2 * EPS)
            polygon(points = [
                [0, 0],
                [cutter_r * cos(-half_angle), cutter_r * sin(-half_angle)],
                [cutter_r * cos( half_angle), cutter_r * sin( half_angle)]
            ]);
}

module tube_clamp(
    tube_diameter = tube_diameter,
    wall_thickness = wall_thickness,
    clamp_width = clamp_width,
    opening_angle = opening_angle,
    clearance = clearance
) {
    assert(tube_diameter > 0, "tube_diameter must be > 0");
    assert(wall_thickness > 0, "wall_thickness must be > 0");
    assert(clamp_width > 0, "clamp_width must be > 0");
    assert(opening_angle > 0 && opening_angle < 180,
        "opening_angle must be between 0 and 180 degrees");
    assert(clearance >= 0, "clearance must be >= 0");

    difference() {
        full_ring(tube_diameter, wall_thickness, clamp_width, clearance);
        opening_cutter(
            tube_diameter,
            wall_thickness,
            clamp_width,
            opening_angle,
            clearance
        );
    }
}

module render_design_view() {
    if (design_view == "01-ring") {
    full_ring();
} else if (design_view == "02-opening") {
    color("lightgray")
        full_ring();

    color([1, 0.25, 0.15, 0.55])
        opening_cutter();
} else {
    tube_clamp();
}
