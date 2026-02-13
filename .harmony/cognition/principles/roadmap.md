# Principles Roadmap

Roadmap for maturing Harmony’s Principles layer as the operational bridge between pillars and methodology.

Last updated: 2026-02-11

## Progress Checklist

### Immediate (P0)

- [x] Finalize `.harmony/cognition/principles/principles.md` as production guidance (no draft status)
- [x] Reconcile `.harmony/cognition/principles/README.md` as the canonical index
- [x] Align principles with methodology guarantees and Trust terminology

### Short-Term (P1)

- [x] Create missing detailed guides for canonical core principles
- [x] Create missing detailed guides for canonical agentic principles
- [x] Add explicit quality-attribute coverage mapping
- [x] Verify pillar relationship mapping across principles docs

### Medium-Term (P2)

- [ ] Add principle-to-kit matrix with executable checks in CI
- [ ] Add principle compliance checks to PR template and review bot prompts
- [ ] Publish a compact onboarding quick-reference for principles

## Completed in This Cycle

| Deliverable | Location | Result |
|---|---|---|
| Audit and gap reconciliation | `.harmony/cognition/principles/README.md` (Audit Snapshot) | Completed |
| Production principles reference | `.harmony/cognition/principles/principles.md` | Completed |
| Full principle index + pillar map | `.harmony/cognition/principles/README.md` | Completed |
| Quality attributes cross-reference | `.harmony/cognition/principles/README.md` | Completed |
| Methodology guarantee alignment check | `.harmony/cognition/principles/README.md` | Completed |
| New core guides | `.harmony/cognition/principles/*.md` (new files) | Completed |
| New agentic guides | `.harmony/cognition/principles/*.md` (new files) | Completed |

## New Guides Added

### Core

- `monolith-first-modulith.md`
- `contract-first.md`
- `small-diffs-trunk-based.md`
- `flags-by-default.md`
- `observability-as-a-contract.md`
- `security-and-privacy-baseline.md`
- `accessibility-baseline.md`
- `documentation-is-code.md`
- `ownership-and-boundaries.md`
- `learn-continuously.md`

### Agentic

- `no-silent-apply.md`
- `determinism-and-provenance.md`
- `idempotency.md`
- `guardrails.md`

## Remaining Work

### 1. Principle-to-Kit Enforcement (P2)

Convert documentation mappings into executable checks:

- policy checks for required evidence per principle (trace_id, rollback plan, risk rubric)
- PR lint checks for branch age / diff size thresholds
- contract drift checks tied to contract-first principle

### 2. Contribution Workflow Integration (P2)

Embed principles into daily workflow surfaces:

- PR template principle checklist
- review bot prompts referencing principle IDs
- optional waiver template with expiry metadata

### 3. Onboarding Asset (P2)

Add a 1-page quick-reference that maps common decisions to relevant principles for faster adoption.

## Success Criteria (Current)

- Every principle listed in `.harmony/cognition/principles/principles.md` has a detailed guide in `.harmony/cognition/principles/`.
- Every principle maps to at least one pillar and at least one quality attribute.
- Methodology guarantees map to explicit principles.
- Naming uses pillar-consistent terminology (for example, Governed Determinism under Trust).

## Related Documentation

- `.harmony/cognition/principles/principles.md`
- `.harmony/cognition/principles/README.md`
- `.harmony/cognition/principles/pillars/README.md`
- `.harmony/cognition/methodology/README.md`
