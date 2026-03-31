# File-Level Remediation Specification

## Exact file-by-file changes

| Path | Current problem | Atomic remediation | Validator/workflow consequence |
|---|---|---|---|
| `/.octon/framework/constitution/contracts/objective/family.yml` | phase receipt still looks live | point live selector at March 30 receipt; move phase receipt to explicit lineage field | covered by constitutional-family-live-model validator |
| `/.octon/framework/constitution/contracts/authority/family.yml` | phase receipt still looks live | point live selector at March 30 receipt; move phase receipt to explicit lineage field | covered by constitutional-family-live-model validator |
| `/.octon/framework/constitution/contracts/runtime/family.yml` | phase receipt still looks live | point live selector at March 30 receipt; move phase receipt to explicit lineage field | covered by constitutional-family-live-model validator |
| `/.octon/framework/constitution/contracts/assurance/family.yml` | phase receipt still looks live | point live selector at March 30 receipt; move phase receipt to explicit lineage field | covered by constitutional-family-live-model validator |
| `/.octon/framework/constitution/contracts/retention/family.yml` | phase receipt still looks live | point live selector at March 30 receipt; move phase receipt to explicit lineage field | covered by constitutional-family-live-model validator |
| `/.octon/framework/constitution/contracts/disclosure/family.yml` | already fixed at HEAD but vulnerable to regression | preserve current semantics; optionally add explicit historical-only comment/field for lab mirrors if helpful | covered by disclosure-live-root validator |
| `/.octon/instance/bootstrap/START.md` | raw additive inputs listed as instance-native authority | remove from authority list; add raw-input/publication-chain wording | covered by bootstrap-authority-surface validator |
| `/.octon/instance/governance/support-targets.yml` | declaration outruns retained proof | demote all unproved live envelopes or publish proof in same change | covered by support-target-live-claim validator |
| `/.octon/instance/governance/disclosure/harness-card.yml` | claim summary is broader than proved envelope | narrow summary and known-limits wording to current proved live envelope | compared against release HarnessCard and proof bundle |
| `/.octon/state/evidence/disclosure/releases/2026-03-30-unified-execution-constitution-atomic-cutover/harness-card.yml` | retained release card mirrors broad claim | update to match authored narrowed claim exactly | publication gate checks parity with authored source |
| `/.octon/framework/constitution/CHARTER.md` | portability/support framing is broader than current proof | rewrite to distinguish architectural portability intent from proved live support | covered by manual review + wording check |
| `/.octon/instance/charter/workspace.md` | success language can be overread as broader live support | rewrite to support-target-bounded portability wording | covered by manual review + wording check |
| `/.octon/README.md` | broad architectural framing lacks proof-bounded qualifier | add explicit statement that live support claims are support-target/disclosure bounded | covered by manual review + wording check |
| `/.octon/framework/cognition/governance/principles/principles.md` | placeholder owner + broad live framing | replace owner with `octon-maintainers`; narrow live support wording | covered by placeholder-owner validator |
| `/.octon/framework/cognition/governance/exceptions/principles-charter-overrides.md` | placeholder `responsible_owner` values | replace placeholder owner identifiers with `octon-maintainers` | covered by placeholder-owner validator |
| `/.octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh` | current alignment profile does not necessarily check these drift classes | invoke new family, bootstrap, support-claim, disclosure-root, and placeholder-owner validators | becomes the normal developer/CI entrypoint |
| `/.octon/framework/assurance/runtime/_ops/scripts/assurance-gate.sh` | publication can succeed without these drift classes being checked | make publication fail closed on new validator failures | prevents silent re-publication of drift |

## New validator scripts proposed under the existing assurance runtime surface

The exact filenames may be adjusted, but the packet assumes new checks under:

- `/.octon/framework/assurance/runtime/_ops/scripts/validate-constitutional-family-live-model.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-bootstrap-authority-surfaces.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-support-target-live-claims.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-disclosure-live-roots.sh`
- `/.octon/framework/assurance/runtime/_ops/scripts/validate-subordinate-owner-identifiers.sh`

## Out-of-scope repo-local exact files

These are intentionally **not** promotion targets of this octon-internal packet:

- `/README.md`
- `/CODEOWNERS`

They remain follow-on items only.
