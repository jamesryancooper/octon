# Example: Refactor Target

Input:

```text
/octon-impact-map-and-validation-selector \
  --bundle refactor-target \
  --strictness balanced \
  '{"type":"rename","old":"old-name","new":"new-name"}'
```

Expected route:

- `refactor-target`

Expected result shape:

- `/refactor` is the primary next step
- extra validators are added only when the affected surfaces require them
