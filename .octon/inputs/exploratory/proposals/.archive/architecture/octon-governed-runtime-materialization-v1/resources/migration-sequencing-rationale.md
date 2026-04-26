# Migration Sequencing Rationale

## Why these three capabilities belong together

Support reconciliation, typed effect enforcement, and run health all protect the
same promise: Octon gives agents governed freedom only inside checked,
reviewable boundaries.

If they are implemented separately, Octon can end up with:

- support claims that do not match routes;
- valid-looking authorization that targets stale or unsupported routes;
- operator health views that summarize stale or unreconciled truth;
- runtime effects that bypass the boundary while docs claim governance.

The integrated migration prevents those splits.

## Why Phase 1 comes first

Typed effects must bind to a support tuple and route posture. If support truth is
inconsistent, token enforcement can only enforce an inconsistent claim. The
support envelope must reconcile first.

## Why Phase 2 comes second

Once support truth is stable, material side effects need enforcement. Without
typed effect-token closure, support reconciliation remains a publication guard
but not a runtime guard.

## Why Phase 3 comes third

Run health should summarize reconciled support and enforced authorization. It
must not be generated from weaker pre-migration assumptions.

## Why this is higher leverage than adapters or UI

Adapters expand what Octon can touch. UI polish expands how Octon is seen. This
migration strengthens whether Octon can be trusted when it acts. For serious
solo operators building consequential products, that is the higher-leverage
foundation.
