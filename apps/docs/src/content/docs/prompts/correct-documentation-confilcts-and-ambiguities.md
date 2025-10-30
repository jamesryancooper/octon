---
title: Correct Documentation Conflicts and Ambiguities Prompt - Low-Friction Remediation & Patch Plan
description: Prompt for planning and applying fixes to documentation conflicts, inconsistencies, and ambiguities.
---

Using the issues identified in the **Documentation Conflict and Ambiguity Scan**, implement fixes that unblock a **two-developer team** to ship **clean, efficient, stable** code fast, while meeting **enterprise-grade security, scalability, performance, and reliability**.

## Principles (decision heuristics)

* **Keep it simple**: prefer configuration edits over code changes; additive over breaking; reuse existing tools.
* **Stay consistent**: keep the current package manager, language/runtime, and repo conventions unless a change is mandatory.
* **Zero surprise**: maintain backward compatibility (APIs, CLI flags, env vars) unless explicitly marked deprecated with a migration note.
* **No new infra/deps** unless they clearly reduce risk or effort; if added, choose widely adopted, lightweight options.
* **Safety first**: never introduce plaintext secrets; least-privilege scopes; pin versions where security matters.
* **Performance & reliability**: avoid added latency; cap retries with backoff; don’t increase memory/CPU footprints without justification.

## What to produce

Output the following sections—short and prescriptive. Quote only the necessary lines/file paths.

1. **Change Summary**

   * Bullet list mapping each fix to the original issue ID (Conflict/Inconsistency/Ambiguity) with a one-line rationale.

2. **Patch (ready to apply)**

   * Provide **unified diffs** from repo root. One code block per file:

     * `diff --git a/<path> b/<path>`
     * Minimal edits only (no cosmetic reformatting).
   * If creating/removing files, include them in the diff.

3. **Docs & Config Updates**

   * Snippets for `README`, `RUNBOOK`, `.env.example`, `Dockerfile`, CI config, or `tsconfig/pyproject` showing exact replacements.
   * Keep commands/tooling aligned (e.g., if repo uses `pnpm`, use `pnpm` everywhere).

4. **Tests (lightweight)**

   * Only add/adjust tests necessary to verify the fixes.
   * Include exact test names and commands to run locally and in CI.

5. **Verification Commands**

   * One compact block that runs end-to-end locally (install → build/typecheck → test → start).
   * Mirror the same steps for CI; note any required env vars.

6. **Risk, Rollback, and Migration**

   * Risk level (Low/Med/High) per change group.
   * One-liner rollback instructions (e.g., `git revert <sha>` or config toggle).
   * If behavior changes, include a ≤3-step migration note with a deadline and deprecation tag.

7. **PR Description & Checklist**

   * Short PR body summarizing scope and impact.
   * Checklist: backward-compat verified, secrets safe, logging levels sane, metrics names stable, pagination/idempotency unaffected, local≙CI parity.

## Tie-breakers

* If multiple valid options exist, **choose the smallest diff** that keeps the team on current tooling and minimizes ongoing maintenance.
* Prefer explicit config to “magic” defaults; prefer fail-fast errors over silent fallbacks.
* Avoid renames/moves unless they fix a correctness or safety bug.
