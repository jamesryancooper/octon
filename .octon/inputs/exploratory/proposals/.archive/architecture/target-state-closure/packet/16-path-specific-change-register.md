# 16. Path-Specific Change Register

This register lists the decisive repository changes required to close the audited blockers.

| ID | Current path(s) | Target path(s) | Decision | Why | Enforcement | Migration | Cutover | Acceptance | Risk if postponed |
|---|---|---|---|---|---|---|---|---|---|
| 01 | `.octon/framework/constitution/**` | same | preserve | already correct kernel | constitution validator | none | none | kernel remains supreme | low |
| 02 | `.octon/framework/cognition/_meta/architecture/specification.md` + distributed constitutional prose | shims to `framework/constitution/**` | re-bound | remove parallel constitutional authority | no-conflicting-constitution validator | replace content with redirects/reference sections | safe before cutover | one kernel, no active parallel constitutional sources | medium |
| 03 | `.octon/instance/ingress/AGENTS.md` | same path, slimmed | harden/simplify | ingress should dispatch, not re-author constitution | ingress validator | edit in place | required pre-cutover | ingress references charter, workspace, continuity only | medium |
| 04 | `instance/governance/disclosure/harness-card.yml` | generated mirror of active release bundle | re-bound | claim-bearing surface cannot be authored | generated-only + parity validators | convert file ownership to generator | at cutover | byte-equal to active release HarnessCard | critical |
| 05 | `instance/governance/closure/*.yml` | generated mirrors of release closure bundle | re-bound | eliminate optimistic authored status | generated-only + parity validators | convert or replace | at cutover | no hand-edited green status possible | critical |
| 06 | `state/evidence/disclosure/releases/<release-id>/` | same + full closure bundle | harden | canonical live claim-bearing root | freshness + certification validators | expand artifact set | at cutover | full release bundle exists | high |
| 07 | `objective/run-contract-v1` + `runtime/run-contract-v2` | `runtime/run-contract-v3` | normalize | end split lineage | single-family validator | add v3, mark v1/v2 shims | pre-cutover required | all live bindings point to v3 | critical |
| 08 | mission artifacts only in instance missions | add constitutional `mission-charter-v1` schema | normalize | mission authority needs contract normalization | mission-charter validator | add schema, rebind mission files | pre-cutover | every live mission validates against schema | high |
| 09 | quorum in `mission-autonomy.yml` | `authority/quorum-policy-v1` + instance declaration | normalize | quorum must be first-class | quorum binding validator | add contract and refs | pre-cutover | approvals reference standalone quorum | high |
| 10 | `state/control/execution/exceptions/leases.yml` | `.../exceptions/leases/<lease-id>.yml` + generated index | normalize | per-artifact lifecycle clearer and safer | lease validator | migrate entries + optional index | pre-cutover | no active lease exists only in set-file form | medium |
| 11 | `state/control/execution/revocations/grants.yml` | `.../revocations/grants/<revocation-id>.yml` + generated index | normalize | same as leases | revocation validator | migrate entries + optional index | pre-cutover | no active revocation exists only in set-file form | medium |
| 12 | no explicit host projection evidence root | `state/evidence/control/host-projections/**` | add | separate host signals from authority | host projection validator | add generator from host adapters | pre-cutover | host inputs auditable, non-authoritative | medium |
| 13 | exemplar `evidence-classification.yml` empty | same path, v2 populated | harden/normalize | current closure invalidator | non-empty validator | backfill and regenerate | pre-cutover | every active exemplar non-empty | critical |
| 14 | measurement summaries with superseded wording | regenerated summaries from records | harden | stale claim wording invalidates closure | wording coherence validator | regenerate from records | pre-cutover | no stale wording in active artifacts | critical |
| 15 | run decision / manifest / card mismatch | no path change; enforce parity across existing roots | harden | closure depends on tuple/route consistency | cross-artifact validators | backfill or regenerate inconsistent artifacts | pre-cutover | active exemplar bundles agree everywhere | critical |
| 16 | `framework/lab/**` with light hidden/adversarial specificity | add `scenarios/hidden-checks/**`, `scenarios/adversarial/**`, `probes/evaluator-independence/**` | harden | lab must support closure-grade proof | lab coverage validators | add subdomains and scenario contracts | can stage before cutover | hidden + adversarial coverage declared and evidenced | high |
| 17 | AI review workflow still partly host-shaped | keep workflow, re-bind as evaluator adapter | re-bound | preserve utility, remove authority leakage | host non-authority + evaluator validators | change outputs to projection receipts and evaluator reports | pre-cutover | ai-review no longer defines authority or support state | medium |
| 18 | `framework/agency/runtime/agents/architect/**` and `SOUL.md` | legacy/archive or overlay-only | simplify/delete | no active persona-heavy kernel path | no-legacy-active-path validator | retain shims temporarily | after cutover if needed | no active execution references legacy paths | high |
| 19 | `framework/agency/manifest.yml` | same | preserve | orchestrator-centric default is correct | manifest validator | no move | none | orchestrator remains default accountable role | low |
| 20 | no support dossiers | `instance/governance/support-dossiers/<tuple-id>/dossier.yml` | add | matrix needs evidential admission backing | support dossier validator | create dossiers for all live tuples | pre-cutover | no live tuple lacks dossier | high |
| 21 | browser/API packs present but bounded | same roots | preserve/harden | support expansion should remain explicit | unsupported-case validator | no widening during closure | none | unsupported packs remain denied or stage_only | low |
| 22 | no retirement registry | `instance/governance/retirement/registry.yml` | add | build-to-delete must be institutionalized | retirement validator | create registry and populate transitional surfaces | can stage before cutover | every transitional surface tracked | medium |
| 23 | no ablation receipt root | `state/evidence/validation/publication/build-to-delete/ablation-receipts/**` | add | deletions need evidence | ablation validator | create root and first receipts | can stage before cutover | at least one active transitional surface has ablation plan | medium |
| 24 | drift reports implicit only | `state/evidence/validation/publication/drift/**` | add | closure should fail on unresolved drift | drift validator | create generated reports | pre-cutover helpful; required by final certification | drift visible and acted on | medium |
| 25 | no dedicated closure certification workflow | `.github/workflows/closure-certification.yml` | add | live claim promotion must be controlled and repeatable | workflow gates G0-G13 | create workflow | required for cutover | no release promotion without certification | critical |
| 26 | architecture-conformance lacks full closure validators | extend existing workflow | harden | preserve strong structural gate and add closure-critical checks | updated CI jobs | modify in place | pre-cutover | closure-critical validators run on PRs | high |
| 27 | no explicit generated-only claim-surface guard | same paths as active mirrors | harden | prevent manual optimism | claim-surface-generated-only validator | add git diff checks | pre-cutover | claim-bearing mirrors cannot be edited directly | critical |
| 28 | no release-bundle manifest contract | add disclosure manifest schema + artifact | add | freshness and regeneration need provenance | freshness validator | generator emits manifest | pre-cutover | every certified release bundle has manifest | high |
| 29 | no final closure certificate contract | add closure certificate schema + artifact | add | certification needs a canonical output | certification validator | generator emits after dual-pass | cutover | active release has certificate | high |
| 30 | no projection parity report artifact | add report under release closure bundle | add | stable mirrors must prove parity | parity validator | generator emits | cutover | projection parity proven for active release | high |

## Reading the register

- **preserve** = keep as is, only revalidate
- **harden** = keep path/surface but tighten enforcement
- **normalize** = keep concept, unify schema or lifecycle
- **re-bound** = keep surface but change what is canonical vs projected
- **simplify** = reduce complexity while preserving value
- **delete** = remove from active path or entirely
- **postpone** = not required for closure-valid admitted claim
