prompt_id: retained-run-evidence-index-materialization-clean-delivery-closeout-20260709T021335Z
target_packet: .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization
route: proposal-packet-delivery
target_outcome: cleaned
required_route: branch-no-pr
pr_fallback_allowed: false
generated_at: 2026-07-09T02:13:35Z

# Custom Closeout Prompt

Run clean delivery for the implemented packet
`.octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization`.

The target outcome is terminal, archived, landed/synced, branch-cleaned, and
worktree-clean. Use `proposal-packet-delivery` as the outer route and preserve
target-owned lifecycle authority throughout.

Do not claim closeout, archive readiness, archive, delivery, landing, sync,
branch cleanup, terminal proof, or `cleaned` unless each owning route has fresh
passing evidence.

## Current State

- Packet status is `implemented`.
- Durable promotion targets exist:
  - `.octon/framework/assurance/runtime/_ops/scripts/generate-retained-run-evidence-index.sh`
  - `.octon/framework/assurance/runtime/_ops/tests/test-generate-retained-run-evidence-index.sh`
- Current implementation-readiness, implementation-conformance, and
  post-implementation drift/churn validators pass.
- Current worktree hygiene classification for this packet is clean.
- No `support/proposal-closeout.md` exists yet.
- No `support/proposal-terminal-closeout.yml` exists yet.
- The packet is not archived yet.

## Known Blockers To Clear First

1. Strict pre-integration architecture receipt is stale.
   `support/pre-integration-architecture-review.yml#packet_digest` currently
   records `sha256:8e83f9a93af3bcaa2e76b8e0e538775e8f631f03a5c622ea78b9b6ede76515fb`,
   while the current packet digest observed by
   `validate-architectural-review-receipts.sh` is
   `sha256:4025eb2bae471e6adee514dc5727bd947bf24370ff081652c6c95cd5d40b5ff5`.
   Refresh this receipt through the owning strict architecture review route at
   the current stable packet digest before any archive-ready claim.

2. Terminal freshness currently fails because generated proposal artifacts are
   stale for this packet. The owning repair route is:

   ```sh
   bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh --proposal .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization --write
   ```

3. Terminal freshness currently reports unresolved `proposal.yml#related_proposals`
   IDs:
   - `proposal-program-freshness-readiness-projection`
   - `lifecycle-run-evidence-index-contract`

   Resolve these before archive readiness. Do not fabricate proposal manifests
   to satisfy the validator. Prefer a current canonical successor if one exists
   in the proposal registry. If no current proposal manifest exists, perform the
   smallest proposal metadata correction that removes or reclassifies these as
   non-authoritative source lineage, then rerun all packet digest, proposal
   standard, architecture, implementation-readiness, conformance, drift, and
   terminal freshness gates.

4. `architecture-proposal.yml#parent_program_ref`,
   `resources/source-lineage.md`, and the stale architecture review evidence
   reference the parent program at its historical active path. The current
   manifested parent is archived at
   `.octon/inputs/exploratory/proposals/.archive/architecture/operator-free-packet-lifecycle-autonomy`.
   Normalize references only through an explicit packet metadata/evidence
   correction, then rerun digest-bound gates. Do not treat archived parent
   evidence as child lifecycle authority.

## Required Outer Route

Use the canonical command shape:

```text
/proposal-packet-delivery target=.octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization outcome=cleaned route=branch-no-pr profile=<profile-path> run-id=<delivery-run-id>
```

If the slash command is unavailable, execute the same stage order from
`.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/workflow.yml`.

Use a stable delivery run id such as:

```text
20260709T021335Z-proposal-packet-delivery-retained-run-evidence-index-materialization
```

Write the delivery profile under the delivery evidence bundle, for example:

```text
.octon/state/evidence/runs/workflows/20260709T021335Z-proposal-packet-delivery-retained-run-evidence-index-materialization/delivery-profile.yml
```

The profile must validate with:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-profile.sh --profile <profile-path>
```

Minimum profile content:

```yaml
schema_version: proposal-packet-delivery-profile-v1
profile_id: retained-run-evidence-index-materialization-clean-delivery
created_at: "2026-07-09T02:13:35Z"
target_packet_path: .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization
target_outcome: cleaned
route_preference:
  work_unit_route: branch-no-pr
  landing_route: branch-no-pr
  pr_creation_allowed: false
pr_policy:
  mode: forbid-pr
  allow_pr_creation: false
  fallback_to_pr: false
stash_policy:
  mode: forbidden
  preserve_unrelated_work: true
packet_execution:
  replan_after_material_changes: true
  target_owned_receipts_required: true
  aggregate_receipt_replaces_target_receipts: false
  self_authorization_allowed: false
packet_state_routing:
  pre_archive_states:
    - implemented
    - closeout-ready
    - archive-ready
  already_archived_states:
    - archived
    - change-closeout-pending
    - landed
    - synced
  pre_archive_required_owners:
    - closeout-packet
    - proposal-packet-terminal-closeout
    - archive-proposal
  already_archived_required_owners:
    - archive-proposal
    - closeout-change
    - closeout-worktree
    - repo-hygiene-cleanup
  missing_state_evidence_outcome: blocked
  blocked_receipt_requires_explicit_blockers: true
  blocked_receipt_requires_next_owning_lifecycle: true
required_proposal_validators:
  - validate-proposal-standard.sh
  - validate-proposal-review-gate.sh
  - validate-proposal-implementation-readiness.sh
  - validate-architecture-proposal.sh
  - validate-architectural-review-receipts.sh
required_implementation_validators:
  - validate-proposal-implementation-conformance.sh
  - validate-proposal-post-implementation-drift.sh
  - validate-proposal-lifecycle-terminal-freshness.sh
publication_checks:
  owning_publishers_only: true
  generated_outputs_are_non_authority: true
  freshness_validator: validate-proposal-lifecycle-terminal-freshness.sh
  direct_generated_output_edits_allowed: false
mechanism_integration_checks:
  required_when_applicable: true
  receipt_required_when_required: true
promotion_requirements:
  promote_proposal_required: true
  implemented_status_required: true
  promotion_receipt_required: true
closeout_requirements:
  packet_closeout_required: true
  terminal_closeout_required: true
  archive_lifecycle_required: true
  change_closeout_required: true
  delegate_git_mutation_to_change_closeout: true
hygiene_requirements:
  cleanup_authorization_required: true
  classification_alone_authorizes_deletion: false
terminal_proof_requirements:
  terminal_current_state_proof_required: true
  worktree_hygiene_required: true
final_sync_requirements:
  main_origin_landed_ref_equality_required: true
non_authority_boundaries:
  proposal_local_files: non-authority
  generated_prompts: non-authority
  generated_outputs: derived-only-non-authority
  dashboards: non-authority
  chat_or_model_memory: non-authority
```

## Stage Plan

### 1. Preflight And Authority Binding

- Read repository ingress and relevant lifecycle skills/workflows.
- Select `release_state: pre-1.0` and `change_profile: atomic`.
- Confirm the worktree state with `git status --short`.
- Preserve unrelated or ambiguous work. Do not stash.
- Use `branch-no-pr` for Change closeout. Do not create a PR.
- Treat this prompt, proposal-local support files, generated outputs, host
  state, chat, model memory, and dashboards as non-authority.

### 2. Revalidate Current Packet State

Run from the repo root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/tests/test-generate-retained-run-evidence-index.sh
```

If the strict architecture review receipt is stale, refresh it through the
owning review route before continuing. If any implementation receipt is stale,
missing, failing, or unresolved, stop and route to packet correction or
implementation rerun instead of closeout.

### 3. Repair Terminal Freshness Before Closeout

Resolve the `related_proposals` and archived parent reference issues described
above, then refresh generated proposal artifacts only through the canonical
generator:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh --proposal .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization --write
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --proposal .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization --targeted --run-registry-check
```

If generated artifact freshness, related proposal resolution, or archived parent
reference normalization remains blocked, write a blocked delivery receipt with
the next owning lifecycle. Do not proceed to archive-ready.

### 4. Packet Closeout

Route packet closeout through `octon-proposal-lifecycle-closeout-packet`.

Required packet closeout evidence:

- Fresh passing implementation-grade receipt.
- Fresh accepted proposal review evidence.
- Fresh passing strict architecture review receipt.
- Fresh passing implementation conformance receipt.
- Fresh passing post-implementation drift/churn receipt.
- Fresh generated proposal artifact and terminal freshness evidence.
- Worktree hygiene classification:

  ```sh
  bash .octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh --target .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization --lifecycle proposal-packet --format yaml
  ```

Write or refresh:

```text
.octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization/support/proposal-closeout.md
```

Successful packet closeout must record:

- `verdict: pass`
- `archive_authorized: yes`
- `target_outcome: archive-ready`
- `lifecycle_outcome: archive-ready`
- `archive_disposition: implemented`
- `promotion_evidence` containing only durable repo-relative evidence outside
  the packet:
  - `.octon/framework/assurance/runtime/_ops/scripts/generate-retained-run-evidence-index.sh`
  - `.octon/framework/assurance/runtime/_ops/tests/test-generate-retained-run-evidence-index.sh`

Packet closeout must not move the packet to `.archive`, mutate Git, delete
residue, edit generated outputs by hand, or claim `cleaned`.

After writing `support/proposal-closeout.md`, rerun:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh --proposal .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization --write
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --proposal .octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization --targeted --run-registry-check
```

### 5. Terminal Closeout

Route terminal readiness through `proposal-packet-terminal-closeout`.

Use an optional terminal profile if needed; it must validate with:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-profile.sh --profile <terminal-profile-path>
```

Terminal closeout must write:

```text
.octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization/support/proposal-terminal-closeout.yml
```

Successful terminal closeout must record:

- `terminal_verdict: archive-ready`
- `archive_ready: yes`
- `blocker.class: none`
- archive relocation not performed
- target-owned receipts are summarized but not replaced

Validate the terminal receipt with:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-receipt.sh --receipt <terminal-receipt>
```

Terminal closeout must not move the packet, mutate `proposal.yml#status`, stage,
commit, push, delete residue, or claim `cleaned`.

### 6. Archive Proposal

After terminal closeout reports archive-ready, route archival through
`archive-proposal` with:

```text
proposal_path=.octon/inputs/exploratory/proposals/architecture/retained-run-evidence-index-materialization
disposition=implemented
promotion_evidence=.octon/framework/assurance/runtime/_ops/scripts/generate-retained-run-evidence-index.sh,.octon/framework/assurance/runtime/_ops/tests/test-generate-retained-run-evidence-index.sh
```

Archive-proposal owns:

- moving the packet to
  `.octon/inputs/exploratory/proposals/.archive/architecture/retained-run-evidence-index-materialization`
- rewriting `proposal.yml` to `status: archived` with coherent archive metadata
- regenerating archived artifact catalog/index/spine
- regenerating `generated/proposals/registry.yml`
- validating archived terminal freshness:

  ```sh
  bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --proposal .octon/inputs/exploratory/proposals/.archive/architecture/retained-run-evidence-index-materialization --run-registry-check
  ```

Do not archive by manual `mv`; use the archive route or faithfully execute its
workflow contract.

### 7. Change Closeout And Clean Worktree

After archive relocation and generated registry freshness pass, route the
coherent Change through `closeout-change` or `closeout-worktree` with
`target_lifecycle_outcome: cleaned` and route `branch-no-pr`.

Change closeout owns:

- staging the coherent change set
- commit creation
- branch publication
- hosted no-PR landing authorization
- exact source-SHA hosted checks
- hosted no-PR landing
- final sync
- rollback handle
- branch cleanup authorization and cleanup
- terminal current-state proof
- final worktree hygiene proof

Repo hygiene deletion is allowed only through `repo-hygiene-cleanup` with a
valid cleanup authorization. Classification alone never authorizes deletion.

Do not claim `landed`, `synced`, or `cleaned` until closeout evidence proves:

- branch landing authorization exists
- landed ref is recorded
- final sync proves local `main`, `origin/main`, and landed ref equality
- branch cleanup authorization and cleanup disposition exist
- rollback posture exists
- terminal current-state proof exists and is fresh after the final mutation
- worktree is clean

### 8. Final Delivery Receipt

Emit and validate the aggregate delivery receipt:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-receipt.sh --receipt <delivery-receipt>
```

The aggregate receipt may summarize target-owned receipts and route-owned
terminal proof, but it must not replace packet closeout, terminal closeout,
archive, Change closeout, cleanup authorization, final sync, or terminal proof
evidence.

## Refusal Criteria

Stop with `blocked` and name the next owning lifecycle if any of these remain
true:

- strict architecture review receipt is stale or failing
- unresolved `related_proposals` IDs remain in `proposal.yml`
- generated proposal artifacts are stale
- terminal freshness fails
- packet closeout receipt is missing, failing, or lacks `archive_authorized: yes`
- terminal closeout receipt is missing, failing, or lacks `archive_ready: yes`
- archive relocation is incomplete or stale
- generated proposal registry is stale after archive
- Change closeout has not produced landing/final sync/cleanup/terminal proof
- repo hygiene residue needs deletion but lacks cleanup authorization
- worktree is dirty
- PR fallback is required
- any evidence would depend on proposal-local files, generated outputs, host
  state, chat, model memory, dashboards, or tool state as authority

## Success Condition

The run is complete only when all are true:

- packet is archived under
  `.octon/inputs/exploratory/proposals/.archive/architecture/retained-run-evidence-index-materialization`
- archived `proposal.yml` records `status: archived` and
  `disposition: implemented`
- `support/proposal-closeout.md` and `support/proposal-terminal-closeout.yml`
  exist in the archived packet and validate through their owning routes
- `generated/proposals/registry.yml` is fresh
- proposal artifact outputs are fresh for the archived packet
- aggregate delivery receipt validates
- Change closeout receipt validates
- local `main`, `origin/main`, and landed ref are aligned
- source branch cleanup is authorized and completed or explicitly retained with
  evidence
- final `git status --short` is empty
