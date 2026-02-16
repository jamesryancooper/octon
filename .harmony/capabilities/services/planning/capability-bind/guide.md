# Capability Bind Guide

## Purpose

`capability-bind` converts plan requirements into a deterministic capability profile
before scheduling or execution.

## Input

- `plan` or `planPath`
- `requiredCapabilities` (optional; derived from plan steps if omitted)
- `availableCapabilities` (optional)
- `strict`/`command`
- `strategy` (`prefer-native`, `prefer-adapter`, `prefer-available`)

## Output

Returns deterministic bindings and missing-capability diagnostics:
- `bindingSummary`: compact count and category buckets.
- `stepBindings`: per-step required and missing capabilities.
- `capabilityCatalog`: resolved capability state map.

## Example

```bash
cat <<'JSON' | .harmony/capabilities/services/planning/capability-bind/impl/capability-bind.sh
{"command":"bind","plan":{"goal":"ship","steps":[{"id":"build","requires":["flow","artifacts"]}],"requiredCapabilities":["flow","artifacts"],"availableCapabilities":{"flow":"native","artifacts":"adapter"}}
JSON
```
