"""Tube clamp - PythonSCAD implementation.

The geometry intentionally mirrors the OpenSCAD implementation.
"""

from math import radians, tan

from pythonscad import *

tube_diameter = 20
clearance = 0.0
wall_thickness = 3
clamp_width = 16
opening_angle = 60

design_view = globals().get("design_view", "final")

EPS = 0.05


def clamp_inner_radius(tube_diameter, clearance):
    return (tube_diameter + clearance) / 2


def clamp_outer_radius(tube_diameter, clearance, wall_thickness):
    return clamp_inner_radius(tube_diameter, clearance) + wall_thickness


def full_ring(
    tube_diameter,
    clearance,
    wall_thickness,
    clamp_width,
):
    inner_r = clamp_inner_radius(
        tube_diameter,
        clearance,
    )
    outer_r = clamp_outer_radius(
        tube_diameter,
        clearance,
        wall_thickness,
    )

    return (
        cylinder(h=clamp_width, r=outer_r, fn=120)
        - cylinder(
            h=clamp_width + 2 * EPS,
            r=inner_r,
            fn=120,
        ).translate([0, 0, -EPS])
    )


def opening_cutter(
    tube_diameter,
    clearance,
    wall_thickness,
    clamp_width,
    opening_angle,
):
    outer_r = clamp_outer_radius(
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


def tube_clamp(
    tube_diameter,
    clearance,
    wall_thickness,
    clamp_width,
    opening_angle,
):
    return (
        full_ring(
            tube_diameter,
            clearance,
            wall_thickness,
            clamp_width,
        )
        - opening_cutter(
            tube_diameter,
            clearance,
            wall_thickness,
            clamp_width,
            opening_angle,
        )
    )



if design_view == "01-ring":
    show(
        full_ring(
            tube_diameter,
            clearance,
            wall_thickness,
            clamp_width,
        )
    )
elif design_view == "02-opening":
    show(
        full_ring(
            tube_diameter,
            clearance,
            wall_thickness,
            clamp_width,
        ).color("lightgray")
        + opening_cutter(
            tube_diameter,
            clearance,
            wall_thickness,
            clamp_width,
            opening_angle,
        ).color([1, 0.25, 0.15, 0.55])
    )
else:
    show(
        tube_clamp(
            tube_diameter,
            clearance,
            wall_thickness,
            clamp_width,
            opening_angle,
        )
    )
