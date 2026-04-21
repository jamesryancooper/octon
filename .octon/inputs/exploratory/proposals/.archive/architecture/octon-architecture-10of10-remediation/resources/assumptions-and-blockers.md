# Assumptions and Blockers

proposal_id: `octon-architecture-10of10-remediation`  
resource_role: grounded assumptions and unresolved blockers  
status: non-authoritative proposal resource under `inputs/**`

---

## 1. Grounded assumptions

These assumptions are grounded in observed repository surfaces and the prior architecture evaluation.

| ID | Assumption | Basis |
|---|---|---|
| A-001 | `/.octon/` remains the single authoritative super-root. | `/.octon/README.md`, architecture specification, charter. |
| A-002 | `framework/**` and `instance/**` remain the only authored authority roots. | `.octon` topology doctrine. |
| A-003 | `generated/**` remains rebuildable and never source of truth. | Architecture specification, README, precedence/fail-closed doctrine. |
| A-004 | raw `inputs/**` remain non-authoritative and cannot be direct runtime/policy dependencies. | README, architecture spec, fail-closed obligations. |
| A-005 | host UI, comments, labels, checks, chat transcripts, and generated summaries remain non-authoritative projections. | normative precedence and architecture spec. |
| A-006 | material execution must cross `authorize_execution(...)` before side effects. | execution authorization spec. |
| A-007 | support claims are bounded by `support-targets.yml`. | charter and support-target posture. |
| A-008 | no foundational architectural rewrite is required. | prior evaluation severity judgment. |
| A-009 | runtime enforcement needs proof hardening rather than replacement. | runtime sources and execution specs exist. |
| A-010 | operator-grade views must be generated/read-model surfaces, not canonical authority. | generated non-authority invariant. |
| A-011 | the live repo already identifies `contract-registry.yml` as the machine-readable execution/path/policy invariant registry. | architecture specification. |
| A-012 | broader GitHub/Studio/browser/API/frontier surfaces should remain stage-only until proof-backed. | support-target posture and bootstrap statement. |

---

## 2. Open blockers

| ID | Blocker | Required resolution |
|---|---|---|
| B-001 | Runtime execution was not locally executed during proposal generation. | Before promotion, run the full runtime test suite and material path inventory locally/CI. |
| B-002 | Exact authority-engine module ownership and current internal call graph require code-level refactor planning. | Generate call graph and refactor plan from current Rust sources. |
| B-003 | Evidence-store backend implementation choice is unresolved. | Decide local file-backed retained evidence store vs optional external immutable backend. |
| B-004 | Operator view implementation surface is unresolved. | Decide minimum viable surface: CLI-only, TUI, local web Studio, or all staged. |
| B-005 | Support-target proof suite shape needs implementation-specific fixtures. | Define tuple IDs and scenario fixtures for each admitted support tuple. |
| B-006 | Current generated/effective publication lock mechanics need source-level verification. | Audit generated/effective publication code and receipts. |
| B-007 | CI workflow changes require repo maintainer permission. | Promote through normal PR/review path after packet review. |
| B-008 | Historical/cutover material relocation needs maintainer review to avoid losing useful context. | Create relocation index and backreferences before moving. |

---

## 3. Non-blocking uncertainties

| ID | Uncertainty | Handling |
|---|---|---|
| U-001 | Whether `contract-registry.yml` can absorb all topology/authority metadata without becoming too broad. | Extend incrementally; split generated views but keep one registry of invariants. |
| U-002 | Whether evidence store should be purely repo-local. | Default repo-local retained evidence; optional external retention adapter after proof. |
| U-003 | Whether operator read models should be CLI-first or Studio-first. | Start CLI/generated files; Studio can project later. |
| U-004 | Whether long-running mission demos should be required before 10/10 certification. | Required for final certification, optional for first cutover. |
