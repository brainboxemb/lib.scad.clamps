# Scripts

The scripts in this directory are repository helpers. Functional verification is
kept separate from repository/migration plumbing: `run-verification.sh` tests the
library behaviour that a consumer depends on, while the shared SCAD workflow and
its CI evidence prove tooling pins, capability selection, runtime choice and
publication behaviour.

## Functional verification

Run inside the shared SCAD toolchain environment:

```bash
bash ./scripts/run-verification.sh
bash ./scripts/build-verification-index.sh
```

`run-verification.sh` exercises the public tube-clamp API through separate
consumer fixtures for both supported engines:

- OpenSCAD renders `vrf/out/openscad/tube-clamp-api.png` and exports the matching
  STL;
- PythonSCAD renders `vrf/out/pythonscad/tube-clamp-api.png` and exports the
  matching STL;
- each command must exit successfully, may not emit an `ERROR:` diagnostic, and
  must leave a non-empty output file.

The consumer fixtures create multiple independently parameterised clamps and
therefore cover the public construction API rather than merely loading the source
file.

`build-verification-index.sh` writes `vrf/out/index.md`, linking the generated
PNG/STL evidence and summarising the functional contract being checked. It does
not execute CAD itself.

Migration-005 configuration is intentionally **not** re-tested here with grep
checks against `moon.yml` or workflow YAML. The shared planner/workflow, exact
pinned tool revisions and PR CI evidence are the authority for that integration
contract. Keeping those checks out of the product verification script prevents
configuration spelling from becoming a second hidden test API.

## Standalone library entrypoints

```bash
bash ./scripts/test-library-entrypoints.sh
```

This is a developer smoke test for the two standalone/show entrypoints. It
renders the OpenSCAD and PythonSCAD library entrypoints directly and verifies that
they produce non-empty PNG output. The images are written next to the respective
library sources; this helper is distinct from the consumer-API verification under
`vrf/out`.

## Design documentation renders

Run:

```bash
bash ./scripts/render-design-images.sh
```

This regenerates the documentation views for both implementations:

```text
openscad/tube-clamp/design/img/
pythonscad/tube-clamp/design/img/
```

The script is intended to run inside the shared SCAD toolchain container.

### OpenSCAD

The OpenSCAD implementation renders multiple views from the same source file by
passing `design_view` through OpenSCAD's `-D` command-line option.

### PythonSCAD

The PythonSCAD implementation uses the `DESIGN_VIEW` environment variable to
select the equivalent documentation view before PythonSCAD executes the model.

PNG rendering is executed through `xvfb-run -a` because PythonSCAD needs an X
server / OpenGL context for offscreen rendering in the headless CI container.

## Compatibility wrapper

`render-openscad-design.sh` is retained as a compatibility wrapper and forwards
to `render-design-images.sh`.

New automation should call `render-design-images.sh` directly.
