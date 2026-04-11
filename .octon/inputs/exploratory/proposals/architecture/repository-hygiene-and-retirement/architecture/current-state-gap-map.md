# Current-State Gap Map

## Authoritative current-state baseline

The live repository already defines the essential authority and lifecycle
boundaries that this proposal must honor:

- `/.octon/README.md` and the umbrella architecture specification define the
  five-class super-root, the authored-authority rule, the state/evidence role,
  and the prohibition against treating `generated/**` or raw `inputs/**` as
  control-plane authority.
- the constitutional ingress read set explicitly includes the charter, fail-
  closed and evidence obligations, precedence files, ownership roles, contract
  registry, workspace objective pair, and orchestrator profile surface.
- the proposal-system contract already defines the canonical packet path,
  manifest pair, and active-scope target-family rule.
- the build-to-delete spine already exists through retirement policy,
  retirement registry/register, review contracts, claim gate, and current
  release lineage.
- the repo-native command lane exists and is explicitly reserved for
  instance-owned commands.

## Live repo reality relevant to this proposal

### Existing command and pack posture

- `/.octon/instance/capabilities/runtime/commands/README.md` reserves the
  command lane for repo-native commands.
- the command manifest is currently empty.
- the runtime skills manifest is also empty.
- the live support universe already admits `repo`, `git`, `shell`,
  `telemetry`, `browser`, and `api` packs; the workload classes already admit
  `observe-and-read`, `repo-consequential`, and `boundary-sensitive`.
- the runtime pack projection registry already records the admitted status and
  evidence requirements for those packs.

### Existing retirement/build-to-delete posture

- the retirement registry already contains transitional, historical, and
  deleted entries such as ingress adapters, compatibility shims,
  helper-authored projections, historical mirrors, and superseded release
  bundles.
- the retirement register already retains rationale and status for the
  corresponding human-facing surfaces.
- the ablation workflow already governs `delete`, `retain`, and `demote`
  decisions, and closeout reviews already point to a live review packet.
- the claim gate already protects final closure claims by requiring current
  nonblocking statuses and review evidence.
- release-lineage already distinguishes an active release from superseded
  historical releases.

### Existing runtime, CI, and toolchain posture

- the Rust workspace lives at
  `/.octon/framework/engine/runtime/crates/Cargo.toml` with multiple member
  crates.
- architecture conformance and closure certification workflows already exist,
  including a build-to-delete governance job and a two-pass closure
  certification job.
- the root manifest already defines generated commit defaults and fail-closed
  generated staleness handling.

## Observed gaps

### Gap 1 — no repo-hygiene policy exists

The live repo has build-to-delete governance, but no dedicated policy surface
that defines detection scope, confidence rules, protect lists, classification,
mode boundaries, or same-change requirements for repository hygiene.

### Gap 2 — no repo-native hygiene command exists

The repo-native command lane exists, but the manifest is empty and there is no
operator surface for scan/enforce/audit/packetize repository hygiene actions.

### Gap 3 — no explicit hygiene routing into the retirement spine

The retirement policy and review contracts govern compensating mechanisms, but
there is no explicit rule requiring newly detected transitional residue from
hygiene scans to register into the existing retirement plane.

### Gap 4 — no standardized shell/script orphan or artifact-bloat detection

The live repo has many shell-driven validators and workflows, but no canonical
command or policy for shell-orphan detection, generated/output classification,
or repo-bloat triage.

### Gap 5 — no hygiene-specific validator or workflow integration

Architecture and closure workflows exist, but there is no dedicated validator
for repo-hygiene governance and no dedicated repo-hygiene CI workflow.

### Gap 6 — no closure-packet attachment for hygiene findings

Current build-to-delete closeout reviews point at review receipts and the
ablation receipt, but there is no required `repo-hygiene-findings.yml`
attachment for closure-grade cleanup evidence.

### Gap 7 — no current manifest-governed packet exists for this change program

The active architecture proposal workspace currently contains one legacy packet
directory, while the archive contains many normalized packets. None of those
existing packets is this repository-hygiene architecture packet, and the live
proposal contract is stricter than the older active example's file layout.

## Constraints that must be preserved

1. `framework/**` and `instance/**` remain the only authored authority.
2. `state/**` remains operational truth and retained evidence only.
3. `generated/**` remains derived-only.
4. raw `inputs/**` must never become runtime or policy dependencies.
5. no support-target or capability-pack widening occurs by default.
6. cleanup classification is separated from destructive action.
7. existing build-to-delete governance is reused rather than bypassed.
8. active proposal targets remain `.octon/**`-only because active proposals may
   not mix target families.

## Current-state summary

Octon already has the right constitutional and retirement governance spine for
this problem. What is missing is the repo-specific hygiene layer that turns
that spine into a real operator capability for Rust + Shell repository
cleanup. The proposal therefore fills a genuine architecture gap, but it does
so by extending existing surfaces instead of inventing a new governance plane.
