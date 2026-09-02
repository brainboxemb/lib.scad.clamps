from math import radians, tan

from pythonscad import *


EPS = 0.05
fn = 120


# -----------------------------------------------------------------------------
# Public API
# -----------------------------------------------------------------------------

def tube_clamp(
    tube_diameter,
    clearance,
    wall_thickness,
    clamp_width,
    opening_angle,
):
    assert tube_diameter > 0, "tube_diameter must be > 0"
    assert clearance >= 0, "clearance must be >= 0"
    assert wall_thickness > 0, "wall_thickness must be > 0"
    assert clamp_width > 0, "clamp_width must be > 0"
    assert 0 < opening_angle < 180, (
        "opening_angle must be between 0 and 180 degrees"
    )

    return (
        _full_ring(
            tube_diameter,
            clearance,
            wall_thickness,
            clamp_width,
        )
        - _opening_cutter(
            tube_diameter,
            clearance,
            wall_thickness,
            clamp_width,
            opening_angle,
        )
    )


def render_tube_clamp(
    mode="final",
    tube_diameter=20,
    clearance=0.0,
    wall_thickness=3,
    clamp_width=16,
    opening_angle=60,
):
    if mode == "01-ring":
        return _full_ring(
            tube_diameter,
            clearance,
            wall_thickness,
            clamp_width,
        )

    if mode == "02-opening":
        return (
            _full_ring(
                tube_diameter,
                clearance,
                wall_thickness,
                clamp_width,
            ).color("lightgray")
            + _opening_cutter(
                tube_diameter,
                clearance,
                wall_thickness,
                clamp_width,
                opening_angle,
            ).color([1, 0.25, 0.15, 0.55])
        )

    return tube_clamp(
        tube_diameter,
        clearance,
        wall_thickness,
        clamp_width,
        opening_angle,
    )


# -----------------------------------------------------------------------------
# Private implementation
# -----------------------------------------------------------------------------

def _clamp_inner_radius(
    tube_diameter,
    clearance,
):
    return (tube_diameter + clearance) / 2


def _clamp_outer_radius(
    tube_diameter,
    clearance,
    wall_thickness,
):
    return (
        _clamp_inner_radius(
            tube_diameter,
            clearance,
        )
        + wall_thickness
    )


def _full_ring(
    tube_diameter,
    clearance,
    wall_thickness,
    clamp_width,
):
    inner_r = _clamp_inner_radius(
        tube_diameter,
        clearance,
    )

    outer_r = _clamp_outer_radius(
        tube_diameter,
        clearance,
        wall_thickness,
    )

    return (
        cylinder(
            h=clamp_width,
            r=outer_r,
        )
        - cylinder(
            h=clamp_width + 2 * EPS,
            r=inner_r,
        ).translate([0, 0, -EPS])
    )


def _opening_cutter(
    tube_diameter,
    clearance,
    wall_thickness,
    clamp_width,
    opening_angle,
):
    outer_r = _clamp_outer_radius(
        tube_diameter,
        clearance,
        wall_thickness,
    )

    cutter_length = outer_r + 10
    cutter_half_width = cutter_length * tan(
        radians(opening_angle / 2)
    )

    points = [
        [0, 0],
        [cutter_length, -cutter_half_width],
        [cutter_length,  cutter_half_width],
    ]

    return polygon(points).linear_extrude(
        height=clamp_width + 2 * EPS
    ).translate([0, 0, -EPS])

# Standalone preview
show(render_tube_clamp())
