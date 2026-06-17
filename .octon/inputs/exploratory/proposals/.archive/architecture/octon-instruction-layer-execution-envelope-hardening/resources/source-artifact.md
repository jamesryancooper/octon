# Source Artifact Register

## Source metadata

- **Title:** The Anatomy of an Agent Harness
- **Author:** Avi Chawla
- **Date:** 2026-04-06
- **Type:** article / technical post
- **Source delivery:** user-provided in prompt context

## Source concepts that mattered after verification

The stage-2 verification reduced the useful concept set to two surviving refinements:

1. explicit instruction-layer / prompt-construction / progressive-disclosure provenance
2. typed capability invocation with normalized output-envelope handling

Everything else from the source was either already covered in live Octon or not transferable without violating existing invariants.

## Source claims retained in this packet

- production agents fail when context and tool surfaces are unmanaged
- prompt construction and context management are distinct engineering concerns
- the harness should expose the smallest high-signal token set needed for the step
- tool use should be structured and schema-backed rather than free-form
- tool/result handling must preserve self-correction and observability without turning chat memory into authority

## Source claims explicitly not promoted

- memory/session stores as durable truth
- framework-specific embodiments as architecture recommendations
- rhetoric such as “the harness is the product”
