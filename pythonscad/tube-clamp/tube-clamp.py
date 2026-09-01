"""Tube clamp - PythonSCAD implementation.

The structure intentionally mirrors the OpenSCAD implementation so both
versions can be compared directly.
"""

import os
from math import cos, pi, sin

from pythonscad import *

tube_diameter = 20
clearance = 0.0
wall_thickness = 3
clamp_width = 16
opening_angle = 60

EPS = 0.05


def clamp_inner_radius():
    return (tube_diameter + clearance) / 2


def clamp_outer_radius():
    return clamp_inner_radius() + wall_thickness


def full_ring():
    inner_r = clamp_inner_radius()
    outer_r = clamp_outer_radius()

    return (
        cylinder(h=clamp_width, r=outer_r, fn=120)
        - cylinder(
            h=clamp_width + 2 * EPS,
            r=inner_r,
            fn=120,
        ).translate([0, 0, -EPS])
    )


def opening_cutter():
    outer_r = clamp_outer_radius()
    cutter_r = outer_r + 2 * wall_thickness + 1
    half_angle = opening_angle / 2

    points = [
        [0, 0],
        [
            cutter_r * cos(-half_angle * pi / 180),
            cutter_r * sin(-half_angle * pi / 180),
        ],
        [
            cutter_r * cos(half_angle * pi / 180),
            cutter_r * sin(half_angle * pi / 180),
        ],
    ]

    return polygon(points).linear_extrude(
        height=clamp_width + 2 * EPS
    ).translate([0, 0, -EPS])


def tube_clamp():
    return full_ring() - opening_cutter()


design_view = os.environ.get("DESIGN_VIEW", "final")

if design_view == "01-ring":
    show(full_ring())
elif design_view == "02-opening":
    show(opening_cutter())
else:
    show(tube_clamp())
