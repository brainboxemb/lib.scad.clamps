from dataclasses import dataclass
from math import radians, tan

from pythonscad import *

fn = 120
EPS = 0.05


@dataclass(frozen=True)
class TubeClamp:
    tube_diameter: float = 20
    clearance: float = 0.0
    wall_thickness: float = 3
    clamp_width: float = 16
    opening_angle: float = 60


def tube_clamp_create(
    tube_diameter=20,
    clearance=0.0,
    wall_thickness=3,
    clamp_width=16,
    opening_angle=60,
):
    return TubeClamp(
        tube_diameter=tube_diameter,
        clearance=clearance,
        wall_thickness=wall_thickness,
        clamp_width=clamp_width,
        opening_angle=opening_angle,
    )


def tube_clamp_inner_radius(clamp):
    return (clamp.tube_diameter + clamp.clearance) / 2


def tube_clamp_outer_radius(clamp):
    return tube_clamp_inner_radius(clamp) + clamp.wall_thickness


def tube_clamp_build(clamp):
    assert clamp.tube_diameter > 0
    assert clamp.clearance >= 0
    assert clamp.wall_thickness > 0
    assert clamp.clamp_width > 0
    assert 0 < clamp.opening_angle < 180

    return _full_ring(clamp) - _opening_cutter(clamp)


def tube_clamp_render(clamp, mode="final"):
    if mode == "01-ring":
        return _full_ring(clamp)

    if mode == "02-opening":
        return (
            _full_ring(clamp)
            + color([1, 0, 0, 0.35])(_opening_cutter(clamp))
        )

    return tube_clamp_build(clamp)


def _full_ring(clamp):
    inner_r = tube_clamp_inner_radius(clamp)
    outer_r = tube_clamp_outer_radius(clamp)

    outer = cylinder(
        h=clamp.clamp_width,
        r=outer_r,
    )

    inner = cylinder(
        h=clamp.clamp_width + 2 * EPS,
        r=inner_r,
    ).translate([0, 0, -EPS])

    return outer - inner


def _opening_cutter(clamp):
    outer_r = tube_clamp_outer_radius(clamp)
    cutter_length = outer_r + 10
    cutter_half_width = cutter_length * tan(
        radians(clamp.opening_angle / 2)
    )

    points = [
        [0, 0],
        [cutter_length, -cutter_half_width],
        [cutter_length, cutter_half_width],
    ]

    return polygon(points).linear_extrude(
        height=clamp.clamp_width + 2 * EPS
    ).translate([0, 0, -EPS])


clamp = tube_clamp_create()

show(
    tube_clamp_render(
        clamp,
        mode="final",
    )
)
