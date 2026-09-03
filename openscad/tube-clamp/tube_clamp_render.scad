$fn = 120;

use <tube_clamp.scad>

design_view = is_undef(design_view) ? TUBE_CLAMP_VIEW_FINAL : design_view;

clamp = tube_clamp_create();

tube_clamp_render(
    clamp,
    view = design_view
);
