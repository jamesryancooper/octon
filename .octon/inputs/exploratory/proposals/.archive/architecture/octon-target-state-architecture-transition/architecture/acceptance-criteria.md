# Acceptance Criteria

The target-state transition is accepted only when all criteria pass.

## Authority and boundary criteria

- [ ] `.octon/` remains the only super-root.
- [ ] No new top-level root or rival control plane is introduced.
- [ ] Authored authority remains limited to `framework/**` and `instance/**`.
- [ ] Generated outputs remain derived-only and cannot mint authority.
- [ ] `inputs/**` remains non-authoritative and excluded from direct runtime/policy dependency.
- [ ] Host UI state, labels, comments, checks, and chat transcripts remain projections only.

## Identifier hygiene criteria

- [ ] All fail-closed obligation IDs are globally unique and stable.
- [ ] All evidence obligation IDs are globally unique and stable.
- [ ] Reason-code mappings are deterministic and validator-covered.

## Runtime enforcement criteria

- [ ] Material side-effect inventory exists and is validator-covered.
- [ ] Authorization coverage map exists and covers every material runtime command/service/workflow/publication path.
- [ ] Every material side-effect path has a request builder and authorization call site or documented fail-closed exception.
- [ ] Negative-control tests prove unmediated side effects fail closed.
- [ ] Runtime-generated/effective consumption fails closed without publication receipts and freshness artifacts.

## Runtime maintainability criteria

- [ ] Kernel command handling is modularized by command family.
- [ ] Authorization request construction is centralized in request builders.
- [ ] Authority engine emits phase-level results.
- [ ] Phase-level tests pass for allow, deny, stage-only, approval, exception, revocation, support, rollback, budget, and egress cases.

## Proof-plane criteria

- [ ] Consequential run closeout retains evidence completeness receipts.
- [ ] RunCard, HarnessCard, and SupportCard projections derive only from retained evidence and durable authority.
- [ ] Support tuple proof bundles include positive, negative-control, recovery, and replay evidence.
- [ ] Support dossiers meet raised sufficiency thresholds before live claims are cited.

## Registry and documentation criteria

- [ ] Registry metadata identifies coverage maps, generated maps, publication/freshness rules, and compatibility retirement metadata.
- [ ] Active docs are slim, steady-state, and free of historical wave/proposal lineage as operating contract.
- [ ] Generated architecture/navigation maps exist and are clearly marked non-authoritative.

## Transitional retirement criteria

- [ ] Every compatibility projection has owner, consumer, canonical replacement, expiry/review date, and retirement evidence.
- [ ] No validator/runtime consumer depends on undocumented compatibility projection.
- [ ] Retired shims are removed only after no active dependency remains.

## Closure criteria

- [ ] Full validation plan passes.
- [ ] Promotion evidence is retained.
- [ ] ADR `101-target-state-architecture-transition.md` exists.
- [ ] Durable targets stand without proposal-path dependency.
- [ ] This proposal is archived only after promotion outputs are independently durable.
