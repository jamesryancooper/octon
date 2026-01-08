# EvalKit — Verification & Regression Checks

- **Purpose:** Verifies docs/code/diffs with deterministic checks and AI judges, adding governed, evaluable quality gates aligned to Harmony.
- **Responsibilities:** validating contracts, checking links/style, scoring hallucination risk with goldens, parsing diffs for risk, emitting pass/fail gates.
- **Harmony alignment:** advances governance and consistency by enforcing interoperable contracts and policy‑aware gates across kits; ensures evaluable outputs before merge.
- **Integrates with:** PlanKit/AgentKit (orchestrate checks), DevKit/Dockit/StackKit (targets), QueryKit (ground truth), TestKit (contracts), PolicyKit (policies), PatchKit (PR status/comments).
- **I/O:** targets (paths or diffs) in; JSON reports and PR statuses/comments out.
- **Wins:** Catches regressions early; merges only when evidence and policies pass.
- **Common Qs:** *Block merges?* Yes—status checks via PatchKit. *LLM judges optional?* Yes—use when goldens exist. *Offline?* Runs deterministic checks without external calls.
- **Implementation Choices (opinionated):**
  - jsonschema: enforce output contracts with precise, machine‑readable failures.
  - unidiff: parse/score patch diffs for risk thresholds and gating.
  - ragas: lightweight faithfulness/hallucination scoring when golden Q/A datasets exist.
- **Harmony default:** Include security/static checks (**CodeQL**, **Semgrep**), license/SBOM, secret scanning, and contract tests from **TestKit** as required gates.

## Minimal Interfaces (copy/paste scaffolds)

### EvalKit (checks)

```json
{
  "targets": ["docs_out/**","src/**"],
  "checks": ["format","links","style","grounding","tests","codeql","semgrep","sbom","secrets"],
  "thresholds": {"hallucination_risk":"low","tests_pass":true}
}
```
