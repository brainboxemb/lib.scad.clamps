from dataclasses import dataclass
from enum import StrEnum
from math import radians, sqrt, tan

from pythonscad import *

fn = 120
EPS = 0.05
FOOT_OVERLAP = 1.0


@dataclass(frozen=True)
class TubeClamp:
    class View(StrEnum):
        FINAL = "Final clamp"
        RING = "Full ring"
        OPENING = "Opening cutter"
        CLIP_BODY = "Clip body"
        FOOT = "Mounting foot"
        TRANSITION = "Foot transition"
        SIDE = "Side view"

    tube_diameter: float = 20
    clearance: float = 0.0
    wall_thickness: float = 3
    clamp_width: float = 16
    opening_angle: float = 60

    foot_length: float = 40
    foot_thickness: float = 4
    foot_transition_width: float = 30
    foot_transition_height: float = 8

    def __post_init__(self):
        assert self.tube_diameter > 0
        assert self.clearance >= 0
        assert self.wall_thickness > 0
        assert self.clamp_width > 0
        assert 0 < self.opening_angle < 180
        assert self.foot_length > 0
        assert self.foot_thickness > 0
        assert 0 < self.foot_transition_width <= self.foot_length
        assert self.foot_transition_height > 0
        assert self.outer_radius > FOOT_OVERLAP

    @property
    def inner_radius(self):
        return (self.tube_diameter + self.clearance) / 2

    @property
    def outer_radius(self):
        return self.inner_radius + self.wall_thickness

    @property
    def _center_x(self):
        return (
            self.foot_thickness
            + self.outer_radius
            - FOOT_OVERLAP
        )

    def build(self):
        outer_body = (
            self._outer_ring_solid()
            | self._mounting_foot()
        )

        return (
            outer_body
            - self._inner_bore_cutter()
            - self._opening_cutter()
        )

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

        if view == self.View.CLIP_BODY:
            return self._clip_body()

        if view == self.View.FOOT:
            return self._flat_foot()

        if view == self.View.TRANSITION:
            return [
                self._clip_body().color("lightgray"),
                self._flat_foot().color("lightgray"),
                self._transition_supports().color(
                    "red",
                    alpha=0.35,
                ),
            ]

        # SIDE uses the final geometry; the render workflow changes the
        # camera to show the X/Y profile directly.
        return self.build()

    def _outer_ring_solid(self):
        return cylinder(
            h=self.clamp_width,
            r=self.outer_radius,
        ).translate([
            self._center_x,
            0,
            0,
        ])

    def _inner_bore_cutter(self):
        return cylinder(
            h=self.clamp_width + 2 * EPS,
            r=self.inner_radius,
        ).translate([
            self._center_x,
            0,
            -EPS,
        ])

    def _full_ring(self):
        return (
            self._outer_ring_solid()
            - self._inner_bore_cutter()
        )

    def _clip_body(self):
        return (
            self._full_ring()
            - self._opening_cutter()
        )

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
        ).translate([
            self._center_x,
            0,
            -EPS,
        ])

    def _flat_foot(self):
        return cube([
            self.foot_thickness,
            self.foot_length,
            self.clamp_width,
        ]).translate([
            0,
            -self.foot_length / 2,
            0,
        ])

    def _mounting_foot(self):
        return self._flat_foot() | self._foot_transition()

    def _transition_supports(self):
        return (
            self._foot_transition()
            - self._inner_bore_cutter()
        )

    def _foot_transition(self):
        attach_x = min(
            self.foot_thickness + self.foot_transition_height,
            self._center_x + self.outer_radius - EPS,
        )

        dx = attach_x - self._center_x
        attach_y = sqrt(max(
            0.01,
            self.outer_radius * self.outer_radius - dx * dx,
        ))

        base_half_width = self.foot_transition_width / 2

        points = [
            [self.foot_thickness, -base_half_width],
            [self.foot_thickness, base_half_width],
            [attach_x, attach_y],
            [attach_x, -attach_y],
        ]

        return polygon(points).linear_extrude(
            height=self.clamp_width
        )


clamp = TubeClamp()

show(
    clamp.render()
)
