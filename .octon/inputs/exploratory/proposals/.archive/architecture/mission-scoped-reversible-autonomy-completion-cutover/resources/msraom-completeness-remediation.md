# MSRAOM Completeness Remediation

## Decision

Octon should perform one more **atomic MSRAOM completion cutover** rather than a
series of piecemeal follow-ons.

The initial MSRAOM rollout did the hard conceptual work: it established mission
authority, mission policy, ownership routing, v2 execution contracts, and
retained ACP/reversibility semantics. The remaining work is not a new operating
model. It is the missing implementation glue that makes the model complete and
trustworthy in practice.

## Why A Second Atomic Cutover Is The Right Shape

A piecemeal approach would prolong exactly the contradictions the audit found:

- canonical generated views that do not exist
- runtime-required control files without durable contracts
- policy richness that is not yet runtime-consumable
- mission-authority fields that are not fully consumed everywhere
- scenario handling that exists implicitly but not coherently

Because Octon is still pre-1.0, a clean break is preferable to a long-lived dual
mode. One atomic completion cutover gives the repo:

- one live control model
- one mission-control file family
- one runtime routing path
- one operator read-model family
- one conformance baseline

## Resolved Open Questions

### 1. Continuation lease design
Resolved by adding `mission-control-lease-v1` and requiring lease state for any
active autonomous mission.

### 2. Intent register design
Resolved by adding `intent-register-v1` with versioned entries and binding
`intent_ref` on autonomous execution requests.

### 3. Scenario routing
Resolved by a derived scenario resolver under
`generated/effective/orchestration/missions/**`, not by a new authoritative
registry.

### 4. Autonomy burn calibration
Resolved by mission-class default profiles in `mission-autonomy.yml` plus
action-class modifiers from ACP policy, with per-mission override only through
repo-authoritative policy or explicit authorize-update.

### 5. Safe interrupt taxonomy
Resolved by standard boundary classes:
- `file_batch`
- `test_batch`
- `resource_batch`
- `environment_stage`
- `chunk_boundary`
- `api_page`
- `containment_step`
- `finalize_boundary`

Each action slice binds to one boundary class.

### 6. Recovery-window defaults
Resolved by policy defaults keyed by reversibility primitive and scenario family:

- repo-local reversible edits: `72h`
- canary/staged deploys: `24h`
- soft-deletes / detach / deprovision-pre-finalize: `168h`
- migration chunk rollback: `24h`
- external compensable sync: `24h`
- public or compensable communications: `4h`
- irreversible finalize: no recovery window; approval or break-glass only

### 7. Quorum independence
Resolved by policy rules requiring independent evidence sources, not merely
multiple votes. For ACP-2/ACP-3 paths, quorum members must not all derive from
the same tool, same model family, or same evidence stream when independence is
required.

### 8. External UX rule
Resolved by keeping all external clients derived-only; any binding action must
write into canonical repo control truth and emit control receipts.

## What This Proposal Changes

This proposal does **not** rename the model or replace the existing MSRAOM
spine. It completes it by requiring:

- contractization of the per-mission control family
- runtime consumption of mission-autonomy policy
- scheduler/directive semantics
- retained control-plane evidence
- generated mission/operator views
- effective scenario routing
- conformance tests and merge gates
- contradiction cleanup and stale reader alignment

## What It Does Not Change

- public-facing model name remains **Mission-Scoped Reversible Autonomy**
- ACP remains the durable execution-governance backbone
- `STAGE_ONLY` remains the humane fail-closed default
- historical run receipts remain retained without rewrite
- no second mutable control plane is added outside `/.octon/`

## Promotion Standard

The cutover should ship only when a reviewer can answer **yes** to all of these:

1. Does every runtime-required mission control file now have a durable schema,
   scaffold, validator, and writer?
2. Does the runtime use policy-derived scenario resolution rather than hidden
   hardcoded fallback behavior?
3. Do `Now / Next / Recent / Recover` and operator digests actually exist?
4. Do directives, schedule changes, breaker trips, safing changes, and
   break-glass activations emit retained control evidence?
5. Does the scenario suite prove behavior across routine, incident, migration,
   release, external, destructive, absent-human, late-feedback, and
   conflicting-human cases?

If any answer is no, the cutover is not complete.
