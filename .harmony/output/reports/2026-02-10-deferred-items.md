# Deferred Items - Skills System (2026-02-10)

## 1. Parameter Types Expansion

- **What:** Add non-text parameter types: `number`, `enum`, `list`, `object`, `secret`.
- **Why deferred:** Current active skills are fully covered by `text|boolean|file|folder`; no concrete runtime need yet.
- **Trigger to add:** A real skill requires typed numeric bounds, constrained option sets, structured payloads, or secure secret inputs that cannot be safely modeled as plain text.

## 2. I/O Kinds Expansion

- **What:** Add output/input kinds: `api`, `database`, `stream`.
- **Why deferred:** Existing skills primarily emit files/logs and represent external artifacts via `external-output` references.
- **Trigger to add:** A production skill must declare non-file machine-consumable outputs (for example direct API payload contracts, database writes, or streaming channels) as first-class registry schema.

## 3. Trigger Pattern Engine

- **What:** Add regex/intent trigger matching beyond literal phrase lists.
- **Why deferred:** Current catalog size and trigger specificity are still manageable with explicit strings.
- **Trigger to add:** Catalog scale exceeds practical manual disambiguation (around 50+ active skills) and routing precision degrades due phrase overlap.

## 4. Dependency Model Enhancements

- **What:** Add optional dependencies, version constraints, and cycle detection for skill dependencies.
- **Why deferred:** Current `depends_on` usage is sparse and mostly linear; no active dependency graph complexity.
- **Trigger to add:** Multiple skills begin composing into reusable chains with explicit dependency versions or failure isolation requirements.

## 5. New Skill Sets

- **What:** Introduce `observer`, `notifier`, `generator` skill sets.
- **Why deferred:** Existing seven skill sets cover current behavioral patterns without ambiguity.
- **Trigger to add:** New production skills repeatedly express patterns that do not map cleanly to current bundles and require consistent capability presets.

## 6. New Capabilities

- **What:** Introduce `adaptive`, `feedback-aware`, `multimodal-input`, `multimodal-output`, `streaming-output`, `secret-handling`, `security-scanning`.
- **Why deferred:** No shipped skill has mandatory behavior that requires these capabilities as schema-level contracts today.
- **Trigger to add:** A concrete skill proposal requires one or more of these behaviors for correctness, safety, or operability, and the behavior must be validated automatically by tooling.
