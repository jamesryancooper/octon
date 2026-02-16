# harmony_studio

Desktop workflow studio for Harmony harness projects.

## Scope

- Workflow inventory and validation overview
- Dependency graph canvas with pan/zoom/select
- Workflow detail inspector from parsed `WORKFLOW.md` frontmatter steps
- Staged edit buffer with patch preview export
- Guarded apply flow with transactional rollback
- Apply audit index, filtering, preview, and path actions

## Run

From repository root:

```bash
.harmony/runtime/run studio
```

From runtime crates workspace:

```bash
cargo run -p harmony_studio
```

## Verify

```bash
cargo fmt -p harmony_studio
cargo check -p harmony_studio
cargo test -p harmony_studio
```
