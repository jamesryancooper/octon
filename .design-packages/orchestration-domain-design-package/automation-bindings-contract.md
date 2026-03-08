# Automation Bindings Contract

## Purpose

Define the canonical semantics for `bindings.yml`, especially
`event_to_param_map`.

This document is normative for automation input binding behavior.

## Core Concepts

| Concept | Meaning |
|---|---|
| binding source path | Canonical path into the triggering event envelope |
| destination parameter | Workflow input parameter name |
| required binding | Missing source value blocks launch |
| optional binding | Missing source value uses default or omission |

## Binding Object Shape

```yaml
event_to_param_map:
  target_path:
    from: "event.source_ref"
    required: true
    value_type: "string"
  severity:
    from: "event.severity"
    required: false
    default: "warning"
    value_type: "string"
```

## Source Path Grammar

Allowed `from` roots:

- `event.<field>`
- `event.payload.<field>`

No other roots are valid in v1.

## Type Rules

Allowed `value_type` values:

- `string`
- `integer`
- `number`
- `boolean`

Type mismatch blocks launch with `binding_validation_failure`.

## Defaulting Rules

- defaults are allowed only when `required=false`
- defaults must match `value_type`
- required bindings ignore defaults and block if the source is missing

## Validation Behavior

Before a launch may be admitted:

1. validate the binding object structure
2. resolve every `from` path
3. apply defaulting for optional bindings
4. verify types
5. emit `block` if any required binding fails

## Non-Goals

The binding contract does not permit arbitrary transforms, templating, or code
execution in v1.

It is intentionally declarative and minimal.
