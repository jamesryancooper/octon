# Program Lifecycle Run

run_id: lifecycle-proposal-program-1780340449025-2f63bcfb
recorded_at: 2026-06-01T19:54:52.280128Z
lifecycle_id: proposal-program
execution_strategy: orchestrated-replan-loop
target: .octon/inputs/exploratory/proposals/architecture/proposal-program-runner-terminal-routing-and-recovery-hardening
executor: auto
execution_mode: gated-parallel
runnable_children: proposal-program-runner-publication-freshness-preflight
scheduler_phase: phase-3
skipped_blocked_children: proposal-program-runner-aggregate-terminal-blockers, proposal-program-runner-terminal-gap-map, proposal-program-runner-terminal-routing-tests, proposal-program-runner-workflow-retry-ids
aggregate_state: partial
final_verdict: step-budget-exhausted-continuable
stop_reason: dispatch-available

Required Child Completion:
- child_id: proposal-program-runner-aggregate-terminal-blockers; terminal: no; terminal_outcome: none; final_verdict: route-ready; selected_route: closeout-packet; blockers: stale-receipt
- child_id: proposal-program-runner-archive-observation-recovery; terminal: no; terminal_outcome: none; final_verdict: route-ready; selected_route: generate-packet-implementation-prompt; blockers: none
- child_id: proposal-program-runner-change-handoff-checkpoints; terminal: yes; terminal_outcome: archived; final_verdict: completed; selected_route: none; blockers: none
- child_id: proposal-program-runner-parent-review-churn; terminal: no; terminal_outcome: none; final_verdict: route-ready; selected_route: generate-packet-implementation-prompt; blockers: none
- child_id: proposal-program-runner-promotion-evidence-binding; terminal: yes; terminal_outcome: archived; final_verdict: completed; selected_route: none; blockers: none
- child_id: proposal-program-runner-publication-freshness-preflight; terminal: no; terminal_outcome: none; final_verdict: route-ready; selected_route: promote-proposal; blockers: none
- child_id: proposal-program-runner-terminal-gap-map; terminal: no; terminal_outcome: none; final_verdict: route-ready; selected_route: closeout-packet; blockers: stale-receipt
- child_id: proposal-program-runner-terminal-routing-tests; terminal: no; terminal_outcome: none; final_verdict: route-ready; selected_route: generate-packet-implementation-prompt; blockers: dependency-gate-unsatisfied,dependency-gate-unsatisfied
- child_id: proposal-program-runner-workflow-retry-ids; terminal: no; terminal_outcome: none; final_verdict: route-ready; selected_route: closeout-packet; blockers: stale-receipt

Aggregate Terminal Blockers:
path: .octon/state/evidence/runs/workflows/lifecycle-proposal-program-1780340449025-2f63bcfb/aggregate-terminal-blockers.yml
digest: sha256:f568764fad95309e05c2287a29660cfd90157ec8b9dfe2f5f62674bb817e5dc5
blocked_required_child_count: 7
authority_boundary: parent evidence summarizes only; child manifests, receipts, validation verdicts, promotion evidence, archive metadata, closeout authorization, and lifecycle outcomes remain child-owned

Blockers:
- scope: child; child_id: proposal-program-runner-aggregate-terminal-blockers; blocker_class: stale-receipt; recovery_route: closeout-packet
- scope: child; child_id: proposal-program-runner-terminal-gap-map; blocker_class: stale-receipt; recovery_route: closeout-packet
- scope: child; child_id: proposal-program-runner-terminal-routing-tests; blocker_class: dependency-gate-unsatisfied; recovery_route: none
- scope: child; child_id: proposal-program-runner-terminal-routing-tests; blocker_class: dependency-gate-unsatisfied; recovery_route: none
- scope: child; child_id: proposal-program-runner-workflow-retry-ids; blocker_class: stale-receipt; recovery_route: closeout-packet

Normalized Taxonomy:
- scope: child; child_id: proposal-program-runner-aggregate-terminal-blockers; raw_value: stale-receipt; normalized_blocker_class: stale-receipt; normalized_category: recoverable; disposition: autonomous/recoverable
- scope: child; child_id: proposal-program-runner-terminal-gap-map; raw_value: stale-receipt; normalized_blocker_class: stale-receipt; normalized_category: recoverable; disposition: autonomous/recoverable
- scope: child; child_id: proposal-program-runner-terminal-routing-tests; raw_value: dependency-gate-unsatisfied; normalized_blocker_class: dependency-gate-unsatisfied; normalized_category: recoverable; disposition: autonomous/recoverable
- scope: child; child_id: proposal-program-runner-terminal-routing-tests; raw_value: dependency-gate-unsatisfied; normalized_blocker_class: dependency-gate-unsatisfied; normalized_category: recoverable; disposition: autonomous/recoverable
- scope: child; child_id: proposal-program-runner-workflow-retry-ids; raw_value: stale-receipt; normalized_blocker_class: stale-receipt; normalized_category: recoverable; disposition: autonomous/recoverable

Program evidence coordinates child lifecycle work only. Child packet manifests, receipts, promotion targets, validation verdicts, and archive metadata remain child-owned.
