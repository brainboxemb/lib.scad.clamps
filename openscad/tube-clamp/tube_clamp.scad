$fn = 120;
EPS = 0.05;

/* [View] */
design_view = "final"; // [final,01-ring,02-opening]

/* [Clamp] */
tube_diameter = 20;
clearance = 0.0;
wall_thickness = 3;
clamp_width = 16;
opening_angle = 60;
// -----------------------------------------------------------------------------
// Public API
// -----------------------------------------------------------------------------

module tube_clamp(
    tube_diameter,
    clearance,
    wall_thickness,
    clamp_width,
    opening_angle
) {
    assert(tube_diameter > 0, "tube_diameter must be > 0");
    assert(clearance >= 0, "clearance must be >= 0");
    assert(wall_thickness > 0, "wall_thickness must be > 0");
    assert(clamp_width > 0, "clamp_width must be > 0");
    assert(
        opening_angle > 0 && opening_angle < 180,
        "opening_angle must be between 0 and 180 degrees"
    );

    difference() {
        _full_ring(
            tube_diameter,
            clearance,
            wall_thickness,
            clamp_width
        );

        _opening_cutter(
            tube_diameter,
            clearance,
            wall_thickness,
            clamp_width,
            opening_angle
        );
    }
}


module render_tube_clamp(
    mode = "final",
    tube_diameter = 20,
    clearance = 0.0,
    wall_thickness = 3,
    clamp_width = 16,
    opening_angle = 60
) {
    if (mode == "01-ring") {
        _full_ring(
            tube_diameter,
            clearance,
            wall_thickness,
            clamp_width
        );
    } else if (mode == "02-opening") {
        color("lightgray")
            _full_ring(
                tube_diameter,
                clearance,
                wall_thickness,
                clamp_width
            );

        color([1, 0.25, 0.15, 0.55])
            _opening_cutter(
                tube_diameter,
                clearance,
                wall_thickness,
                clamp_width,
                opening_angle
            );
    } else {
        tube_clamp(
            tube_diameter,
            clearance,
            wall_thickness,
            clamp_width,
            opening_angle
        );
    }
}


// -----------------------------------------------------------------------------
// Private implementation
// -----------------------------------------------------------------------------

function _clamp_inner_radius(
    tube_diameter,
    clearance
) =
    (tube_diameter + clearance) / 2;


function _clamp_outer_radius(
    tube_diameter,
    clearance,
    wall_thickness
) =
    _clamp_inner_radius(
        tube_diameter,
        clearance
    ) + wall_thickness;


module _full_ring(
    tube_diameter,
    clearance,
    wall_thickness,
    clamp_width
) {
    inner_r = _clamp_inner_radius(
        tube_diameter,
        clearance
    );

    outer_r = _clamp_outer_radius(
        tube_diameter,
        clearance,
        wall_thickness
    );

    difference() {
        cylinder(
            h = clamp_width,
            r = outer_r
        );

        translate([0, 0, -EPS])
            cylinder(
                h = clamp_width + 2 * EPS,
                r = inner_r
            );
    }
}


module _opening_cutter(
    tube_diameter,
    clearance,
    wall_thickness,
    clamp_width,
    opening_angle
) {
    outer_r = _clamp_outer_radius(
        tube_diameter,
        clearance,
        wall_thickness
    );

    cutter_length = outer_r + 10;
    cutter_half_width =
        cutter_length * tan(opening_angle / 2);

    translate([0, 0, -EPS])
        linear_extrude(
            height = clamp_width + 2 * EPS
        )
            polygon(points = [
                [0, 0],
                [cutter_length, -cutter_half_width],
                [cutter_length,  cutter_half_width]
            ]);
}


// -----------------------------------------------------------------------------
// Direct-open preview
// -----------------------------------------------------------------------------

render_tube_clamp(
    mode = design_view,
    tube_diameter = tube_diameter,
    clearance = clearance,
    wall_thickness = wall_thickness,
    clamp_width = clamp_width,
    opening_angle = opening_angle
);
