verdict: blocked
closed_at: 2026-06-16T14:42:31Z
archive_authorized: no
target_outcome: archive-ready
run_id: lifecycle-proposal-packet-20260616-closeout-friction-remediation-closeout-rerun
selected_git_route: stage-only-escalate
worktree_hygiene_verdict: blocked
worktree_hygiene_blocker_class: worktree-hygiene-blocked
worktree_hygiene_owned_path_count: 4
worktree_hygiene_in_scope_path_count: 36
worktree_hygiene_retained_fixture_path_count: 0
worktree_hygiene_foreign_path_count: 149
worktree_hygiene_foreign_fingerprint: sha256:63382ee76449927db963107d6c7c4f6e675f64b6d6dfc3c515f99059a3d2bb05
worktree_hygiene_evidence: .octon/state/evidence/runs/skills/lifecycle-proposal-packet-20260616-closeout-friction-remediation-closeout-rerun-worktree-hygiene.yml
next_route_condition: closeout-change or operator scope resolution
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
  git_diff_check: pass
  publication_freshness_gates: not_completed_after_blocking_current_state_failure
  repo_hygiene_governance: not_completed_after_blocking_current_state_failure
  proposal_lifecycle_terminal_freshness: not_completed_after_blocking_current_state_failure
  run_health_read_model: fail
blockers:
  - class: worktree-hygiene-blocked
    detail: The read-only proposal worktree hygiene classifier reported 149 foreign-or-ambiguous paths, so archive authorization is refused.
    evidence_ref: .octon/state/evidence/runs/skills/lifecycle-proposal-packet-20260616-closeout-friction-remediation-closeout-rerun-worktree-hygiene.yml
  - class: generated-run-health-digest-drift
    detail: validate-run-health-read-model.sh --no-report reported 943 errors, including digest drift in generated run health projections for runtime_route_bundle and pack_routes; negative controls were skipped because no valid health file exists.
    evidence_ref: terminal validator output from this closeout run
actions_not_performed:
  - archive
  - stage
  - commit
  - push
  - delete
  - reset
  - worktree_cleanup
