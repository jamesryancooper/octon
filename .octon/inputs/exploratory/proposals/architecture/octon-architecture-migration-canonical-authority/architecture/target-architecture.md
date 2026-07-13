# Target Architecture

RP-01 creates a single installed authority path whose evaluator, policy,
configuration, executable identity, and receipt format are fixed before a
candidate can influence them. The evaluator accepts a versioned request and
returns a typed grant or denial bound to actor, operation, candidate identity,
repository, path/ref/URI scope, time, epoch, revocation state, and exact launch
inputs. Scope comparison is structural and boundary-aware, never a string
prefix test.

Every candidate launch passes through one structural launch API. The final
guard revalidates the exact evaluator identity, policy/config digest, grant,
revocation/high-water state, candidate digest, Harness digest, and requested
capabilities immediately before spawn. Consumption is one-shot and at-most-once
under concurrency. Missing, stale, widened, substituted, revoked, or already
consumed authorization denies without a candidate-tree fallback.

RP-01 owns semantic records and the guard API. RP-03 owns the later SQLite/WAL
persistence adapter; RP-02 owns isolation mechanics; RP-04 owns credentials and
effects; RP-11 owns Harness compilation; RP-13 owns child budgets. Shared call
sites are serialized through the program integration lane and may not redefine
RP-01 semantics.

Safe intermediate state SI-01 permits guarded, non-privileged candidate
launches only. Brokered provider or Git effects remain disabled. Rollback means
disabling launch and selecting a previously independently certified authority
package; log-only checks, loose candidate files, or same-change authority are
prohibited.

For publication scope, the generic typed grant explicitly binds issuer
identity, repository, source producer identity/ref, exact candidate `S`, target
ref, expected old `O`, route-policy digest, operation, expiry/revocation/epoch,
and consequence scope. RP-01 owns these field semantics and issuance only;
RP-06 owns the route-policy values and verdict, RP-03 owns consumption, and
RP-04 owns effect hosting.
