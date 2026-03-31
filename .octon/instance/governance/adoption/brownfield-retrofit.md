# Brownfield Retrofit Playbook

This playbook operationalizes the brownfield retrofit gate for Octon adoption in
older or messy repositories. It is subordinate to the constitutional kernel and
does not itself widen live support claims.

## Scope

Use this playbook only when introducing Octon into a repository that does not
already satisfy the greenfield assumptions of the workspace-charter pair,
run-control roots, and release-gated evidence model.

## Intake

1. Inventory current system-of-record surfaces for runtime, governance,
   deployment, release, and incident response.
2. Record hidden knowledge that currently lives only in tickets, chat, or local
   operator memory.
3. Identify current proof gaps across structural, functional, behavioral,
   governance, recovery, and maintainability planes.
4. Freeze the current supported envelope before any architecture widening.

## Minimum control-plane retrofit

1. Bind a workspace charter pair under `instance/charter/**`.
2. Bind ingress through `instance/ingress/AGENTS.md`.
3. Move durable runtime and governance truth into `framework/**`,
   `instance/**`, or `state/**`; do not rely on `inputs/**`.
4. Create the minimum run roots required for consequential execution:
   `state/control/execution/runs/**`, `state/continuity/runs/**`,
   `state/evidence/runs/**`.

## Minimum runtime retrofit

1. Publish the initial support-target tuple set under
   `instance/governance/support-targets.yml`.
2. Publish the initial host and model adapter manifests.
3. Require run-contract binding before consequential side effects.
4. Require measurement, intervention, replay-pointer, and disclosure roots for
   supported consequential runs.

## Minimum governance retrofit

1. Add structural validation before enabling agent write paths.
2. Add release and closeout gating before widening support.
3. Add disclosure surfaces only for claims the repository can currently prove.
4. Register every compatibility shim in the retirement registry with an owner,
   review date, and retirement trigger.

## Brownfield done gate

A brownfield walkthrough satisfies Octon's repo-local closeout when a real
target repository has been assessed against this playbook with retained
evidence showing the retrofit path is explicit, bounded, and executable.

A downstream target repository is not eligible for its own full unified
execution constitution claim until it can pass its own closeout contract.

- authoritative status matrix is fully green
- claim readiness checklist passes without waiver
- release promotion checklist passes without waiver
- brownfield retrofit walkthrough is retained for at least one real target repo
- ordinary live-path evidence, not migration bundles, carries Octon's claim

## Current blocker

This playbook is authored and may be satisfied by a retained walkthrough on a
real target repository. Full adoption of the target repository remains a
separate downstream claim for that repository.
