# Integration Strategy, Surface Disposition Matrix, and Impact Map

## Integration Strategy

The suite integrates as the **method layer inside the existing Architectural
Review Mechanism**. Concretely:

1. `naming.yml` moves from a single `method:` key to a `methods:` list
   (schema `architectural-review-naming-v2`) with Balanced marked default.
   This is the one structural refactor in the program: the current shape
   encodes a single-method assumption that is now a mismatch.
2. `review-routing.yml` keeps its routes as review occasions and gains a
   `method_selection` block (schema `architectural-review-routing-v2`):
   default method, per-route allowed methods, method escalation map, and
   fail-closed `unknown_method` / `missing_method_record` conditions.
3. Method docs and the lens bank land as sibling methodology docs in the
   existing directory; no new mechanism, no new methodology directory tree.
4. Report and routing-decision schemas gain additive `method` and
   `lenses_applied` fields (v2 alongside v1 per existing contract-versioning
   practice); the support receipt schema is untouched — the pre-integration
   gate is unchanged.
5. Existing review workflow contracts record the selected method in run
   evidence; they gain no new steps, gates, or evidence roots.
6. Readiness and surface-architecture doctrine are composed with via the
   boundary statements in `method-taxonomy.md`; neither file changes.

## Surface Disposition Matrix

Classifications: **remain unchanged** / **extend** / **refactor or replace**
/ **proposal-only for now**.

| Surface | Disposition | Owning child | Notes |
| --- | --- | --- | --- |
| `methodology/architectural-review/balanced-architecture-review-method.md` | extend (minimal) | taxonomy-and-routing | Add lens-id cross-references and suite escalation pointers; required sequence and output contract unchanged. |
| `methodology/architectural-review/README.md` | extend | taxonomy-and-routing | Canonical-names table gains the five method rows and the lens bank; method-layer section added. |
| `methodology/architectural-review/review-routing.yml` | extend (schema v2) | taxonomy-and-routing | Additive `method_selection` block + new fail-closed conditions; routes themselves unchanged. |
| `methodology/architectural-review/naming.yml` | refactor | taxonomy-and-routing | `method:` singular → `methods:` list, schema v2; single-method assumption is a structural mismatch. Slugs, modes, aliases otherwise preserved. |
| New method docs (5) + `architecture-lens-bank.md` + `lens-bank.yml` | extend (new files) | lens-bank-foundation; greenfield-method; companion-methods | All inside the existing methodology directory. |
| `methodology/architecture-readiness/README.md` + `framework.md` | remain unchanged | — | Readiness owns its verdicts and failure-mode assessment; suite cites, never edits. |
| `methodology/audits/surface-architecture.md` | remain unchanged | — | Owns single-unit authority classification; Boundary/Authority Review escalates to it. |
| Schemas `architectural-review-report-v1` / `-routing-decision-v1` (constitution/contracts/assurance/) | extend (v2 additive) | schema-extensions | Add `method`, `lenses_applied`; v1 retained per contract-versioning practice. |
| Schema `architectural-review-support-receipt-v1` | remain unchanged | — | Pre-integration gate semantics untouched. |
| Workflow contracts (pre/post-integration, current-state-mechanism, readiness audit) | extend (minimal) | suite-integration | Record selected method id in run evidence; no new steps, gates, or evidence roots. |
| Validators `validate-architectural-review-naming/-routing/-receipts.sh` + fixtures | extend | taxonomy-and-routing; schema-extensions | v2 awareness + negative controls (unknown method, undefined lens id, method without profile). |
| New lens-reference validator | extend (new) | lens-bank-foundation | Methods reference only defined lens ids; every method has a profile. |
| Command/skill facades (`.claude/commands/`, `.claude/skills/`, `validate-architectural-review-skills-commands.sh`) | proposal-only for now | command-facades (conditional) | No facades in wave one; conditional child, default no-action. |
| Product feature note `product/features/architectural-review-mechanism.md` | extend | suite-integration | Navigation-only suite section; authorizes nothing. |
| Governed mechanism detail (`cognition/_meta/architecture/governed-cross-surface-mechanisms/`) | extend | suite-integration | Mechanism entry notes the method layer. |
| Generated projections (proposal registry, capability/host projections, published methodology/feature projections) | extend (derived-only) | suite-integration | Refreshed only through canonical publication scripts after children land. |
| Proposal lifecycle integration (pre-integration gate, lifecycle prompts) | extend (advisory only) | suite-integration | Lifecycle prompts may recommend a method for a review occasion; gates unchanged. |
| Boundary/Authority generic (adopted-repo) mode | proposal-only for now | — | Deferred with owner and trigger recorded at program closeout. |

## Proposed File/Path Layout (implementation-time, child-owned)

```
.octon/framework/cognition/practices/methodology/architectural-review/
  README.md                                    (extended)
  balanced-architecture-review-method.md       (extended, minimal)
  greenfield-reference-architecture-review.md  (new)
  architecture-tradeoff-review.md              (new)
  failure-mode-architecture-review.md          (new)
  evolution-fitness-architecture-review.md     (new)
  boundary-authority-architecture-review.md    (new)
  architecture-lens-bank.md                    (new)
  lens-bank.yml                                (new)
  naming.yml                                   (refactored, v2)
  review-routing.yml                           (extended, v2)
.octon/framework/constitution/contracts/assurance/
  architectural-review-report-v2.schema.json           (new, additive)
  architectural-review-routing-decision-v2.schema.json (new, additive)
.octon/framework/assurance/runtime/_ops/scripts/
  validate-architectural-review-naming.sh      (extended)
  validate-architectural-review-routing.sh     (extended)
  validate-architectural-review-receipts.sh    (extended)
  validate-architectural-review-lens-bank.sh   (new)
  (+ fixtures / negative controls per validator convention)
.octon/framework/orchestration/runtime/workflows/audit/
  pre-integration-architecture-review/         (extended: method recording)
  post-integration-architecture-review/        (extended: method recording)
  current-state-mechanism-architecture-review/ (extended: method recording)
  architecture-readiness-audit/                (extended: method recording)
.octon/framework/product/features/
  architectural-review-mechanism.md            (extended)
```

Exact filenames inside workflow directories and fixture paths are finalized
by the owning children against the live repository at child creation.

## Impact Map (by concern)

| Concern | Impact | Where decided |
| --- | --- | --- |
| Methodology docs | +7 files, 2 extended | taxonomy in `method-taxonomy.md`; contracts owned by children |
| Routing | additive method-selection semantics, fail-closed on unknown method | `method-taxonomy.md` common rules; taxonomy child |
| Naming | schema v2, methods list, no slug changes, no retired names | taxonomy child |
| Workflows | method-id recording only | suite-integration child |
| Schemas | report/routing-decision v2 additive; support receipt unchanged | schema-extensions child |
| Validators | 3 extended + 1 new, with negative controls | lens-bank + taxonomy + schema children |
| Generated projections | derived-only refresh via canonical publishers | suite-integration child |
| Product feature catalog | navigation-only extension | suite-integration child |
| Proposal lifecycle | advisory method recommendations; gates unchanged | suite-integration child |
| Commands/skills | none in wave one; conditional child | command-facades child |
