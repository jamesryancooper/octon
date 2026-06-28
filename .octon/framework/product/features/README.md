# Product Feature Catalog

This directory is Octon's central navigation catalog for cross-surface product
features.

The catalog answers four questions for agents and operators:

- what the mechanism is called
- what it does
- where the authoritative and runtime surfaces live
- what validation proves the checked-in implementation

## Files

- `catalog.yml`: machine-readable feature index.
- `<feature-id>.md`: human-readable feature notes for individual mechanisms.
- `proposal-packet-terminal-closeout.md`: terminal readiness receipt for
  implemented proposal packets before archive relocation.
- `fixture-retention-closeout.md`: evidence-only retention receipt for
  temporary proposal fixtures used as validation residue.
- `governed-proposal-delivery.md`: accepted proposal program delivery
  coordination through target-owned lifecycles, closeout, archive handoff,
  Change closeout, final sync, cleanup, and terminal proof.
- `governed-mechanism-integration-verification.md`: cross-surface mechanism
  integration verification before proposal closeout/archive readiness.
- `architectural-review-mechanism.md`: navigation-only entry for native
  architectural review doctrine, modes, invocation aliases, validators, and
  generated projections.

## Cataloged Feature Notes

- `engagement-change-package-compiler.md`: Engagement Change Package Compiler.
- `mission-autonomy-and-planning.md`: Mission Autonomy and Mission Plan Compiler.
- `continuous-stewardship-runtime.md`: Continuous Stewardship Runtime.
- `connector-admission-runtime.md`: Connector Admission Runtime.
- `self-evolution-runtime.md`: Self-Evolution Runtime.
- `trust-compatibility-and-portable-proof.md`: Trust, Compatibility, Federation, and Portable Proof.
- `runtime-effective-publication-and-routing.md`: Runtime Effective Publication and Capability Routing.
- `operator-read-models.md`: Operator Read Models and Run Health Views.
- `run-first-runtime-lifecycle.md`: Run-First Runtime Lifecycle and Canonical Run Binding.
- `repo-hygiene-cleanup.md`: Repo Hygiene Cleanup Authorization.
- `host-tool-provisioning.md`: Host Tool Provisioning.
- `repository-bootstrap-and-harness-portability.md`: Repository Bootstrap and Harness Portability.
- `grounded-query-retrieval.md`: Grounded Query Retrieval.
- `deterministic-filesystem-observation.md`: Deterministic Filesystem Observation.
- `native-agent-platform-interop.md`: Native Agent Platform Interop.
- `workflow-authoring-and-studio.md`: Workflow Authoring and Octon Studio.
- `native-service-runtime-and-catalog.md`: Native Service Runtime and Catalog.
- `support-universe-admission-and-disclosure.md`: Support Universe Admission and Disclosure.
- `context-pack-builder-and-binding.md`: Context Pack Builder and Binding.
- `execution-authorization-and-effect-tokens.md`: Execution Authorization and Effect Tokens.
- `evidence-store-and-proof-plane.md`: Evidence Store and Proof Plane.
- `governed-promotion-activation-and-recertification.md`: Governed Promotion, Activation, and Recertification.
- `workflow-statechart-task-harness.md`: Workflow Statechart and Task Harness.
- `proposal-packet-authoring-validation-archival.md`: Proposal Packet Authoring, Validation, and Archival.

## Non-Authority Posture

This catalog is navigation-only. It does not create runtime discovery,
publication authority, support-target admission, policy authority, or durable
execution evidence. Generated outputs remain derived-only, raw inputs remain
non-authoritative, and proposal-local receipts remain evidence only.

For authority-class and cross-surface boundary detail, use
`.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/`.
That architecture index uses `governed cross-surface mechanisms`; this product
catalog continues to use `product features`.

## Update Rule

When adding or changing a cross-surface feature entry, update `catalog.yml`,
add or update the matching feature note when helpful, and run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
```
