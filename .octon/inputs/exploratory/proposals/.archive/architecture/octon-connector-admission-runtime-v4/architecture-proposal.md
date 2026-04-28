# Architecture Proposal: Connector Admission Runtime and Trust Dossier v4

## Decision

Select **Connector Admission Runtime + Connector Trust Dossier** as the single highest-leverage v4 implementation step.

## Why not the whole v4 architecture

A fully realized v4 includes portfolios, cross-repo engagements, release envelopes, campaigns, connector runtimes, lab gates, and federated evidence. Implementing all of that at once would over-expand the migration and risk creating a broad control plane before Octon has a safe external-operation boundary.

Connector admission is the correct first v4 cut because it is the required safety boundary for external tools, MCPs, APIs, browser surfaces, CI/service operations, release systems, cross-repo coordination, and eventual portfolio workflows.

## Selected target

Add a proof-backed admission model where:

> Connector -> Operation -> Capability Packs -> Material-Effect Classes -> Support Posture -> Policy -> Authorization -> Evidence

This must not create a shortcut around:
- support targets;
- capability-pack admission;
- execution authorization;
- authorized effect token verification;
- context-pack requirements;
- egress and budget policies;
- run contracts;
- evidence retention;
- rollback/compensation posture.

## Scope

In scope:
- connector operation contract;
- connector admission contract;
- connector trust dossier;
- connector execution receipt;
- connector posture control/evidence roots;
- runtime/CLI shape for inspect/admit/quarantine/retire;
- validator and evidence requirements;
- support-target proof hooks;
- generated connector read models as derived-only projections.

Out of scope:
- broad live MCP marketplace;
- arbitrary effectful API writes;
- browser-driving autonomy;
- production deployment automation;
- credential self-provisioning;
- multi-repo portfolio runtime;
- campaign promotion runtime;
- autonomous support-target widening.
