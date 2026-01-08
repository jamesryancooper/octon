# DevKit — AI-Assisted Coding & Development

- **Purpose:** Packages AI‑grounded, plan‑aligned code change packs with contract‑aware diffs and preflight gates to add governed change delivery to Harmony.
- **Responsibilities:** assembling QueryKit evidence; mapping edits to PlanKit steps; tagging diffs by intent; emitting TestKit‑ready stubs; delegating gates to EvalKit/PolicyKit.
- **Harmony alignment:** Advances Interoperability and Evidence‑First via consistent change‑pack contracts; exposes governance hooks so diffs are grounded, reviewable, and policy‑gated.
- **Integrates with:** QueryKit (evidence), PromptKit (code prompts), PlanKit (plans), AgentKit (runs), CodeModKit (AST refactors), TestKit/EvalKit/PolicyKit (gates), PatchKit (PRs).
- **I/O:** inputs: `src/**`, `evidence/**`; outputs: `change_pack/intent.json`, unified `.patch` diffs, and `tests/**` stubs.
- **Wins:** Smaller, rationale‑backed PRs; faster reviews with gated, predictable diffs.
- **Implementation Choices (opinionated):**
  - difflib: minimal unified diffs for small, human‑readable patches.
  - unidiff: parse/validate patch hunks before handing to PatchKit.
  - tree-sitter: structure‑aware snippet placement across languages to reduce merge risk.
- **Common Qs:**
  - *Replace Cursor?* No—Cursor handles in‑editor edits; DevKit packages and gates changes.
  - *Direct commits?* Through PatchKit with required approvals.
  - *Large refactors?* Use CodeModKit; DevKit focuses on packaging and gates.
  - *Prompts live where?* PromptKit; rationales attach to the change pack.

## Minimal Interfaces (copy/paste scaffolds)

### DevKit (code change proposal)

```json
{
  "targets": ["src/**"],
  "intent": "add retries and inline docs for FooService",
  "strategy": {"explain": true, "tests": true}
}
```