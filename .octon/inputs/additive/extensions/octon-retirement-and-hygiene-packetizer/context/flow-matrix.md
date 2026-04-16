# Flow Matrix

| Flow | Primary Inputs | Primary Outputs | Authority Boundary |
| --- | --- | --- | --- |
| `scan-to-reconciliation` | `repo-hygiene scan`, registry/register, claim gate | reconciliation summary under skill evidence | summary only, no packet draft |
| `audit-to-packet-draft` | repo-hygiene audit artifacts, registry/register, closeout reviews, claim gate | `cleanup-packet-inputs.yml`, draft summary, optional migration proposal draft | non-authoritative draft only |
| `registry-gap-analysis` | registry, register, latest review packet refs, optional audit evidence | `gap-analysis.md`, `gap-analysis.yml` | analysis only, no governance mutation |
| `ablation-plan-draft` | audit artifacts or packet attachment, protected-surface rules, ablation workflow | `ablation-plan.md`, `ablation-targets.yml`, optional migration proposal draft | guarded planning only, no delete execution |

## Guardrails

- Protected surfaces from `repo-hygiene.yml` stay `never-delete`.
- `claim_adjacent: true` entries from `retirement-register.yml` stay
  `never-delete`.
- Any raw `safe-to-delete` signal is rewritten into a governed ablation-review
  candidate in extension-authored drafts.
