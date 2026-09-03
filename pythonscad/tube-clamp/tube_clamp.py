from dataclasses import dataclass
from enum import StrEnum
from math import radians, sqrt, tan

from pythonscad import *

fn = 120

# Boolean tolerance / intentional overlap.
EPS = 0.05
BASE_OVERLAP = 1.0


@dataclass(frozen=True)
class TubeClamp:
    """Reusable basic tube clip with a compact flat back."""

    class View(StrEnum):
        FINAL = "Final clamp"
        OUTER_RING = "Outer ring"
        BASE = "Compact base"
        TRANSITION = "Base transition"
        BORE = "Tube bore"
        OPENING = "Snap opening"
        PROFILE = "Profile view"

    # Tube and snap-fit geometry.
    tube_diameter: float = 20
    clearance: float = 0.0
    wall_thickness: float = 3
    clamp_width: float = 16
    opening_angle: float = 60

    # Compact base geometry.
    #
    # There is deliberately no independent base width. transition_width is
    # also the width of the flat base, so the base cannot extend sideways
    # beyond the lower edge of the transition.
    base_thickness: float = 4
    transition_width: float = 30
    transition_depth: float = 8

    def __post_init__(self):
        assert self.tube_diameter > 0
        assert self.clearance >= 0
        assert self.wall_thickness > 0
        assert self.clamp_width > 0
        assert 0 < self.opening_angle < 180
        assert self.base_thickness > 0
        assert self.transition_width > 0
        assert self.transition_depth > 0
        assert self.outer_radius > BASE_OVERLAP

    @property
    def inner_radius(self):
        """Radius of the free tube cavity."""
        return (self.tube_diameter + self.clearance) / 2

    @property
    def outer_radius(self):
        """Outside radius of the circular clip body."""
        return self.inner_radius + self.wall_thickness

    @property
    def _center_x(self):
        """Circle position relative to the rear surface.

        BASE_OVERLAP makes the circle and base genuinely overlap instead of
        merely touching at a tangent.
        """
        return (
            self.base_thickness
            + self.outer_radius
            - BASE_OVERLAP
        )

    def build(self):
        """Build outside first, then subtract the two functional cutouts."""
        return (
            self._outer_shape()
            - self._inner_bore_cutter()
            - self._opening_cutter()
        )

    def render(self, view=View.FINAL):
        """Return final geometry or one documented construction step."""
        view = self.View(view)

        if view == self.View.OUTER_RING:
            return self._outer_ring_solid()

        if view == self.View.BASE:
            return [
                self._outer_ring_solid().color("lightgray"),
                self._flat_base().color("red", alpha=0.45),
            ]

        if view == self.View.TRANSITION:
            return [
                self._outer_ring_solid().color("lightgray"),
                self._flat_base().color("lightgray"),
                self._base_transition().color("red", alpha=0.45),
            ]

        if view == self.View.BORE:
            return [
                self._outer_shape().color("lightgray", alpha=0.50),
                self._inner_bore_cutter().color("red", alpha=0.45),
            ]

        if view == self.View.OPENING:
            return [
                self._hollow_body().color("lightgray"),
                self._opening_cutter().color("red", alpha=0.35),
            ]

        # PROFILE uses final geometry; the workflow only changes camera.
        return self.build()

    # ------------------------------------------------------------------
    # Construction geometry
    # ------------------------------------------------------------------

    def _outer_shape(self):
        """One complete solid outside before the bore/opening cuts."""
        return (
            self._outer_ring_solid()
            | self._flat_base()
            | self._base_transition()
        )

    def _outer_ring_solid(self):
        """Solid circular outside; the bore is intentionally a later step."""
        return cylinder(
            h=self.clamp_width,
            r=self.outer_radius,
        ).translate([
            self._center_x,
            0,
            0,
        ])

    def _flat_base(self):
        """Compact rear face, exactly as wide as transition_width."""
        return cube([
            self.base_thickness,
            self.transition_width,
            self.clamp_width,
        ]).translate([
            0,
            -self.transition_width / 2,
            0,
        ])

    def _base_transition(self):
        """Trapezoidal transition from compact base to circular outside."""
        attach_x = min(
            self.base_thickness + self.transition_depth,
            self._center_x + self.outer_radius - EPS,
        )

        dx = attach_x - self._center_x
        attach_y = sqrt(max(
            0.01,
            self.outer_radius * self.outer_radius - dx * dx,
        ))

        base_half_width = self.transition_width / 2

        points = [
            [self.base_thickness, -base_half_width],
            [self.base_thickness, base_half_width],
            [attach_x, attach_y],
            [attach_x, -attach_y],
        ]

        return polygon(points).linear_extrude(
            height=self.clamp_width
        )

    def _inner_bore_cutter(self):
        """Cylinder removed once from the completed outside shape."""
        return cylinder(
            h=self.clamp_width + 2 * EPS,
            r=self.inner_radius,
        ).translate([
            self._center_x,
            0,
            -EPS,
        ])

    def _hollow_body(self):
        """Outside after the tube bore but before the snap opening."""
        return (
            self._outer_shape()
            - self._inner_bore_cutter()
        )

    def _opening_cutter(self):
        """Simple triangular cutter that creates the snap opening."""
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


# Opening this source directly shows the default final clip.
clamp = TubeClamp()
show(clamp.render())
