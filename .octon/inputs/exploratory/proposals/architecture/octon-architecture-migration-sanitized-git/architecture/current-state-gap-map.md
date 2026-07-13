# Current-State Gap Map

## Current Preservable Primitives

The current hosted no-PR path already provides useful pieces:

- source branch must not be main;
- an authorization receipt is required before mutation;
- source SHA, remote, target branch, and target pre-ref are recorded;
- ancestry and ordinary non-force push provide partial fast-forward safety;
- post-push fetch and equality confirm the observed target state;
- protected PR remains an existing safe lane.

These are inputs to the new boundary, not proof that the target exists.

## Material Gaps

| Gap | Current evidence | Required RP-05 change |
| --- | --- | --- |
| Ambient Git state | Hosted helpers run Git in the repository and inherit host context | Move the effect into broker-owned minimal Git state |
| Candidate-controlled extensions | Current helpers do not establish a complete closed Git surface | Deny every extension and substitution surface while preserving the positive path |
| Shared object database | Current branch/worktree flow uses canonical repository state | Import only the exact object closure into independent broker state |
| Non-atomic target binding | Current helper reads target pre-ref, then performs ordinary push | Use server-observed exact expected-old binding plus independent ancestry |
| No durable attempt attribution | Post-push equality proves state, not which attempt caused it | Emit observations/receipts with explicit state-satisfied versus attempt-performed semantics |
| Broad helper behavior | Existing shell helpers combine route, authorization, provider inspection, and mutation | Keep RP-05 effect primitive narrow; RP-06 owns classification and RP-08 owns reconciliation |
| Ambient credential risk | Git execution is not broker-custodied and operation-scoped | Consume only RP-04 broker-projected credentials |

## Findings

- RF-008: autonomous direct-main and ambient Git contradict the target.
- RF-009: check-then-push fails exact target-pre authorization.
- RF-018: rollback cannot restore retired ambient or dual-control hazards.
- RF-023: a linked worktree is not independent Git isolation.
- RF-026: provider CAS and causal-attribution mechanism require targeted proof.

## Baseline Drift

The reconciliation baseline is c5b1f5760c78ff521cca6b054e4e8fef5300505b.
Creation ran at d78ee8b42cb3a39557bbe39b66cb5d156946172a.
The intervening delta contains no changes in the RP-05 source families,
including the engine runtime, execution roles, product contracts, assurance
runtime, instance governance, and GitHub workflow roots. The reconciled current
state therefore remains applicable to this packet.

## What Is Removed Or Demoted

- Ambient hosted Git mutation is retired from the supported autonomous path.
- Agent direct-main is not restored by this packet.
- Existing hosted helper scripts become broker adapter facades or are retired
  after equivalent proof; they cannot remain independent effect paths.
- Post-push equality is retained as an observation, not promoted to causal
  attribution or final verdict.
- Protected PR remains the safe production bridge while the full vertical is
  incomplete.
