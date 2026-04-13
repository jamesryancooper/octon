# Coverage Traceability Matrix

| Source artifact evidence | Extraction output | Verification output | Current Octon evidence | Packet decision | Proposed durable targets | Acceptance / closure proof |
|---|---|---|---|---|---|---|
| `claw-code` mock parity harness, scenario manifest, parity diff tooling | parity harness selected | survives as `Adapt` | Octon lab scenario registry + runtime proof pack exist | adapt | repo-shell scenario pack + scenario workflow + registry edits | retained scenario-proof bundle + publication receipt |
| `permission_enforcer.rs` path/command gating | permission enforcement selected | survives as `Adapt` | repo-shell adapter exists | adapt | repo-shell execution-class policy + adapter/spec/suite edits | deterministic classifier tests + policy/run receipts |
| `README.md` + `USAGE.md` doctor first-run guidance | doctor/preflight selected | corrected to `Adapt` | START + agent-led-happy-path exist | adapt | bootstrap-doctor workflow + onboarding updates | retained readiness receipt + successful onboarding run |
| `ROADMAP.md` failure taxonomy and degraded reporting | missed upstream | added by verification | failure taxonomy + reporting policy exist | adapt | taxonomy/reporting expansion + workflow summary requirements | operator digests cite failure classes and retained evidence |
| `ROADMAP.md` + `stale_branch.rs` branch freshness before blame | missed upstream | added by verification | no freshness gate found; only branch closeout prompt exists | adapt | branch-freshness policy + repo-consequential-preflight workflow + task workflow edits | freshness gate blocks/warns correctly and emits retained receipt |
