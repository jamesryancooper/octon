# File Change Map

This map declares planned durable ownership. A target may be absent before
implementation; absence is not evidence of completion.

| Target | Current assumption | Required change | Owner | Priority | Rationale |
| --- | --- | --- | --- | --- | --- |
| .octon/framework/engine/runtime/crates/local_broker/src/adapters/git/ | No accepted broker Git module exists | Add closed adapter, request/result boundary, non-executing import, source-ref expected-absent/expected-tip operations, target CAS, conditional delete, mirror primitive, and observations | RP-05 | P0 | Isolates privileged Git from broker core and candidate state |
| .octon/framework/engine/runtime/crates/authorized_effects/ | Generic typed effects exist | Add the minimum sealed Git effect data needed by the broker; no minting or route policy | RP-05 with RP-01 interface review | P0 | Keeps the effect exact and authority-neutral |
| .octon/framework/engine/runtime/spec/material-side-effect-inventory.yml | Protected CI is inventoried; broker Git is not a live accepted path | Register broker Git effect and classify legacy direct writers as retired or denied | RP-05 | P0 | Makes the physical writer enumerable |
| .octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml | No broker Git consumer entry exists | Bind request builder, token consumer, receipt, denial code, rollback, and negative tests | RP-05 | P0 | Proves no token bypass |
| .octon/framework/execution-roles/_ops/scripts/git/git-branch-land-hosted-no-pr.sh | Reads target-pre then performs ambient ordinary push and post-check | Convert to a broker-only facade or retire after parity proof; remove independent mutation | RP-05 | P0 | Eliminates ambient effect execution |
| .octon/framework/execution-roles/_ops/scripts/git/git-branch-hosted-preflight.sh | Provides useful source, route, and provider checks | Narrow to non-mutating preflight that cannot substitute for broker validation | RP-05 | P1 | Preserves useful checks without a second gate |
| .octon/framework/execution-roles/_ops/scripts/git/git-branch-authorize-hosted-no-pr.sh | Emits a route-specific authorization receipt | Bind its output to the broker request interface or retire its effect-facing role | RP-05, consuming RP-01/RP-06 | P1 | Prevents stale, parallel authorization semantics |
| .octon/framework/execution-roles/_ops/scripts/git/git-pr-cleanup.sh | Legacy cleanup can delete closed-unmerged work and compare then delete | Retire ambient behavior or make it a broker-only expected-tip facade; RP-08 owns eligibility/status | RP-05 for primitive only | P0 | Preserves unlanded work and closes the delete race |
| .octon/framework/execution-roles/practices/git-github-autonomy-workflow-v1.md | Documents ambient and hosted helper behavior | State broker-only Git and sealed expected-old/expected-tip operations; PR is policy-selected, not a fallback | RP-05 for primitive text | P1 | Aligns durable operating doctrine |
| .octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml | Defines hosted no-PR helper roles | Replace ambient landing helper posture with broker adapter consumption and proof | RP-05 for primitive fields | P1 | Keeps route-neutral contract aligned |
| .octon/framework/assurance/runtime/_ops/tests/sanitized-git/ | Dedicated suite absent | Add hostile extensions, import, identity, CAS/race, attribution, and outage fixtures | RP-05 | P0 | Supplies PO-FD-009 and UE-005 proof |
| .octon/state/evidence/validation/proposals/octon-architecture-migration-sanitized-git/ | Child proof absent | Retain implementation, adversarial, provider, rollback, conformance, and drift evidence | RP-05 lifecycle/proof owners | P0 | Keeps evidence child-owned |

## Consumed But Not Owned

- .octon/framework/product/contracts/default-work-unit.yml is consumed from
  RP-00/RP-06 ownership; RP-05 does not redefine Change routing.
- RP-04 broker core, IPC, supervision, credential custody, and store writer
  remain outside the adapter directory.
- RP-03 SQL transitions remain frozen.
- RP-06 verifier, check binding, classification predicate, and publication
  adapter remain outside this packet.
- .octon/instance/governance/support-targets.yml is not widened here.
- .github/** is a derived host projection and is not a promotion target.

## Generated And Downstream Effects

Later implementation may require registry, feature-catalog, or provider
projection refresh through their owning routes. Those are downstream
coordination effects, not permission for RP-05 to edit generated outputs or
non-.octon targets.
