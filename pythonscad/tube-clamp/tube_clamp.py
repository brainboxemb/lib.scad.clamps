from dataclasses import dataclass
from math import radians, tan

from pythonscad import *

fn = 120
EPS = 0.05

VIEW_FINAL = 0
VIEW_RING = 1
VIEW_OPENING = 2

VIEW_CONFIG = [
    (VIEW_FINAL, "Final clamp"),
    (VIEW_RING, "Full ring"),
    (VIEW_OPENING, "Opening cutter"),
]


def tube_clamp_view_label(view):
    assert VIEW_CONFIG[view][0] == view, "VIEW_CONFIG index/value mismatch"
    return VIEW_CONFIG[view][1]


@dataclass(frozen=True)
class TubeClamp:
    tube_diameter: float = 20
    clearance: float = 0.0
    wall_thickness: float = 3
    clamp_width: float = 16
    opening_angle: float = 60

    def __post_init__(self):
        assert self.tube_diameter > 0
        assert self.clearance >= 0
        assert self.wall_thickness > 0
        assert self.clamp_width > 0
        assert 0 < self.opening_angle < 180

    @property
    def inner_radius(self):
        return (self.tube_diameter + self.clearance) / 2

    @property
    def outer_radius(self):
        return self.inner_radius + self.wall_thickness

    def build(self):
        return self._full_ring() - self._opening_cutter()

    def render(self, view=VIEW_FINAL):
        if view == VIEW_RING:
            return self._full_ring()

        if view == VIEW_OPENING:
            return [
                self._full_ring(),
                self._opening_cutter().color(
                    "red",
                    alpha=0.35,
                ),
            ]

        return self.build()

    def _full_ring(self):
        outer = cylinder(
            h=self.clamp_width,
            r=self.outer_radius,
        )

        inner = cylinder(
            h=self.clamp_width + 2 * EPS,
            r=self.inner_radius,
        ).translate([0, 0, -EPS])

        return outer - inner

    def _opening_cutter(self):
        cutter_length = self.outer_radius + 10
        cutter_half_width = cutter_length * tan(
            radians(self.opening_angle / 2)
        )

        points = [
            [0, 0],
            [cutter_length, -cutter_half_width],
            [cutter_length, cutter_half_width],
        ]

        return polygon(points).linear_extrude(
            height=self.clamp_width + 2 * EPS
        ).translate([0, 0, -EPS])


clamp = TubeClamp()

show(
    clamp.render(
        view=VIEW_FINAL,
    )
)
