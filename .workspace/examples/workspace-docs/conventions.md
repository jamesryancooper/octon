# Conventions

## File Naming

- Lowercase with hyphens: `get-user.md`, `authentication.md`
- Index files: `README.md` in each directory
- Versioned docs: `v2/endpoint-name.md`

## Document Structure

### Endpoint Documentation

```markdown
# Endpoint Name

Brief description of what this endpoint does.

## Request

`METHOD /path/to/endpoint`

### Headers

| Header | Required | Description |
|--------|----------|-------------|

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|

### Body

```json
{
  "example": "request"
}
```

## Response

### Success (200)

```json
{
  "example": "response"
}
```

### Errors

| Code | Description |
|------|-------------|
```

## Writing Style

| Do | Don't |
|----|-------|
| Use active voice | Use passive voice |
| Show concrete examples | Describe abstractly |
| Keep descriptions concise | Write lengthy paragraphs |
| Include error scenarios | Only show happy path |

## Code Examples

- Always include curl example
- Include JavaScript and Python when relevant
- Use realistic (but fake) data in examples

## Progress Log Format

```markdown
## YYYY-MM-DD

**Session focus:** [one-line summary]

**Completed:**
- [task 1]

**Next:**
- [priority item]

**Blockers:**
- [if any]
```
