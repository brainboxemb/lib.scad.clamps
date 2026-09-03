$fn = 120;

// Small overlap used to avoid tangent/coincident surfaces.
// The circular body intentionally enters the flat base slightly so the
// resulting union is one robust printable solid.
EPS = 0.05;
BASE_OVERLAP = 1.0;

// Public design views. Numeric values intentionally equal their table index.
TUBE_CLAMP_VIEW_FINAL = 0;
TUBE_CLAMP_VIEW_OUTER_RING = 1;
TUBE_CLAMP_VIEW_BASE = 2;
TUBE_CLAMP_VIEW_TRANSITION = 3;
TUBE_CLAMP_VIEW_BORE = 4;
TUBE_CLAMP_VIEW_OPENING = 5;
TUBE_CLAMP_VIEW_PROFILE = 6;

TUBE_CLAMP_VIEW_TABLE = [
    [TUBE_CLAMP_VIEW_FINAL,      "Final clamp"],
    [TUBE_CLAMP_VIEW_OUTER_RING, "Outer ring"],
    [TUBE_CLAMP_VIEW_BASE,       "Compact base"],
    [TUBE_CLAMP_VIEW_TRANSITION, "Base transition"],
    [TUBE_CLAMP_VIEW_BORE,       "Tube bore"],
    [TUBE_CLAMP_VIEW_OPENING,    "Snap opening"],
    [TUBE_CLAMP_VIEW_PROFILE,    "Profile view"]
];

function tube_clamp_view_label(view) =
    assert(
        TUBE_CLAMP_VIEW_TABLE[view][0] == view,
        "TUBE_CLAMP_VIEW_TABLE index/value mismatch"
    )
    TUBE_CLAMP_VIEW_TABLE[view][1];

/* [View] */
design_view = 0; // [0:Final clamp, 1:Outer ring, 2:Compact base, 3:Base transition, 4:Tube bore, 5:Snap opening, 6:Profile view]

/* [Tube clamp] */
tube_diameter = 20;
clearance = 0.0;
wall_thickness = 3;
clamp_width = 16;
opening_angle = 60;

/* [Compact base] */
// The base is deliberately not a mounting plate. Its width is derived from
// transition_width, so it never extends beyond the lower transition.
// A consumer or later library variant can add its own mounting geometry.
base_thickness = 4;
transition_width = 30;
transition_depth = 8;


// ----------------------------------------------------------------------
// Public object API
// ----------------------------------------------------------------------

function tube_clamp_create(
    tube_diameter = 20,
    clearance = 0.0,
    wall_thickness = 3,
    clamp_width = 16,
    opening_angle = 60,
    base_thickness = 4,
    transition_width = 30,
    transition_depth = 8
) =
    object(
        tube_diameter = tube_diameter,
        clearance = clearance,
        wall_thickness = wall_thickness,
        clamp_width = clamp_width,
        opening_angle = opening_angle,
        base_thickness = base_thickness,
        transition_width = transition_width,
        transition_depth = transition_depth
    );

function tube_clamp_inner_radius(clamp) =
    (clamp.tube_diameter + clamp.clearance) / 2;

function tube_clamp_outer_radius(clamp) =
    tube_clamp_inner_radius(clamp) + clamp.wall_thickness;


// ----------------------------------------------------------------------
// Derived construction dimensions
// ----------------------------------------------------------------------

// Place the circular body just inside the front face of the flat base.
// BASE_OVERLAP gives the union real material overlap instead of a tangent.
function _tube_clamp_center_x(clamp) =
    clamp.base_thickness
    + tube_clamp_outer_radius(clamp)
    - BASE_OVERLAP;


// ----------------------------------------------------------------------
// Public geometry
// ----------------------------------------------------------------------

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
    assert(clamp.base_thickness > 0, "base_thickness must be > 0");
    assert(clamp.transition_width > 0, "transition_width must be > 0");
    assert(clamp.transition_depth > 0, "transition_depth must be > 0");
    assert(
        outer_r > BASE_OVERLAP,
        "outer radius must be larger than BASE_OVERLAP"
    );

    // Model the part in the same order used by design.md:
    //   1. create one continuous OUTER shape;
    //   2. remove the cylindrical tube bore once;
    //   3. remove the triangular snap opening.
    //
    // This keeps the construction easy to reason about: the bore is not
    // repeatedly cut from separate pieces.
    difference() {
        _outer_shape(clamp);

        _inner_bore_cutter(clamp);
        _opening_cutter(clamp);
    }
}


// ----------------------------------------------------------------------
// Design/debug rendering
// ----------------------------------------------------------------------

module tube_clamp_render(clamp, view = TUBE_CLAMP_VIEW_FINAL) {
    if (view == TUBE_CLAMP_VIEW_OUTER_RING) {
        _outer_ring_solid(clamp);

    } else if (view == TUBE_CLAMP_VIEW_BASE) {
        color("lightgray")
            _outer_ring_solid(clamp);

        // Red = geometry introduced by this design step.
        color([1, 0, 0, 0.45])
            _flat_base(clamp);

    } else if (view == TUBE_CLAMP_VIEW_TRANSITION) {
        color("lightgray") {
            _outer_ring_solid(clamp);
            _flat_base(clamp);
        }

        // Still solid here: the tube bore is deliberately a later step.
        color([1, 0, 0, 0.45])
            _base_transition(clamp);

    } else if (view == TUBE_CLAMP_VIEW_BORE) {
        // Semi-transparent outside lets the red bore cutter remain visible.
        color([0.75, 0.75, 0.75, 0.50])
            _outer_shape(clamp);

        color([1, 0, 0, 0.45])
            _inner_bore_cutter(clamp);

    } else if (view == TUBE_CLAMP_VIEW_OPENING) {
        color("lightgray")
            _hollow_body(clamp);

        color([1, 0, 0, 0.35])
            _opening_cutter(clamp);

    } else {
        // PROFILE uses the final geometry. The workflow only changes camera.
        tube_clamp_build(clamp);
    }
}


// ----------------------------------------------------------------------
// Construction geometry
// ----------------------------------------------------------------------

// Complete outside before any functional material is removed.
module _outer_shape(clamp) {
    union() {
        _outer_ring_solid(clamp);
        _flat_base(clamp);
        _base_transition(clamp);
    }
}

// Solid cylinder defining the outside of the circular clip.
// It is intentionally NOT a ring yet: the bore is cut later.
module _outer_ring_solid(clamp) {
    translate([_tube_clamp_center_x(clamp), 0, 0])
        cylinder(
            h = clamp.clamp_width,
            r = tube_clamp_outer_radius(clamp)
        );
}

// Compact rear surface of the base clip.
//
// Its width is exactly transition_width. There is deliberately no independent
// base width: the basic clip should not become a mounting plate by itself.
module _flat_base(clamp) {
    translate([
        0,
        -clamp.transition_width / 2,
        0
    ])
        cube([
            clamp.base_thickness,
            clamp.transition_width,
            clamp.clamp_width
        ]);
}

// Sloped transition from the compact base to the circular outside.
//
// transition_width = full width where the transition leaves the base.
// transition_depth = distance in X before it meets the circular body.
module _base_transition(clamp) {
    outer_r = tube_clamp_outer_radius(clamp);
    center_x = _tube_clamp_center_x(clamp);

    attach_x = min(
        clamp.base_thickness + clamp.transition_depth,
        center_x + outer_r - EPS
    );

    // Intersection of attach_x with the outer circle determines where the
    // sloped transition naturally meets the round body.
    dx = attach_x - center_x;
    attach_y = sqrt(max(
        0.01,
        outer_r * outer_r - dx * dx
    ));

    base_half_width = clamp.transition_width / 2;

    linear_extrude(height = clamp.clamp_width)
        polygon(points = [
            [clamp.base_thickness, -base_half_width],
            [clamp.base_thickness,  base_half_width],
            [attach_x,               attach_y],
            [attach_x,              -attach_y]
        ]);
}

// Cylindrical material removed once from the completed outside.
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

// State after the bore, before the snap opening.
// Kept as a helper because it is both conceptually useful and a design view.
module _hollow_body(clamp) {
    difference() {
        _outer_shape(clamp);
        _inner_bore_cutter(clamp);
    }
}

// Simple triangular cutter for the snap opening.
// Keep this simple unless a later requirement gives a reason to change it.
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


// ----------------------------------------------------------------------
// Standalone Customizer preview
// ----------------------------------------------------------------------

clamp = tube_clamp_create(
    tube_diameter = tube_diameter,
    clearance = clearance,
    wall_thickness = wall_thickness,
    clamp_width = clamp_width,
    opening_angle = opening_angle,
    base_thickness = base_thickness,
    transition_width = transition_width,
    transition_depth = transition_depth
);

tube_clamp_render(clamp, view = design_view);
