# Target Architecture

Host projection publishing should be a deterministic projection over canonical
capability and extension sources.

The target publisher:

- copies or updates files only when content changes;
- prunes unexpected projection files only through publisher-owned rules;
- preserves non-authority posture;
- validates host parity across `.claude`, `.codex`, and `.cursor`;
- records no-op projection metrics.
