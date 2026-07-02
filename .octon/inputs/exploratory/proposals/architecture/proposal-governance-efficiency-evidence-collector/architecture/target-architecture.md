# Target Architecture

The collector should accept a lifecycle run, proposal packet, program packet, or surface reference and produce normalized advisory input facts.

Collected facts include:

- route and gate timing;
- retry and recovery counts;
- blocker classes;
- validation pass, fail, warning, and skipped states;
- evidence freshness and publication freshness signals;
- worktree hygiene and handoff signals;
- missing evidence and uncertainty markers.

Collector output is an input to reporting and scoring, not an authority surface.
