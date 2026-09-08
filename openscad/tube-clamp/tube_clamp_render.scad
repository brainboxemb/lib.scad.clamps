// File: tube_clamp_render.scad
//   Design-render adapter for the reusable tube clamp.
//
// FileSummary: Maps readable design-view names to the public clamp render API.

$fn = 120;

use <tube_clamp.scad>

// Function: _tube_clamp_design_view_id()
// Description:
//   Converts stable design-documentation names into the numeric public view
//   values used by the OpenSCAD clamp implementation.
function _tube_clamp_design_view_id(view) =
    view == "outer-ring" ? 1 :
    view == "base"       ? 2 :
    view == "transition" ? 3 :
    view == "bore"       ? 4 :
    view == "opening"    ? 5 :
    view == "profile"    ? 6 :
    0;

// Module: tube_clamp_design()
// Usage:
//   tube_clamp_design("final");
// Description:
//   Creates the default clamp and renders one named documentation view.
// Arguments:
//   view = Stable design-documentation view name.
module tube_clamp_design(view = "final") {
    clamp = tube_clamp_create();

    tube_clamp_render(
        clamp,
        view = _tube_clamp_design_view_id(view)
    );
}

// Direct opening still shows a useful final clamp.
tube_clamp_design();
