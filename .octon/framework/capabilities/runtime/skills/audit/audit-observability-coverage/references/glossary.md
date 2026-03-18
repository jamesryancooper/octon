---
title: Glossary Reference
description: Observability coverage audit terminology.
---

# Glossary Reference

Terminology used in the audit-observability-coverage skill.

## Core Terms

| Term | Definition |
| ---- | ---------- |
| **Service surface** | A bounded operational unit in scope (for example, a service manifest and its companion artifacts). |
| **Signal contract** | Declared expectation for traces, logs, and metrics required to observe a service surface. |
| **Coverage matrix** | Layered accounting table showing whether each service surface has signal, SLO/alert, and runbook/dashboard coverage. |
| **Coverage ledger** | Detailed list accounting for each in-scope artifact as finding-backed, clean, excluded, or unknown. |
| **Done gate** | Formal completion criterion that becomes strict in post-remediation mode. |

## Observability Terms

| Term | Definition |
| ---- | ---------- |
| **SLI** | Service Level Indicator; measurable metric tied to service behavior. |
| **SLO** | Service Level Objective; target threshold for one or more SLIs. |
| **Error budget** | Allowable SLO miss budget within an objective window. |
| **Burn-rate alert** | Alert indicating the error budget is being consumed too quickly. |
| **Operational runbook** | Stepwise incident response guidance linked to alerts and ownership. |
| **Dashboard reference** | Artifact pointing to visualization needed for diagnosis and triage. |

## Bounded Audit Terms

| Term | Definition |
| ---- | ---------- |
| **Lens isolation** | Rule requiring each coverage layer to complete before the next starts. |
| **Stable finding ID** | Deterministic finding identifier for tracking remediation across reruns. |
| **Convergence receipt** | Metadata proving rerun stability under fixed inputs and seed policy. |
| **Unknown** | Explicit marker for unresolved claims caused by insufficient evidence. |
