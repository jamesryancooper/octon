# Existing Lifecycle Run Admission v1

`octon run bind-lifecycle --run-id <id> --rollback-posture <repo-relative-path>`
is the sole canonical route for binding an already-created proposal packet
lifecycle run to the consequential run-contract system without changing its
identity.

The runtime derives lifecycle type, target, selected route, delegation proof,
and effective write scope from canonical retained state. Callers cannot supply
those values. Before any authority artifact is written, the runtime validates
the checkpoint, full event hash chain, route convergence, delegation proof,
proposal manifest, exact promotion-target scope, rollback posture, and absence
of completed implementation effects. It then digest-binds those inputs into a
v3 run contract, v2 manifest, runtime state, authority bundle, and retained
admission receipt.

For `run-packet-implementation`, the lifecycle executor owns rollback-posture
materialization. Only after delegation, evidence, context, and scope gates pass
does it write the complete canonical
`.octon/state/control/execution/runs/<id>/rollback-posture.yml`, derived from
the packet rollback plan and retained delegation proof. `bind-lifecycle`
accepts only that exact run-owned path and rejects caller-authored or
cross-run posture files.

An exact existing binding is an idempotent success. Partial or conflicting
artifacts fail closed. This route does not mutate checkpoints or event logs,
does not use workflow compatibility, and grants no Git, hosted-provider,
cleanup, archive, connector, or external-effect authority.
