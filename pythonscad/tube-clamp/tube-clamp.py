"""lib.scad.clamps - tube-clamp

PythonSCAD implementation of the same open tube-clamp design as the
OpenSCAD reference implementation.
"""

import os
from math import cos, pi, sin

from pythonscad import *

TUBE_DIAMETER = 20
WALL_THICKNESS = 3
CLAMP_WIDTH = 16
OPENING_ANGLE = 60
CLEARANCE = 0.0


def _sector_points(radius, angle_deg, segments=48):
    start = -angle_deg / 2
    return [[0, 0]] + [
        [
            radius * cos((start + angle_deg * i / segments) * pi / 180),
            radius * sin((start + angle_deg * i / segments) * pi / 180),
        ]
        for i in range(segments + 1)
    ]


def full_ring(
    tube_diameter=TUBE_DIAMETER,
    wall_thickness=WALL_THICKNESS,
    clamp_width=CLAMP_WIDTH,
    clearance=CLEARANCE,
):
    inner_radius = (tube_diameter + clearance) / 2
    outer_radius = inner_radius + wall_thickness

    outer = cylinder(h=clamp_width, r=outer_radius, fn=120)
    inner = cylinder(
        h=clamp_width + 0.1,
        r=inner_radius,
        fn=120,
    ).translate([0, 0, -0.05])

    return outer - inner


def opening_cutter(
    tube_diameter=TUBE_DIAMETER,
    wall_thickness=WALL_THICKNESS,
    clamp_width=CLAMP_WIDTH,
    opening_angle=OPENING_ANGLE,
    clearance=CLEARANCE,
):
    inner_radius = (tube_diameter + clearance) / 2
    outer_radius = inner_radius + wall_thickness
    points = _sector_points(
        outer_radius + 2 * wall_thickness + 1,
        opening_angle,
    )

    return polygon(points).linear_extrude(
        height=clamp_width + 0.1
    ).translate([0, 0, -0.05])


def tube_clamp(
    tube_diameter=TUBE_DIAMETER,
    wall_thickness=WALL_THICKNESS,
    clamp_width=CLAMP_WIDTH,
    opening_angle=OPENING_ANGLE,
    clearance=CLEARANCE,
):
    if tube_diameter <= 0:
        raise ValueError("tube_diameter must be > 0")
    if wall_thickness <= 0:
        raise ValueError("wall_thickness must be > 0")
    if clamp_width <= 0:
        raise ValueError("clamp_width must be > 0")
    if not 0 < opening_angle < 180:
        raise ValueError("opening_angle must be between 0 and 180 degrees")
    if clearance < 0:
        raise ValueError("clearance must be >= 0")

    return full_ring(
        tube_diameter,
        wall_thickness,
        clamp_width,
        clearance,
    ) - opening_cutter(
        tube_diameter,
        wall_thickness,
        clamp_width,
        opening_angle,
        clearance,
    )


def design_object(view):
    """Return the geometry used for a generated design-document view."""
    if view == "01-ring":
        return full_ring()
    if view == "02-opening":
        return opening_cutter()
    if view in ("final", "03-final"):
        return tube_clamp()

    raise ValueError(f"Unknown DESIGN_VIEW: {view}")


show(design_object(os.environ.get("DESIGN_VIEW", "final")))
