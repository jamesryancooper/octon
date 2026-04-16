# Output Contract

Return all results under exactly these top-level sections.

## `impact_map`

- `status`
- `route_id`
- `direct_surfaces`
- `adjacent_surfaces`
- `declared_but_unobserved_surfaces`
- `non_impacts`

## `minimum_credible_validation_set`

- `selected[]` with:
  - `id`
  - `kind`
  - `invocation`
  - `scope`
  - `requirement_level`
  - `selected_because`
- `omitted[]` with:
  - `id`
  - `kind`
  - `why_omitted`

## `rationale_trace`

- ordered assertion-level entries that tie input facts and repo evidence to
  the chosen validations and next-step route

## `recommended_next_step`

- `primary`
  - `route_kind`
  - `route_id`
  - `invocation`
  - `why`
  - `prerequisites`
- `alternates[]`

If a credible answer is impossible, keep the schema intact and set
`impact_map.status` to `needs-clarification` or `blocked`.
