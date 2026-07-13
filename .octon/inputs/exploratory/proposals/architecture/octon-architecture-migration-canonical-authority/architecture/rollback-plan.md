# Rollback Plan

Before cutover, abandon the candidate implementation and retain RP-00's safe
manual/protected-PR posture. After cutover but before privileged effects, disable
candidate launch and atomically select only the last independently certified
authority package with its matching policy/config/receipt contracts. Preserve
denial and migration evidence.

Rollback must never select candidate-controlled policy, a loose-file evaluator,
an older revoked epoch, a log-only guard, or a direct launcher. If no certified
package is available, remain fail-closed with candidate work preserved for
manual handling.
