from dataclasses import dataclass
from enum import StrEnum
from math import radians, sqrt, tan

from pythonscad import *

fn = 120

# Boolean tolerance / intentional overlap. It must not move nominal datums.
DEFAULT_EXTRA = 0.01


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
    tension_diameter: float | None = None
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
    extra: float = DEFAULT_EXTRA

    def __post_init__(self):
        assert self.tube_diameter > 0
        assert self.clearance >= 0
        assert (
            self.tension_diameter is None
            or 0 < self.tension_diameter <= self.functional_diameter
        )
        assert self.extra >= 0
        assert self.wall_thickness > 0
        assert self.clamp_width > 0
        assert 0 < self.opening_angle < 180
        assert self.base_thickness > 0
        assert self.transition_width > 0
        assert self.transition_depth > 0

    @property
    def functional_diameter(self):
        """Nominal/visual bore diameter."""
        return self.tube_diameter + self.clearance

    @property
    def resolved_tension_diameter(self):
        """Printed clamping bore diameter, or functional diameter if unset."""
        return (
            self.functional_diameter
            if self.tension_diameter is None
            else self.tension_diameter
        )

    def bore_diameter(self, use_tension_bore=True):
        """Selected bore diameter for visual or printed geometry."""
        return (
            self.resolved_tension_diameter
            if use_tension_bore
            else self.functional_diameter
        )

    @property
    def inner_radius(self):
        """Backward-compatible functional/visual bore radius."""
        return self.functional_diameter / 2

    @property
    def tension_radius(self):
        """Printed clamping bore radius."""
        return self.resolved_tension_diameter / 2

    def bore_radius(self, use_tension_bore=True):
        """Selected bore radius for visual or printed geometry."""
        return self.bore_diameter(use_tension_bore) / 2

    @property
    def outer_radius(self):
        """Outside radius based on functional bore plus wall thickness."""
        return self.inner_radius + self.wall_thickness

    @property
    def _center_x(self):
        """Circle position relative to the rear surface.

        Boolean overlap is created locally with extra so this nominal
        physical datum is not shifted.
        """
        return self.base_thickness + self.outer_radius

    def build(self, use_tension_bore=True):
        """Build outside first, then subtract the selected bore and opening."""
        return (
            self._outer_shape()
            - self._inner_bore_cutter(use_tension_bore)
            - self._opening_cutter()
        )

    def render(self, view=View.FINAL, use_tension_bore=True):
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
                self._inner_bore_cutter(
                    use_tension_bore
                ).color("red", alpha=0.45),
            ]

        if view == self.View.OPENING:
            return [
                self._hollow_body(
                    use_tension_bore
                ).color("lightgray"),
                self._opening_cutter().color("red", alpha=0.35),
            ]

        # PROFILE uses final geometry; the workflow only changes camera.
        return self.build(
            use_tension_bore=use_tension_bore
        )

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
            self.base_thickness + self.extra,
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
            self._center_x + self.outer_radius - self.extra,
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

    def _inner_bore_cutter(self, use_tension_bore=True):
        """Cylinder removed once from the completed outside shape."""
        return cylinder(
            h=self.clamp_width + 2 * self.extra,
            r=self.bore_radius(use_tension_bore),
        ).translate([
            self._center_x,
            0,
            -self.extra,
        ])

    def _hollow_body(self, use_tension_bore=True):
        """Outside after the selected tube bore, before the snap opening."""
        return (
            self._outer_shape()
            - self._inner_bore_cutter(use_tension_bore)
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
            height=self.clamp_width + 2 * self.extra
        ).translate([
            self._center_x,
            0,
            -self.extra,
        ])


# Opening this source directly shows the default final clip.
clamp = TubeClamp()
show(clamp.render())
