# Closure Certification Plan

## Closure objective

Certify that the remediation program promoted all mandatory architecture corrections into durable non-proposal targets and that Octon's architecture now satisfies the target-state acceptance criteria.

## Required closure evidence

Retain evidence under:

```text
.octon/state/evidence/validation/architecture/10of10-remediation/
```

Required subfamilies:

| Evidence family | Required contents |
|---|---|
| `registry/` | Contract registry diff, generated docs, registry validation receipt. |
| `authorization-boundary/` | Side-effect inventory, coverage report, negative bypass results, GrantBundle fixtures. |
| `authority-engine/` | Module map, test report, review signoff, old-file disposition. |
| `evidence-store/` | Evidence-store schema, conformance report, completeness report, sample RunCard/HarnessCard. |
| `promotion/` | Promotion receipt examples, validator report, direct-publication removal evidence. |
| `run-lifecycle/` | State machine fixtures for allow, deny, stage, pause, revoke, fail, rollback, close. |
| `support-targets/` | Per-tuple proof cards, live and denied scenario evidence, support matrix regeneration receipt. |
| `operator-views/` | Generated view examples, traceability report, stale-source failure case. |
| `docs-simplification/` | Diff showing historical material relocated and active docs simplified. |
| `ci/` | CI run links or retained summaries for all gates. |

## Required receipts

- architecture registry publication receipt;
- authorization coverage receipt;
- evidence-store adoption receipt;
- promotion semantics adoption receipt;
- support-target proofing receipt;
- operator read-model publication receipt;
- proposal archive receipt.

## Required disclosures

- target-state HarnessCard;
- support-target claim envelope;
- known limitations after remediation;
- remaining non-live or stage-only surfaces;
- generated view non-authority statement;
- retained evidence-store statement.

## Required reviews

| Reviewer | Required signoff |
|---|---|
| Architecture owner | Target-state design and registry consolidation. |
| Runtime owner | Authorization coverage and authority engine decomposition. |
| Governance owner | Promotion semantics, fail-closed posture, support target proofing. |
| Assurance owner | Validators, evidence completeness, closure certification. |
| Operator representative | Operator read-model legibility and inspectability. |

## Closure decision record

Create:

```text
.octon/instance/cognition/decisions/architecture-10of10-remediation-closeout.md
```

It must state what changed, what remained unchanged, which validators passed, where closure evidence is retained, what support claims are admitted, what remains stage-only, where this proposal packet was archived, and why the architecture is target-state-grade.

## Archive rule

After closure, this proposal moves to:

```text
.octon/inputs/exploratory/proposals/.archive/architecture/octon-architecture-10of10-remediation/
```

Archived proposal content remains historical lineage only and must not become runtime or policy authority.
