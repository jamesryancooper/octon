# Ontology and Runtime Contract

## Execution role

An execution role is a governed participant in a run. It is not a person, persona,
model, chat session, or UI affordance. It is a contract-bound role with explicit
authority posture, capability constraints, evidence obligations, and escalation
rules.

## Orchestrator

The orchestrator is the required accountable execution role for consequential
runs. Exactly one orchestrator is legal per consequential run.

## Specialist

A specialist is a bounded stateless helper for scoped work. A specialist exists
only inside the run envelope and cannot own mission continuity or widen authority.

## Verifier

A verifier is an optional independent execution role used for separation of
duties, high materiality, support-proof, or weak deterministic proof.

## Composition profile

A composition profile is reusable handoff and routing configuration. It does not
execute and cannot authorize.

## Subagent

`subagent` is runtime-only external terminology for a delegated isolated
execution context. In Octon it maps to a specialist invocation context and never
to a durable artifact family.

## Mission

A mission is the continuity/autonomy container for long-running or recurring
work. It may bind many runs. It is not the atomic execution unit.

## Run-contract

The run-contract is the atomic consequential execution unit. Material side
effects must be bound to a run-contract, control root, evidence root, grant, and
receipt obligations.

## Workflow

A workflow is a governance/evidence/recovery procedure inside a run. It survives
only when it contributes authority, evidence, rollback, publication, support
proof, or review value.

## Capability pack

A capability pack is a governance envelope above commands, skills, tools, and
services. Capability packs must be admitted by support-target tuple and granted
by the authorization engine before material use.

## Support target

A support target is a finite admitted live support tuple backed by admission
record and support dossier. Broad taxonomies are not support claims.

## Adapter tuple

An adapter tuple is the host/model boundary selected for a run. Adapters are
replaceable and non-authoritative.

## Context pack

A context pack is the deterministic, provenance-labeled, freshness-checked
context assembly bound to a consequential run. It records authoritative sources,
derived inputs, exclusions, hashes, omissions, budget, and authority labels.
