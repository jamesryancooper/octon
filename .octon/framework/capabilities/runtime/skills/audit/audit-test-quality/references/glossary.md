---
title: Glossary Reference
description: Test-quality audit terminology.
---

# Glossary Reference

Terminology used in the audit-test-quality skill.

## Core Terms

| Term | Definition |
| ---- | ---------- |
| **Testing baseline** | Canonical artifact defining expected testing strategy and surface obligations. |
| **Quality-gate baseline** | Canonical artifact defining release-gate expectations for test outcomes. |
| **Coverage matrix** | Layered accounting table showing whether each in-scope surface has strategy, assurance, and gate-evidence coverage. |
| **Coverage ledger** | Detailed list accounting for each in-scope artifact as finding-backed, clean, excluded, or unknown. |
| **Done gate** | Formal completion criterion that becomes strict in post-remediation mode. |

## Test Quality Terms

| Term | Definition |
| ---- | ---------- |
| **Test surface** | Executable or documented tests that verify behavior across risk layers. |
| **Contract assurance** | Evidence that interface contracts are tested and enforced. |
| **Integration assurance** | Evidence that component boundaries are validated under realistic interaction paths. |
| **Flake control** | Controls that reduce nondeterministic test outcomes and false confidence. |
| **Gate evidence** | Receipts and reports proving quality gates executed and passed/fail criteria were applied. |
| **Unknown** | Explicit marker for unresolved claims caused by insufficient evidence. |

## Bounded Audit Terms

| Term | Definition |
| ---- | ---------- |
| **Lens isolation** | Rule requiring each coverage layer to complete before the next starts. |
| **Stable finding ID** | Deterministic finding identifier for tracking remediation across reruns. |
| **Convergence receipt** | Metadata proving rerun stability under fixed inputs and seed policy. |
