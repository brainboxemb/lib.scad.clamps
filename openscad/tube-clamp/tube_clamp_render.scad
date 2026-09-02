$fn = 120;

use <tube_clamp.scad>

design_view = is_undef(design_view) ? "final" : design_view;

render_tube_clamp(
    mode = design_view
);
