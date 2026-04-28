# Repository Baseline Audit

## Summary

The live repository presents Octon as a pre-1.0 Constitutional Engineering Harness with a Governed Agent Runtime. It supports bounded admitted repo-local work and does not claim universal support for future-facing designs.

## Root authority model

The architecture specification defines durable authored authority under `framework/**` and `instance/**`, mutable operational truth under `state/control/**`, retained proof under `state/evidence/**`, continuity under `state/continuity/**`, derived-only generated surfaces under `generated/**`, and non-authoritative input/proposal surfaces under `inputs/**`.

It also states that mission authority remains the continuity container under `instance/orchestration/missions/**`, while consequential run control lives under `state/control/execution/runs/**`.

## Proposal convention

Manifest-governed proposals require `proposal.yml`, exactly one subtype manifest, `README.md`, `navigation/source-of-truth-map.md`, and `navigation/artifact-catalog.md`. Architecture proposals additionally require `architecture-proposal.yml`, `architecture/target-architecture.md`, `architecture/acceptance-criteria.md`, and `architecture/implementation-plan.md`.

## Runtime baseline

The inspected kernel exposes run-first commands: `run start --contract`, inspect, resume, checkpoint, close, replay, and disclose. Workflow execution is a compatibility wrapper over run-first lifecycle semantics. Orchestration commands are read-only inspection surfaces.

## Existing v2 ingredients

The repo already contains or references mission charter, mission-control lease, autonomy budget, circuit breaker, action slice, run lifecycle, execution authorization, context pack, evidence store, policy interface, support targets, and capability pack registry surfaces.

## v1 dependency

First-class v1 Engagement / Project Profile / Work Package surfaces were not visible in the live snapshot inspected for this packet. v2 remains dependent on v1 and should not silently implement v1.
