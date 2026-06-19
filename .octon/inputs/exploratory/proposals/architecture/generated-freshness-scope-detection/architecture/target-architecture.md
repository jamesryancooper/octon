# Target Architecture

Proposal-packet delivery detects when durable changes affect generator inputs
or generated read-model dependencies. When freshness is in scope, delivery must
route to the owning generator or validator before terminal closeout can
continue.

Generated outputs remain derived-only. A fresh generated projection can support
operator understanding and validation evidence, but it cannot authorize
runtime, policy, cleanup, closeout, archive, or parent lifecycle state.

The workflow must distinguish:

- generated-input scope detected and owner-routed;
- generated freshness not in scope;
- generated refresh needed but not authorized;
- generated output present but stale;
- generated output fresh but non-authoritative.
