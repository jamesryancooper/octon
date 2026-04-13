# Evidence Plan

## Retained evidence families required by this packet

### 1. Bootstrap doctor receipts
Expected retained evidence:
- validation/publication receipt proving the doctor workflow ran
- run checkpoint showing readiness outcome
- evidence of any failure-class annotation when readiness is degraded

### 2. Repo-consequential preflight receipts
Expected retained evidence:
- run checkpoint showing fresh / stale / diverged outcome
- any auto-route action or block/warn decision
- publication receipt when the preflight is used to justify proceeding to broad verification

### 3. Repo-shell scenario proof
Expected retained evidence:
- scenario-proof bundle
- replay bundle or pointer when produced
- publication receipt if a support-claim-facing report cites the run

### 4. Repo-shell classification receipts
Expected retained evidence:
- structured allow / deny / escalate receipt carried through existing authorization/evidence flows
- evidence of the policy version and adapter contract version used at runtime

### 5. Operator degraded summaries
Expected retained evidence:
- underlying run/control evidence that the summary cites
- zero tolerance for “summary only” states without retained evidence

## Evidence placement rules

- operational truth and checkpoints stay in `state/control/**`
- retained evidence stays in `state/evidence/**`
- operator summaries stay in `generated/cognition/summaries/operators/**`
- no generated output becomes truth

## Packet-level closure proof bundle

Closure requires a packet-level bundle citing:
- merged durable targets
- successful assurance runs
- at least one clean bootstrap-doctor receipt
- at least one clean repo-consequential-preflight receipt
- at least one repo-shell-supported-scenario proof bundle
- any non-happy-path evidence with failure taxonomy citations
