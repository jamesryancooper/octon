# Runtime and CLI Shape

## Assumed v1 commands

```text
octon start
octon profile
octon plan
octon arm --prepare-only
```

## Current live runtime baseline

The current runtime CLI is run-first. It exposes `octon run start --contract`, `run inspect`, `run resume`, `run checkpoint`, `run close`, `run replay`, and `run disclose`. Workflow execution is a compatibility wrapper over run-first lifecycle semantics.

## v2 commands

```text
octon continue
octon mission open --engagement <id>
octon mission status --mission-id <id>
octon mission continue --mission-id <id>
octon mission pause --mission-id <id>
octon mission resume --mission-id <id>
octon mission revoke --mission-id <id>
octon mission close --mission-id <id>
octon mission queue --mission-id <id>
octon mission next --mission-id <id>
octon decide list
octon decide resolve <decision-id>
octon connector inspect
octon connector admit --stage-only
```

## Required behavior

`octon mission continue` must:

1. verify Autonomy Window gates;
2. select next Action Slice;
3. compile run-contract candidate;
4. build/validate context pack;
5. evaluate policy/approvals;
6. authorize;
7. execute through `octon run start --contract <run-contract>` or equivalent run-first internal entrypoint;
8. emit Continuation Decision.

## Effectful connector admission

`connector admit --live` is blocked in the v2 MVP. Only stage-only connector admission is implemented; future live observe/read admission requires a later promoted contract, support posture, capability mapping, policy treatment, evidence obligations, and authorization path.
