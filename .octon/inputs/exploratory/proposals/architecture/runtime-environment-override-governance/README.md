# Runtime Environment-Override Governance

Architecture proposal packet. Status: **draft**. Candidate lineage only — this
packet is not authority and authorizes nothing.

## Problem

The Prompt 1 super-root balanced architecture review (retained evidence:
`.octon/state/evidence/validation/architecture/reviews/super-root-balanced-review/20260709-super-root-balanced-review/`,
finding **F-01**, high severity) found that ambient `OCTON_*` environment
variables affect authority decisions without a declared contract:

- `OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE` skips route-bundle freshness
  verification (`crates/authority_engine/src/implementation/execution.rs:68`,
  `crates/core/src/config.rs:11`), routing around FCR-025's mandated DENY.
- `OCTON_POLICY_MODE_OVERRIDE` / `OCTON_EFFECTIVE_POLICY_MODE` alter the
  effective policy mode (`api.rs:734-735`, `policy_engine/src/lib.rs:969`).
- `OCTON_EXECUTION_ROLE_KIND` / `OCTON_EXECUTION_ROLE_ID` shape the recorded
  execution role (`api.rs:720`).
- Execution-intent env overrides participate in intent binding.

These are authority-adjacent because they are ambient process state: settable
outside any governed artifact, inheritable by child processes, mostly
undocumented, and covered by no fail-closed rule, inventory, or negative
control. The one evidenced legitimate use is programmatic: the kernel sets the
stale-bundle bypass for itself during route-bundle publication bootstrap
(`kernel/src/commands/mod.rs:1111-1114`) — a need that does not require an
ambient variable. Attached finding **F-02**: the `stage_only_behavior` policy
configuration field (`policy_engine/src/lib.rs:195`) is undocumented in
`policy-interface-v1.md`.

## Central Decision

- **Option A — break-glass contract:** retain the overrides as governed,
  receipted break-glass controls (inventory, documentation, mandatory retained
  receipts, protected-mode prohibition, negative controls).
- **Option B — removal/replacement (recommended):** remove ambient
  authority-affecting overrides; replace the publication bootstrap case with
  an explicit receipted runtime input on the narrow publication path;
  break-glass stays the existing human-issued constitutional rank-1 route.
- **Option C — hybrid:** only if evidence justifies retaining a specific
  override ambiently. None was found; see
  `architecture/decision-options.md`.

**This packet's selected recommended direction is Option B**, elaborated for
maximum self-governance: legitimate flexibility moves to explicit, typed,
receipted, **system-governed** control paths in a three-tier hierarchy —
normal operations are system-governed (tier 1), exceptional-but-anticipated
operations like publication bootstrap are system-governed with stricter
evidence and automatic denial on unprovable preconditions (tier 2), and human
break-glass (tier 3) is reserved for true exceptional override: overriding a
deny, bypassing preconditions, emergency recovery outside admitted policy, or
governance-directed action. No routine operation gains a human-in-the-loop
step because ambient variables were removed. See
`architecture/operational-flexibility-and-migration.md`. **Final acceptance
still requires human governance** (`ownership/roles.yml` governance_owner) —
that acceptance, and true break-glass, are where human involvement lives.

## Contents

See `navigation/artifact-catalog.md` for the full map:

- `architecture/decision-options.md` — options, evidence, recommendation
- `architecture/operational-flexibility-and-migration.md` — preserved flexibility, break-glass boundary, phased migration
- `architecture/target-architecture.md` — accepted-state definition and per-override replacement table
- `architecture/acceptance-criteria.md` — what acceptance must pin down
- `architecture/implementation-plan.md` — architecture-level plan (no patches)
- `navigation/traceability-map.md` — finding → remediation → validation chain
- `resources/` — preserved source context and review evidence copies
- `support/` — creation and revision receipts, recorded governance decision
  context, validation plan, rollback plan, evidence plan

Operator governance direction (Option B, the self-governance hierarchy, the
Tier 2 bootstrap preconditions, the break-glass boundary, and the deprecation
policy) is recorded in `support/governance-decision-context.md`. That record
is decision context, not formal acceptance: the packet remains `draft` until
the governed review and acceptance steps complete.

Per the review-continuation decision (`make-targeted-gates`), a **targeted
Prompt 4 Architecture Readiness Audit gate** (not yet run) stands between
this packet's acceptance and its implementation planning — see
`architecture/implementation-plan.md` precondition 3 and its "Prompt 4 Gate
Result Handling" section: when the gate runs, its result must be
dispositioned (proceed / revise / defer / escalate / rerun); readiness
defects block planning; material architecture changes trigger revision plus a
gate rerun; a constitutional conflict routes to the Constitutional Challenge
path.

## Non-Authority Statement

This proposal is candidate lineage only. It cites retained review evidence by
path; the evidence remains evidence, not authority. This packet does not
create authority, does not change support claims, does not authorize
implementation, and does not mutate runtime/control truth or generated
outputs. Implementation requires later governed acceptance and implementation
planning through the proper Octon route.
