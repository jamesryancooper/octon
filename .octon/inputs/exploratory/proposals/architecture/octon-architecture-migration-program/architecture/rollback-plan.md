# Program Rollback Plan

The parent has no runtime rollback. A program coordination error is corrected in
the owning parent artifact while child statuses/evidence remain untouched. A
child failure invokes that child's rollback and returns to the highest proved
safe intermediate state; it never restores a prohibited bridge.

Before first transactional effect, immutable snapshot rollback is allowed.
Afterward only crash-consistent certified state plus reconciliation/forward
repair is allowed. Publication failure disables the route and preserves work for
protected PR. Trust failure leaves the new version inert or restores the exact
certified prior version. Optional claim failure demotes that claim while lower
safe states remain.
