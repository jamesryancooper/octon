# Support-Claim Review (claim vs implemented proof)

> What the current evidence and governance language claims, versus what the
> implementation at commit `c5b1f5760c78ff521cca6b054e4e8fef5300505b` actually
> proves. Overstatement is a correctness defect in an autonomy system: it invites
> misplaced trust. Each row cites the implementation gap.

## Claims that OVERSTATE what is implemented

| Claim (source) | What is implemented | Verdict | Evidence |
|---|---|---|---|
| "Broker and verifier **sign** direct observations; **signed** checkpoints" (FD-014 register text) | No signing of any kind — only unkeyed SHA-256; no keypair, HMAC, or signature field on any event/checkpoint | **OVERSTATED** — no signing primitive exists | E-01, E-02; `Cargo.toml:33-34`; `checkpoint-v2.schema.json` |
| "Rechaining breaks checkpoint verification" (FD-014 required proof) | Verifier recomputes the same public hash a tamperer already recomputed; a rewritten log passes `validate_journal` | **FALSE as implemented** | E-01; `replay_store/src/lib.rs:554-617`; `lifecycle_program.rs:29412-29539` |
| ACP-2+ quorum "signature" / "attestation" (capability agent + platform docs) | `signature` = unkeyed `shasum -a 256` over public inputs; quorum only checks the string is non-empty and distinct-role — a literal `"x"` passes | **OVERSTATED — presence-counting theater** | E-03; `agent.sh:279-290`; `policy_engine/src/lib.rs:2586-2667` |
| Complete mediation of agent-facing effects (implied by authority-engine framing) | The agent-launch path never calls the authority engine; `side_effects` INVENTORY marking ExecutorLaunch material is `#![allow(dead_code)]` and enforces nothing | **OVERSTATED for the agent path** | J-01, J-05; `side_effects/mod.rs:1-90` |
| "Verified no-PR landing default; agents never publish on main" (target framing vs contract) | `route_selection_order` prefers `direct-main` over `branch-no-pr`; solo low-risk changes push on main | **CONTRADICTED by the contract** | C-005; `default-work-unit.yml:295-317` |
| Candidate-immutable exact-SHA verification | Required-check jobs live in candidate-editable `change-route-projection.yml`; exact-SHA job passes trivially without a receipt | **OVERSTATED — verifier is candidate-controlled** | C-003, C-006 |
| One-shot invocation guard on every launch | ExecutorLaunch one-shot token guards only the `octon studio` dev process | **OVERSTATED — not on agent launches** | A-02 |

## Claims that are HONEST and accurate (preserve the wording)

| Claim (source) | Why it holds | Evidence |
|---|---|---|
| "Missing required evidence blocks closure/promotion/live claim" (evidence-store-v1) | Fail-closed completeness rules; retained snapshot must hash-match live journal at closeout | E-06; `evidence-store-v1.md:229-243` |
| Effective route bundle is non-authority, digest-bound, denied on drift | `runtime_resolver` enforces in-kernel; forbidden consumers denied | G-04; `runtime_resolver/src/lib.rs:368-535` |
| Adapters "may shape execution quality but may not widen authority or support tiers" | `authority_mode: non_authoritative`, `replaceable: const true`, bounded to `support-targets.yml` | G-08; `model-adapter-v1.schema.json` |
| Project Profile "does not mint runtime authority" | Schema exposes only descriptive fields; runtime consumes it as a read artifact | G-02; `project-profile-v1.schema.json` |
| "No public marketplace" | No marketplace endpoint/URL surface; trust is repo-owned | G-05 |
| No standalone capacity/lease service | Only an inline network-egress exception-lease input | E-05 |

## The honest tamper-evidence story (what IS true)

The genuine integrity property today is **not** cryptographic. It is that evidence
logs are git-tracked and pushed to GitHub — content-addressed commit history with
an off-machine copy. That provides meaningful, honest tamper-*evidence* against
casual rewriting, and it is the property the system should claim. It does **not**
provide authenticity, non-repudiation, or protection against a candidate agent
that (today) inherits repo write access and could rewrite local logs before push.

## Required support-claim transition (for migration)

1. Either implement real signing (ed25519 or operator-held HMAC over event-log
   heads/checkpoints, verified — not recomputed — at closeout/promotion), **or**
   reword FD-014 and all schema/doc uses of "sign/signed/signature/attestation" to
   "hash-chained and git-anchored" and state the detection boundary explicitly.
2. Rename the capability-layer `signature` field (e.g. `attestation_digest`) and
   make quorum verify identity/binding, not string presence.
3. Downgrade any "complete mediation / tamper-proof / attested" language to
   "bounded local evidence for kernel-mediated effects only" until the agent path
   is actually mediated.
4. Rename the evidence-retention "Class A/B/C" to remove the collision with the
   FD-002 consequence classes.

No support claim should be stronger than the implemented, testable proof. Today
several are; correcting the language is a Phase-0/PP-00 prerequisite before any
production trust claim.
