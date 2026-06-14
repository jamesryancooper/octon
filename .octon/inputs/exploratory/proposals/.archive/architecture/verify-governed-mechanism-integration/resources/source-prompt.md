# Source Recommendation

The source recommendation proposed `Verify Governed Mechanism Integration`,
slug `verify-governed-mechanism-integration`, as a native closeout verification
workflow and validator suite for proposals that add or materially change a
governed cross-surface mechanism.

Key source points retained for lineage:

- make it a workflow-backed proposal closeout gate, not a new control plane;
- compose implementation conformance, drift/churn, generated publication
  checks, current-state mechanism architecture review, and optional lifecycle
  postmortem evidence;
- run at proposal review, after implementation before closeout, before archive,
  and after merge or terminal cleaned outcome;
- hard-gate deterministic facts such as mechanism index coverage, product
  feature documentation, workflow registration, schema validation, executable
  validators, generated projection freshness, lifecycle hooks, evidence roots,
  extension boundaries, and non-authority classification;
- keep design quality, usability, documentation polish, future workflow ideas,
  and optional post-integration architecture findings advisory;
- write a strict support receipt at
  `support/governed-mechanism-integration-evaluation.yml`;
- retain workflow evidence under
  `.octon/state/evidence/runs/workflows/<run-id>/governed-mechanism-integration/<mechanism-id>/`;
- use `review-finding-v1` and `review-disposition-v1` rather than creating a
  parallel finding model;
- declare customization through `governed-mechanism-integration-profile-v1`;
- keep durable profiles near the governed mechanism index after
  implementation;
- fail closed when a required surface class is omitted without an explicit
  `not_applicable` rationale;
- add one targeted proposal packet covering the workflow, profile schema,
  receipt schema, validators, lifecycle hook, terminal freshness hook, and docs
  updates.

This source context is non-authoritative. Durable semantics must come from
promoted workflow, schema, validator, lifecycle, and documentation surfaces.
