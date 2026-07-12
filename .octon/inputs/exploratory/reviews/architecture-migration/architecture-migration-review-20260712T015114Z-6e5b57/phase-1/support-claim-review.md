# Support-Claim Review

## Finding

Active support material overstates complete mediation. The material
side-effect inventory and authorization-boundary receipt pass structural
validators, yet material process and provider paths remain outside the
claimed token boundary.

## Claims that are supported

- AuthorizedEffect and VerifiedEffect are typed and sealed.
- authority_engine validates canonical record, digest, grant, scope, route,
  support, expiry, revocation, rollback, budget, egress, lifecycle, and
  sequential prior consumption.
- Runtime-bus tests detect tested event-hash tampering and reject tested
  lifecycle violations.
- Hosted no-PR receipt validation checks exact source bindings, required-check
  references, fast-forward posture, landing authorization presence, and
  target-result fields.
- The live GitHub ruleset enforces deletion, non-fast-forward, linear-history,
  and four required-check rules without a current-user bypass.

## Claims that must be narrowed immediately

### Complete executor-launch mediation

The inventory maps kernel studio launch to a helper that creates a directory,
while the actual cargo process spawn follows outside that helper:

- .octon/framework/engine/runtime/spec/material-side-effect-inventory.yml:127-174@c5b1f5760c78ff521cca6b054e4e8fef5300505b
- .octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs:725-757@c5b1f5760c78ff521cca6b054e4e8fef5300505b

Lifecycle Codex, Claude, and workflow dispatches are absent from the effective
typed-launch inventory.

### Protected-CI token mediation

The inventory describes protected CI merge as live token coverage, but the
pull_request_target workflow executes candidate-controlled code with a
write-capable token. A repository JSON control object and candidate validator
are not independent authorization:

- .octon/framework/engine/runtime/spec/material-side-effect-inventory.yml:224-250@c5b1f5760c78ff521cca6b054e4e8fef5300505b
- .github/workflows/pr-auto-merge.yml:257-330@c5b1f5760c78ff521cca6b054e4e8fef5300505b

### Complete boundary coverage

The coverage validator proves that declared strings and files exist. It does
not enumerate raw process-spawn, Git, gh, credential, or provider-write call
sites and prove dominance by a consuming guard:

- .octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh:1-260@c5b1f5760c78ff521cca6b054e4e8fef5300505b
- .octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md:1-120@c5b1f5760c78ff521cca6b054e4e8fef5300505b

### Evidence authenticity and bounded retention

Hash chaining supports tested corruption detection, not writer authenticity,
non-repudiation, completeness, truthfulness, or automatically bounded
retention. Until broker/verifier signing and retention enforcement exist,
claims must use those narrower terms.

## Required support posture during migration

| Capability | Current honest claim | Promotion condition |
|---|---|---|
| Canonical decision | Implemented for selected kernel paths | All material routes enumerate and dominate through authority_engine |
| One-shot launch | Prototype primitive only | Every process launch structurally consumes a transactional guard |
| Credentialless candidate | Not supported | Dynamic sandbox probes prove no credential/user-state/Git access |
| Brokered Git effect | Not supported | Broker owns sanitized adapter and credentials; candidate denial proved |
| No-PR landing | Receipt validation supported; trusted autonomous effect unsupported | Exact source/target broker effect plus independent verifier |
| Evidence integrity | Hash-chain format and tested tamper detection | Retain wording |
| Evidence authenticity | Not supported | Broker/verifier signatures and negative forgery tests |
| Crash-safe idempotency | Not supported | Transactional reservation/outbox and crash matrix |
| Trust activation | Declared governance only | Staged exact-version independent activation and rollback proof |

Support claims should be corrected before privileged implementation so design,
tests, and operator expectations do not rely on non-existent mediation.

