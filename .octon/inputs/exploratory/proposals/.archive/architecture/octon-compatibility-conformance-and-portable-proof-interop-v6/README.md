# Octon Compatibility Conformance and Portable Proof Interop v6

This manifest-governed architecture proposal defines the highest-leverage next implementation step toward Octon's fully realized **Octon Compatibility and Federated Trust Runtime v6**.

## Selected Step

**Octon Compatibility Conformance + Portable Proof Interop**

This is narrower than the full v6 target. It establishes the prerequisite layer that lets Octon answer whether an external project/system is a non-Octon evidence source, an Octon-compatible emitter, an Octon-mediated connector, an Octon-enabled repo, or an Octon federation peer.

## Durable Rule

> Federate proof, not authority. Delegate narrowly, not permanently. Execute locally, not by external trust.

## Packet Status

- Proposal kind: `architecture`
- Status: `archived`
- Promotion scope: `octon-internal`
- Original path: `/.octon/inputs/exploratory/proposals/architecture/octon-compatibility-conformance-and-portable-proof-interop-v6/`
- Archive path: `/.octon/inputs/exploratory/proposals/.archive/architecture/octon-compatibility-conformance-and-portable-proof-interop-v6/`

## Non-Canonical Warning

This proposal packet is exploratory lineage under `inputs/**`. It is not runtime authority, policy authority, or generated truth. Durable outputs must be promoted into `framework/**`, `instance/**`, `state/**`, or `generated/**` according to Octon's root discipline.

## Implemented Entry Points

The selected layer is implemented through compatibility/adoption, proof, attestation, and trust-hook commands:

- `octon compatibility inspect <repo>`
- `octon compatibility profile <repo>`
- `octon adopt <repo>`
- `octon proof export|import|verify|accept|reject|status`
- `octon attest verify|accept|reject|status`
- `octon trust status`
- `octon trust registry validate`
