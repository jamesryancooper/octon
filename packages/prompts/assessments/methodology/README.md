---
title: Harmony Assessment Prompt Suite
description: Unified validation prompt suite for Harmony, AI-Toolkit, and Implementation Guide.
---

# 🧩 Unified Validation Prompt Suite (Harmony + AI-Toolkit + Implementation Guide)

This is the **Unified Validation Prompt Suite**, formatted for agent-driven assessments (works well for automation or multi-stage evaluation pipelines).

It’s structured in **three layers** — each validating a distinct system artifact:

1. **Harmony Methodology**,
2. **AI-Toolkit**, and
3. **Implementation Guide (SpecKit + PlanKit/BMAD integration)**.

Each layer includes consistent expectations, “no update” rules, and a **stop instruction** for deterministic task completion.

You can embed this directly into your evaluation or MCP pipeline as a YAML or JSON prompt set.

---

## 1️⃣ Harmony Methodology — Continuous Improvement (Applied Assessment)

**Purpose:**
Evaluate and refine the Harmony methodology as a **robust, self-reinforcing system** for AI-accelerated small-team software delivery.

**Prompt:**
[methodology-assessment.md](methodology-assessment.md)

---

## 2️⃣ AI-Toolkit — System Alignment and Optimization

**Purpose:**
Ensure the AI-Toolkit’s modular architecture (kits) functions as a deterministic, Harmony-aligned system.

**Prompt:**
[toolkit-assessment.md](toolkit-assessment.md)

---

## 3️⃣ Implementation Guide — SpecKit (Spec‑First) + PlanKit (Agentic Agile) Integration Alignment

**Purpose:**
Verify that the **Harmony Implementation Guide** — which wires Spec-First and Agentic Agile into a Turborepo + Vercel stack — is perfectly aligned with Harmony and the AI-Toolkit.

**Prompt:**
[implementation-guide-assessment.md](implementation-guide-assessment.md)

---

## ✅ Usage Notes

- **Run order:** Harmony → AI-Toolkit → Implementation Guide.
- **Scope:** Each validation step is self-contained; if one layer requires changes, re-run dependent validations afterward.
- **Output discipline:** Every step ends deterministically — either with a single updated file or a “no update required” declaration.
- **Automation:** Ideal for MCP, CI/CD agent loops, or local validation pipelines before merging major updates.

---

## 📦 assessment.yaml — Drop‑in Suite

Use [`assessment.yaml`](assessment.yaml) as a ready‑to‑run configuration you can drop into your MCP/agent orchestration to validate all three layers in order. It includes:

- **Targets:** Per‑step `target.document_path` pointing to the file to validate/update.
- **No‑update phrases:** Deterministic “no update required” messages for pass‑through steps.
- **Stop conditions:** Explicit stop rules so each step ends deterministically.
- **Prompt sourcing:** Uses `prompt_path` to load prompts from the markdown files in this folder (single source of truth).

Minimal customization:

- Update only the `target.document_path` values to match your repository layout.
- Keep the phrases and stop conditions unchanged for deterministic behavior.
- If any step applies edits, re‑run downstream steps to re‑validate cross‑document consistency.
