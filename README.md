# Generated build output

This directory contains generated output for a successful project build.
It is generated automatically and should not be edited manually.

## Artifacts

- [Design documentation](design/README.md)

<!-- scad-project-evidence-navigation -->
## Producer execution evidence

These files describe the SCAD producer executions that actually created the retained output.
They remain unchanged when equivalent output is later hydrated from cache.

- [scad-docs execution](evidence/executions/scad-docs/execution.json) — capability, producer source revision, exact owner revision, result and producer timing when available.
  - [scad-docs log](evidence/executions/scad-docs/execution.log) — concise human-readable producer summary.

## Domain evidence

Structured SCAD/SCons reports contain the detailed target-level build and cache decisions.
They are richer domain evidence, not alternate producer logs.

- No structured domain reports are present for this output.

## Orchestration/materialization evidence

Current-run orchestration evidence explains why capabilities were selected, whether Moon executed or hydrated them, and how long current materialization and snapshot preparation took.
Producer execution evidence above remains the authority for the work that originally created cached output.

- [Workflow phase timings](orchestration/timings.json)
- [Run context and snapshot-preparation timing](orchestration/run-context.json)
- [Moon impact decision](orchestration/impact-decision.json)
- [Affected Moon task ids](orchestration/affected-task-ids.json)
- [SCAD execution/materialization plan](orchestration/scad-ci-plan.json)

### Current workflow timing

| Phase | Duration |
| --- | ---: |
| Preflight + execution plan | 10.663 s |
| Cache restore | 457 ms |
| Runtime pull | 15.465 s |
| Capability materialization | 9.353 s |
| Cache save | 64 ms |
| Validation + finishing | 645 ms |
| Snapshot preparation | 4 ms |
| **Total to prepared snapshot** | **36.727 s** |

The table stops when this generated snapshot is ready. The remote branch push happens afterwards; detailed per-capability timings remain in the materialization files below.

- [consumer:scad.docs materialization](orchestration/moon-invocations/consumer_scad.docs/materialization.json) — current execute/cache/hydrate result and duration.
  - [consumer:scad.docs raw Moon/producer log](orchestration/moon-invocations/consumer_scad.docs/moon.log)
- [consumer:scad.verify materialization](orchestration/moon-invocations/consumer_scad.verify/materialization.json) — current execute/cache/hydrate result and duration.
  - [consumer:scad.verify raw Moon/producer log](orchestration/moon-invocations/consumer_scad.verify/moon.log)

## Publication context

`publication-info.txt` records generated-branch context plus source, tooling and runtime provenance.
Publication/finalization consumes prepared output and must not rewrite producer execution evidence.
