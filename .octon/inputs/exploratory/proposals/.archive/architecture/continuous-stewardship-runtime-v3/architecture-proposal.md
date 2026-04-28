# Architecture Proposal: Continuous Stewardship Runtime v3

## Decision

Adopt a new **Continuous Stewardship Runtime v3** architecture layer above v1
Engagements and v2 Mission Autonomy. This layer introduces long-lived
Stewardship Programs and finite Stewardship Epochs so Octon can remain available
for ongoing repository care without running an unbounded agent loop.

## Core Architectural Move

Create a stewardship control loop that:

1. resolves a Stewardship Program;
2. opens or verifies a finite Stewardship Epoch;
3. observes recognized triggers;
4. emits Stewardship Admission Decisions;
5. emits Idle Decisions when no admissible work exists;
6. hands admitted work to v1/v2 surfaces as Engagement / Work Package / Mission
   candidates;
7. optionally coordinates missions through campaigns only when campaign
   promotion criteria are met;
8. aggregates evidence into a Stewardship Ledger;
9. emits Renewal Decisions at epoch close;
10. closes, renews, pauses, escalates, revokes, or idles.

## Non-Goals

This proposal does not implement indefinite execution, arbitrary MCP execution,
browser-driving autonomy, deployment automation, credential provisioning,
multi-repo federation, silent campaign promotion, autonomous governance
amendments, or destructive external operations.

## Required Promotion Output

Promotion must create portable framework contracts, repo-local instance
stewardship authority, canonical control/evidence/continuity roots, runtime/CLI
handlers, validators, generated read-model publishers, and retained promotion
evidence outside this proposal workspace.
