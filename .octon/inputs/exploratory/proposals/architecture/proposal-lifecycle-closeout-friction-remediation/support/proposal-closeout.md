verdict: blocked
closed_at: 2026-06-16T15:29:26Z
archive_authorized: no
archive_disposition: implemented
target_outcome: archive-ready
lifecycle_outcome: blocked
run_id: lifecycle-proposal-packet-1781622378859-09c90209
prompt_set_id: octon-proposal-lifecycle-closeout-packet
prompt_bundle_sha256: sha256:ab81b653f770ba751ba03a9c5dc3ffc500e5b7425a7cb54a31f82a14d22f8bf0
release_state: pre-1.0
change_profile: atomic
selected_git_route: stage-only-escalate
validation_blocker_class: worktree-hygiene-blocked
validation_blocker_count: 1
implementation_readiness_verdict: pass
implementation_conformance_verdict: pass
post_implementation_drift_verdict: pass
governed_mechanism_integration_verdict: not_required
terminal_freshness_verdict: pass
proposal_review_gate_verdict: pass
worktree_hygiene_verdict: blocked
worktree_hygiene_blocker_class: worktree-hygiene-blocked
worktree_hygiene_owned_path_count: 10
worktree_hygiene_in_scope_path_count: 1
worktree_hygiene_retained_fixture_path_count: 0
worktree_hygiene_foreign_path_count: 2
worktree_hygiene_foreign_fingerprint: sha256:501aa2178a53f8cb0ee1b3e2cc38c5d30c69298c314ced82dd4f2935d30ddf1b
worktree_hygiene_evidence: .octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/lifecycle-proposal-packet-1781622378859-09c90209/worktree-hygiene.yml
validation_evidence: .octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/lifecycle-proposal-packet-1781622378859-09c90209/command-status.yml
next_route_condition: closeout-change or operator scope resolution for generated proposal artifact changes
promotion_evidence: []
validation_summary:
  prompt_capsule_digest_check: pass
  proposal_standard_target: pass_with_warning
  architecture_proposal: pass
  proposal_review_gate: pass
  implementation_readiness: pass
  implementation_conformance: pass
  post_implementation_drift_churn: pass
  terminal_closeout_workflow: pass
  archive_proposal_workflow: pass
  publication_freshness_gates: pass
  repo_hygiene_governance: pass
  proposal_artifact_index_freshness: pass
  proposal_artifact_spine_validation: pass
  proposal_lifecycle_terminal_freshness: pass
  git_diff_check: pass
  worktree_hygiene: blocked
blockers:
  - class: worktree-hygiene-blocked
    detail: >-
      The read-only proposal worktree hygiene classifier reports two
      foreign-or-ambiguous modified generated proposal artifact paths:
      .octon/generated/proposals/artifacts/architecture/proposal-lifecycle-closeout-friction-remediation/proposal-artifact-index.yml
      and
      .octon/generated/proposals/artifacts/architecture/proposal-lifecycle-closeout-friction-remediation/proposal-program-spine.yml.
      Archive authorization is refused until those generated artifact changes
      are resolved through Change closeout or explicit operator scope
      resolution.
    evidence_ref: .octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/lifecycle-proposal-packet-1781622378859-09c90209/worktree-hygiene.yml
cleared_blockers:
  - class: generated-proposal-artifact-stale
    detail: >-
      The owning generator refreshed the target proposal artifact index and
      program spine, and
      validate-proposal-lifecycle-terminal-freshness.sh --proposal
      .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-closeout-friction-remediation
      --run-registry-check now reports checked=1 errors=0.
    evidence_ref: .octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/lifecycle-proposal-packet-1781622378859-09c90209/command-status.yml
cleanup_summary: >-
  No archive move, staging, commit, push, PR, merge, branch cleanup,
  hosted-provider action, Git ref mutation, direct generated-output hand edit,
  deletion, or worktree cleanup was performed by this packet closeout route.
  The canonical proposal artifact generator refreshed the target generated
  proposal artifacts to clear terminal freshness, but those modified generated
  files remain outside this route's hygiene scope and therefore block archive
  authorization.
actions_not_performed:
  - archive
  - stage
  - commit
  - push
  - delete
  - reset
  - direct_generated_output_edit
  - worktree_cleanup
