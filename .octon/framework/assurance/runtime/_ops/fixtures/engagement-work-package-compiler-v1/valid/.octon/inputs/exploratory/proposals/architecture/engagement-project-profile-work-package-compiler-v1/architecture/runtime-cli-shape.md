# Runtime and CLI Shape

The compiler exposes `octon start`, `octon profile`, `octon plan`,
`octon arm --prepare-only`, `octon decide`, and `octon status`.

The material execution handoff remains:

```text
octon run start --contract .octon/state/control/engagements/<engagement-id>/run-contract-candidate.yml
```

The compiler must not bypass this existing entrypoint in v1.
