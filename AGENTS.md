# Repository agent guidance

Start with [doc/10-00-plan.md](doc/10-00-plan.md), then use [doc/README.md](doc/README.md) to route to the repository manuals, specification, design and verification.

For shared BrainboxEmb working conventions, read
[brainboxemb.meta/AGENTS.md](https://github.com/brainboxemb/brainboxemb.meta/blob/main/AGENTS.md).
That entrypoint owns current Git/commit/PR/CI workflow and routes to the shared
SCAD coding, documentation and source conventions.

Do not inherit `AGENTS.md` from pinned tools as working policy for this
library. Exact dependency behavior comes from this repository's config/gitlinks
plus the pinned dependency's README, docs, source and tests.

Library-specific design knowledge belongs in the numbered documents and the
OpenSCAD/PythonSCAD component-local design documents.
