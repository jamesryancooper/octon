# Solo-Builder Usability Review

> Non-authoritative. Does the target + Phase 2 plan actually deliver a low-friction
> one-operator experience? Reviewed commit `c5b1f5760c…`. The usability lane found
> the plan architecturally sound but usability-light, with the operator surface
> deferred to the last packet.

## Usability property scorecard (against the migrated design)

| Property (FD-001/002/024, PROOF-USABILITY) | Verdict | Evidence / gap |
|---|---|---|
| One-command / guided trust enrollment, no manual secret copying | **UNMET** | OD-05 recommends unix-socket+keychain but PP-04's gate is effect-denial, not enrollment UX; "no manual secret copy" is aspirational (L4-06) |
| Automatic broker operation (no babysitting) | **UNMET** | No daemon/launchd/UnixListener pattern exists today; PP-04 names IPC but not process lifecycle, supervision, or crash-recovery (L4-01) |
| Automatic project inference | PARTIAL | OD-02 picks the lighter model; multi-project registry deferred (SR-08) |
| Zero routine Class A/B prompts | **PARTIAL** | Policy substrate supports machine 2nd-party (`mission-autonomy.yml:147`), but the `default` quorum still requires 1 operator approval and risk-tiers end in "Approve PR"; the plan does not delete these (L4-03) |
| Automatic no-PR vs PR selection | MET | Target route order makes it automatic (once GAP-08 lands) |
| Concise completion + progressive evidence disclosure | PARTIAL | Large evidence volume (SR-10) undercuts this until run-exhaust is moved out of the tree |
| Automatic recovery | PARTIAL | Reconciliation (PP-07) is designed but broker crash-recovery/supervision undefined (L4-01) |
| No manual profile selection in normal use | MET | Existing Profile inference is automatic |
| Low monthly maintenance burden | **UNMET** | 42 workflows, 42,257 tracked state files, 167 state-touching commits/30d; no burden budget; trim deferred to PP-12 (L4-05) |
| Safe background / overnight work | **PARTIAL/REGRESSES** | `proceed_on_silence.forbidden_action_classes` includes `credential_change`, so broker enrollment / key rotation cannot run unattended — first-run and (if signing) rotation block overnight autonomy (L4-04) |

## The single biggest usability risk: the broker as an unsupervised second process

The migration's central new component is a long-running credential-holding broker. The
usability lane verified (grep for `UnixListener`/`launchd`/`LaunchAgent`/`daemon` = zero)
that **no such process pattern exists in the runtime today**, and PP-04 is silent on: who
starts it, what happens when it dies mid-mission, how it auto-recovers, whether an overnight
run survives a broker crash. For a solo operator this converts "run a mission" into "keep a
second daemon alive" — a burden the current file-native system does not impose (L4-01).

**Cheapest mitigation:** ship the broker as a supervised launchd LaunchAgent with health-gated
auto-restart and a **fail-closed-on-restart** posture (a crashed broker blocks durable effects,
never falls open), and make "operator can diagnose broker/store/credential/mission health in
one `octon doctor` command" an **exit gate of PP-04** — not PP-12.

## Structural ordering problem: usability arrives last

All hard usability guarantees are bundled into GAP-18/PP-12, which depends on PP-07 (signing/
recovery) and PP-08 (trust activation). So during the *entire* proof-of-architecture phase
(PP-01…PP-07) the operator runs a system with a broker, isolation, a store, an out-of-tree
verifier, and inert trust landing but **no doctor, no inbox, no trimmed gates** — the
maximum-friction intermediate state, and exactly when a solo builder is most likely to abandon
the tool (L4-02).

**Recommendation (accepted refinement):** split PP-12. Pull forward, to land *with* PP-04:
- `octon doctor` operator-mode health (broker/store/credential/mission),
- the FD-002 zero-prompt crosswalk + Class-A/B/C rename (also SR-12; land in PP-00),
- a one-command `octon enroll`.
Keep only the cross-project inbox and CI-gate trimming in the tail.

## Zero-prompt reality check (L4-03)

The claim "verifier-as-second-quorum-member removes the prompt" is only *policy-reachable*
today: `mission-autonomy.yml:147` defines ACP-2 as `execution_agent_plus_independent_verifier_
or_deterministic_validator`, so a machine can be the second party. **But** the `default`
quorum policy still requires 1 explicit operator approval for approval-bearing routes, and the
shipped risk-tiers doc ends every tier (T1/T2/T3) at a human "Approve PR" click. Unless PP-00/
PP-12 explicitly *deletes* those residual human-approval defaults for the reversible-isolated-
branch route class, the operator still gets a routine prompt — "zero prompts" would be asserted,
not enforced. Acceptance: 20 consecutive routine reversible T1/T2 missions produce **0** human
prompts, and an ACP-3/destructive mission still prompts exactly once.

## Overnight autonomy regression (L4-04)

`proceed_on_silence.forbidden_action_classes` correctly forbids `credential_change`/`identity_
change` for unattended operation. The new broker's credential enrollment (OD-05) and any signing-
key rotation (OD-01 Option A) are `credential_change` events — so they cannot run overnight, and
a first-run or rotation stalls an unattended mission. This is another reason to prefer **OD-01
Option B (git-anchored, no rotation)** and to make broker enrollment a strictly one-time,
operator-present, out-of-band step never on the mission critical path.

## Burden budgets the plan must set (currently absent)

The plan gives no measurable solo budget. Phase 3 requires PP-12 promotion gates to include:
- **Enrollment:** clone → broker credential-ready in ≤ 1 guided command, 0 manual secret pastes.
- **Broker MTTR:** crash → auto-restart + reconcile in ≤ 5s, 0 manual steps.
- **Routine prompts:** T1/T2 reversible missions = 0 human prompts; ACP-3+ = exactly 1.
- **Maintenance:** ≤ N minutes/week operator upkeep over a 4-week dogfood; the set of workflows
  the solo operator must keep green reduced to the named load-bearing subset, rest quarantined.
- **Fresh-install-to-first-mission:** bounded, measured step count.

## Net assessment

The architecture supports a good solo experience, but the plan defers the *experience* behind
all the *infrastructure*. Re-sequence so the operator always has a diagnosable, supervised
broker and a zero-prompt routine path *before* the heavy trust packets; prefer the git-anchored
evidence option to avoid rotation burden; and set explicit burden budgets as promotion gates.
None of this changes the architecture — it changes packet ordering and adds measurable exit
criteria — but without it the migration can be correct yet still fail FD-001's core proof that
one person can install, operate, diagnose, and recover within burden targets.
