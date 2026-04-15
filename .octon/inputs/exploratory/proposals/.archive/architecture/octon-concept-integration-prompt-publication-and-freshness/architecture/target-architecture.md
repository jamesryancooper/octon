# Target Architecture

## Goal

Harden the `octon-concept-integration` extension pack so its prompt set evolves
with Octon through the same class-rooted, publication-backed, fail-closed
discipline that Octon applies to other runtime-facing generated surfaces.

The ideal end state is not merely “run alignment when it seems wise.”
The ideal end state is:

1. an authored prompt-set contract in the pack
2. a generated effective prompt bundle derived from that contract
3. retained alignment and publication receipts
4. fail-closed execution when the prompt bundle is stale or unaligned
5. run-level provenance showing exactly which prompt bundle a run consumed

## Proposed Durable Surface

### 1. Authored prompt-set contract inside the pack

Add an authored manifest at:

`/.octon/inputs/additive/extensions/octon-concept-integration/prompts/octon-concept-integration-pipeline/manifest.yml`

This manifest should define at minimum:

- prompt-set schema/version
- stage prompt ids and paths
- companion prompt ids and paths
- prompt role classes: `stage`, `maintenance-companion`, `prompt-generation-companion`
- required live repo anchors to hash or inspect
- required prompt bundle inputs and outputs
- freshness invalidation conditions
- alignment policy defaults for `alignment_mode=auto`
- narrow override policy for `alignment_mode=skip`

The prompt manifest is authored additive input.
It is not runtime authority by itself.

### 2. Generated effective prompt bundle

Extend the effective extension family with a first-class prompt publication
surface, preferably under:

- `/.octon/generated/effective/extensions/prompt-bundles.effective.yml`
- and published prompt assets under
  `/.octon/generated/effective/extensions/published/<pack-id>/<source-id>/prompts/**`

If the existing `catalog.effective.yml` is extended instead of introducing a
new file, the resulting structure must still provide a stable, machine-readable
prompt bundle record per pack.

The effective prompt bundle must include:

- pack id and source id
- prompt-set manifest digest
- per-prompt digests
- repo anchor digests
- alignment status
- alignment receipt path
- publication status
- projection source paths for published prompt assets when applicable

### 3. Retained alignment and publication receipts

Retain receipts under canonical evidence roots, not inside generated outputs.

Preferred surfaces:

- publication receipts under
  `/.octon/state/evidence/validation/publication/extensions/**`
- prompt alignment receipts under a dedicated retained evidence family such as
  `/.octon/state/evidence/validation/extensions/prompt-alignment/**`

Each retained receipt should capture:

- prompt bundle id
- prompt manifest digest
- repo anchor digest set
- whether alignment was reused or recomputed
- what drift was detected
- whether the bundle is safe to run

### 4. Fail-closed skill gating

Update the `octon-concept-integration` skill contract and metadata so
`alignment_mode=auto` becomes a real gate, not only a convention.

Required behavior:

- if the current effective prompt bundle is fresh and aligned, execute
- if the bundle is stale and re-alignment succeeds, publish and execute the new
  bundle
- if the bundle is stale and re-alignment fails, stop
- if `alignment_mode=skip` is used, require explicit run-level disclosure and
  mark the run as degraded

The skill should consume the effective prompt bundle and alignment receipts,
not re-read raw pack prompts as the default runtime path.

### 5. Run-level prompt provenance

Every retained concept-integration run should record:

- prompt bundle id
- prompt bundle digest
- alignment receipt id
- alignment mode used
- whether the run was fresh, realigned, or degraded-by-skip

This may live inside the run log or in a sibling structured receipt under:

`/.octon/state/evidence/runs/skills/octon-concept-integration/**`

## Relationship To Existing Follow-On Work

The already-created packet
`octon-extension-skill-registry-effective-surface`
addresses extension skill registry visibility.

This packet is broader and preferred because it hardens:

- prompt publication
- freshness and alignment
- fail-closed execution
- and run provenance

The two packets are complementary.
This packet should not be forced to depend on the other unless the final design
needs both changes to converge in one publication model.

## Preferred Landing

The preferred landing is:

- authored prompt manifest in the pack
- generated effective prompt bundle in the extension effective family
- retained alignment/publication receipts
- fail-closed `alignment_mode=auto` behavior
- explicit degraded mode for `alignment_mode=skip`
- run-level prompt provenance
- optional use of the native prompt modeling service to compile the bundle into
  deterministic prompt payloads where it materially reduces drift

## Explicitly Avoided Alternatives

### Workflow convention only

Rejected because “remember to run alignment” is not a durable freshness model.

### Raw prompt rereads at runtime

Rejected because direct runtime reads from raw pack prompt files bypass the
effective publication model and make freshness unverifiable.

### Generated prompt authority

Rejected because effective prompt bundles are runtime-facing publication aids,
not authored authority.

### Silent skip behavior

Rejected because prompt freshness overrides must be explicit, retained, and
easy to audit.
