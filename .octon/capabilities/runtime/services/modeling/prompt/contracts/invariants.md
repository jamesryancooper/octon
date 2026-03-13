# Prompt Invariants

1. `compile` requires a non-empty `promptId`.
2. Output always includes `promptId`, `content`, and `messages`.
3. `messages` preserves deterministic role ordering (`system`, then `user`).
4. `tokens.estimated` is always a positive integer.
5. `hash` is emitted only when hash generation is enabled.
