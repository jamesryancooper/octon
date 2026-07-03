# Target Architecture

`.octon/generated/.tmp` should be treated as explicitly governed local scratch.

The target architecture includes:

- declared scratch roots;
- TTL and size budgets;
- concrete maximum file count and byte count per scratch or cache root;
- cleanup trigger for each scratch or cache root;
- cleanup dry-run by default;
- rebuildability proof;
- refusal for retained evidence, control truth, active generated/effective outputs, and host projections;
- metrics for file count, byte count, runtime, and residue after validation.
