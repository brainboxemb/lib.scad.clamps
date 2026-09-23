# lib.scad.clamps verification

## Strategy

Verification treats the OpenSCAD and PythonSCAD implementations as external
consumers of their public APIs.

The source tests live under `test/openscad/` and `test/pythonscad/`. They
exercise multiple parameter sets, derived dimensions, public build/render paths,
PNG rendering and STL export.

## Current acceptance boundary

Verification proves library/API behavior for the existing tube clamp. It does
not replace consumer-product fit testing and does not reimplement shared
repository/tooling policy as product tests.

OpenSCAD output must also satisfy the shared logged geometry warning/error
policy, not only process exit status.

## PythonSCAD status

PythonSCAD remains a maintained comparison implementation. Its current
OpenSCAD-interoperability limitations are not a reason to flatten the OpenSCAD
object API.

## Evidence and publication

Successful generated evidence is published under the technical `vrf`
namespace:

```text
dev/pr-N/vrf
prod/vrf
rel/vX.Y.Z/vrf
```

The generated verification snapshot includes a copy of this document. For
current tool/runtime health, inspect live Actions and `publication-info.txt`
rather than freezing version text here.
