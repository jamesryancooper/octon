---
title: "Composition Profile: high-risk-review"
description: "Non-executing routing profile for high-risk changes that require independent verification."
---

# Composition Profile: high-risk-review

## Purpose

Use this profile when a change is high-risk, governance-heavy, or materially
benefits from independent verification.

## Topology

- Lead execution role: orchestrator
- Optional supporting roles: reviewer, refactor, docs
- Required verifier when activated: independent-verifier

## Handoff Policy

1. The orchestrator owns scope, sequencing, and final integration.
2. Specialists execute only bounded scoped work.
3. The independent verifier assesses outcome without becoming a co-owner.

## Execution Rule

This profile does not execute. It only selects and constrains a topology.
