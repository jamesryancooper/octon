# Contract Alignment Matrix

Baseline: repo inspection on 2026-03-24.

## Problem
The effective proposal contract is currently split across human standards, scaffolding templates, JSON schemas, and shell validators. Several of those layers disagree. This proposal chooses one promoted contract per surface and removes drift without redesigning the model.

## Chosen Rule
Where current surfaces disagree, the promoted contract follows the live template plus validator plus active-manifest combination, then updates the standards and schemas to match that contract.

## Alignment Table
| Surface | Current evidence | Drift | Promoted contract | Exact change |
| --- | --- | --- | --- | --- |
| Base archive disposition | `proposal-standard.md`, `validate-proposal-standard.sh`, and the registry schema allow `superseded`; `proposal.schema.json` omits it | Base schema rejects a disposition the rest of the system already uses | `archive.disposition` remains `implemented`, `rejected`, `historical`, `superseded` | Update `proposal.schema.json` to include `superseded`; keep validator and registry schema aligned |
| Architecture subtype | Template and validator use `architecture_scope` plus `decision_type`; the live `migration-rollout` manifest uses the same; `architecture-proposal.schema.json` requires `architecture_kind` | Schema conflicts with the live manifest contract | `architecture-proposal.yml` requires `schema_version`, `architecture_scope`, and `decision_type` | Replace `architecture_kind` schema with the live two-field contract |
| Migration subtype | Template and validator use `change_profile` plus `release_state`; `migration-proposal.schema.json` requires `validation.plan_template_path` instead of `release_state` | Schema conflicts with the template and validator contract | `migration-proposal.yml` requires `schema_version`, `change_profile`, and `release_state` | Update the migration schema to match the validator and template; move any plan-template hint out of the required schema |
| Policy subtype | Template and validator use `policy_area` plus `change_type`; `policy-proposal.schema.json` requires `policy_kind` | Schema conflicts with the template and validator contract | `policy-proposal.yml` requires `schema_version`, `policy_area`, and `change_type` | Update the policy schema to match the validator and template |
| Design subtype | No high-confidence contract drift was singled out in this pass | No justified change | Preserve the current design subtype contract | Defer design-subtype changes unless new evidence requires them |
| Registry contract | The registry is a projection and creation flows update it, but current validation is primarily package-to-registry rather than registry-to-package | Reverse drift can survive | Registry becomes a deterministically rebuilt projection from manifests with fail-closed consistency checks | Add a rebuild path and reverse validation; remove reliance on manual registry edits |
| Navigation inventory | `navigation/artifact-catalog.md` is required and hand-authored | Inventory is derivable and can drift without adding authority | Artifact catalog becomes generated inventory; semantic boundary work stays manual in `navigation/source-of-truth-map.md` | Keep the file for v1 compatibility inside this proposal; promote generator and template changes |

## Deferred
- No new proposal kinds
- No new active lifecycle statuses
- No stronger proposal dependency graph beyond `related_proposals`
