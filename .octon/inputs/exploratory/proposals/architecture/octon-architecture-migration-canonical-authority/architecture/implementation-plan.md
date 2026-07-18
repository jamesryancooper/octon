# Implementation Plan

1. Bind the RP-00 closed-world 919-launcher inventory and the exhaustive
   candidate/non-candidate partition in `resources/candidate-launch-census.yml`;
   enumerate every evaluator, policy, binary, configuration, receipt,
   revocation, and candidate spawn call site.
2. Specify the versioned request/decision/guard records and typed scope algebra;
   bind ROD-003's accepted small content-addressed semantic epoch-zero
   inventory and one-time human trust anchor/bootstrap.
3. Refactor `authority_engine` so the installed evaluator is the only issuer and
   decision receipts bind all implementation and request identities.
4. Implement `consume_candidate_launch_guard` in
   `lifecycle_executor::authorization`; invoke it in the four census-owned
   helpers immediately before each final spawn. Remove or hard-deny bypasses
   while leaving command construction, workflow semantics, and isolation to
   their declared owners.
5. Extend the authorization coverage validator and its named positive,
   negative-control, and material-effect fixture tests. They must reject a new
   unowned raw candidate spawn and a census-owned spawn without the consuming
   guard, and dynamically exercise all four guarded seams.
6. Add negative fixtures for substitution, widening, expiry, revocation,
   N-way concurrency, and crash consumption. After the exact implementation is
   authorized, execute them against its commit and capture UE-001/UE-002.
7. Freeze the semantic API and handoff contract. Only then may RP-03 migrate
   persistence. Shared files are edited sequentially through the trusted
   integration lane.
8. Cut over atomically in clean-break mode, retain a certified rollback
   package, validate SI-01, and promote only after packet-owned gates pass.

No compatibility bridge may act as authority. A read-only diagnostic bridge
may compare legacy outcomes during pre-cutover proof and is removed at cutover.
