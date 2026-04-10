# 02. Current-state constitutional baseline

## 2.1 Precedence model used by this packet

This packet follows the precedence rule requested in the prompt:

1. **Current live repository implementation** is the source of truth for what exists.
2. **The current audit** is the authoritative retained audit description of findings.
3. **The packet-contained full implementation audit** is a confirmatory interpretive source for present-state honesty and remediation priorities, but does not override authored authority or retained evidence.
4. **Current disclosure artifacts and residual ledger** are authoritative for what is currently claimed, bounded, retained, or deferred.
5. **This packet** defines the target state and remediation path.

## 2.2 Current super-root authority model

The repository’s current `/.octon/README.md` is explicit:

- `framework/**` and `instance/**` are the only authored authority surfaces;
- `inputs/**` is non-authoritative additive/exploratory material only;
- `state/**` is operational truth and retained evidence;
- `generated/**` is rebuildable output only.

This is the correct constitutional base and should be preserved, not replaced.

## 2.3 Current constitutional kernel and family model

The constitutional registry declares the kernel, active contract families, and retained shims. The active families are currently organized around:

- objective
- authority
- runtime
- assurance
- disclosure
- adapters
- retention

The contract family model is already mature enough to support bounded closure; the problem is no longer “missing families,” but rather **cross-family normalization, review freshness, and claim calibration**.

## 2.4 Current bounded claim posture

The current live claim is expressed across at least five aligned artifacts:

- `/.octon/instance/governance/disclosure/harness-card.yml`
- `/.octon/instance/governance/closure/unified-execution-constitution.yml`
- `/.octon/framework/constitution/claim-truth-conditions.yml`
- `/.octon/generated/effective/closure/claim-status.yml`
- `/.octon/instance/governance/disclosure/release-lineage.yml`

Across these surfaces, the live prose claim is bounded to the **admitted live support universe** and explicitly disclaims universal support outside active tuples.

## 2.5 Current admitted live support universe

The live support-target declaration currently admits a six-tuple finite universe spanning:

- model classes: `repo-local-governed`, `frontier-governed`
- workload classes: `observe-and-read`, `repo-consequential`, `boundary-sensitive`
- context classes: `reference-owned`, `extended-governed`
- locales: `english-primary`, `spanish-secondary`
- host adapters: `repo-shell`, `github-control-plane`, `ci-control-plane`, `studio-control-plane`
- capability packs: `repo`, `git`, `shell`, `telemetry`, `browser`, `api`

The coverage ledger and support dossiers align to that admitted set.

## 2.6 Current closure posture

The active closure bundle marks:

- `claim_status: complete`
- `preclaim_blockers_open: 0`
- gates `G0`–`G16` green
- claim-critical residual items `CC-01`–`CC-05` closed
- six non-critical hardening items retained with rationale

## 2.7 Current latest explicit audit bundle

The latest explicit audit bundle retained under `state/evidence/validation/audits/**` is:

- `2026-03-08-orchestration-domain-design-package-audit`

That audit bundle contains three findings:

- `ODP-AUD-001` — decision evidence continuity mismatch
- `ODP-AUD-002` — incident governance mismatch
- `ODP-AUD-003` — machine-readable validation proof gap

The live April constitutional state appears to have resolved or materially reduced those findings, but the resolution is not explicitly encoded back into a current audit crosswalk.

This packet also includes `12_FULL_IMPLEMENTATION_AUDIT_2026-04-09.md`, which is not a live authority artifact but is a packet-contained full implementation audit of the April 9, 2026 repository state. Its key verdict is that the current bounded claim is materially honest and supportable, while the remaining debt sits in normalization, evidence-depth asymmetry, evaluator breadth, and projection-heavy workflow coupling rather than in missing constitutional foundations.

## 2.8 Current repository mismatches and debt

### 2.8.1 Mismatch A — review lineage freshness defect
The current closeout review set and ablation review still point to the 2026-04-06 build-to-delete packet as the latest active review packet. That packet’s support-target and adapter review summaries describe a narrower support envelope (“two repo-shell tuples”; “repo-shell only” / “repo-local-governed only”) than the currently admitted six-tuple live support universe.

This is a **real repository mismatch** between live support scope and review-lineage freshness.

### 2.8.2 Mismatch B — active wording still carries overbroad machine enums
Artifacts such as:

- `support-targets.yml` (`support_claim_mode: global-complete-finite`)
- `closure-summary.yml` (`support_universe_mode: global-complete-finite`)
- `release-lineage.yml` (`claim_scope: global-complete-finite`)
- `claim-status.yml` (`support_universe_mode: global-complete-finite`)

still use machine wording that overstates what the prose claim actually says.

### 2.8.3 Mismatch C — current audit bundle is not explicitly reconciled with active closure artifacts
The audit bundle remains the latest explicit audit evidence under `state/evidence/validation/audits/**`, yet there is no current machine-readable artifact that says:

- which audit findings are now closed by live implementation,
- which were superseded by design changes,
- which remain relevant as future widening obligations.

### 2.8.4 Mismatch D — authority and non-authority clarity is correct but distributed
Current non-authority rules are spread across:

- `/.octon/README.md`
- constitutional registry and family READMEs
- `retirement-register.yml`
- adapter review / drift review / retirement review receipts
- ingress adapter parity conventions

This is good enough for humans, but not yet ideal for a strong machine-verifiable closure posture.

### 2.8.5 Mismatch E — agency/ingress semantics are improved but still more interpretive than necessary
The canonical ingress file already distinguishes mandatory read order from optional orientation material. But it still references optional overlays in prose rather than through a strongly machine-readable ingress manifest. That leaves interpretive room around what is required vs merely available.

### 2.8.6 Mismatch F — family version declarations and live artifact versions are not yet fully aligned
The packet-contained full implementation audit confirms that objective, runtime, and disclosure family READMEs still retain stale canonical-active version references even though live artifacts now use newer versions such as `run-contract-v3`, `stage-attempt-v2`, `run-card-v2`, and `harness-card-v2`.

This is a real version-coherence and discoverability defect. It does not presently falsify the bounded claim, but it keeps the constitutional documentation layer less exact than the target-state bar requires.

### 2.8.7 Mismatch G — workflow-hosted evaluator and approval flows are still thicker than ideal
The current repo correctly treats GitHub workflows and similar host surfaces as non-authoritative projections, and the active closure bundle reports host-authority purity as green. But the full implementation audit also shows that some approval and evaluator paths remain visibly hosted in workflow shells rather than being reduced to thin orchestration wrappers over canonically defined repo-local logic.

This is not a claim-breaker for the current bounded release. It is hardening debt that matters for portability, interpretability, and future widening readiness.

## 2.9 Current-state conclusion

Octon’s present state is **much stronger than a typical “demo harness”** and, as confirmed by the packet-contained full implementation audit, strong enough to support a truthful bounded attainment claim today.

But it is **not yet the strongest fully hardened bounded target state** because:

- active machine wording still overstates boundedness,
- review-lineage freshness lags the current support envelope,
- audit-to-live closure traceability is missing,
- permanent non-authority surfaces are not inventoried in one place,
- contract-family version declarations still lag live artifact usage,
- workflow-hosted approval and evaluator paths remain thicker than ideal,
- and the retained hardening items are still open.
