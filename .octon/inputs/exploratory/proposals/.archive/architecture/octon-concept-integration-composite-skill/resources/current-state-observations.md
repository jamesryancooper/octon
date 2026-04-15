# Current-State Observations

## Repo-Grounded Facts Used For This Packet

1. `instance/**` is the repo-specific durable authority layer, and
   `instance/capabilities/runtime/**` is explicitly instance-native.
2. Raw additive packs live only under `inputs/additive/extensions/**` and are
   the canonical reusable pack surface.
3. Repo-owned extension activation lives only in `instance/extensions.yml`.
4. Runtime-facing extension consumption reads only
   `generated/effective/extensions/**`.
5. Runtime-facing capability consumption reads only
   `generated/effective/capabilities/**`.
6. The current concept-integration prompt set already defines:
   - extraction
   - verification
   - proposal packet generation
   - implementation-prompt generation
   - prompt-set alignment as a companion audit
7. The prompt-set README already defines the alignment audit and executable
   prompt generator as companions rather than numbered stages.
8. Existing publication scripts and tests show that extension command and skill
   contributions can be surfaced into effective capability routing through
   extension `routing_exports`.
9. The active runtime-facing extension publication model is centered on
   `catalog.effective.yml`, `artifact-map.yml`, and `generation.lock.yml`.
10. The visible publication model for extensions is routing-oriented; it does
    not currently advertise a separate first-class effective surface for
    extension skill registry metadata.

## Design Consequence

These facts support the following packet decisions:

- use an extension pack, not a repo-native skill, for modular portability
- keep the composite skill as the reusable execution core
- add a thin command wrapper as the safest v1 invocation surface
- internalize the prompt assets into the pack itself
- keep the output proposal packet under the existing manifest-governed proposal
  workspace
