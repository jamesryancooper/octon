---
title: Incidents
description: Canonical Octon incident governance contract for severity, authority, escalation, containment, and closure.
---

# Incidents

This document is the canonical Octon incident governance contract.

It defines:

- what counts as an incident
- how incident severity and lifecycle work
- which actions may be automated
- which actions require explicit human acceptance
- what evidence is required before closure

It does not prescribe product-specific rollback commands. Those belong in
`production-incident-runbook.md`.

## Purpose

An incident is an abnormal condition that requires explicit containment,
escalation, mitigation, or closure handling outside the normal delivery flow.

Incidents exist to keep exception handling:

- operator-visible
- evidence-backed
- policy-bounded
- separate from routine mission or workflow execution

## Severity Model

| Severity | Meaning | Typical Response Posture |
|---|---|---|
| `sev0` | Catastrophic system-wide or safety/compliance impact | immediate containment, mandatory human escalation |
| `sev1` | Critical user, reliability, or security impact | immediate containment, human oversight required |
| `sev2` | Significant but bounded impact | prompt mitigation, explicit owner required |
| `sev3` | Minor or localized abnormal condition | monitor, mitigate, and close with evidence |

Severity must always be explicit.

## Lifecycle

Canonical lifecycle:

```text
open -> acknowledged -> mitigating -> monitoring -> resolved -> closed
open -> acknowledged -> cancelled
```

Definitions:

- `open`: incident is created and awaiting ownership
- `acknowledged`: an owner has accepted responsibility
- `mitigating`: containment, rollback, or remediation work is underway
- `monitoring`: active mitigation is complete and the system is being observed
- `resolved`: technical issue is mitigated and remaining work is documentation or follow-up
- `closed`: closure evidence is complete and closure authority has approved
- `cancelled`: incident record was opened unnecessarily or superseded before full handling

## Authority Boundaries

### Allowed automated actions

Automation may:

- propose incident creation or enrichment
- propose severity changes
- launch policy-permitted containment or rollback workflows
- attach run, mission, and decision evidence
- recommend closure when criteria appear satisfied

### Human-required actions

A human or explicit policy-backed approval is required for:

- `sev0` and `sev1` closure
- final transition to `closed`
- any break-glass or override action not already policy-covered
- severity downgrades that materially reduce response posture
- waiving missing remediation evidence

Incidents may coordinate execution. They do not self-authorize policy
exceptions.

## Evidence Requirements

Every incident should retain:

- explicit `incident_id`, `severity`, `status`, and `owner`
- timeline of major status or severity changes
- links to triggering runs or other initiating evidence
- links to containment or remediation workflows and runs
- linked missions when follow-up becomes multi-session work

Closure requires:

- closure summary
- linked remediation evidence or explicit waiver
- linked runs or explicit note that none exist
- `closed_at`
- `closed_by`

## Containment And Closure Rules

- Containment actions should favor the smallest reversible intervention first.
- Rollback may be automated only when already covered by policy and evidence requirements.
- Incident closure must fail closed when required evidence is missing.
- Closing an incident must not delete or rewrite lineage.
- Follow-up work larger than one bounded run should move into mission state, not remain hidden in the incident.

## Relationship To Runtime State

If Octon later promotes a runtime `incidents/` surface, this file remains the
governance authority for:

- severity semantics
- lifecycle rules
- escalation thresholds
- closure authority
- evidence requirements

Runtime incident objects may project status and linkage. They do not replace
this governance contract.

## Operational Runbook

Use `production-incident-runbook.md` for product-specific operational response
steps such as rollback, feature flag handling, and production investigation
commands.
