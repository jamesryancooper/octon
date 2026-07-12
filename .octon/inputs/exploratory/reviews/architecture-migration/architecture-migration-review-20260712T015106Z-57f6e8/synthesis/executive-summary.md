# Executive Summary

> Non-authoritative. Independent architecture + migration review of Octon at commit
> `c5b1f5760c…` against the 24 accepted final decisions. Verdict:
> **READY_WITH_BLOCKING_DECISIONS**.

## Bottom line

Octon has the **right authorization primitive** but applies it to the **wrong set of
paths**. The single-use effect-token verifier is strong and is correctly enforced on
the kernel command/workflow/pipeline paths. But the most consequential effect —
launching a credentialed autonomous agent — runs on a separate self-attesting plane
that never calls the authority engine, the agent inherits ambient credentials in the
canonical repo with no OS sandbox, and (the deepest finding) even the authority
engine's own Allow/Deny decision is computed by executing a **candidate-editable**
policy file and bash runner. The result: today the boundary is fully permeable to a
misbehaving candidate agent.

The good news: the fix is **additive around a strong core**, not a rewrite. The
compile-time surfaces (deterministic Harness Factory, non-authoritative adapters,
extension catalog) are genuine strengths to preserve. The smallest safe migration
adds roughly **three** new components (one broker that owns the transactional store +
sanitized git + credentials; an isolation launcher; a trust-activation controller),
delegates the exact-SHA verifier to a GitHub App, corrects several overstated claims,
and inverts the direct-main route ordering.

## Decision alignment at a glance (24 final decisions)

- **Satisfied (2):** FD-020 Harness Factory, FD-023 provider adapters.
- **Partially satisfied (9):** FD-001, 003, 012, 013, 015, 016, 019, 021, 024.
- **Contradicted (8):** FD-002, 004, 009, 010, 011, 014, 017, 022.
- **Absent (5):** FD-005, 006, 007, 008, 018.

## The five things that must happen before privileged implementation (PP-00)

1. **Correct overstated claims** — no signing exists; "signed/complete-mediation/
   attestation" must become "hash-chained + git-anchored," and quorum must verify
   identity, not string presence.
2. **Pin the authority decision function** — the ACP policy file + bash runner are
   candidate-editable and env-overridable; pin them out-of-tree or compile the
   decision into the kernel (lead-verified BLOCKER).
3. **Disable autonomous direct-main + managed git hooks** and force PR fallback until
   the verifier lands.
4. **Complete the git-extension allowlist** (sshCommand, credential.helper,
   include.path, filter/textconv, insteadOf, gitmodules, aliases — not just hooks).
5. **Make every `OCTON_*` override fail-closed** and complete the credential inventory.

## The three blocking operator decisions

- **OD-01:** evidence integrity — implement signing, or reword to git-anchored?
  *(Recommend git-anchored: lower burden, matches the true property.)*
- **OD-06:** gate the multi-party federation/trust-compact surface (~1.5k LOC) off
  for the solo vertical? *(Recommend yes — permanently out of scope for one operator.)*
- **OD-08:** ratify the trust-root inventory and a human-anchored epoch-0 bootstrap
  *(required before trust-root activation can be designed at all).*

## What the migration must never do

No second broker/control plane, distributed consensus, VM, enterprise identity,
public marketplace, persistent agent org, universal PR ceremony, or autonomous
direct-main. The plan introduces none of these; Phase 3 verified it does not smuggle
a second control plane (though it flagged that the GitHub Actions credential plane
must be *removed*, not merely narrowed).

## What proof looks like

One integration test on one macOS machine against a scratch remote:
authorize → one-shot launch guard on every spawn → credentialless sandboxed candidate
in a disposable worktree → the *only* durable effect is a brokered exact-SHA no-PR
land → transactional reconcile — with fault sub-assertions (concurrent consume,
target-race, crash reconcile, credential scrub, decision-pinning) and a red-team where
a prompt-injected candidate is denied across all six bypass vectors. The one piece
provable today is FD-020's digest-drift deny — run it first as a cheap anchor.

## Residual risk (honestly bounded)

After a corrected migration the residual is dominated by items a solo builder must
*accept*: sandbox-escape completeness (regression suite, not a proof), out-of-tree
verifier immutability (provider-config-derived), off-git tamper-evidence (git-anchored),
epoch-0 bootstrap (human-anchored), the broker as a single point of operational failure
(needs supervision), and overall maintenance burden (needs run-exhaust removal + gate
trimming + a budget). None re-open a blocker if the Phase 3 gates are met.
