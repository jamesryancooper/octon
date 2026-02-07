---
examples:
  - input: "{{example input}}"
    invocation: "/skill-name '{{example input}}'"
    output: ".harmony/output/{{category}}/{{timestamp}}-{{name}}.md"
    description: "{{What this example demonstrates}}"
  - input: "{{another example}}"
    invocation: "/skill-name '{{another example}}' --option={{value}}"
    output: ".harmony/output/{{category}}/{{timestamp}}-{{name}}.md"
    description: "{{What this example demonstrates}}"
---

# Examples Reference

**Optional:** Include when output format benefits from worked examples.

Full examples demonstrating skill-name skill usage.

## Example 1: {{Example Name}}

### Input

```text
/skill-name "{{example input}}"
```

### Expected Output

```markdown
# {{Output Title}}

{{Example of what the output would look like}}

## Section 1

{{Content}}

## Section 2

{{Content}}
```

### Notes

{{Any notes about this example - what it demonstrates, edge cases it handles, etc.}}

## Example 2: {{Example Name with Options}}

### Input

```text
/skill-name "{{example input}}" --option={{value}}
```

### Expected Behavior

With `--option={{value}}`, the skill:

1. {{Behavior change 1}}
2. {{Behavior change 2}}
3. {{Behavior change 3}}

### Notes

{{Notes about using options}}
