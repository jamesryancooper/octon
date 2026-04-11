# Follow-up Gates

## Explicitly deferred items

| Item | Why deferred | Blocking? | Reopen condition |
| --- | --- | --- | --- |
| Automatic intra-file Rust patch generation | This proposal is for architecture and governance, not for auto-edit synthesis. | no | reopen if the landed capability proves stable and an auto-patch design is desired |
| Git history or packfile shrink / purge work | High-risk and potentially irreversible; outside ordinary repo hygiene. | no | reopen only under a separate break-glass or ACP-4 style process |
| Hard lint promotion to `-D warnings` across the whole Rust workspace | Baseline audit should land first to avoid masking true architectural work under mass lint churn. | no | reopen after several clean audit cycles |
| Tool-specific ignore metadata for `cargo machete` / `cargo udeps` | Useful after baseline findings are known; premature before real scans. | no | reopen after baseline audit identifies stable false positives |
| Additional language ecosystems beyond current Rust + Shell focus | Not part of the current user request or repo-grounded baseline. | no | reopen if new durable language surfaces become claim-relevant |

## Future hardening or widening gates

1. **Workflow-scope purity gate** — if proposal-governed change control later
   requires a separate repo-local implementation packet for `.github/**`
   integrations, open that linked packet before promotion, but do not alter the
   architecture defined here.
2. **Tighter lint gate** — only after baseline stabilization may workspace lint
   hardening or deny-by-default lint promotion be considered.
3. **Expanded detector gate** — new detectors must prove they do not create a
   second control plane or widen support scope.
4. **Support widening gate** — any attempt to add packs, locales, workload
   classes, or adapters remains governed by support-target review and is out of
   scope for this packet.

## Out-of-scope items and rationale

- generalized repository janitor automation not specific to Octon governance;
- Python-centric cleanup tooling;
- ad hoc delete scripts outside the repo-native command lane;
- rewriting historical evidence to make past posture appear cleaner than it was.

## Why these items do not block the current packet target state

The target state for this proposal is the existence of a governed capability
family plus its initial evidence burden. None of the deferred items above is
required for that architecture to exist, remain bounded, or operate safely.
They are improvements or adjacent programs, not missing core obligations.
