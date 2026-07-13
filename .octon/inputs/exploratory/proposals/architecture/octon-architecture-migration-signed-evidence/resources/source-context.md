# Source Context

## Coordination And Proof Baseline

The intake controls accepted operator intent while remaining non-authoritative
pending formal promotion. This packet also uses the complete reconciliation
package for packet coordination, current findings, engineering refinement, and
proof planning:

`.octon/inputs/exploratory/reviews/architecture-migration/reconciliations/architecture-migration-reconciliation-20260712T032411Z-10c3ff/`

The reconciled RP-07 coordination and proof sources are:

- `reconciliation/reconciled-proposal-packet-map.yml` — RP-07 purpose,
  scope, dependencies, ownership, proof, findings, and exclusions;
- `reconciliation/reconciled-workgroup-roadmap.yml` — RWG-07 wave, entry,
  exit, rollback, and parallelization constraints;
- `reconciliation/reconciled-decision-register.yml` — FD-013 and FD-014,
  plus the evidence-availability portion of FD-016;
- `reconciliation/reconciled-finding-register.yml` — RF-012, RF-013,
  RF-017, RF-022, RF-027, and RF-029;
- `reconciliation/proof-obligations.yml` — PO-FD-013 with
  PG-07-EVIDENCE-CAPACITY and PO-FD-014 with PG-07-SIGNED-EVIDENCE;
- `reconciliation/unresolved-evidence.yml` — UE-008;
- `reconciliation/remaining-operator-decisions.yml` — ROD-001; and
- `reconciliation/safe-intermediate-states.md` and
  `reconciliation/preserve-modify-add-retire.md` — safe-state and retirement
  boundaries.

## Current Repository Facts Used

The packet treats these as statically inspected starting facts, not proof of
the target:

- `.octon/framework/engine/runtime/spec/evidence-store-v1.md` already defines
  honest completeness and hash-match behavior, but no producer signatures or
  monotonic anti-rollback head;
- `.octon/framework/constitution/contracts/runtime/checkpoint-v2.schema.json`
  defines checkpoints without the required cryptographic signature/head
  envelope;
- `.octon/framework/constitution/contracts/retention/**` provides retention,
  classification, disclosure, and publishability contracts whose bounds and
  compaction semantics must become executable;
- `.octon/framework/engine/runtime/crates/runtime_bus/**` and
  `.octon/framework/engine/runtime/crates/replay_store/**` show current journal
  and replay concepts, but RP-03 owns their convergence into one transaction
  model; and
- existing evidence localization/retention validators provide reusable
  boundaries but do not prove FD-013/FD-014 or UE-008.

## Fixed Reconciled Boundaries

- broker and verifier sign their own direct observations;
- range and terminal checkpoints are signed;
- the latest accepted head is monotonic and candidate-inaccessible;
- logical capacity is reserved with operation admission and backed by real
  physical terminal headroom;
- evidence is bounded by quotas/pins and compacted only after verified signed
  checkpoint plus anchor commit;
- raw payloads stay local/outside project Git by default;
- minimal signed checkpoints/pointers may be retained in Git but Git is never
  the signature mechanism;
- there is no standalone capacity lease or unsigned fallback; and
- missing evidence blocks the dependent transition and preserves work.

## Open Design-Exit Judgment

ROD-001 is operator-accepted: raw evidence remains bounded/local/outside project
Git; longer-lived signed receipts, checkpoints, and rollback references are
retained; terminal reserve and no unsigned fallback remain mandatory; and
unavailable recovery evidence denies the dependent transition while preserving
work. Engineering selects the signer
algorithm/provider, candidate-inaccessible monotonic-anchor mechanism, reserve
implementation, and provisional values using conservative reversible defaults
and mechanism-specific proof. The recommended initial engineering posture is
separate platform Keychain identities, a candidate-inaccessible local head,
bounded local raw evidence, preallocated terminal headroom, and signed Git-
retained checkpoints/pointers without raw payloads. This narrowed judgment does
not reopen the fixed boundaries above and does not block proposal-program
creation. Binding the invariants and proving/tuning engineering defaults still
blocks RP-07 implementation readiness and design exit; no operator disposition
remains.

## Named Predecessor Use

The named Revision 2 architecture proposal is consulted only for compatible
lineage/detail. It is not modified, accepted, rejected, superseded, archived,
or treated as a child of this program by RP-07. The reconciliation controls
packet detail when predecessor wording differs, but it cannot override or reopen
accepted intake intent without the permitted new evidence.

## Evidence Classification

- reconciliation content: retained planning/evaluation evidence,
  non-authoritative;
- current repository claims: `STATICALLY_INSPECTED`;
- target design: architectural inference constrained by accepted decisions;
- signature, rollback, capacity, retention, and compaction claims:
  unproven until `DYNAMICALLY_EXECUTED`/`ADVERSARIALLY_TESTED` evidence closes
  PO-FD-013, PO-FD-014, and UE-008.

## Excluded Inputs

Unrelated review packages, chat state, generated summaries, host UI state,
provider dashboards, and unscoped ideation are not semantic inputs. No raw
proposal path becomes a runtime or policy dependency after promotion.
