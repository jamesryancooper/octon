# Program Rollback Plan

The parent has no runtime rollback. A program coordination error is corrected in
the owning parent artifact while child statuses/evidence remain untouched. A
child failure invokes that child's rollback and returns to the highest proved
safe intermediate state; it never restores a prohibited bridge.

Before first transactional effect, immutable snapshot rollback is allowed.
Afterward only crash-consistent certified state plus reconciliation/forward
repair is allowed. Publication failure, expected-old collision, or unknown
effect preserves the frozen route, exact candidate, and evidence for
reconciliation; it never switches to PR. A later attempt requires a fresh tuple
and independent pre-effect route decision. Trust failure leaves the new version inert or restores the exact
certified prior version. Optional claim failure demotes that claim while lower
safe states remain.

Canonical local `main` rolls forward only as a fast-forward downstream mirror.
Cleanup rollback never deletes an unlanded candidate and never reports
`cleaned` when conditional cleanup was not proved.
