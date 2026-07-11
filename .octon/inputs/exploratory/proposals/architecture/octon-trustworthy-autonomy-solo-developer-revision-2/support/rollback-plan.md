# Rollback Plan

## Packet

Before promotion, rollback is deletion or rejection of this temporary packet.
No live runtime or provider state changes.

## Implementation

The first installation and later upgrades have different trust ancestry.

For the first broker/signer/verifier/activation-gate installation:

1. retain the current legacy authority/launcher runtime as a bounded rollback
   target with autonomous mutation disabled or higher-assurance containment;
   before a durable-family cutover its legacy effect route remains current,
   but after cutover that family fails closed and its direct credential/path
   is never reactivated;
2. use a fixed signed verifier pinned outside repository/candidate control;
3. install every candidate component into an inactive slot;
4. require explicit operator activation bound to the candidate and legacy
   digests, health checks, migration, expiry, and rollback action;
5. record the operator-signed bootstrap receipt in an external
   conditional-create location;
6. automatically restore only the bounded legacy authority/launcher runtime
   on failed health or partial activation, while revoking candidate
   credentials and preserving work; disable any already-cut-over durable
   effect family rather than restore its unmediated path.

Once a trusted epoch exists, implement upgrades behind versioned contracts and
inactive release slots:

1. retain the previously trusted authority engine, broker, signer, verifier,
   policy bundle, and host adapter;
2. migrate Class A candidate execution first while keeping durable effects on
   the existing path;
3. shadow the new broker and verifier without effect authority;
4. activate Class B routes incrementally by typed effect kind;
5. require explicit activation for Class C and trust-root changes;
6. automatically revert to the last-known-good trust epoch on failed health,
   evidence, reconciliation, or provider checks.

Rollback must never restore a known-revoked key, grant, verifier, support
claim, or policy. Work produced in a candidate sandbox is preserved as a
patch, bundle, local commit, or quarantined sandbox before cleanup.
