# Cutover Checklist

This is an additive, atomic (`change_profile: atomic`) documentation change with no
runtime state to migrate. "Cutover" is the single governed acceptance-and-promote
step, not a phased live migration. No intermediate live states are created.

## Preconditions

- [ ] Dependency `architecture-review-method-taxonomy-and-routing` verified;
      `naming.yml` v2 and `review-routing.yml` v2 present (grounding-confirmed).
- [ ] `lens-bank.yml` `method_profiles` complete for all four companion slugs;
      `validate-architectural-review-lens-references.sh` green.
- [ ] Strict pre-integration architecture review support receipt is passing for
      this packet (proposal-lifecycle acceptance gate).
- [ ] No competing in-flight edit to `naming.yml`/`README.md` in the review
      directory.

## Cutover Steps (single atomic promotion)

1. [ ] Author the four `<slug>.md` docs (Workstream A).
2. [ ] Add the four additive `doc:` pointers to `naming.yml` (Workstream B.1).
3. [ ] Add the four References links to `README.md` (Workstream B.2).
4. [ ] Run the doc/registry consistency check — all nine assertions pass for all
       four docs.
5. [ ] Run the three regression validators — each `errors=0`.
6. [ ] Run `validate-proposal-standard.sh --package <this packet>
       --skip-registry-check` — no errors.
7. [ ] Retain validator + consistency-check evidence under
       `.octon/state/evidence/validation/proposals/companion-architecture-review-methods/`.
8. [ ] Refresh the proposal registry projection only in the coordinated
       cross-packet pass (not mutated by this child route).

## Post-Cutover Verification

- [ ] Operator can navigate from `README.md` References and `naming.yml`
      `methods.catalog[].doc` to each of the four docs.
- [ ] Conformance and drift/churn gate receipts pass (proposal lifecycle).
- [ ] `git` diff is confined to the four new docs plus the two additive edits in
      `architectural-review/`; nothing else changed.

## Abort / Hold Conditions

- Any regression validator turns red, or the consistency check fails → hold, do
  not promote, record the finding, and correct.
- A live-repo contradiction with the source design emerges that is NOT a settled
  naming/path canonicalization → stop and trigger a program registry/design
  revision at the parent instead of implementing a stale claim.
