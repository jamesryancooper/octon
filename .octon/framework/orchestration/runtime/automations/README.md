# Orchestration Automations

Schema-backed unattended launch policy for schedule and event-triggered
workflow execution.

## Authority Order

`manifest.yml -> registry.yml -> automation.yml + trigger.yml + bindings.yml + policy.yml -> state/`

`automation.yml` owns identity and workflow target.
`trigger.yml` owns event or schedule selection.
`bindings.yml` owns defaults and event-to-parameter mapping.
`policy.yml` owns overlap, idempotency, retry, and incident escalation policy.
