$fn = 120;

EPS = 0.05;

TUBE_CLAMP_VIEW_FINAL = 0;
TUBE_CLAMP_VIEW_RING = 1;
TUBE_CLAMP_VIEW_OPENING = 2;

TUBE_CLAMP_VIEW_TABLE = [
    [TUBE_CLAMP_VIEW_FINAL,   "Final clamp"],
    [TUBE_CLAMP_VIEW_RING,    "Full ring"],
    [TUBE_CLAMP_VIEW_OPENING, "Opening cutter"]
];

function tube_clamp_view_label(view) =
    assert(
        TUBE_CLAMP_VIEW_TABLE[view][0] == view,
        "TUBE_CLAMP_VIEW_TABLE index/value mismatch"
    )
    TUBE_CLAMP_VIEW_TABLE[view][1];

/* [View] */
design_view = 0; // [0:Final clamp, 1:Full ring, 2:Opening cutter]

/* [Tube clamp] */
tube_diameter = 20;
clearance = 0.0;
wall_thickness = 3;
clamp_width = 16;
opening_angle = 60;

function tube_clamp_create(
    tube_diameter = 20,
    clearance = 0.0,
    wall_thickness = 3,
    clamp_width = 16,
    opening_angle = 60
) =
    object(
        tube_diameter = tube_diameter,
        clearance = clearance,
        wall_thickness = wall_thickness,
        clamp_width = clamp_width,
        opening_angle = opening_angle
    );

function tube_clamp_inner_radius(clamp) =
    (clamp.tube_diameter + clamp.clearance) / 2;

function tube_clamp_outer_radius(clamp) =
    tube_clamp_inner_radius(clamp) + clamp.wall_thickness;

module tube_clamp_build(clamp) {
    assert(clamp.tube_diameter > 0, "tube_diameter must be > 0");
    assert(clamp.clearance >= 0, "clearance must be >= 0");
    assert(clamp.wall_thickness > 0, "wall_thickness must be > 0");
    assert(clamp.clamp_width > 0, "clamp_width must be > 0");
    assert(
        clamp.opening_angle > 0 && clamp.opening_angle < 180,
        "opening_angle must be between 0 and 180 degrees"
    );

    difference() {
        _full_ring(clamp);
        _opening_cutter(clamp);
    }
}

module tube_clamp_render(clamp, view = TUBE_CLAMP_VIEW_FINAL) {
    if (view == TUBE_CLAMP_VIEW_RING) {
        _full_ring(clamp);
    } else if (view == TUBE_CLAMP_VIEW_OPENING) {
        _full_ring(clamp);
        color([1, 0, 0, 0.35])
            _opening_cutter(clamp);
    } else {
        tube_clamp_build(clamp);
    }
}

module _full_ring(clamp) {
    inner_r = tube_clamp_inner_radius(clamp);
    outer_r = tube_clamp_outer_radius(clamp);

    difference() {
        cylinder(h = clamp.clamp_width, r = outer_r);

        translate([0, 0, -EPS])
            cylinder(
                h = clamp.clamp_width + 2 * EPS,
                r = inner_r
            );
    }
}

module _opening_cutter(clamp) {
    outer_r = tube_clamp_outer_radius(clamp);
    cutter_length = outer_r + 10;
    cutter_half_width =
        cutter_length * tan(clamp.opening_angle / 2);

    translate([0, 0, -EPS])
        linear_extrude(height = clamp.clamp_width + 2 * EPS)
            polygon(points = [
                [0, 0],
                [cutter_length, -cutter_half_width],
                [cutter_length,  cutter_half_width]
            ]);
}

clamp = tube_clamp_create(
    tube_diameter = tube_diameter,
    clearance = clearance,
    wall_thickness = wall_thickness,
    clamp_width = clamp_width,
    opening_angle = opening_angle
);

tube_clamp_render(clamp, view = design_view);
