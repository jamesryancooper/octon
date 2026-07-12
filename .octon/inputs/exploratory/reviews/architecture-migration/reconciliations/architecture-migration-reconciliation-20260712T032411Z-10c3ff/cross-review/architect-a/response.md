# Architect A Cross-Review Response

## Scope and posture

This is Architect A's independent cross-review of Architect B's completed review. It does not rewrite either original review and it does not create the final reconciliation. The comparison uses the shared clean baseline commit `c5b1f5760c78ff521cca6b054e4e8fef5300505b`, the accepted intake decisions, the two named reviews, and targeted repository reverification.

## Strongest agreement

The reviews converge on the direction that matters most: Octon should retain its existing authority, lifecycle, run-contract, context, support-target, and provider-adapter primitives, while replacing candidate-controlled privileged effects with a credentialless candidate boundary, one local transactional state store, one local broker, sanitized privileged Git, candidate-immutable exact-SHA verification, recoverable Class B publication, and staged trust-root activation. Both reviews also agree that the repository currently declares more trust than it proves, that direct-main and ambient credential paths must retire, and that implementation must be gated by proof rather than documentation alone.

Architect B materially strengthens the attack-surface account in five places: the authorization decision currently executes repository-controlled policy code and policy data; production accepts policy and route-bundle environment overrides; additional credentialed workflows, including Release Please, belong in the effect-writer inventory; the existing run/evidence surface is operationally excessive; and the local broker needs an explicit supervision, socket-authentication, recovery, enrollment, and diagnosis story.

## Important factual disagreements

1. Architect B classifies FD-020, the deterministic Harness Factory, as satisfied. The repository contains a useful task-harness contract and a digest-bound runtime route-bundle compiler, but the generator does not compile the complete approved project, mission, Run Contract, policy, context, model, tool, validation, evidence, and rollback envelope required by the intake target. The supported conclusion is `PARTIALLY_SATISFIED`, with substantial primitives to preserve.
2. Architect B classifies FD-023, provider-native component delegation, as satisfied. Replaceable host/model adapter manifests and conformance contracts exist, but current privileged workflows and incomplete replacement/conformance proof do not establish that changing providers preserves authority, evidence, recovery, and publication semantics. The supported conclusion is `PARTIALLY_SATISFIED`.
3. Architect B describes the route-write lease as the prohibited standalone evidence-capacity lease subsystem while also declaring the intake negative constraint satisfied. The route-write lease is not an evidence-capacity reservation service. The current repository still lacks FD-013's same-transaction evidence-capacity reservation; the two concepts must not be conflated.
4. Architect B's broad statement that post-push validation is absent is too strong. The shell no-PR path performs a post-push check, although the broader runtime still lacks durable unknown-outcome attempt state and reconciliation. The migration gap is real; the universal claim is not.
5. Some hook wording implies a candidate can commit `.git/hooks`. Git hooks are not normally tracked. The supported risk is that repository-controlled installers, Git configuration, filters, helpers, drivers, and privileged invocations can arrange candidate-influenced execution unless broker Git is fully sanitized.

## Important architectural disagreements

Architect B proposes treating evidence signing as an operator choice and recommends replacing FD-014 with Git-anchored evidence. FD-014 is already accepted and explicitly requires broker and verifier signatures. No infeasibility, contradiction, or material-safety record was supplied, so the proposed reopening is rejected. Cryptographic mechanism and key custody remain implementation choices; the signed-observation property does not.

Architect B also recommends deferring Workspace Projects until a second project exists. FD-019 is accepted, FD-024 explicitly targets multiple projects, and the target record is intentionally minimal. Broad portfolio machinery should not be built, but the minimal non-authoritative project boundary should remain in the first complete vertical.

Several proposed rollback paths are unsafe: re-enabling ambient Git, falling back from the authoritative store to YAML read-through, or allowing a log-only privileged guard would restore dual authority or candidate-controlled privilege. After each trust-sensitive cutover, rollback must restore the last known-good implementation behind the same boundary, preserve the transactional store, or stop at a safe disabled/PR-only posture.

The packet structures are broadly compatible. Architect A's fourteen workgroups provide clearer exclusive ownership for project/harness work and final claim/promotion work, while Architect B contributes necessary scope to the authority, broker, Git, evidence, trust, and usability packets. A synthesized fourteen-packet sequence is preferable to either package unchanged.

## Corrections accepted from Architect B

- Pin authorization decision code, policy data, receipt writers, and effective-route inputs to a candidate-immutable/base-certified source before privileged use.
- Remove or tightly test-disable `OCTON_POLICY_RUNNER_OVERRIDE`, `OCTON_POLICY_MODE_OVERRIDE`, and `OCTON_ALLOW_STALE_RUNTIME_ROUTE_BUNDLE` in production paths.
- Inventory and contain every credentialed workflow, including auto-merge, Release Please, and push-triggered trust gates; do not limit the migration to one workflow.
- Expand the broker packet with automatic startup, single-instance supervision, authenticated IPC, crash recovery, credential enrollment, status, doctor, repair, and uninstall semantics.
- Expand Git hardening to hooks, includes, aliases, helpers, filters, external diff/merge drivers, fsmonitor, submodules, environment variables, and attempt attribution.
- Require an independent object database, not merely a linked worktree, for candidate isolation where shared Git state would violate the threat model.
- Move setup, doctor, blocked-state explanation, and recovery UX into the early vertical rather than postponing all product work to the final packet.
- Treat tracked run-state volume and CI/control-plane surface area as explicit simplification and retention inputs.

## Conclusions rejected

- Reopening FD-014 to remove signed direct observations without the required decision-reopen record.
- Deferring the minimal FD-019 Workspace Project boundary out of the target vertical.
- Treating route-write serialization as the forbidden evidence-capacity lease subsystem.
- Restoring ambient Git, YAML runtime authority, log-only privileged guards, or candidate-head gate construction as rollback bridges.
- Treating a linked Git worktree alone as sufficient independent Git isolation.
- Declaring FD-020 or FD-023 fully satisfied from contracts and partial implementation alone.
- Requiring operator decisions before proposal-program authoring when those choices can be resolved inside bounded packets before their implementation gates.

## Missing evidence

Live provider protection and identity configuration was not fully observable from repository state. The normalized baseline does not dynamically prove native macOS sandbox escape resistance, full effect-path mediation, crash safety, evidence authenticity, trust-root rollback, or provider replacement. These remain packet proof gates, not reasons to guess or to block creation of the proposal program.

## Effect on migration architecture

The core sequence from Architect A remains, but the first authority packet must also make the decision function candidate-immutable, the broker packet must include operability, the Git packet must use an independent repository/object database and a full sanitization allowlist, the evidence packet must address current state exhaust, and operator UX must arrive with the first safe vertical. All privileged rollback bridges must fail closed or restore a previously certified implementation behind the new boundary.

## Effect on proposal-program readiness

The cross-review increases confidence in the need and feasibility of the migration and sharpens packet acceptance criteria. It does not reveal a factual uncertainty that prevents program design, nor a current repair that must precede research/program authoring. Privileged implementation remains blocked behind Gate 0 and packet-specific proof. Architect A therefore retains `READY_FOR_PROPOSAL_PROGRAM`.
