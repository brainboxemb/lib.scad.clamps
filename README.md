# Generated build output

This directory contains generated output for a successful project build.
It is generated automatically and should not be edited manually.

## Artifacts

- [Design documentation](design/README.md)

<!-- scad-project-evidence-navigation -->
## Producer execution evidence

These files describe the SCAD producer executions that actually created the retained output.
They remain unchanged when equivalent output is later hydrated from cache.

- [scad-build execution](evidence/executions/scad-build/execution.json) — capability, producer source revision, exact owner revision, result and producer timing when available.
  - [scad-build log](evidence/executions/scad-build/execution.log) — concise human-readable producer summary.
- [scad-docs execution](evidence/executions/scad-docs/execution.json) — capability, producer source revision, exact owner revision, result and producer timing when available.
  - [scad-docs log](evidence/executions/scad-docs/execution.log) — concise human-readable producer summary.

## Domain evidence

Structured SCAD/SCons reports contain the detailed target-level build and cache decisions.
They are richer domain evidence, not alternate producer logs.

- No structured domain reports are present for this output.

## Orchestration/materialization evidence

Current-run orchestration evidence explains why capabilities were selected, whether Moon executed or hydrated them, and how long current materialization and snapshot preparation took.
Producer execution evidence above remains the authority for the work that originally created cached output.

- Current orchestration evidence is attached by the publication layer.
- A later cache hydration may therefore have a current materialization revision that differs from the retained producer `source_revision`.

## Publication context

- Context: `release`
- Source: tag `v0.1.6`
- Generated branch: `rel/v0.1.6/bld`
- Policy: immutable release snapshot; never replaced or force-pushed

See `publication-info.txt` for the exact source commit, tooling and runtime provenance.
Publication/finalization consumes prepared output and must not rewrite producer execution evidence.
