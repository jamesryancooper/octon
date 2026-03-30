# Octon Unified Execution Constitution Cutover

This packet is the implementation-grade architecture proposal for taking Octon from its
current repository-grounded constitutional harness baseline to a **fully unified execution
constitution**.

It is optimized for:
- long-term architectural correctness
- the best target-state architecture needed for the cutover, even when it requires broad or non-minimal change
- governed autonomy
- run-first execution control
- long-running execution reliability
- replayability, auditability, and reproducibility
- strong proof and behavioral discovery
- portability where valuable and explicit non-portability where necessary
- simplification and deletion of obsolete scaffolding as models improve

## Packet kind
- proposal kind: `architecture`
- promotion scope: `octon-internal`
- current repo baseline: `0.6.8`
- recommended start release: `0.7.0`
- recommended claim release: `0.8.0`
- cutover style:
  - `staged`
  - `constitutional`
  - `run-first`
  - `repo-wide`
  - `pre-1.0`

## What this packet does
This packet:
1. defines the current repository-grounded baseline
2. defines the full target-state architecture
3. specifies the constitutional kernel Octon should become
4. provides a contract catalog and repository restructuring plan
5. provides a phased implementation and cutover program
6. defines the acceptance criteria required for a valid target-state claim
7. includes a repository-grounded audit of implemented progress against the packet

## What this packet does not do
This packet does **not**:
- optimize for the smallest or easiest migration
- preserve transitional structure purely to keep the diff smaller
- preserve host-native approval semantics as authority
- preserve persona-heavy kernel paths unless they provide real boundary value
- treat placeholder contracts, TODOs, or reserved roots as complete implementation
- treat this proposal as a canonical authority after promotion

## Implementation posture
When implementation choices differ between a smaller change and the
target-state-correct architecture, this packet chooses the target-state-correct
architecture. Transitional scaffolding should be preserved only when it serves a
real cutover, compatibility, or evidentiary need, not merely to keep the change
set smaller.

## Audit addendum
This packet now includes `resources/unified-execution-constitution-audit.md`, a
repository-grounded audit added after the original design materials.

Treat that audit as the current implementation-status verdict against this
packet. The baseline and gap-analysis resources remain useful as original
packet framing documents, but they do not replace the later audit.

## Reading order
1. `architecture/target-architecture.md`
2. `resources/unified-execution-constitution-audit.md`
3. `resources/repository-grounded-baseline.md`
4. `resources/current-state-to-target-gap-analysis.md`
5. `architecture/constitutional-kernel.md`
6. `architecture/repository-restructuring.md`
7. `architecture/contract-catalog.md`
8. `architecture/control-authority-model.md`
9. `architecture/runtime-evidence-model.md`
10. `architecture/verification-evaluation-lab-model.md`
11. `architecture/portability-adapters-support-targets.md`
12. `architecture/simplification-deletion-model.md`
13. `architecture/implementation-plan.md`
14. `architecture/acceptance-criteria.md`
15. `architecture/validation-plan.md`
16. `navigation/source-of-truth-map.md`
17. `navigation/change-map.md`
18. `architecture/cutover-checklist.md`

## Non-negotiable cutover rules
1. The class-root super-root remains intact.
2. The constitutional kernel becomes supreme repo-local authority.
3. Run contracts become mandatory for material execution.
4. Host adapters may project authority status but may not define authority.
5. Mission remains the continuity/ownership/autonomy container for long-horizon work; it is not the atomic execution primitive.
6. Structural and governance proof may not be weakened to make room for new planes.
7. Behavioral and recovery proof may not remain nominal or optional for supported tiers that claim them.
8. RunCard and HarnessCard become mandatory disclosure surfaces for supported execution and release claims.
9. Unsupported support-target combinations fail closed.
10. Every new compensating mechanism must carry a retirement trigger.
