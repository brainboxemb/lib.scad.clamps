$fn = 120;

use <tube_clamp.scad>

design_view = is_undef(design_view) ? "final" : design_view;

clamp = tube_clamp_create();

tube_clamp_render(
    clamp,
    mode = design_view
);
