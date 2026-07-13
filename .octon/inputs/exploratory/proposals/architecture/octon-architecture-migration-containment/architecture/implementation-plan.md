# Implementation Plan

This plan becomes executable only after proposal acceptance and the gates in
AC-01. It does not authorize implementation.

## Workstream 0 — Bind Decisions and Exact Baseline

1. Bind accepted ROD-006: Octon exposes no human or agent direct-main route;
   ordinary human Git remains outside Octon. No universal PR bridge follows
   from this decision.
2. Bind the exact implementation commit, branch, tree state, and provider
   observation; mark unavailable provider facts stale rather than inferred.
3. Freeze the promotion-target and affected-projection ledger.
4. Prepare rollback handles before changing a route or claim.

## Workstream 1 — Fail-Closed Containment

1. Change the durable default-work-unit contract so no Octon-owned human or
   agent route can select direct-main; ordinary human Git remains outside Octon.
2. Inventory write-capable or credential-bearing GitHub projections, including
   auto-merge, release, AI review, and check-producer planes.
3. Disable candidate-head privileged writers, current autonomous no-PR/local
   landing effects, and destructive unlanded cleanup. Retain protected PR only
   for independently review-selected work after its boundary is proved safe.
4. Validate the host projection against the updated durable contract and
   record any provider mutation through separately authorized provider
   receipts.

## Workstream 2 — Complete Physical Inventories

1. Enumerate Rust, shell, workflow, generated-publication, and provider
   writers and launchers.
2. Enumerate credential consumers, installed and repository policy inputs,
   trust roots, check producers, rulesets, Apps, environments, and workflow
   identities without reading secret values.
3. Assign authenticated role, canonical interface, owner packet, support
   posture, evidence requirement, rollback posture, and retirement/repair
   disposition.
4. Add negative fixtures for unknown writers and launchers.

## Workstream 3 — Claim Correction

1. Compare every live support row, admission, dossier, and HarnessCard source
   claim with direct retained proof and evidence classification.
2. Demote or remove wording that exceeds proof; do not manufacture evidence.
3. Add the referenced-only-versus-executed negative fixture.
4. Regenerate derived support and disclosure views only through their owning
   generators and retain freshness receipts.

## Workstream 4 — Burden Baseline and Exit Proof

1. Measure tracked state files, bytes, inodes, workflow count, normal command
   concepts, routine prompts, and operator time.
2. Run the validation matrix and rollback drill.
3. Retain PO-FD-015 and Gate 0 evidence under the packet evidence root.
4. Produce implementation conformance and drift/churn reviews.
5. Handoff frozen inventories and containment receipts to RP-01 and RP-02;
   later privileged work remains blocked until this packet exits.

## Parallelization Constraints

- Design work for other packets may proceed in parallel.
- No other packet may perform a privileged change before RP-00 exit.
- RP-00 may temporarily remove routes but may not implement RP-05/RP-06 final
  publication semantics.
- Trust-sensitive implementation, sole review, adversarial testing, and final
  integration must remain independent roles.

## Dependency and New-Surface Discipline

No new software dependency or control plane is planned. Existing contracts,
inventories, validators, generators, and protected-PR mechanisms are reused.
Any proposed new daemon, database, credential proxy, workflow controller, or
proposal-specific integrity scheme is outside RP-00 and must be rejected.
