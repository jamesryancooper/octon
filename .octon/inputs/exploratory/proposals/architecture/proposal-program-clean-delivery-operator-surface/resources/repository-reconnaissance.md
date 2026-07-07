# Repository Reconnaissance

Searches reviewed before creating this program:

- `AGENTS.md` and `.octon/instance/ingress/AGENTS.md`
- `.codex/skills/octon-proposal-lifecycle-create-program/SKILL.md`
- Existing proposal program packet shape under `proposal-program-governance-efficiency-evaluation`
- Existing child packet shape under `proposal-governance-efficiency-report-contract`
- Proposal-program lifecycle command docs and effective lifecycle contract
- Proposal-program delivery command docs and workflow contract

Existing surfaces found:

- `octon lifecycle run --lifecycle proposal-program --target <path>`
- `.codex/commands/octon-proposal-run-program-lifecycle.md`
- `.codex/commands/proposal-program-delivery.md`
- `.octon/generated/effective/extensions/published/octon-proposal-lifecycle/bundled-first-party/context/lifecycles/proposal-program.contract.yml`
- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml`

Reused surfaces:

- Existing proposal-program lifecycle runner
- Existing proposal-program delivery workflow
- Existing review/revise loop model
- Existing architecture-review receipt model
- Existing Change closeout and worktree cleanup authority boundaries

Rejected alternatives:

- A single proposal packet, because the work spans command UX, runtime route graph output, architecture-review visibility, delivery admission, documentation, and regression fixtures.
- A proposal-only wrapper that bypasses the lifecycle runner, because it would duplicate route authority.
- Flattening delivery and closeout authority into the program runner, because that would weaken child and Change closeout ownership.

New surfaces proposed:

- One parent proposal program and six sibling child packets under `inputs/**`. These are temporary, non-authoritative proposal lineage only.
