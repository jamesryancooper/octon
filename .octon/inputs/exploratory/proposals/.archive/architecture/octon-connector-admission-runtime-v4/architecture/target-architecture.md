# Target Architecture

## Target state

Octon gains a first-class **Connector Admission Runtime** for external tool/service operations while preserving its constitutional runtime boundary.

The target introduces these durable concepts:

1. `Connector Operation`
2. `Connector Admission`
3. `Connector Trust Dossier`
4. `Connector Execution Receipt`
5. `Connector Posture`
6. `Connector Support-Target Proof Hook`
7. `Connector Generated Read Model`

## Core model

```text
Connector
  -> Operation
    -> Capability Packs
      -> Material-Effect Classes
        -> Support Posture
          -> Policy
            -> Authorization
              -> Verified Effect
                -> Receipt/Evidence
```

## Connector Operation

A connector operation is a normalized operation exposed by an external service, MCP server, API, browser adapter, release system, CI provider, or other capability surface.

It must define:

- connector identity;
- operation identity;
- operation version;
- input/output schema;
- side-effect class;
- material-effect inventory class;
- capability packs consumed;
- credential class;
- egress requirements;
- replayability;
- rollback/compensation posture;
- evidence obligations;
- allowed modes;
- budget class;
- rate limits;
- privacy/data handling;
- support posture;
- failure taxonomy.

## Admission modes

- `observe_only`
- `read_only`
- `stage_only`
- `live_effectful`
- `quarantined`
- `retired`
- `denied`

Only `live_effectful` may perform material external actions, and only after execution authorization grants the specific effect.

## Connector Trust Dossier

A trust dossier is the proof bundle for an operation's admission posture.

It must include or reference:

- support-target tuple;
- operation contract;
- side-effect inventory mapping;
- egress policy result;
- credential handling evidence;
- replay behavior;
- rollback/compensation plan;
- failure-mode tests;
- security review;
- retained admission evidence;
- generated support-card projection where appropriate;
- lab/shadow/stage evidence for anything beyond observe/read.

## Runtime behavior

The runtime must:

1. resolve connector operation metadata;
2. validate support-target and capability-pack posture;
3. evaluate egress/budget/credential posture;
4. require context-pack inclusion for consequential/boundary-sensitive operations;
5. submit material operations through `authorize_execution`;
6. require typed `AuthorizedEffect<T>` verification before invocation;
7. define connector execution receipt requirements for any future material connector operation;
8. update connector control state;
9. retain evidence under canonical evidence roots;
10. fail closed on drift, missing proof, unsupported posture, stale handle, missing token, missing receipt, or capability mismatch.

## Operator experience

Proposed CLI:

```text
octon connector inspect
octon connector inspect --connector <id>
octon connector list --connector <id>
octon connector status --connector <id> --operation <op>
octon connector validate --connector <id> --operation <op>
octon connector admit --stage-only --connector <id> --operation <op>
octon connector admit --read-only --connector <id> --operation <op>
octon connector quarantine --connector <id> --operation <op>
octon connector retire --connector <id> --operation <op>
octon connector evidence --connector <id> --operation <op>
```

The CLI does not execute connector operations directly. Execution remains routed through work packages, missions, stewardship, run contracts, context packs, authorization, and verified effects.

## Compatibility with v1-v3

If v1/v2/v3 surfaces exist, connector admission attaches to:
- Work Package capability posture;
- Mission Runner capability posture refresh;
- Stewardship Trigger/admission evaluation;
- Decision Requests for connector admission, support widening, risk acceptance, and credentialed writes.

If those surfaces are missing, this proposal still lands the connector contracts, governance, validators, evidence roots, and fail-closed runtime posture without pretending full v1-v3 orchestration exists.
