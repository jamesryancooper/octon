# Proposal-Program Readiness

> Non-authoritative. Whether the repository is ready for a formal Octon proposal
> program, and what remains. Verdict: **READY_WITH_BLOCKING_DECISIONS**.

## What "ready" means here

The intake's immediate next action was: *reverify the accepted decisions against a
clean current repository baseline, produce the reconciled decision set, and authorize
the first proof-of-architecture workgroup sequence.* This review completes the
reverification (the intake left `current_head_commit: unknown`) and produces the
reconciled crosswalk, the migration design, the adversarial assurance pass, the
fault/proof plan, and a packet/workgroup structure. That is sufficient to **author**
the formal proposal program.

## Readiness checklist

| Prerequisite | Status |
|---|---|
| Clean-baseline reverification performed | **Done** (this review, `c5b1f5760c…`) |
| Every final decision reverified + classified | **Done** (`phase-1/final-decision-to-repository-crosswalk.yml`, 24/24) |
| Current findings evidence-classified + cited | **Done** (66 Phase 1 + 40 Phase 3, exact `path:line`) |
| Smallest safe migration designed | **Done** (`phase-2/`, corrected by Phase 3) |
| Packet boundaries / dependencies / source ownership | **Done** (`phase-2/proposal-program-packet-map.yml`, `component-contract-schema-map.yml`) |
| Safe vs prohibited intermediate states | **Done** (`phase-2/safe-intermediate-states.md`) |
| Rollback + recovery per packet | **Done** (`phase-2/rollback-and-recovery-plan.md`) |
| Acceptance tests / fault plan | **Done** (`phase-3/fault-injection-plan.md`, F1–F17) |
| Implementation-readiness gates by class | **Done** (`phase-3/implementation-readiness-gates.yml`) |
| Support claims mapped to proof | **Done** (`phase-3/support-claim-proof-map.yml`) |
| Adversarial pass on target + plan | **Done** (`phase-3/`, L1-01 lead-verified) |
| **Blocking operator decisions settled** | **Pending** — OD-01, OD-06, OD-08 |
| **PP-00 blocker corrections completed** | **Pending** — G-B1…G-B5 (this is the first packet, not a pre-req to authoring) |

## Why not "READY_FOR_PROPOSAL_PROGRAM" outright

Three things must be settled to make the program authoritative rather than
provisional:
1. **OD-01 (signing vs git-anchored)** determines PP-00 and PP-07 scope and the
   FD-014 claim wording.
2. **OD-06 (federation off)** determines how much surface PP-08 must protect.
3. **OD-08 (trust-root inventory + epoch-0 bootstrap)** is a genuine prerequisite:
   FD-018 activation cannot be *designed*, let alone implemented, without the operator
   naming the trust root and anchoring epoch-0 (RR-05).

Additionally, Phase 3 raised a lead-verified BLOCKER (L1-01: the authority decision
function is candidate-editable) that the intake's packet map did not scope into PP-01.
The program must fold this in before privileged work. Because these are settle-first
items rather than a broken architecture, the honest classification is
READY_WITH_BLOCKING_DECISIONS, not the unqualified "ready."

## Why not "NOT_READY_*"

- **Not `NOT_READY_REVERIFICATION_REQUIRED`:** the clean-baseline reverification is
  done and the findings are current and cited.
- **Not `NOT_READY_ARCHITECTURE_REPAIR_REQUIRED`:** the target architecture is
  feasible and safe for one operator; the gaps are additive around a strong core, not
  evidence that the accepted direction is infeasible. No superseded alternative needs
  reviving.

## Recommended first authorized step

Author and execute **WG-00 / PP-00** (baseline + blocker corrections): reword claims,
pin the authority decision function, disable autonomous direct-main + hooks, complete
the git allowlist and env fail-closed set, land the FD-002 crosswalk + rename, and
plan run-exhaust removal. WG-00 is low-risk (no privileged runtime change), clears the
five blockers, and its exit unlocks the proof-of-architecture sequence WG-01…WG-07.
Run the FD-020 digest-drift test (F11) alongside it as the one dynamic proof available
today.

## Guardrails for the program

- No packet publishes a support claim stronger than the test it has passed
  (`support-claim-proof-map.yml` is the gate).
- No packet may create a prohibited intermediate state
  (`safe-intermediate-states.md`).
- The "one unavoidable boundary" claim may not be made until the L1-07 red-team (all
  six bypass vectors denied) passes at WG-07.
- Do not author authoritative proposal packets from this review without explicit
  operator instruction — this review is research input only.
