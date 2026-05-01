# Executable Implementation Prompt

You are a senior Octon extension publication and proposal lifecycle automation
engineer.

Implement the proposal packet at:

```text
.octon/inputs/exploratory/proposals/architecture/octon-proposal-packet-lifecycle-automation/
```

Treat the proposal packet as non-authoritative execution input. Durable
behavior must land only in the declared promotion targets, published generated
extension/capability outputs, host projections, validators, and retained
evidence.

## Mission

Create and publish the first-party additive extension pack:

```text
.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/
```

The pack must automate the full proposal packet lifecycle:

1. collect and preserve source context,
2. classify proposal scenarios,
3. create or generate proposal packets,
4. explain proposal packets,
5. generate executable implementation prompts,
6. execute through existing packet implementation routes where available,
7. generate follow-up verification prompts,
8. generate targeted correction prompts,
9. run verification/correction convergence loops,
10. generate closeout prompts,
11. execute proposal archive, GitHub/CI/review/merge/branch/sync closeout,
12. create and operate proposal programs across child proposal packets,
13. retain evidence and packet support artifacts in canonical locations.

Do not implement an MVP subset. The proposal is intentionally whole-lifecycle.

## Required Preflight

Before editing:

1. Read repo ingress instructions and current repository conventions.
2. Re-read this proposal's:
   - `proposal.yml`
   - `architecture-proposal.yml`
   - `navigation/source-of-truth-map.md`
   - `architecture/target-architecture.md`
   - `architecture/reusable-patterns.md`
   - `architecture/proposal-program-pattern.md`
   - `architecture/lifecycle-route-matrix.md`
   - `architecture/implementation-plan.md`
   - `architecture/validation-plan.md`
   - `architecture/acceptance-criteria.md`
   - `resources/manual-prompt-mapping.md`
   - `resources/manual-prompt-variant-guidance.md`
3. Re-ground against live Octon proposal, extension, capability, host
   projection, validator, and generated-output conventions.
4. Inspect existing first-party extension packs, especially
   `octon-concept-integration`, `octon-impact-map-and-validation-selector`,
   and `octon-pack-scaffolder`.

## Implementation Requirements

### 1. Scaffold The Extension Pack

Create the full pack under:

```text
.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/
```

Use the recommended scaffold from `architecture/target-architecture.md` unless
live repository conventions justify a better structure. If you deviate, record
the rationale in the pack README or context docs and prove equivalent coverage.

At minimum, the pack must contain:

- `pack.yml`
- `README.md`
- `context/**`
- `prompts/**`
- `skills/**`
- `commands/**`
- `validation/**`

### 2. Author Shared Contracts

Add shared prompt contracts covering:

- repository grounding,
- proposal contracts,
- proposal authority and non-authority boundaries,
- source context preservation,
- lifecycle artifact placement,
- generated custom prompt requirements,
- validation and evidence,
- verification finding identity,
- correction prompt output,
- GitHub/CI/review closeout boundaries,
- evidence retention and registry regeneration.

Preferred filenames are:

- `repository-grounding.md`
- `proposal-contract.md`
- `proposal-authority-boundaries.md`
- `lifecycle-artifact-contract.md`
- `validation-and-evidence-contract.md`
- `github-closeout-boundary.md`

### 3. Implement The Reusable Pattern Layer

Materialize these patterns in the extension pack context tree:

- lifecycle state machine,
- route dispatcher,
- packet support artifact placement,
- finding-to-correction,
- convergence loop,
- closeout gate,
- evidence receipt,
- composition first,
- authority firewall,
- scenario fixtures,
- proposal program.

The Proposal Program pattern must be first-class. Prefer:

```text
.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle/context/patterns/proposal-program.md
```

or include the full contract as a clearly labeled section in a shared
`context/patterns.md`.

### 4. Implement Prompt Bundles

Implement route-specific prompt bundles for:

- `create-proposal-packet`
- `explain-proposal-packet`
- `generate-implementation-prompt`
- `generate-verification-prompt`
- `generate-correction-prompt`
- `run-verification-and-correction-loop`
- `generate-closeout-prompt`
- `closeout-proposal-packet`
- `create-proposal-program`
- `generate-program-implementation-prompt`
- `generate-program-verification-prompt`
- `generate-program-correction-prompt`
- `run-program-verification-and-correction-loop`
- `generate-program-closeout-prompt`
- `closeout-proposal-program`

Each bundle must have a manifest, README, stages, references, at least one
maintenance companion, and validation scenarios unless live pack conventions
require an equivalent shape.

The `create-proposal-packet` bundle should preserve these behavioral stages:

```text
01-normalize-source-context.md
02-classify-proposal-scenario.md
03-select-creation-route.md
04-generate-or-create-packet.md
05-validate-packet.md
```

### 5. Preserve Manual Prompt Intent As Guidance

Use `resources/manual-prompt-variant-guidance.md` only as non-authoritative
guidance for fixtures, examples, companions, and validation expectations.

Do not copy the old manual prompts verbatim as canonical prompt text. Preserve
their behavioral intent:

- audit-aligned proposal creation,
- concise source-to-packet creation,
- architecture evaluation packet creation,
- highest-leverage next-step packet creation,
- executable implementation prompt generation,
- follow-up verification prompt generation,
- correction loop behavior,
- packet explanation,
- closeout.

### 6. Compose Existing Octon Surfaces

Prefer existing Octon surfaces before adding custom behavior:

- proposal standards and subtype standards,
- proposal templates,
- proposal create, validate, promote, and archive workflows,
- proposal validators and registry generator,
- `octon-concept-integration` source-to-packet and packet-to-implementation
  routes,
- `octon-impact-map-and-validation-selector`,
- `octon-drift-triage`,
- `octon-retirement-and-hygiene-packetizer`,
- extension publication scripts,
- capability routing publication,
- host projection publication.

### 7. Add Commands And Skills

Add a composite route and leaf command/skill surfaces for:

- `octon-proposal-packet-lifecycle`
- `octon-proposal-packet-lifecycle-create`
- `octon-proposal-packet-lifecycle-explain`
- `octon-proposal-packet-lifecycle-generate-implementation-prompt`
- `octon-proposal-packet-lifecycle-generate-verification-prompt`
- `octon-proposal-packet-lifecycle-generate-correction-prompt`
- `octon-proposal-packet-lifecycle-generate-closeout-prompt`
- `octon-proposal-packet-lifecycle-closeout`
- `octon-proposal-packet-lifecycle-create-program`
- `octon-proposal-packet-lifecycle-generate-program-implementation-prompt`
- `octon-proposal-packet-lifecycle-generate-program-verification-prompt`
- `octon-proposal-packet-lifecycle-generate-program-correction-prompt`
- `octon-proposal-packet-lifecycle-generate-program-closeout-prompt`
- `octon-proposal-packet-lifecycle-closeout-program`

The composite route must dispatch deterministically from source kind, packet
path, lifecycle action, proposal state, and user constraints.

### 8. Publish Generated Outputs

Update extension selection and publish generated outputs:

- `.octon/instance/extensions.yml`
- `.octon/state/control/extensions/active.yml`
- `.octon/generated/effective/extensions/**`
- `.octon/generated/effective/capabilities/**`
- host projections emitted by the current publication system.

Generated outputs must be produced by canonical scripts. Do not hand-edit
generated registries or projections unless the repository explicitly documents
that as the supported path.

## Proposal Program Requirements

Implement Proposal Program support exactly as a coordinator pattern:

- parent packets are normal proposals,
- child packets remain normal proposals at canonical paths,
- child packets are never nested under parent packet directories,
- parent packets may coordinate sequence, gates, aggregate implementation,
  aggregate verification, aggregate correction routing, aggregate closeout,
  risk, evidence, and deferrals,
- parent packets must not override child `proposal.yml`, subtype manifests,
  validation verdicts, acceptance criteria, archive metadata, or promotion
  targets.

Program validation fixtures must include same-kind children, mixed-kind
children, sequential execution, parallel-independent execution, gated-parallel
execution, program-atomic execution, manual-gated execution, blocked children,
deferred children, invalid nested child directories, relationship mismatches,
and aggregate prompts attempting to override child manifests.

## Authority And Safety Constraints

- Do not make raw extension pack paths runtime or policy authority.
- Do not make prompts, generated prompt artifacts, proposal packets, chat, PR
  comments, labels, issue bodies, CI dashboards, MCP/tool availability, browser
  state, external dashboards, Durable Object state, external workflow engines,
  or model memory authority.
- Do not create a rival proposal authority model.
- Do not create a rival runtime control plane.
- Do not leave partially published lifecycle routes.
- Do not broaden packet implementation beyond declared promotion targets.
- Do not archive this proposal until durable targets stand without proposal-path
  dependency.
- Do not regenerate the proposal registry until all visible proposal packets in
  the worktree are intentionally handled.

## Validation Requirements

Run the proposal validators:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-proposal-packet-lifecycle-automation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-proposal-packet-lifecycle-automation
```

If unrelated visible proposal packets make registry validation unsafe, use
`--skip-registry-check` and record the reason.

Run extension, capability, host projection, and pack-local validation listed in
`architecture/validation-plan.md`, including:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh
bash .octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-extension-local-tests.sh
bash .octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh
bash .octon/framework/capabilities/_ops/scripts/publish-host-projections.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projection-purity.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-host-projection-non-authority.sh
```

If any command is obsolete or replaced in the live repository, use the current
canonical equivalent and record the substitution.

## Verification And Correction

After implementation:

1. Run the packet's follow-up verification prompt from
   `support/follow-up-verification-prompt.md`.
2. Emit findings with stable IDs, severity, paths, evidence, expected behavior,
   correction scope, and acceptance criteria.
3. For every unresolved finding, generate a targeted correction prompt under
   `support/correction-prompts/` or record an explicit deferral with rationale.
4. Repeat verification and correction until the result is `clean`, `blocked`,
   `needs-packet-revision`, `superseded`, or explicitly deferred.

## Done Gate

Do not call the implementation complete until:

- the extension pack exists and contains all route families,
- shared contracts and reusable patterns are present,
- Proposal Program support is implemented and validated,
- manual prompt variants are represented as guidance-only fixtures or examples,
- commands and skills are published,
- extension state and capability routing are published,
- host projections are coherent,
- pack-local tests pass,
- generated support artifact placement is validated,
- authority boundaries are validated,
- follow-up verification reports no unresolved implementation findings,
- this proposal can be archived without any durable target depending on the
  proposal packet path.

Prepare closeout only after the done gate is satisfied.
