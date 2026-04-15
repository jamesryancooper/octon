# Alignment Mode Contract

This file is the human-readable source of truth for prompt-bundle alignment
mode semantics across the `octon-concept-integration` bundle family.

## Behavioral Source Of Truth

`/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh`
is the behavioral source of truth for `alignment_mode`.

Bundle prompts and skill docs may list supported modes, but they must not
redefine the resolver's behavior.

## Supported Modes

- `auto`
  Use the published bundle when fresh; otherwise block until realignment and
  republish restore a safe bundle.
- `always`
  Force explicit realignment/republication before use, even when the last
  published bundle would otherwise resolve fresh.
- `skip`
  Allow degraded execution only when foundational prompt-bundle integrity still
  holds and the run explicitly records degraded execution.

## Default Policy Source Of Truth

Each bundle manifest's `alignment_policy` block is the source of truth for that
bundle's default mode, skip policy, and receipt root.
