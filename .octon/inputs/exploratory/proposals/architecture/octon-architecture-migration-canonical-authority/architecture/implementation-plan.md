# Implementation Plan

1. Freeze RP-00 inventories and enumerate every evaluator, launcher, policy,
   binary, configuration, receipt, revocation, and spawn call site.
2. Specify the versioned request/decision/guard records and typed scope algebra;
   bind ROD-003's accepted small content-addressed semantic epoch-zero
   inventory and one-time human trust anchor/bootstrap.
3. Refactor `authority_engine` so the installed evaluator is the only issuer and
   decision receipts bind all implementation and request identities.
4. Refactor lifecycle and kernel launch seams behind the exact one-shot guard;
   remove or hard-deny bypasses while leaving isolation to RP-02.
5. Add negative fixtures for substitution, widening, expiry, revocation,
   concurrency, and crash consumption; capture UE-001/UE-002 evidence.
6. Freeze the semantic API and handoff contract. Only then may RP-03 migrate
   persistence. Shared files are edited sequentially through the trusted
   integration lane.
7. Cut over atomically in clean-break mode, retain a certified rollback
   package, validate SI-01, and promote only after packet-owned gates pass.

No compatibility bridge may act as authority. A read-only diagnostic bridge
may compare legacy outcomes during pre-cutover proof and is removed at cutover.
