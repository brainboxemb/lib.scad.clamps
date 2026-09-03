from dataclasses import dataclass
from enum import StrEnum
from math import radians, tan

from pythonscad import *

fn = 120
EPS = 0.05


@dataclass(frozen=True)
class TubeClamp:
    class View(StrEnum):
        FINAL = "Final clamp"
        RING = "Full ring"
        OPENING = "Opening cutter"

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

    def render(self, view=View.FINAL):
        view = self.View(view)

        if view == self.View.RING:
            return self._full_ring().color("lightgray")

        if view == self.View.OPENING:
            return [
                self._full_ring().color("lightgray"),
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
    clamp.render()
)
