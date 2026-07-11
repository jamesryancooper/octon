# Child Packet Contract

Every child of this program is an independent, manifest-governed proposal
packet at its canonical sibling path
`.octon/inputs/exploratory/proposals/architecture/<child-id>/`. Children are
never nested under this parent. The parent coordinates; it does not own.

## Obligations Every Child Must Meet

1. **Independent validity.** Each child passes
   `validate-proposal-standard.sh` and its subtype validator at its own path,
   with its own `proposal.yml`, subtype manifest, README, navigation docs,
   and required working docs.
2. **Own receipts.** Creation, review, implementation, verification, and
   closeout receipts are child-local. Parent program evidence, this contract,
   and the registry never satisfy a child receipt, promotion target,
   validation verdict, or archive metadata.
3. **Source grounding.** Each child cites the retained review evidence
   (`.../20260709-super-root-balanced-review/findings.yml`) for its findings
   and re-grounds every claim against the live repository before proposing
   changes.
4. **Validation floor.** Before implementation planning, each child defines:
   acceptance criteria, required evidence, required validator depth (with
   negative controls where the child touches enforcement), and rollback
   posture. Children touching the assurance plane
   (`continuity-coherence-validator`, `historical-runcard-support-audit`,
   `evidence-classification-v2-migration`) must define at least one negative
   control. Children touching only documentation/navigation
   (`runtime-spec-directory-index`) must define a doc-consistency check.
5. **Authority boundaries.** No child may create a second control plane,
   widen support claims, publish generated/effective outputs outside governed
   publication, treat evidence or read models as authority, or convert this
   program's coordination into authority. Durable changes land only under
   `framework/**`/`instance/**` through governed acceptance.
6. **Write-scope discipline.** Each child stays inside its registry-declared
   `write_scopes`; touching another child's scope requires a registry
   revision at the parent, not silent expansion.
7. **Terminal outcomes.** Allowed child terminal states: closed (implemented
   and verified), superseded, rejected, or — for
   `governance-quorum-revisit-trigger` only — program-recorded no-action.

## Per-Child Charters

- `retirement-register-compatibility-refresh` (F-04): run/structure the seven
  overdue reviews; each review outcome (retain/retire/re-date) recorded with
  retained evidence; closeout requires zero overdue entries or explicit
  re-dated cadence.
- `runtime-spec-directory-index` (F-05): add a spec-directory index aligned
  with the active-version declarations in `octon.yml#runtime_contract_refs`;
  must not alter which versions are active.
- `retained-evidence-operability-contract` (F-03, F-06): author the
  immutable:// store operational contract (authority, backup, verification,
  DR) and either retention-duration enforcement or an explicit policy-only
  declaration; resolves open-questions items 2 and 3 of the source review.
  **Pre-acceptance evidence gate (not yet run):** before this child may be
  accepted, a targeted Prompt 5 run (Domain Architecture Audit,
  `.octon/inputs/additive/.incoming/octon-architecture-review-prompt-library/payload/prompts/05-domain-architecture-audit.md`,
  targeted mode with the evidence-retention / retained-evidence operability
  domain supplied) must produce retained evidence under
  `.octon/state/evidence/validation/architecture/reviews/domain-architecture-audit/<review-id>/`
  covering F-03, F-06, and the F-09 dependency implications, with the exact
  prompt artifact copied into the gate bundle and the model actually used
  recorded. The child cites that evidence by path; parent program evidence
  never satisfies this gate. Creation before the gate is permitted;
  acceptance before it is not.
  **Gate result handling (when the gate runs):** the run is not a checkbox —
  its retained evidence must be dispositioned before this child may be
  accepted. If the audit passes with no material gaps, the child cites the
  evidence and proceeds toward acceptance through its governed lifecycle. If
  it finds material gaps in the evidence-retention domain, the child must be
  revised before acceptance — incorporated at creation if the child does not
  exist yet, or through the governed packet revision route if it does. If it
  changes dependency assumptions for `evidence-classification-v2-migration`,
  that child's planned scope, dependency notes, or acceptance gates must be
  updated before that child is accepted. If it identifies a concern outside
  the existing child scopes, the concern must be routed as exactly one of: a
  new child packet via registry revision at the parent, an explicit deferral
  with owner and trigger, or a no-action record with rationale — never
  silently dropped. The recorded disposition must name the retained evidence
  path, prompt number/title, target domain, actual model used, verdict,
  blocking findings (if any), the packet/program/child changes made in
  response, and one explicit decision: proceed, revise, defer, escalate, or
  no-action. The gate evidence remains evidence, not authority.
- `continuity-coherence-validator` (F-07): define the pre-resumption
  coherence check (handoff vs control/evidence roots) and its evidence
  contract; authority impact must remain nil (GrantBundle still required for
  every run).
- `evidence-classification-v2-migration` (F-09): plan v1→v2 migration with
  per-run mapping evidence, validation, and rollback; may not begin
  implementation until `retained-evidence-operability-contract` passes
  verification, and must treat that child's targeted Prompt 5 gate evidence
  as dependency input, cited before its own implementation planning.
- `historical-runcard-support-audit` (F-08): audit historical RunCard
  support-tuple references; outcome is either remediation criteria or a
  frozen-as-of-issuance declaration — both are acceptable closures.
- `governance-quorum-revisit-trigger` (F-10): conditional; only if durable
  action is justified. A no-action rationale recorded at program closeout is
  the expected default for a single-maintainer repository.
