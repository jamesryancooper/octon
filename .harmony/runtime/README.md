# Runtime

Executable runtime layer for harness-native service invocation.

## Contents

| Path | Purpose |
|---|---|
| `run` | POSIX launcher entrypoint |
| `run.cmd` | Windows launcher entrypoint |
| `config/` | Runtime policy and cache configuration |
| `crates/` | Runtime implementation crates |
| `spec/` | Runtime protocol and schema contracts |
| `wit/` | Canonical runtime WIT contracts |
| `_ops/bin/` | Runtime-local prebuilt binaries |
| `_ops/state/` | Runtime-local mutable state (cache/traces/kv) |
| `_meta/evidence/` | Verification artifacts and implementation evidence |

## Contract

- Keep runtime structural assets under `config/`, `crates/`, `spec/`, and `wit/`.
- Keep mutable operational data under `_ops/state/`.
- Keep audit/verification documents under `_meta/evidence/`.

## Studio Launch

Use the runtime CLI to open the desktop workflow studio:

```bash
.harmony/runtime/run studio
```

or, if `harmony` is already on PATH:

```bash
harmony studio
```

When invoked as `studio`, the launcher forces source mode so the command works
even if bundled prebuilt kernel binaries are older than the workspace code.

## Studio Scope

`harmony_studio` provides:

- workflow index and validation visibility
- dependency graph canvas (pan/zoom/select)
- workflow detail inspector from parsed `WORKFLOW.md` frontmatter
- staged edit buffer with patch preview export
- guarded apply with rollback and apply audit artifacts

## Studio Artifacts

Studio writes reports under:

- `.harmony/output/reports/*-studio-patch-preview.diff`
- `.harmony/output/reports/*-studio-apply-audit.md`

Operational build state uses runtime-local storage:

- `.harmony/runtime/_ops/state/build/runtime-crates-target/`
