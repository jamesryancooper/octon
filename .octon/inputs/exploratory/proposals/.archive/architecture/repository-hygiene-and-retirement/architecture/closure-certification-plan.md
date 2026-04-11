# Closure Certification Plan

## What certification means for this proposal

Certification for this proposal does **not** mean that the repository will
never again accumulate dead code or temporary residue. It means that Octon has
landed a governed capability family that can detect, classify, and safely route
repository-hygiene findings without violating constitutional authority or
build-to-delete governance.

## Mandatory closure criteria

All of the following must be true before the proposal can be marked
implemented/closeable:

1. all official `.octon/**` promotion targets are landed;
2. the dependent workflow integrations are landed and running;
3. a baseline full audit exists under retained evidence roots;
4. any blocking high-confidence transitional findings from that audit are fixed
   or registered;
5. closure-grade packetization exists for hygiene findings;
6. two consecutive clean validation passes have been retained.

## Certification artifact list

Required durable or retained artifacts:

- policy file: `/.octon/instance/governance/policies/repo-hygiene.yml`
- command registration + command files under
  `/.octon/instance/capabilities/runtime/commands/repo-hygiene/`
- updated retirement/drift/ablation contracts
- hygiene validator and updated closure validators
- repo-hygiene audit evidence under
  `/.octon/state/evidence/runs/ci/repo-hygiene/<audit-id>/`
- closure-grade `repo-hygiene-findings.yml` attachment under the active
  build-to-delete packet when a closure claim is made
- same-change retirement registry/register updates for any newly registered
  transitional or historical surfaces
- two retained clean-pass validation records

## Required certificate statements

Any future closure certificate for this capability should be able to state all
of the following truthfully:

1. a repo-native hygiene capability exists and is the recognized cleanup path
   for the Rust + Shell repository;
2. destructive or historical-retention outcomes are routed into the existing
   build-to-delete governance spine;
3. support-target and capability-pack scope were not silently widened to land
   the capability;
4. the capability produced baseline evidence and no blocking high-confidence
   residue remained untracked at certification time.

## Pass / fail logic

### Pass when

- every implementation acceptance gate is satisfied;
- closure packet evidence is present and current;
- claim gate conditions remain compatible with any non-retired relevant
  targets; and
- dual-pass validation is clean.

### Fail when

- any blocking high-confidence finding remains unresolved or unregistered;
- any closure packet omits the hygiene attachment where required;
- any direct delete outcome touches a protected or claim-adjacent surface
  without ablation-backed governance; or
- any support widening, second control plane, or proposal-path dependency is
  introduced.

## Residual-discipline rules

Residual items may remain after the architecture lands, but only when they are:

- explicitly listed in `architecture/follow-up-gates.md` and/or the risk or
  rejection ledgers;
- nonblocking to the architecture target state;
- not hidden inside narrative prose; and
- bounded by clear reopen conditions.

## Exact effect of certification

Certification closes the architecture proposal for implementation use. It does
not automatically close every future cleanup campaign, and it does not certify
that all future repository changes will remain clean without continuing audits.
The landed capability remains a living governed subsystem that must continue to
run.
