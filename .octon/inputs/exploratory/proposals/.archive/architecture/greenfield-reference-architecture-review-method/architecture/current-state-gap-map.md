# Current-State Gap Map

Verified against the live mechanism at
`.octon/framework/cognition/practices/methodology/architectural-review/` at HEAD.

## Current State

| Surface | Today | Source of truth |
| --- | --- | --- |
| Greenfield method name | Declared in `naming.yml` `methods.catalog` as `greenfield-reference-architecture-review-method` (role `companion`), with `lens_profile_ref` but **no `doc:` field** | `naming.yml` |
| Greenfield routing | Routable via `review-routing.yml` `method_selection` — in `allowed_methods_by_route` for pre-integration review, and the target of the Balanced escalation trigger `target-does-not-exist-yet` | `review-routing.yml` |
| Greenfield lens profile | `lens-bank.yml` `method_profiles.greenfield-reference-architecture-review-method` declares 14 required + 3 optional lens ids | `lens-bank.yml` |
| Greenfield method **doc** | **Does not exist.** No `greenfield-reference-architecture-review-method.md` in the mechanism directory; the method is named and routable but has no output contract | (absent) |
| Mechanism README | Canonical-names table already lists the Greenfield method row (phase-1); References section links Balanced but **not** a Greenfield doc | `README.md` |
| Balanced doc | `balanced-architecture-review-method.md` defines the default method; uses `clean-sheet-reference` as a comparison tool | `balanced-architecture-review-method.md` |

## Gap → Target Traceability

| # | Source claim / gap (method-taxonomy.md §2, greenfield charter) | Live gap | Target artifact / action | Acceptance ref |
| --- | --- | --- | --- | --- |
| G1 | Greenfield answers "if this system did not exist, what should we build first?" with a documented output contract | No method doc exists | Author `greenfield-reference-architecture-review-method.md` with question, use cases, required inputs, non-goals | AC-1 |
| G2 | Five required output sections | No sections documented | Author the five sections: domain/job model; reference architecture; quality/security/ops model; authority/evidence model; evolution plan | AC-2 |
| G3 | Initial-build sequencing, minimum viable architecture, what-not-to-build-yet | Not documented | Author the three build-discipline subsections | AC-3 |
| G4 | Output is reference architecture only; never implementation authority | Boundary not stated anywhere | State the reference-architecture-only output boundary fail-closed | AC-4 |
| G5 | Lenses come from the shared bank; no private catalog | Doc absent, so no lens binding | Cite `lens-bank.yml` greenfield profile lens ids verbatim (14 required + 3 optional) | AC-5 |
| G6 | Clean-sheet complementarity with Balanced; non-goals distinguishing it from Balanced and companions | Not stated | Author the clean-sheet complementarity statement and non-goals | AC-6 |
| G7 | Escalation rules (Tradeoff / Failure-Mode / Balanced or proposal drafting / Constitutional Challenge) | Not documented in a method doc | Author escalation rules citing `review-routing.yml` `method_selection.escalation_map` | AC-6 |
| G8 | Doc must be discoverable and wired into the catalog | `naming.yml` greenfield entry has no `doc:`; README has no doc link | Add additive `doc:` reference and README references link | AC-7 |
| G9 | No new authority; additive only; companion/Balanced doctrine untouched | Risk of scope creep into companion docs, schemas, or workflow | Keep changes additive; run full validator suite as no-regression proof | AC-8 |

## Re-Grounding Findings (verified at HEAD)

- **No blocking divergence between the parent design and the live mechanism.**
  The parent `method-taxonomy.md` prose used the non-suffixed slug
  `greenfield-reference-architecture-review-review` shape
  (`greenfield-reference-architecture-review`), but the phase-1
  `architecture-review-method-taxonomy-and-routing` child already fixed the
  canonical slug to `greenfield-reference-architecture-review-method` in the live
  `naming.yml`, and the phase-0 lens bank and program registry `child_id` agree.
  This child adopts the live canonical slug; the earlier prose divergence was
  already resolved by the phase-1 slug-reconciliation decision, so no new
  program registry/design revision is required here.
- **The lens profile is verified and stable.** `lens-bank.yml`
  `method_profiles.greenfield-reference-architecture-review-method` lists 14
  required lens ids (`system-job-framing`, `domain-model`,
  `clean-sheet-reference`, `quality-attribute-scenarios`, `failure-and-recovery`,
  `authority-boundary`, `validation-strategy`, `non-goals-deletion`,
  `security-threat-model`, `data-truth-lineage`, `contracts-compatibility`,
  `operability-observability-evidence`, `evolution-fitness`,
  `sequencing-mvp-migration`) and 3 optional (`current-reality-map`,
  `complexity-separation`, `tradeoff-adr`). The doc cites these exactly; the
  doc-consistency check enforces the match.
- **The method is already routable.** `review-routing.yml`
  `method_selection.allowed_methods_by_route.pre-integration-architecture-review`
  includes the greenfield slug, and
  `escalation_map.balanced-architecture-review-method` routes
  `target-does-not-exist-yet` to it. This child supplies the output contract for
  a method that routing already permits; it changes no routing.
- No other divergence was found. The mechanism README already carries the
  Greenfield canonical-names row (phase-1); only a References link is added here.
