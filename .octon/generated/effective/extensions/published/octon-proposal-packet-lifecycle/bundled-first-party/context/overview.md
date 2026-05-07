# Proposal Packet Lifecycle Overview

## Purpose

Automate the complete proposal packet lifecycle without changing the proposal
authority model. The extension provides reusable lifecycle routes and prompt
bundles that keep packet-specific source context in `resources/**` and
operational prompts in `support/**`.

## Composition

The pack composes these existing Octon surfaces:

- proposal workspace rules and subtype standards,
- proposal templates and validators,
- proposal create, validate, promote, and archive workflows,
- concept-integration source-to-packet and packet-to-implementation routes,
- impact-map-and-validation-selector validation routing,
- drift triage and hygiene packetizer routes where source context requires it,
- extension publication, capability publication, and host projection scripts.

## Non-Goals

- no new proposal workspace root,
- no nested child proposal package directories,
- no runtime or policy dependency on raw proposal packets,
- no direct mutation of generated proposal registry outside its generator,
- no use of GitHub, CI, comments, labels, chat, tools, or browser state as
  Octon authority.
