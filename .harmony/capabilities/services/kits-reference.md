# Kits - Quick Reference for Developers

This is the human-friendly guide to using Harmony Kits. For the full technical documentation, see [`packages/kits/README.md`](/packages/kits/README.md).

## What Are Kits?

Kits are modular tools that AI agents use to accomplish tasks. As a human developer, you typically interact with kits through:

1. **The `harmony` CLI** — High-level commands that orchestrate kits
2. **Kit CLIs directly** — For debugging, testing, and CI/CD
3. **The programmatic API** — When building custom tooling

## Quick CLI Reference

### GuardKit — Check AI Output

```bash
# Check if AI output is safe
guardkit check "AI generated content"
guardkit check --file output.ts

# Sanitize user input before prompts
guardkit sanitize "User input to clean"

# Quick safety check
guardkit quick-check "Content to verify"
```

**Use for:** Checking AI-generated code for injection attacks, secrets, hallucinations.

### PromptKit — Compile Prompts

```bash
# Compile a prompt
promptkit compile spec-from-intent --vars '{"intent":"Add authentication"}'

# Validate variables
promptkit validate spec-from-intent --vars '{"intent":"Add authentication"}'

# List available prompts
promptkit list

# Get token count
promptkit tokens spec-from-intent --vars '{"intent":"..."}'
```

**Use for:** Testing prompt templates, checking token counts, validating inputs.

### CostKit — Manage Costs

```bash
# Get cost estimate
costkit estimate --workflow code-from-plan --tier T2

# Check budget status
costkit status --period monthly

# View cost summary
costkit summary

# See alerts
costkit alerts
```

**Use for:** Checking costs before expensive operations, monitoring budgets.

### FlowKit — Run Workflows

```bash
# Run a flow from a config.flow.json
flowkit run packages/workflows/architecture_assessment/config.flow.json

# Dry-run (validate only)
flowkit run packages/workflows/architecture_assessment/config.flow.json --dry-run

# Inspect run records
flowkit runs list
```

**Use for:** Testing workflows, debugging flow execution.

## Common Flags (All Kits)

| Flag | Short | Description |
|------|-------|-------------|
| `--dry-run` | `-n` | Validate without executing (default in local) |
| `--format json` | `-f json` | Output JSON instead of text |
| `--verbose` | `-v` | Show detailed output |
| `--help` | `-h` | Show help |

### Risk and Stage Flags

| Flag | Values | Description |
|------|--------|-------------|
| `--risk` / `-r` | T1, T2, T3 | Risk tier |
| `--stage` / `-s` | spec, plan, implement, verify, ship, operate, learn | Lifecycle stage |

Example:
```bash
guardkit check --risk T3 --stage verify "Security-sensitive content"
```

## When to Use Kit CLIs Directly

### Debugging

```bash
# Test a prompt before using in a workflow
promptkit compile my-prompt --vars '{"foo":"bar"}' --verbose

# Check why content was flagged
guardkit check --format json "Content to debug" | jq .
```

### CI/CD

```bash
# Check generated code in CI
guardkit check --file ./dist/generated.ts

# Verify prompts haven't drifted
promptkit validate my-prompt --vars '{"required":"value"}'

# Check costs before merge
costkit estimate --workflow code-from-plan --tier T2 --format json
```

### Quick Tests

```bash
# Quick safety check
guardkit quick-check "Some AI output"

# Get a cost estimate
costkit estimate --workflow code-from-plan --tier T2

# Count tokens
promptkit tokens my-prompt --vars '{"content":"..."}'
```

## JSON Output for Scripting

All kits support `--format json` for scripting:

```bash
# Parse with jq
guardkit check "content" --format json | jq '.result.safe'

# Use in scripts
SAFE=$(guardkit check "$CONTENT" --format json | jq -r '.result.safe')
if [ "$SAFE" = "false" ]; then
  echo "Content blocked"
  exit 1
fi
```

## Run Records

All kits generate run records by default — JSON files capturing what happened:

```bash
# Find run records
ls ./runs/guardkit/
# => 2025-01-07T10-30-00Z-guardkit-a1b2.json

# Disable run records for quick tests
guardkit check "content" --enable-run-records=false
```

## Common Workflows

### Before Code Review

```bash
# Check generated code
guardkit check --file ./src/generated.ts

# If issues found:
guardkit check --file ./src/generated.ts --format json | jq '.result.checks[] | select(.passed == false)'
```

### Before Expensive Operations

```bash
# Get estimate first
costkit estimate --workflow code-from-plan --tier T2

# Check budget
costkit status
```

### Testing Prompts

```bash
# Compile and inspect
promptkit compile my-prompt --vars '{"intent":"..."}' --verbose

# Validate schema
promptkit validate my-prompt --vars '{"intent":"..."}'
```

## Troubleshooting

### "Unknown command"

```bash
# Make sure kits are built
cd packages/kits && pnpm build

# Check available commands
guardkit --help
```

### "No content provided"

```bash
# Provide content directly
guardkit check "your content here"

# Or from file
guardkit check --file ./path/to/file.ts
```

### JSON Parse Errors

```bash
# Use single quotes for JSON in bash
promptkit compile my-prompt --vars '{"key":"value"}'

# Or escape double quotes
promptkit compile my-prompt --vars "{\"key\":\"value\"}"
```

## See Also

- [AI-GUARDRAILS.md](./AI-GUARDRAILS.md) — GuardKit usage in workflows
- [COST-MANAGEMENT.md](./COST-MANAGEMENT.md) — CostKit and budgeting
- [DAILY-FLOW.md](./DAILY-FLOW.md) — Day-to-day development workflow
- [Full Kit Documentation](/packages/kits/README.md) — Technical details
