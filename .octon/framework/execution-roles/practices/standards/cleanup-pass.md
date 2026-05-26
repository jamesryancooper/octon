# Cleanup Pass

## Purpose

Require AI-assisted implementation to inspect what it added, simplified, or
made obsolete while preserving repo-hygiene deletion safety.

## Required Questions

After implementation, ask:

- What was added but is not necessary?
- What duplicates an existing helper, contract, policy, validator, workflow, or
  generated output?
- What can be simplified without changing behavior?
- What deletion would require ablation evidence?
- What must be retained with rationale?
- What belongs in the retirement register or a future build-to-delete review?

## Deletion Safety

Deletion must obey `.octon/instance/governance/policies/repo-hygiene.yml`.
Detection never authorizes deletion by itself. Ambiguous findings route to
non-destructive retention, registration, or escalation.

For local run/control/evidence artifacts left by publication, validation,
service-build, closeout, or agent-quorum runs, use
`.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`
before treating untracked `.octon/state/**` files as either retained evidence
or cleanup candidates. The helper is dry-run by default. Deletion requires
explicit confirmation and is allowed only for untracked, unreferenced cleanup
candidates; referenced evidence, active control state, build-to-delete evidence,
and manual-review artifacts must be retained or escalated.

## Stash Archive Convention

When triaging Git stashes, archive a stash before dropping it if it contains
local-only evidence, control snapshots, generated-output residue, closeout
residue, or mixed authored/evidence content whose future review value is
plausible but whose restoration into the worktree would be unsafe or
misleading.

Durable local stash archives live under
`.octon/state/evidence/cleanup/stash-archives/<stash-short-sha>-<context-slug>/`.
Retain a readable layout when practical: `metadata.txt`, `stat.txt`,
`name-status.txt`, `stash.patch`, and `classification-receipt.yml`. A compressed
copy may be kept as convenience evidence, but not as the only evidence when a
readable layout is practical.

The classification receipt must state that the archive is local cleanup
evidence only. It is not authority, current control state, validation proof,
generated-output freshness evidence, or a receipt authorizing restoration.
Restoration or integration requires intentional review against current
`origin/main`, current contracts, authority boundaries, receipt semantics, and
cleanup-safety rules.

A stash may be dropped without archiving when it is proven duplicate, obsolete,
superseded by tracked commits, rebuildable generated output, build cache, or
otherwise disposable, and no local evidence-retention need remains. Generated,
control, evidence, proposal-local, host-state, or lifecycle-event residue from
a stash archive must never be restored as current authority.

## Receipt

Record:

- cleanup scope reviewed;
- simplifications made;
- deletion candidates and routing;
- local run/control/evidence residue classification, when relevant;
- retained surfaces with rationale;
- ablation or retirement-register requirements;
- remaining cleanup risk or `none`.
