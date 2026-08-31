// lib.scad.clamps - tube-clamp
// OpenSCAD implementation

/* [Tube clamp] */
tube_diameter = 20;
wall_thickness = 3;
clamp_width = 16;
opening_angle = 60;

module tube_clamp(
    tube_diameter = tube_diameter,
    wall_thickness = wall_thickness,
    clamp_width = clamp_width,
    opening_angle = opening_angle
) {
    // Initial placeholder geometry. The design will be developed from design/design.md.
    difference() {
        cylinder(h = clamp_width, d = tube_diameter + 2 * wall_thickness, $fn = 96);
        translate([0, 0, -0.1])
            cylinder(h = clamp_width + 0.2, d = tube_diameter, $fn = 96);
    }
}

tube_clamp();
