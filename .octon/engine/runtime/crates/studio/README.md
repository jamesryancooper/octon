# octon_studio

Desktop workflow and operations studio for Octon harness projects.

## Scope

- Workflow inventory and validation overview
- Dependency graph canvas with pan/zoom/select
- Workflow detail inspector from parsed `README.md` frontmatter steps
- Read-only orchestration operations workspace for overview, lookup, runs,
  incidents, queue, watchers, automations, missions, and playbooks
- Staged edit buffer with patch preview export
- Guarded apply flow with transactional rollback
- Apply audit index, filtering, preview, and path actions

## Run

From repository root:

```bash
.octon/engine/runtime/run studio
```

From runtime crates workspace:

```bash
cargo run -p octon_studio
```

## Verify

```bash
cargo fmt -p octon_studio
cargo check -p octon_studio
cargo test -p octon_studio
```
