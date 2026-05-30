# Acceptance Criteria

- All extension and workflow route execution is delegated through the shared lifecycle executor adapter according to route metadata and `delegation_contract`.
- Durable mutation requires retained delegation proof before execution, even when invocation authority defaults to `unattended`.
- Typed human exception grants unblock only the named route in the named program run and are consumed as evidence before dispatch.
- Runner-local workflow shortcuts and route-id special cases for durable mutation are absent.

## Negative Criteria

- Do not bypass the shared executor adapter.
- Do not move workflow-owned promotion, archive, closeout, cleanup, publication, registry, or validator ownership into the runner.
- Do not treat invocation authority alone as sufficient proof for durable mutation.

## Terminal Criteria

- Child implementation evidence exists only after a later
  `run-packet-implementation` route.
- Child promotion is workflow-owned by `promote-proposal` and cannot be claimed
  by parent program evidence.
- Child closeout and archive remain child-owned and route-gated.
