# Decision Options

Source evidence: retained review bundle
`.octon/state/evidence/validation/architecture/reviews/super-root-balanced-review/20260709-super-root-balanced-review/`
(F-01 in `findings.yml`; ambient-process-environment boundary in
`authority-boundary-map.yml`; env-override dimension in
`validator-depth-matrix.yml`).

## In-Scope Surfaces

| Variable / field | Code path | Effect |
| --- | --- | --- |
| `OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE` | `authority_engine/src/implementation/execution.rs:68`; `core/src/config.rs:11`; self-set by `kernel/src/commands/mod.rs:1111-1114` | Skips route-bundle freshness verification (routes around FCR-025 DENY); bypass records `publication-bypass` metadata |
| `OCTON_POLICY_MODE_OVERRIDE` | `authority_engine/src/implementation/api.rs:734`; `policy_engine/src/lib.rs:969`; name-dropped at `spec/policy-interface-v1.md:308-309` | Overrides effective policy mode |
| `OCTON_EFFECTIVE_POLICY_MODE` | `api.rs:735` | Fallback policy-mode override; fully undocumented |
| `OCTON_EXECUTION_ROLE_KIND` / `OCTON_EXECUTION_ROLE_ID` | `api.rs:720` | Default execution role identity recorded in authority artifacts |
| Execution-intent overrides (`OCTON_EXECUTION_INTENT_ID` / `_VERSION`) | `api.rs` (active_intent_ref) | Participate in intent binding for autonomous execution |
| `stage_only_behavior` (config field, F-02) | `policy_engine/src/lib.rs:195` | Undocumented knob adjacent to STAGE_ONLY semantics |

## Option A — Governed Break-Glass Contract

Retain the overrides; author a runtime environment-input contract declaring
each variable, its owner, permitted contexts, mandatory retained receipt,
protected-mode prohibition, and a negative control.

- Preserves: an operational escape hatch without code change.
- Costs: governs ambient state rather than eliminating it; receipts can only
  disclose use the process itself observes; inheritable environment still
  reaches child processes; adds standing contract + validator machinery for a
  surface with **no evidenced external legitimate consumer**.
- Charter fit: a compensating mechanism requiring owner/removal-review/
  retirement trigger (`CHARTER.md:61-62`) — permanently.

## Option B — Removal / Replacement (RECOMMENDED)

Remove ambient authority-affecting overrides from authority and policy
decision paths. Replace the one evidenced legitimate use — route-bundle
publication bootstrap — with an explicit receipted runtime input (a parameter
on the publication command that emits a retained publication-bypass receipt).
Execution role/intent inputs become explicit request fields rather than
environment reads. Test seams move to injected configuration. Document
`stage_only_behavior` in `policy-interface-v1.md`. Add a candidate fail-closed
rule: ambient environment input to an authority decision is DENY. Add a
negative control proving decision invariance under unauthorized `OCTON_*`
settings.

- Preserves the authority model **by construction**: the clean-sheet lens of
  the source review (review.md §7.11) found ambient environment inputs would
  be forbidden from scratch; every legitimate need has an explicit, receipted
  replacement.
- Avoids a second control plane: process environment ceases to be a
  control-affecting surface at all, rather than becoming a governed one.
- Preserves deny-by-default: FCR-025's DENY on stale bundles holds
  unconditionally except through the explicit, receipted publication input,
  which is itself validator-covered.
- Break-glass remains available where it constitutionally lives: rank-1
  human-issued break-glass directives (`precedence/normative.yml:11-18`) —
  human artifacts, not process environment.

## Option C — Hybrid

Justified only if some override has an evidenced ambient-use requirement that
an explicit input cannot serve. Review of the code paths found none: the
stale-bundle bypass is self-set programmatically inside `cmd_publish`; policy
mode override is exported by the runtime's own wrapper; role/intent defaults
serve absent-value fallback, not operational override. **No evidence supports
a hybrid; Option C is recorded as not justified.**

## Recommendation

**Option B — selected as this packet's recommended direction.** Rationale:
(1) the only evidenced legitimate use is programmatic and in-process — an
explicit parameter serves it with stronger receipts; (2) Option A polices a
surface Option B can eliminate, and permanent compensating mechanisms are
charter-disfavored; (3) invariance-by-construction is testable with a simple
negative control, whereas break-glass-contract compliance is only auditable
after the fact; (4) Option B loses no operational flexibility and does not
trade autonomy for safety — every legitimate capability is preserved at the
highest self-governance tier its preconditions allow: publication bootstrap
and anticipated recovery stay system-governed with machine-checked
preconditions and automatic denial (tier 2); policy-mode selection,
role/intent binding, and dev/test ergonomics stay normal system-governed
(tier 1); only true exceptional override (deny override, precondition bypass,
emergency recovery outside admitted policy, governance-directed action) is
human break-glass (tier 3). Detailed in
`operational-flexibility-and-migration.md`.

**Human governance input required:** the final selection between A and B is an
authority-boundary decision owned by human governance
(`ownership/roles.yml:20-24`, governance_owner approves policy changes). This
packet selects and elaborates Option B as its recommendation; acceptance of
that selection remains a human governance act.
