# Change Map

| Current path / surface | Target-state change | Change mode | Notes |
|---|---|---|---|
| `/.octon/framework/constitution/contracts/objective/family.yml` | Align live receipt semantics to the March 30 atomic cutover and preserve March 28 phase receipt as lineage only | re-bind | Same fix pattern applies to every active family that still points at a phase receipt |
| `/.octon/framework/constitution/contracts/authority/family.yml` | Align live receipt semantics to the March 30 atomic cutover and preserve March 28 phase receipt as lineage only | re-bind | Removes ambiguity between phase activation and current live model |
| `/.octon/framework/constitution/contracts/runtime/family.yml` | Align live receipt semantics to the March 30 atomic cutover and preserve March 29 phase receipt as lineage only | re-bind | Runtime family must not appear to define a different live model |
| `/.octon/framework/constitution/contracts/assurance/family.yml` | Align live receipt semantics to the March 30 atomic cutover and preserve March 29 phase receipt as lineage only | re-bind | Assurance family should follow the same live-model selector as the charter |
| `/.octon/framework/constitution/contracts/retention/family.yml` | Align live receipt semantics to the March 30 atomic cutover and preserve March 29 phase receipt as lineage only | re-bind | Retention semantics must describe the same live model |
| `/.octon/framework/constitution/contracts/disclosure/family.yml` | Preserve current correct atomic disclosure roots and add explicit regression guards | preserve + harden | This issue is already fixed at HEAD; the proposal prevents reversal |
| `/.octon/instance/bootstrap/START.md` | Remove `inputs/additive/extensions/**` from any authored-authority list and restate it as raw additive input only | correct | This is the last high-signal authored-authority leak in orientation docs |
| `/.octon/instance/governance/support-targets.yml` | Narrow live support claims to proof-backed envelopes or demote unproven envelopes to experimental/stage-only | narrow | The packet defaults to demotion when proof is absent |
| `/.octon/instance/governance/disclosure/harness-card.yml` | Narrow the claim summary and known-limits text to the proved live envelope | narrow | The card must not imply broader portability or adapter coverage than retained proof |
| `/.octon/state/evidence/disclosure/releases/2026-03-30-unified-execution-constitution-atomic-cutover/harness-card.yml` | Retain a release card that mirrors the narrowed claim exactly | refresh | Retained release disclosure must match authored source |
| `/.octon/framework/constitution/CHARTER.md` | Narrow portability/self-containment framing to evidence-bounded language | narrow | Architectural intent may remain broad; live support claims may not |
| `/.octon/instance/charter/workspace.md` | Narrow success and portability language to the proved consequential envelope | narrow | Workspace charter must not imply more than durable proof backs |
| `/.octon/README.md` | Add explicit support-target-bounded portability language | narrow | Keep it accurate without behaving like a second control plane |
| `/.octon/framework/cognition/governance/principles/principles.md` | Replace placeholder owner with an ownership-registry-backed identifier and narrow broad portability claims | normalize | Subordinate governance must still be durable and reviewable |
| `/.octon/framework/cognition/governance/exceptions/principles-charter-overrides.md` | Replace placeholder `responsible_owner` values with an ownership-registry-backed identifier | normalize | Historical override ledger remains intact while identifiers stop being placeholders |
| `/.octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh` | Add family-receipt, bootstrap-authority, live-claim, and disclosure-root validators | harden | Existing harness alignment flow should fail closed on these regressions |
| `/.octon/framework/assurance/runtime/_ops/scripts/assurance-gate.sh` | Gate publication on the new validator receipts | harden | Publication must fail closed when claims outrun proof or docs widen authority |
