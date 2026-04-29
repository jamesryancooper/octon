# Octon Compatibility and Federated Trust Runtime v6

This directory is the repo-local authored authority root for Octon v6
compatibility and federated-trust policy.

The durable v6 rule is:

> Federate proof, not authority. Delegate narrowly, not permanently. Execute
> locally, not by external trust.

Trust surfaces here may classify domains, define local acceptance policy, and
coordinate compacts. They must not override the constitutional kernel,
support-target admissions, run contracts, or execution authorization.

Canonical runtime contracts live under `/.octon/framework/engine/runtime/spec/`.
Mutable trust status lives under `/.octon/state/control/trust/**`. Retained
proof lives under `/.octon/state/evidence/trust/**`. Generated trust views live
under `/.octon/generated/cognition/projections/materialized/trust/**` and are
derived only.

## Selected v6 Interop Layer

The compatibility conformance and portable-proof interop layer is the narrow
prerequisite for later federation. It defines external project inspection, safe
adoption posture, Portable Proof Bundle verification, Attestation Envelope
verification, local acceptance records, proof redaction, proof revocation, and a
minimal trust-domain hook. Accepted proof and attestations remain evidence only.

Full Trust Registry runtime, Federation Compact runtime, delegated authority
runtime, cross-domain write authority, certification runtime, and external
execution authority remain deferred from this selected layer.
