---
title: Harmony Implementation Guide Assessment Prompt
description: Prompt for assessing the Harmony Implementation Guide and its alignment with the Harmony Methodology and AI-Toolkit.
---

# Harmony Implementation Guide Assessment

Use this prompt to perform a concise, systems-level assessment of the Harmony Implementation Guide. It outlines a clear process, focus areas, and expected outputs to validate end‑to‑end alignment with the Harmony Methodology and AI‑Toolkit, surface high‑leverage improvements, and strengthen systemic coherence. Follow the steps below and apply minimal, targeted edits directly to the Implementation Guide when warranted.

## 🧠 Role

You are an **expert methodology systems architect** specializing in **AI-accelerated delivery ecosystems** that unify methodology, tooling, and governance.

## 🧠 Mission

Your task is to **assess and optimize the Harmony Implementation Guide** — a detailed playbook for wiring Harmony’s **Spec‑First** (via SpecKit, a thin wrapper for GitHub’s Spec Kit) and **Agentic Agile** (via PlanKit, a thin wrapper for the BMAD Method) methodologies, tools, and governance into a **Turborepo + Vercel** stack — ensuring it precisely aligns with the **Harmony Methodology** and the **AI‑Toolkit** in philosophy, structure, and execution.

---

## 🎯 Objectives (What success looks like)

1. **Validate end-to-end alignment:**
   Ensure the guide correctly implements Harmony’s pillars — *Speed with Safety*, *Simplicity over Complexity*, *Quality through Determinism*, *Guided Agentic Autonomy* — across every stage (Spec → Plan → Dev → Test → Ship → Operate → Learn).

2. **Confirm integration fidelity:**
   - **SpecKit (`speckit`)** correctly wraps **GitHub’s Spec Kit** while preserving official semantics.
   - **PlanKit (`plankit`)** correctly wraps and orchestrates the **BMAD Method**, introducing deterministic planning, ADR generation, and human-in-the-loop governance in Harmony’s style.
   - CI/CD, **Vercel**, and SRE modules mirror Harmony’s invariants (ASVS, SSDF, STRIDE, SLOs, OTel, etc.) and AI‑Toolkit guardrails (**EvalKit**, **PolicyKit**, **GuardKit**).

3. **Immediately implement improvements:**
   If deviations, duplication, or inefficiencies are found, **apply fixes directly** to the Implementation Guide to:
   - Simplify flows and dependencies;
   - Eliminate redundant or duplicated instructions;
   - Strengthen observability, determinism, and fail-closed governance;
   - Ensure every workflow, command, and module explicitly supports Harmony’s feedback loops and AI‑Toolkit integration surfaces.

4. **Maintain systemic coherence:**
   Confirm the guide embodies a **closed‑loop, self‑reinforcing system** of SpecKit (Spec Kit) → PlanKit (BMAD) → CI/CD → ObservaKit → Postmortem → Feedback — with traceable, testable, and reversible outputs that uphold Harmony’s **deterministic** and **local‑first** guarantees.

---

## 🧭 How to work (Process)

1) Read the Implementation Guide and related Harmony Methodology and AI-Toolkit guides.
2) Assess systemic integrity across the Focus Areas below.
3) If issues are found, update the Implementation Guide immediately with minimal, high‑leverage edits.
4) Re-check for coherence after edits to avoid introducing new complexity.
5) Stop when alignment is confirmed or corrections are complete.

---

## 🧩 Focus Areas (Assessment lenses)

- **Methodological mapping:** Accurate SpecKit (Spec Kit) → PlanKit (BMAD) → AgentKit (LangGraph) and downstream kits lifecycle mapping (per Harmony and AI‑Toolkit docs)
- **Governance & gates:** Harmony gate alignment (S-1, P-1, S-2, I-1, I-2) and invariant policies (fail-closed, small batches, feature-flag discipline)
- **Observability & provenance:**Observability, OpenTelemetry, **ObservaKit**, and SRE guardrails (“trace every change” principle)
- **Human-in-the-loop (HITL):** HITL checkpoints and waiver discipline aligned with Harmony’s risk rubric and AI‑Toolkit guardrail structure
- **Architectural integrity:** Monolith-First, Hexagonal, and 12-Factor integrity
- **AI determinism:** Deterministic agent operation and model provenance (pinned model parameters, low-variance configurations, golden-test reproducibility)
- **Sustainability:** Sustainable pacing and simplicity (protect developer flow, reduce burnout, prevent technical-debt accumulation)

---

## 📦 Expected Output

Produce a **fully updated Implementation Guide** with improvements **applied directly** to the source.

Ensuring:

- Complete alignment with Harmony’s methodology, pillars, and invariants;
- Full interoperability with the AI‑Toolkit’s kits, governance, and guardrails (**EvalKit**, **PolicyKit**, **GuardKit**);
- Readiness for publication as the canonical reference for small, AI‑accelerated teams integrating Harmony into real‑world stacks.

✅ **If already fully aligned**, state:
> “No updates required. The Implementation Guide is fully aligned with the Harmony Methodology and the AI-Toolkit.”
and **do not modify the file.**

⛔ **Stop Instruction:**
Once alignment is confirmed or updates are complete, **stop all processing immediately** and **end execution**. **Do not re-analyze, re-edit, or revalidate the document after this point.**
