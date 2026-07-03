# Target Architecture

Run-health generation should become proportional to changed run inputs.

The target shape can include:

- compact aggregate indexes;
- changed-run-only materialization;
- active/recent windows for full per-run files;
- retained-history references by digest or pointer;
- stable serialization and write-if-changed behavior;
- explicit freshness and source traceability metadata.

The generator remains the only legal writer for the generated run-health
projection family.
