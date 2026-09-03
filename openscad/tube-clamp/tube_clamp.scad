$fn = 120;

EPS = 0.05;
FOOT_OVERLAP = 1.0;

TUBE_CLAMP_VIEW_FINAL = 0;
TUBE_CLAMP_VIEW_RING = 1;
TUBE_CLAMP_VIEW_OPENING = 2;
TUBE_CLAMP_VIEW_CLIP_BODY = 3;
TUBE_CLAMP_VIEW_FOOT = 4;
TUBE_CLAMP_VIEW_TRANSITION = 5;
TUBE_CLAMP_VIEW_SIDE = 6;

TUBE_CLAMP_VIEW_TABLE = [
    [TUBE_CLAMP_VIEW_FINAL,      "Final clamp"],
    [TUBE_CLAMP_VIEW_RING,       "Full ring"],
    [TUBE_CLAMP_VIEW_OPENING,    "Opening cutter"],
    [TUBE_CLAMP_VIEW_CLIP_BODY,  "Clip body"],
    [TUBE_CLAMP_VIEW_FOOT,       "Mounting foot"],
    [TUBE_CLAMP_VIEW_TRANSITION, "Foot transition"],
    [TUBE_CLAMP_VIEW_SIDE,       "Side view"]
];

function tube_clamp_view_label(view) =
    assert(
        TUBE_CLAMP_VIEW_TABLE[view][0] == view,
        "TUBE_CLAMP_VIEW_TABLE index/value mismatch"
    )
    TUBE_CLAMP_VIEW_TABLE[view][1];

/* [View] */
design_view = 0; // [0:Final clamp, 1:Full ring, 2:Opening cutter, 3:Clip body, 4:Mounting foot, 5:Foot transition, 6:Side view]

/* [Tube clamp] */
tube_diameter = 20;
clearance = 0.0;
wall_thickness = 3;
clamp_width = 16;
opening_angle = 60;

/* [Mounting foot] */
foot_length = 40;
foot_thickness = 4;
foot_transition_width = 30;
foot_transition_height = 8;

function tube_clamp_create(
    tube_diameter = 20,
    clearance = 0.0,
    wall_thickness = 3,
    clamp_width = 16,
    opening_angle = 60,
    foot_length = 40,
    foot_thickness = 4,
    foot_transition_width = 30,
    foot_transition_height = 8
) =
    object(
        tube_diameter = tube_diameter,
        clearance = clearance,
        wall_thickness = wall_thickness,
        clamp_width = clamp_width,
        opening_angle = opening_angle,
        foot_length = foot_length,
        foot_thickness = foot_thickness,
        foot_transition_width = foot_transition_width,
        foot_transition_height = foot_transition_height
    );

function tube_clamp_inner_radius(clamp) =
    (clamp.tube_diameter + clamp.clearance) / 2;

function tube_clamp_outer_radius(clamp) =
    tube_clamp_inner_radius(clamp) + clamp.wall_thickness;

function _tube_clamp_center_x(clamp) =
    clamp.foot_thickness
    + tube_clamp_outer_radius(clamp)
    - FOOT_OVERLAP;

module tube_clamp_build(clamp) {
    outer_r = tube_clamp_outer_radius(clamp);

    assert(clamp.tube_diameter > 0, "tube_diameter must be > 0");
    assert(clamp.clearance >= 0, "clearance must be >= 0");
    assert(clamp.wall_thickness > 0, "wall_thickness must be > 0");
    assert(clamp.clamp_width > 0, "clamp_width must be > 0");
    assert(
        clamp.opening_angle > 0 && clamp.opening_angle < 180,
        "opening_angle must be between 0 and 180 degrees"
    );
    assert(clamp.foot_length > 0, "foot_length must be > 0");
    assert(clamp.foot_thickness > 0, "foot_thickness must be > 0");
    assert(
        clamp.foot_transition_width > 0
        && clamp.foot_transition_width <= clamp.foot_length,
        "foot_transition_width must be > 0 and <= foot_length"
    );
    assert(
        clamp.foot_transition_height > 0,
        "foot_transition_height must be > 0"
    );
    assert(
        outer_r > FOOT_OVERLAP,
        "outer radius must be larger than FOOT_OVERLAP"
    );

    difference() {
        union() {
            _outer_ring_solid(clamp);
            _mounting_foot(clamp);
        }

        _inner_bore_cutter(clamp);
        _opening_cutter(clamp);
    }
}

module tube_clamp_render(clamp, view = TUBE_CLAMP_VIEW_FINAL) {
    if (view == TUBE_CLAMP_VIEW_RING) {
        _full_ring(clamp);
    } else if (view == TUBE_CLAMP_VIEW_OPENING) {
        color("lightgray")
            _full_ring(clamp);

        color([1, 0, 0, 0.35])
            _opening_cutter(clamp);
    } else if (view == TUBE_CLAMP_VIEW_CLIP_BODY) {
        _clip_body(clamp);
    } else if (view == TUBE_CLAMP_VIEW_FOOT) {
        _flat_foot(clamp);
    } else if (view == TUBE_CLAMP_VIEW_TRANSITION) {
        color("lightgray") {
            _clip_body(clamp);
            _flat_foot(clamp);
        }

        color([1, 0, 0, 0.35])
            _transition_supports(clamp);
    } else {
        // SIDE uses the same geometry as FINAL. The render workflow changes
        // the camera to show the X/Y profile directly.
        tube_clamp_build(clamp);
    }
}

module _outer_ring_solid(clamp) {
    translate([_tube_clamp_center_x(clamp), 0, 0])
        cylinder(
            h = clamp.clamp_width,
            r = tube_clamp_outer_radius(clamp)
        );
}

module _inner_bore_cutter(clamp) {
    translate([
        _tube_clamp_center_x(clamp),
        0,
        -EPS
    ])
        cylinder(
            h = clamp.clamp_width + 2 * EPS,
            r = tube_clamp_inner_radius(clamp)
        );
}

module _full_ring(clamp) {
    difference() {
        _outer_ring_solid(clamp);
        _inner_bore_cutter(clamp);
    }
}

module _clip_body(clamp) {
    difference() {
        _full_ring(clamp);
        _opening_cutter(clamp);
    }
}

module _opening_cutter(clamp) {
    outer_r = tube_clamp_outer_radius(clamp);
    cutter_length = outer_r + 10;
    cutter_half_width =
        cutter_length * tan(clamp.opening_angle / 2);

    translate([
        _tube_clamp_center_x(clamp),
        0,
        -EPS
    ])
        linear_extrude(height = clamp.clamp_width + 2 * EPS)
            polygon(points = [
                [0, 0],
                [cutter_length, -cutter_half_width],
                [cutter_length,  cutter_half_width]
            ]);
}

module _flat_foot(clamp) {
    translate([
        0,
        -clamp.foot_length / 2,
        0
    ])
        cube([
            clamp.foot_thickness,
            clamp.foot_length,
            clamp.clamp_width
        ]);
}

module _mounting_foot(clamp) {
    union() {
        _flat_foot(clamp);
        _foot_transition(clamp);
    }
}

module _transition_supports(clamp) {
    difference() {
        _foot_transition(clamp);
        _inner_bore_cutter(clamp);
    }
}

module _foot_transition(clamp) {
    outer_r = tube_clamp_outer_radius(clamp);
    center_x = _tube_clamp_center_x(clamp);

    attach_x = min(
        clamp.foot_thickness + clamp.foot_transition_height,
        center_x + outer_r - EPS
    );

    dx = attach_x - center_x;
    attach_y = sqrt(max(
        0.01,
        outer_r * outer_r - dx * dx
    ));

    base_half_width = clamp.foot_transition_width / 2;

    linear_extrude(height = clamp.clamp_width)
        polygon(points = [
            [clamp.foot_thickness, -base_half_width],
            [clamp.foot_thickness,  base_half_width],
            [attach_x,               attach_y],
            [attach_x,              -attach_y]
        ]);
}

clamp = tube_clamp_create(
    tube_diameter = tube_diameter,
    clearance = clearance,
    wall_thickness = wall_thickness,
    clamp_width = clamp_width,
    opening_angle = opening_angle,
    foot_length = foot_length,
    foot_thickness = foot_thickness,
    foot_transition_width = foot_transition_width,
    foot_transition_height = foot_transition_height
);

tube_clamp_render(clamp, view = design_view);
