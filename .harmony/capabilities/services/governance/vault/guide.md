# Vault — Secrets Plumbing (Lightweight)

- **Purpose:** Simple wrappers for env/secrets; scanning & rotation hooks.
- **Responsibilities:** inject secrets safely to tools; detect leaks.
- **Integrates with:** Guard, Tool.
- **I/O:** masked env for runs.
- **Wins:** Safer by default.
- **Harmony default:** Pair with Guard and Policy to enforce secret handling in CI and PR reviews.
