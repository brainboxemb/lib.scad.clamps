$fn = 120;

TUBE_CLAMP_RENDER_FN_HIGH = 120;
TUBE_CLAMP_RENDER_FN_LOW = 48;
TUBE_CLAMP_DEFAULT_EXTRA = 0.01;

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
tension_diameter = 0; // 0 = use functional bore
wall_thickness = 3;
clamp_width = 16;
opening_angle = 60;

/* [Fit / preview] */
use_tension_bore = true;
high_resolution = true;
extra = TUBE_CLAMP_DEFAULT_EXTRA;

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
    tension_diameter = undef,
    wall_thickness = 3,
    clamp_width = 16,
    opening_angle = 60,
    base_thickness = 4,
    transition_width = 30,
    transition_depth = 8,
    extra = TUBE_CLAMP_DEFAULT_EXTRA
) =
    let(
        functional_diameter =
            tube_diameter + clearance
    )
    assert(tube_diameter > 0,
        "tube_diameter must be > 0")
    assert(clearance >= 0,
        "clearance must be >= 0")
    assert(
        is_undef(tension_diameter)
        || tension_diameter > 0,
        "tension_diameter must be > 0 when provided"
    )
    assert(
        is_undef(tension_diameter)
        || tension_diameter <= functional_diameter,
        "tension_diameter must not exceed the functional bore diameter"
    )
    assert(extra >= 0,
        "extra must be >= 0")
    object(
        tube_diameter = tube_diameter,
        clearance = clearance,
        tension_diameter = tension_diameter,
        wall_thickness = wall_thickness,
        clamp_width = clamp_width,
        opening_angle = opening_angle,
        base_thickness = base_thickness,
        transition_width = transition_width,
        transition_depth = transition_depth,
        extra = extra
    );

function tube_clamp_functional_diameter(clamp) =
    clamp.tube_diameter + clamp.clearance;

function tube_clamp_tension_diameter(clamp) =
    is_undef(clamp.tension_diameter)
        ? tube_clamp_functional_diameter(clamp)
        : clamp.tension_diameter;

function tube_clamp_bore_diameter(
    clamp,
    use_tension_bore = true
) =
    use_tension_bore
        ? tube_clamp_tension_diameter(clamp)
        : tube_clamp_functional_diameter(clamp);

function tube_clamp_inner_radius(clamp) =
    tube_clamp_functional_diameter(clamp) / 2;

function tube_clamp_tension_radius(clamp) =
    tube_clamp_tension_diameter(clamp) / 2;

function tube_clamp_bore_radius(
    clamp,
    use_tension_bore = true
) =
    tube_clamp_bore_diameter(
        clamp,
        use_tension_bore
    ) / 2;

function tube_clamp_outer_radius(clamp) =
    tube_clamp_inner_radius(clamp)
    + clamp.wall_thickness;


// ----------------------------------------------------------------------
// Derived construction dimensions
// ----------------------------------------------------------------------

// Nominal circular body position. Boolean overlap is created locally with
// clamp.extra instead of shifting this physical datum.
function _tube_clamp_center_x(clamp) =
    clamp.base_thickness
    + tube_clamp_outer_radius(clamp);


// ----------------------------------------------------------------------
// Public geometry
// ----------------------------------------------------------------------

module tube_clamp_build(
    clamp,
    use_tension_bore = true,
    high_resolution = true
) {
    outer_r = tube_clamp_outer_radius(clamp);

    $fn =
        high_resolution
            ? TUBE_CLAMP_RENDER_FN_HIGH
            : TUBE_CLAMP_RENDER_FN_LOW;

    assert(clamp.tube_diameter > 0, "tube_diameter must be > 0");
    assert(clamp.clearance >= 0, "clearance must be >= 0");
    assert(clamp.extra >= 0, "extra must be >= 0");
    assert(clamp.wall_thickness > 0, "wall_thickness must be > 0");
    assert(clamp.clamp_width > 0, "clamp_width must be > 0");
    assert(
        clamp.opening_angle > 0 && clamp.opening_angle < 180,
        "opening_angle must be between 0 and 180 degrees"
    );
    assert(clamp.base_thickness > 0, "base_thickness must be > 0");
    assert(clamp.transition_width > 0, "transition_width must be > 0");
    assert(clamp.transition_depth > 0, "transition_depth must be > 0");
    // Model the part in the same order used by design.md:
    //   1. create one continuous OUTER shape;
    //   2. remove the cylindrical tube bore once;
    //   3. remove the triangular snap opening.
    //
    // This keeps the construction easy to reason about: the bore is not
    // repeatedly cut from separate pieces.
    difference() {
        _outer_shape(clamp);

        _inner_bore_cutter(
            clamp,
            use_tension_bore
        );
        _opening_cutter(clamp);
    }
}


// ----------------------------------------------------------------------
// Design/debug rendering
// ----------------------------------------------------------------------

module tube_clamp_render(
    clamp,
    view = TUBE_CLAMP_VIEW_FINAL,
    use_tension_bore = true,
    high_resolution = true
) {
    $fn =
        high_resolution
            ? TUBE_CLAMP_RENDER_FN_HIGH
            : TUBE_CLAMP_RENDER_FN_LOW;
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
            _inner_bore_cutter(
                clamp,
                use_tension_bore
            );

    } else if (view == TUBE_CLAMP_VIEW_OPENING) {
        color("lightgray")
            _hollow_body(
                clamp,
                use_tension_bore
            );

        color([1, 0, 0, 0.35])
            _opening_cutter(clamp);

    } else {
        // PROFILE uses the final geometry. The workflow only changes camera.
        tube_clamp_build(
            clamp,
            use_tension_bore = use_tension_bore,
            high_resolution = high_resolution
        );
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
            clamp.base_thickness + clamp.extra,
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
        center_x + outer_r - clamp.extra
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
module _inner_bore_cutter(
    clamp,
    use_tension_bore = true
) {
    translate([
        _tube_clamp_center_x(clamp),
        0,
        -clamp.extra
    ])
        cylinder(
            h = clamp.clamp_width
                + 2 * clamp.extra,
            r = tube_clamp_bore_radius(
                clamp,
                use_tension_bore
            )
        );
}

// State after the bore, before the snap opening.
// Kept as a helper because it is both conceptually useful and a design view.
module _hollow_body(
    clamp,
    use_tension_bore = true
) {
    difference() {
        _outer_shape(clamp);
        _inner_bore_cutter(
            clamp,
            use_tension_bore
        );
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
        -clamp.extra
    ])
        linear_extrude(height = clamp.clamp_width + 2 * clamp.extra)
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
    tension_diameter =
        tension_diameter > 0
            ? tension_diameter
            : undef,
    wall_thickness = wall_thickness,
    clamp_width = clamp_width,
    opening_angle = opening_angle,
    base_thickness = base_thickness,
    transition_width = transition_width,
    transition_depth = transition_depth,
    extra = extra
);

tube_clamp_render(
    clamp,
    view = design_view,
    use_tension_bore = use_tension_bore,
    high_resolution = high_resolution
);
