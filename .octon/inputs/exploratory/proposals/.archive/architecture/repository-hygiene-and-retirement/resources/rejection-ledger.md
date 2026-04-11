# Rejection Ledger

| Rejected option | Why rejected | Replacement adopted |
| --- | --- | --- |
| Direct Ruff/Vulture translation | Python-specific and not aligned with the live Rust + Shell repository. | Rust + Shell native detector stack under a repo-native command. |
| New standalone transitional registry | The live repo already has retirement policy, registry/register, reviews, ablation workflow, claim gate, and release lineage. | Extend the existing build-to-delete retirement spine. |
| Skill-first or reusable additive-pack implementation | The problem is repository-specific and the live repo already reserves a command lane for repo-owned commands; skills are currently empty. | Repo-native command under `instance/capabilities/runtime/commands/**`. |
| Auto-delete in the command | Violates the separation between detection and destructive action and conflicts with ACP/ablation expectations. | Read-only `scan`/`enforce`, evidence-emitting `audit`, and stage-only `packetize`. |
| Mixed `.octon/**` and `.github/**` active proposal targets | Forbidden by the live proposal standard. | Keep official promotion targets under `.octon/**`; treat workflow edits as dependent implementation surfaces. |
| Support widening to add new packs or host adapters | Not required to solve the problem and would expand claim scope. | Reuse admitted `repo`, `shell`, and `telemetry` packs plus existing reviews. |
