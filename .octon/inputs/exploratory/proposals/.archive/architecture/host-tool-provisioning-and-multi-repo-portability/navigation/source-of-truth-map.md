# Source of Truth Map

This file defines the proposal-local precedence model, authority boundaries,
and evidence posture for `host-tool-provisioning-and-multi-repo-portability`.
It does not make the proposal itself canonical authority.

## Durable repo authorities

| Concern | Durable source of truth | Why it outranks the packet |
| --- | --- | --- |
| Constitutional boundaries and fail-closed posture | `/.octon/framework/constitution/**` | These define repo-local supreme authority and the authored-authority boundary. |
| Bootstrap and profile model | `/.octon/instance/bootstrap/START.md`, `/.octon/octon.yml` | These define repo bootstrap behavior and profile semantics. |
| Instance overlay and activation model | `/.octon/instance/manifest.yml`, `/.octon/instance/extensions.yml` | These define how repo-owned desired state overlays work today. |
| Extension desired/actual/quarantine/publication pattern | `/.octon/framework/engine/governance/extensions/**` | This is the nearest live architectural analogue for desired versus actual activation. |
| Runtime command lanes | `/.octon/framework/capabilities/runtime/commands/manifest.yml`, `/.octon/instance/capabilities/runtime/commands/manifest.yml` | These determine where a shared host provisioning command versus a repo-native consumer command belongs. |
| Current motivating consumer | `/.octon/instance/governance/policies/repo-hygiene.yml`, `/.octon/instance/capabilities/runtime/commands/repo-hygiene/**` | These show the concrete host-tool dependency pressure that motivated this proposal. |
| Proposal-system contract | `/.octon/inputs/exploratory/proposals/README.md`, `/.octon/framework/scaffolding/governance/patterns/{proposal-standard,architecture-proposal-standard}.md` | These define the packet contract and promotion-scope rules. |

## Proposal-local authorities

| Artifact | Role | Authority level within the packet |
| --- | --- | --- |
| `proposal.yml` | packet identity, lifecycle, promotion targets | highest proposal-local authority |
| `architecture-proposal.yml` | subtype scope and decision classification | secondary proposal-local authority |
| `navigation/source-of-truth-map.md` | boundary and precedence map | tertiary proposal-local authority |
| `architecture/target-architecture.md` | chosen architecture and operating model | primary design surface |
| `architecture/acceptance-criteria.md` | proof contract for landing | binding within the packet |
| `architecture/implementation-plan.md` | workstreams and sequencing | operational planning within the packet |
| other `architecture/*.md` | supporting design and migration detail | supporting proposal-local authority |
| `resources/*.md` | source normalization, risks, evidence, and rejected options | supporting only |
| `README.md` and `PACKET_MANIFEST.md` | human entry and reading order | explanatory only |
| `navigation/artifact-catalog.md` | inventory only | lowest proposal-local authority |

## Host-scoped operational truth

The architecture proposed here introduces one important non-repo state class:
host-scoped Octon operational state outside the repository, for example under
`$OCTON_HOME/**` or its OS-default fallback.

That host-scoped state is:

- not repo-local authored authority;
- not a promotion target of this packet;
- allowed only as runtime operational truth and retained provisioning evidence;
- subordinate to repo-declared desired requirements and framework-defined tool
  contracts.

Examples of host-scoped runtime state in the target architecture:

- `$OCTON_HOME/tools/<tool-id>/<version>/<platform>/...`
- `$OCTON_HOME/state/control/host-tools/{active,quarantine}.yml`
- `$OCTON_HOME/state/evidence/provisioning/host-tools/**`
- `$OCTON_HOME/generated/effective/host-tools/repos/<repo-fingerprint>.yml`

## Derived or non-authoritative surfaces

| Surface | Status | Rule |
| --- | --- | --- |
| `/.octon/generated/proposals/registry.yml` | generated discovery projection | never outranks proposal manifests |
| packet-local copied user inputs under `resources/source_inputs/**` | faithful reproductions | traceability only |
| packet-local repo evidence notes under `resources/repo_evidence/**` | supporting evidence | live repo files outrank packet-local copies |
| `SHA256SUMS.txt` | integrity aid | not semantic authority |
| future repo-local generated host-tool resolution views | derived only | may summarize resolution, never mint policy |

## Boundary rules

1. Durable repo authority remains in `framework/**` and `instance/**` only.
2. Host-scoped binaries and caches must not be stored under `/.octon/**`.
3. Repo-local desired requirements must not silently mutate global system state.
4. `/init` remains repo bootstrap only; host-tool provisioning is a distinct operation.
5. Host-scoped actual state may be shared across multiple repos on one system, but repo-local desired requirements remain independent.
6. Temporary paths such as `/tmp` are acceptable for CI or one-off emergency runs, but they must not become the steady-state architecture.
7. Proposal paths must never become runtime dependencies after promotion.
