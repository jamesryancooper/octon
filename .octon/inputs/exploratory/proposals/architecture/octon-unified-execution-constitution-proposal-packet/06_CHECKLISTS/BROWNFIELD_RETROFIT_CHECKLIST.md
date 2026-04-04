# Brownfield Retrofit Checklist

Use this when applying Octon to an older or messy repository.

## Intake
- [ ] Identify current system-of-record surfaces.
- [ ] Identify hidden knowledge currently living in docs, chat, tickets, or heads.
- [ ] Identify current architecture rules that exist socially but not mechanically.
- [ ] Identify current verification stack and missing proof planes.

## Control-plane retrofit
- [ ] Create or bind a workspace charter pair.
- [ ] Create a minimal ingress/read-order surface.
- [ ] Move critical repo knowledge into repository-local durable artifacts.
- [ ] Keep `AGENTS.md` small; use it as a map, not an encyclopedia.

## Runtime retrofit
- [ ] Define supported workload tiers for the repo.
- [ ] Define the initial host/model adapter set.
- [ ] Define minimum run-manifest, runtime-state, and evidence roots.
- [ ] Add browser/observability feedback only where they materially improve proof.

## Governance retrofit
- [ ] Add structural linters/tests before expecting agents to stay coherent.
- [ ] Add release/promotion gating before widening autonomy.
- [ ] Add disclosure surfaces only for claims the repo can honestly support.

## Adoption discipline
- [ ] Start with a narrow supported envelope.
- [ ] Keep experimental or brownfield-volatile tuples stage_only.
- [ ] Register every transitional shim and assign removal ownership.
- [ ] Do not claim full unification until the brownfield repo can pass the same closeout checklist as greenfield Octon.
