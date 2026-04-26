# SSOT and Authority Boundary Map

## Boundary overview

```text
framework + instance authored authority
          |
          v
resolver / authorization / admission
          |
          v
state/control + state/evidence + state/continuity
          |
          v
generated/effective handles and generated/read models
```

## Authored authority

Authored authority defines what may be true:

- constitution and charter
- architecture registry/specification
- runtime specs and schemas
- instance support declarations
- assurance validator contracts

## Mutable control

State/control defines what is happening in a run:

- run contract
- run manifest
- events journal
- runtime state
- stage attempts
- checkpoints
- rollback posture

## Retained evidence

State/evidence defines what has been proven or observed:

- authorization decisions
- token records and consumption receipts
- validator receipts
- proof bundles
- RunCards/support cards/disclosures where canonical process requires them

## Continuity

State/continuity can carry mission context and long-horizon memory. It cannot
replace run control or mint execution authority.

## Generated/effective

Generated/effective artifacts may narrow and cache runtime-resolved posture.
They cannot widen support or create authority.

## Generated/read-model

Run health is a generated read model. It can answer "what should the operator
look at next?" It cannot answer "may the runtime perform this side effect?"
without returning to canonical authorization.
