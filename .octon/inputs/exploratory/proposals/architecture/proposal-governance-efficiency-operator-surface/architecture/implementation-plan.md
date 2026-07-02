# Implementation Plan

1. Select the canonical command or skill entrypoint.
2. Wire the entrypoint to the report contract, collector, and scoring logic.
3. Add help text and docs that state advisory-only behavior.
4. Add tests proving the operator surface is optional and non-authoritative.
5. Add projection or extension updates only where they cite canonical sources.

This child must not introduce independent scoring or collection logic.
