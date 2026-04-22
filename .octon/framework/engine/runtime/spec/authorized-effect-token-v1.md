# Authorized Effect Token v1

This contract defines the typed authorization product required by material
side-effect APIs.

## Purpose

`authorize_execution` remains the engine-owned authorization boundary.
Side-effecting runtime APIs must consume typed effect tokens derived from that
boundary instead of relying on ambient `GrantBundle` access or raw path inputs.

## Token model

Each token is an instance of:

```text
AuthorizedEffect<T>
```

Where `T` is one of the material effect classes:

- `RepoMutation`
- `GeneratedEffectivePublication`
- `StateControlMutation`
- `EvidenceMutation`
- `ExecutorLaunch`
- `ServiceInvocation`
- `ProtectedCiCheck`
- `ExtensionActivation`
- `CapabilityPackActivation`

## Required token metadata

- request id
- run root or run id
- effect kind
- support tuple ref when applicable
- allowed capability packs
- publication or mutation scope
- non-authority handle context when the effect depends on runtime-effective
  routing

## Construction rules

- Tokens are created only from the authorization boundary or an engine-owned
  projection of a successful grant.
- Arbitrary runtime callers must not be able to mint tokens.
- A token may be single-use or explicitly scope-bounded, but the scope must be
  encoded and enforced.

## Acceptance rule

Material side-effect APIs are not target-state complete until they require the
relevant token type as input.
