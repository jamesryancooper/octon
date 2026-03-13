# Runtime Evidence

Non-structural verification and audit artifacts for the runtime subsystem.

## Purpose

- Keep evidence and reporting material separate from runtime contracts and code.
- Preserve `runtime/` root for executable/runtime structural assets.

## Contents

| File | Purpose |
|---|---|
| `build-output.md` | Captured build/check outputs |
| `compliance-matrix.md` | Requirement-to-implementation mapping |
| `decision-log.md` | Recorded implementation decisions and rationale |
| `gap-report.md` | Deferred/minimal areas and known limitations |
| `verification-scenarios.md` | Manual verification scenarios and expected outcomes |

## Structural Boundary

Do not store runtime binaries, specs, config, or source code here.
Structural runtime assets remain under:

- `.octon/engine/_ops/`
- `.octon/engine/runtime/spec/`
- `.octon/engine/runtime/config/`
- `.octon/engine/runtime/crates/`
- `.octon/engine/runtime/wit/`
