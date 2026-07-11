# Source Artifact: Revision 2 Assignment

## Provenance

- source: operator-provided assignment in the current Codex task
- received: 2026-07-10
- authority: design input and correction ledger; not runtime or policy authority
- prior-packet limitation: no Revision 1 artifact was found in the searched
  exploratory proposal tree

## Product Objective

Enable a solo developer to delegate substantial, focused, long-running
engineering work without surrendering control and without turning normal
software development into governance bureaucracy.

Provide broad autonomy inside a focused, reversible execution envelope, with
strong controls concentrated at durable, external, irreversible, or trust-root
boundaries. Safety and development throughput are coequal architectural
requirements.

## Required Corrections and Decisions

The assignment requires Revision 2 to:

1. unify `authorize_execution`, `GrantBundle`, typed effect capabilities,
   verification/consumption, lifecycle dispatch, delegation, child launch, and
   broker execution into one precise authority lifecycle;
2. define Class A reversible candidate work, Class B durable reversible
   effects, and Class C irreversible/external/trust-root effects;
3. place disposable candidate writes inside a project sandbox and durable
   consequential effects behind a broker;
4. compare eight concrete enforcement topologies and choose a solo default and
   higher-assurance profile;
5. replace a fixed-size TCB claim with five layered inventories;
6. separate human, model, run, mission, harness, executor, authority, broker,
   signer, provider, verifier, and child identities and credentials;
7. distinguish corruption detection, tamper evidence, authenticity,
   non-repudiation, completeness, and truthfulness, including evidence
   economics;
8. bind merge verification to repository, exact SHA, run/grant/harness/policy
   provenance, validation, rollback, evidence root, expiry, and revocation;
9. preserve self-development while preventing same-change self-certification;
10. specify twelve fault-injection and degraded-operation cases;
11. complete Workspace Project and Governed Harness Factory designs without
    letting either authorize execution;
12. add measurable solo-developer performance and usability criteria; and
13. retain a typed evidence appendix for every material current-state finding.

The packet must end with twelve independently approvable architecture
decisions covering authorization, launch authority, effect boundary,
enforcement topology, identity, evidence, merge verification,
self-development, Workspace Project, Harness Factory, degraded operation, and
latency/interruption targets.
