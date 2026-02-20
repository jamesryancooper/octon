# Dev — AI-Assisted Coding & Development

- **Purpose:** Packages AI‑grounded, plan‑aligned code change packs with contract‑aware diffs and preflight gates to add governed change delivery to Harmony.
- **Responsibilities:** assembling Query evidence; mapping edits to Plan steps; tagging diffs by intent; emitting Test‑ready stubs; delegating gates to Eval/Policy.
- **Harmony alignment:** Advances Interoperability and Evidence‑First via consistent change‑pack contracts; exposes governance hooks so diffs are grounded, reviewable, and policy‑gated.
- **Integrates with:** Query (evidence), Prompt (code prompts), Plan (plans), Agent (runs), CodeMod (AST refactors), Test/Eval/Policy (gates), Patch (PRs).
- **I/O:** inputs: `src/**`, `evidence/**`; outputs: `change_pack/intent.json`, unified `.patch` diffs, and `tests/**` stubs.
- **Wins:** Smaller, rationale‑backed PRs; faster reviews with gated, predictable diffs.
- **Implementation Choices (opinionated):**
  - difflib: minimal unified diffs for small, human‑readable patches.
  - unidiff: parse/validate patch hunks before handing to Patch.
  - tree-sitter: structure‑aware snippet placement across languages to reduce merge risk.
- **Common Qs:**
  - *Replace Cursor?* No—Cursor handles in‑editor edits; Dev packages and gates changes.
  - *Direct commits?* Through Patch with required approvals.
  - *Large refactors?* Use CodeMod; Dev focuses on packaging and gates.
  - *Prompts live where?* Prompt; rationales attach to the change pack.

## Minimal Interfaces (copy/paste scaffolds)

### Dev (code change proposal)

```json
{
  "targets": ["src/**"],
  "intent": "add retries and inline docs for FooService",
  "strategy": {"explain": true, "tests": true}
}
```
