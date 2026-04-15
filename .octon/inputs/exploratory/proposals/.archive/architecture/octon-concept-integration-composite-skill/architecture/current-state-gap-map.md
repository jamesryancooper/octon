# Current-State Gap Map

## Observed Current State

- The concept-integration pipeline originally existed as a root-level prompt
  set before it was internalized into the extension pack.
- Octon already has a reusable additive extension-pack model under
  `/.octon/inputs/additive/extensions/**`.
- Octon already supports composite skills as a canonical harness concept.
- Octon already publishes extension command and skill contributions into
  runtime-facing effective routing through extension `routing_exports`.
- Octon currently seeds bundled packs off by default in `instance/extensions.yml`.

## Gaps Blocking Reusable Capability Delivery

### 1. The current prompt set is not packaged as a reusable Octon capability

The root prompt set is a useful authoring artifact, but it is not a stable
runtime capability with:

- one invocable entrypoint
- defined I/O contract
- retained run evidence
- pack-local prompt assets
- or extension-level enablement semantics

### 2. The current prompt location is not portable as a selected pack

The prompt set currently lives outside the additive extension-pack root.

That means a selected `pack_bundle` export cannot carry it as part of the pack,
so any capability that depends on the root `.prompts/` path would remain
non-self-contained.

### 3. The pipeline lacks a durable invocation contract

The prompt set defines execution order and companion semantics, but it does not
yet exist as:

- a composite skill contract
- a published command surface
- or an extension-pack-owned capability that can be turned on or off through
  repo-owned extension state

### 4. Preflight prompt alignment is not capability-wired

The prompt set already defines a maintenance companion audit, but there is no
packaged capability that decides when to run it before extraction and
packetization work.

### 5. Proposal packet output expectations are not yet productized

The existing prompt set can produce a proposal packet in principle, but Octon
does not yet have a reusable capability that consistently:

- writes the packet to the standard proposal path
- validates the packet structure
- and attaches the packet-specific executable implementation prompt as support
  material

### 6. Extension publication appears summary-oriented for skill exports

Current extension publication clearly emits routing-oriented command and skill
exports, but the active runtime-facing model does not obviously expose
extension skill registry metadata as a first-class effective surface.

That makes a thin published command wrapper the safer v1 operator entrypoint,
even while the reusable execution core remains a composite skill.

## Resulting Design Pressure

The architecture should solve the gaps above by:

- internalizing the prompt assets into a bundled pack
- using a composite skill for the reusable execution core
- adding a command wrapper for stable operator invocation
- keeping enablement repo-owned through `instance/extensions.yml`
- and producing validated proposal packets as the primary durable output
