# Program Closeout Plan

## Parent Closeout Conditions

The parent can close only when:

- every required child packet is implemented, rejected, superseded, or
  explicitly deferred by a child-owned receipt;
- implemented child packets retain passing implementation-run,
  implementation-conformance, post-implementation drift/churn, and closeout
  receipts;
- generated registry and compact artifact projections are fresh;
- the child registry no longer references missing or renamed child packets;
- the final validation summary records all commands, results, blockers, and
  evidence refs.

## Non-Authorizing Parent Summary

The parent closeout summary is evidence about coordination only. It does not
prove durable mechanism implementation. Durable implementation is proven by
child promotion evidence and validators.

## Closeout Refusal Criteria

Refuse implemented closeout if:

- any child lacks child-owned receipts;
- any child uses parent evidence to satisfy its gates;
- the architecture-readiness canonical slug migration leaves permanent
  differently named aliases;
- support receipt validators allow prose-only passing receipts;
- post-integration reviews or lifecycle postmortems are treated as closeout
  authority without an explicit later policy contract.
