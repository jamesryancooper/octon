# VaultKit — Secrets Plumbing (Lightweight)

- **Purpose:** Simple wrappers for env/secrets; scanning & rotation hooks.
- **Responsibilities:** inject secrets safely to tools; detect leaks.
- **Integrates with:** GuardKit, ToolKit.
- **I/O:** masked env for runs.
- **Wins:** Safer by default.
- **Harmony default:** Pair with GuardKit and PolicyKit to enforce secret handling in CI and PR reviews.
