# Operational Flexibility, Governance Hierarchy, and Migration

Option B removes ambient authority-affecting environment overrides. This
section defines the governance hierarchy that replaces them, makes explicit
what operational flexibility remains at each tier, and lays out the migration.
Plain-English target: authority decisions may change only through explicit,
typed, receipted inputs on approved narrow paths, with validators proving
ambient env vars cannot silently change protected behavior — **and with Octon
governing itself wherever the system can prove its own preconditions.**

## 1. Governance Hierarchy

Option B preserves maximum self-governance. Human involvement is reserved for
true break-glass, governance acceptance, and constitutionally required
decisions — it is never the routine replacement for a removed env var.

| Tier | Class | Mechanics | Human involvement |
| --- | --- | --- | --- |
| 1 | **Normal operation — system-governed** | Explicit request/config fields; authority-engine validation; policy checks; retained receipts; validators and negative controls | None |
| 2 | **Exceptional but anticipated — system-governed with stricter evidence** | Narrow explicit inputs; machine-checkable precondition proofs; automatic denial when preconditions fail; retained evidence; bounded scope and duration | None while preconditions are provable |
| 3 | **True break-glass — human-governed** | Human-issued directive at normative precedence rank 1; retained receipt; explicit target/scope/duration; post-use review | Required by definition |

Tier 3 is reserved for: overriding a deny decision; bypassing normal
preconditions; emergency recovery outside admitted policy; and
governance-directed exceptional action. An operation that the system can
verify against declared preconditions belongs in tier 2, not tier 3.

## 2. What Operational Flexibility Remains

| Need today | Tier | How it is served after Option B |
| --- | --- | --- |
| Route-bundle publication bootstrap (publishing while the current bundle is stale) | **2 — exceptional system-governed** | Explicit publication-bootstrap input with machine-checked preconditions: (a) the caller is the route-bundle publication path (the command that today self-sets the variable, `kernel/src/commands/mod.rs:1111-1114`); (b) stale-bundle tolerance is necessary for this publication — the current bundle/lock is stale or digest-drifted and this publication regenerates that same bundle; (c) the bypass is scoped to reading the current bundle for this one publication. All preconditions provable by the system → the bootstrap proceeds **without any human step**, emitting a retained receipt recording why tolerance was needed. Any precondition unprovable → automatic denial. Human break-glass enters only to override that denial. |
| Anticipated recovery (e.g., republishing after digest drift, refreshing stale handles) | **2 — exceptional system-governed** | Same pattern: narrow explicit inputs, precondition proofs, auto-deny on failure, retained evidence, bounded scope. No human step while the system can prove its own preconditions. |
| Emergency recovery outside admitted policy; overriding a deny; bypassing preconditions | **3 — true break-glass** | Human-issued directive at normative precedence rank 1 (`precedence/normative.yml:11-18`) with retained receipt, explicit target/scope/duration, and post-use review. Artifact-based, so it cannot leak through shell, CI, or child-process environment. |
| Legitimate policy-mode selection (dev/test/`shadow`/`soft-enforce`) | **1 — normal system-governed** | Explicit policy-mode request/config fields. Modes already declared in `octon.yml#execution_governance.policy_mode.allowed_development_modes` remain usable in non-protected contexts **without human approval** when declared through approved config. Protected contexts categorically reject ambient env-driven mode change. |
| Execution role and intent binding | **1 — normal system-governed** | Explicit typed fields bound into the ExecutionRequest and validated on the same authority path as other authorization inputs. No human step for normal binding; overriding a role/intent **outside admitted policy** is a tier-3 event. |
| Local development and test ergonomics | **1 — normal system-governed** | Explicit local config, injected test fixtures, and non-authority simulation inputs. Existing test seams (`std::env::set_var` at `kernel/src/commands/mod.rs`) become fixture-injected. **Routine local testing never depends on human governance.** |
| Operator diagnosability | 1 | Presence of a legacy `OCTON_*` variable produces a clear, actionable message naming the variable, its ignored/rejected status, and the explicit replacement. Silence is not an acceptable failure mode. |
| Gradual adoption | — | Phased migration below, including a temporary warning/deprecation phase before hard enforcement. |

## 3. Break-Glass Boundary

Break-glass is **not** the ordinary replacement for ambient overrides — the
replacements are the tier 1 and tier 2 system-governed paths above. Option B
relocates break-glass to where the constitution already expects it and
reserves it for genuinely exceptional override:

- **explicit human-issued directive** — an authored artifact, not process state;
- **normative precedence rank 1** — break-glass directives already outrank all
  repo-local authority (`precedence/normative.yml:11-18`);
- **retained receipt** — every use lands durable evidence (EVI-005: hidden
  intervention prohibited);
- **explicit target, scope, and duration** — no open-ended standing bypass;
- **post-use review** — each use is reviewed after the fact and the review is
  retained;
- **inheritance-proof** — artifact-based, so it cannot leak into child
  processes, CI runners, or operator shell profiles by accident.

Deny-by-default composes across tiers: absence of a tier-2 precondition proof
means denial; absence of a tier-3 directive means normal enforcement. The
invariance negative control proves ambient variables do nothing at any tier —
including while a break-glass directive is active.

## 4. Migration and Compatibility Plan

Architecture-level phases; no patches; sequencing gates only.

1. **Inventory.** Enumerate every current read and write of the affected
   variables across the repository (code, scripts, CI workflows, docs, test
   fixtures). Starting set from the source review: `execution.rs:68`,
   `core/config.rs:11`, `api.rs:720,734-735`, `policy_engine/lib.rs:969`,
   `kernel/mod.rs:1111-1114` (self-set), `mod.rs:1288` (test remove_var),
   `spec/policy-interface-v1.md:308-309` (doc mention).
2. **Classify each use** as exactly one of: `legitimate-bootstrap` (tier 2
   candidate), `test-only` (fixture seams), `local-convenience` (tier 1
   explicit config), `stale-compatibility` (doc mentions of removed
   behavior), or `unsafe` (any ambient read reaching an authority decision).
   The classification lands in the packet's implementation-planning evidence.
3. **Build replacements before removal.** The tier-2 publication-bootstrap
   input (with its precondition checks), tier-1 policy-mode fields, and
   tier-1 role/intent fields must exist and pass their positive proofs —
   including the no-human-step bootstrap proof — **before** any ambient read
   is removed. The route-bundle publication bootstrap must never have a gap
   in coverage.
4. **Deprecation phase (warning).** Ambient variables are ignored for
   authority decisions but detected and warned about with the actionable
   message above; warnings are receipted so residual usage is measurable.
   This phase may be skipped only if the inventory shows zero external usage.
5. **Enforcement phase (hard).** Protected-mode contexts fail closed
   (reject with reason code) when an in-scope ambient variable is present;
   non-protected contexts continue to ignore-and-warn. Documentation
   (`policy-interface-v1.md`, the new environment-input contract) is updated
   **before** this flip.
6. **Cleanup.** Remove dead reads, retire the deprecation shims with an owner
   and retirement trigger (per `CHARTER.md:61-62`), and close the boundary row
   in the next architecture review cycle.

### Migration Rollback Conditions

Rollback (atomic revert per `support/rollback-plan.md`) is triggered if:

- route-bundle publication cannot complete through the tier-2 explicit
  bootstrap input in any supported context, or its precondition checks deny a
  publication that admitted policy intends to allow (self-governance
  regression: a routine operation newly requiring human intervention is
  itself a rollback trigger);
- a protected-mode workflow legitimately depended on a removed default in a
  way the inventory missed (role/intent absent-value regression);
- the deprecation warnings reveal load-bearing external usage that needs a
  replacement not yet designed.

Rollback restores the pre-decision state including the ungoverned ambient
surface: F-01 reopens and this packet returns to revision — rollback is never
silent closure.
