# Prompt — Runtime Prompt Compiler

## Overview

Prompt is the **runtime compiler/renderer** that transforms static prompt templates from `@harmony/prompts` into ready-to-use prompts with determinism guarantees. It provides the essential runtime layer for AI agent prompt management.

**Purpose:** Compile, render, and manage prompts at runtime with support for template variables, variant selection, token budget management, and deterministic hashing.

**Key Capabilities:**
- **Template Rendering:** Nunjucks-based (Jinja2-like) variable substitution
- **Prompt Hash Computation:** Deterministic SHA-256 hashes for reproducibility verification
- **Variant Selection:** Automatic variant selection based on tier, stage, and feature flags
- **Token Budget Management:** Estimation, truncation, and context window handling
- **Role-based Assembly:** Combine system, user, and tool prompts into chat format

## Architecture

```
@harmony/prompts (static)     →     Prompt (runtime)     →     LLM
├── Templates                       ├── compile()
├── Schemas                         ├── computeHash()
├── Examples                        ├── selectVariant()
├── Validation                      ├── applyTokenBudget()
└── Catalog                         └── assemble()
```

**Relationship with @harmony/prompts:**
- `@harmony/prompts` provides the **static layer**: templates, schemas, validation, golden tests
- `Prompt` provides the **runtime layer**: compilation, rendering, hashing, variant selection

## Installation

```typescript
import { PromptKit } from '@harmony/promptkit';

const prompt = new PromptKit();
```

## Core API

### compile()

Compile a prompt template with variables:

```typescript
const compiled = prompt.compile('spec-from-intent', {
  intent: 'Add user authentication to the API',
  context: { codebase: 'Node.js/TypeScript' },
  tier: 'T2',
});

console.log(compiled.prompt);           // The fully rendered prompt
console.log(compiled.prompt_hash);      // sha256:abc123... (deterministic)
console.log(compiled.metadata.model);   // gpt-4o (tier-appropriate)
console.log(compiled.metadata.tokens_estimated);  // ~2500
```

**Returns:**
```typescript
interface CompiledPrompt {
  prompt: string;
  prompt_hash: string;
  metadata: PromptMetadata;
  variables_used: Record<string, unknown>;  // Secrets redacted
}
```

### assemble()

Assemble multiple prompts into chat format:

```typescript
const assembled = prompt.assemble({
  system: compiledSystemPrompt,  // CompiledPrompt or string
  user: compiledUserPrompt,
});

// Convert to provider format
const openaiMessages = prompt.toOpenAIFormat(assembled);
const anthropicFormat = prompt.toAnthropicFormat(assembled);
```

### selectVariant()

Select a prompt variant based on context:

```typescript
const variant = prompt.selectVariant('spec-from-intent', {
  tier: 'T1',
  stage: 'draft',
  flags: { 'prompt.concise': true },
});

console.log(variant.id);           // 'concise'
console.log(variant.templatePath); // './core/spec-from-intent/prompt-concise.md'
```

### validate()

Validate a prompt compiles correctly:

```typescript
const result = prompt.validate('spec-from-intent', { intent: '...' });

if (!result.valid) {
  console.error('Errors:', result.errors);
}
if (result.warnings.length > 0) {
  console.warn('Warnings:', result.warnings);
}
```

## Token Budget Management

Prompt provides sophisticated token budget management:

```typescript
const compiled = prompt.compile('spec-from-intent', variables, {
  maxTokens: 8000,
  reserveOutputTokens: 2000,
  truncationStrategy: 'balanced',  // 'prioritize_start' | 'prioritize_recent' | 'balanced'
});

if (compiled.metadata.truncated) {
  console.log(`Truncated using ${compiled.metadata.truncation_strategy}`);
}

// Get detailed token info
const tokenInfo = prompt.getTokenInfo(compiled);
console.log(`${tokenInfo.usagePercent.toFixed(1)}% of context used`);
console.log(`${tokenInfo.availableForOutput} tokens available for output`);
```

## Variant Configuration

Variants are configured in `catalog.yaml`:

```yaml
core_prompts:
  spec-from-intent:
    variants:
      default:
        template_path: "./core/spec-from-intent/prompt.md"
        description: "Standard comprehensive template"
      concise:
        template_path: "./core/spec-from-intent/prompt-concise.md"
        description: "Shorter template for simple changes"
        enabled_when:
          - tier: [T1]
      detailed:
        template_path: "./core/spec-from-intent/prompt-detailed.md"
        description: "Extra detailed for T3 security-sensitive"
        enabled_when:
          - tier: [T3]
```

## Prompt Hashing

Prompt computes deterministic SHA-256 hashes for all compiled prompts:

```typescript
import { computePromptHash, verifyPromptHash, shortHash } from '@harmony/promptkit';

// Compute hash
const hash = computePromptHash(prompt, variables, promptId, version);
// → "sha256:7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069"

// Display short form
console.log(shortHash(hash));  // → "sha256:7f83b165"

// Verify integrity
const isValid = verifyPromptHash(prompt, variables, expectedHash);
```

**Hash includes:**
- Rendered prompt text
- Input variables (with secrets redacted)
- Prompt ID and version

**Secrets are automatically redacted** from variables before hashing:
- `api_key`, `password`, `token`, `secret`, `credential`, `auth`, `private_key`

## Template Syntax

Prompt uses Nunjucks (Jinja2-like) syntax with custom filters:

```markdown
# Specification for: {{ intent }}

## Context
{% if context.codebase %}
This is a {{ context.codebase }} project.
{% endif %}

## Requirements
{% for req in requirements %}
- {{ req }}
{% endfor %}

## Code Example
{{ code | code_block('typescript') }}

## Summary
{{ description | truncate(200) }}
```

**Available Filters:**
- `truncate(length, end='...')` — Truncate text
- `indent(spaces)` — Indent each line
- `json(spaces)` — JSON stringify
- `yaml_list` — Format as YAML list
- `code_block(language)` — Wrap in markdown code block

## CLI

Prompt provides a CLI for development and debugging:

```bash
# Compile a prompt
promptkit compile spec-from-intent --vars '{"intent":"Add auth", "tier":"T2"}'

# Validate a prompt
promptkit validate spec-from-intent --vars '{"intent":"..."}'

# Estimate tokens
promptkit tokens spec-from-intent --vars '{"intent":"..."}'

# List variants
promptkit variants spec-from-intent

# List all prompts
promptkit list -v

# Get prompt info
promptkit info spec-from-intent

# JSON output
promptkit list -j
```

## Observability

Prompt emits spans for tracing:

```typescript
// Span: kit.promptkit.compile
{
  'kit.name': 'promptkit',
  'prompt.id': 'spec-from-intent',
  'prompt.version': '1.0.0',
  'prompt.variant': 'default',
  'prompt.hash': 'sha256:abc123...',
  'tokens.estimated': 2500,
  'truncated': false,
}
```

## Integration with Other Services

### With Cost

```typescript
import { CostKit } from '@harmony/costkit';
import { PromptKit } from '@harmony/promptkit';

const cost = new CostKit();
const prompt = new PromptKit();

// Compile prompt
const compiled = prompt.compile('spec-from-intent', variables);

// Estimate cost before calling LLM
const estimate = cost.estimate({
  workflowType: 'spec-from-intent',
  tier: 'T2',
  inputText: compiled.prompt,
});

console.log(`Estimated cost: $${estimate.estimatedCostUsd.toFixed(4)}`);
```

### With Guard

```typescript
import { GuardKit } from '@harmony/guardkit';

// Validate AI output before processing
const guardResult = await guard.fullCheck({
  output: aiResponse,
  context: {
    promptHash: compiled.prompt_hash,
    tier: 'T2',
  },
});
```

## Best Practices

1. **Always use compile()** — Never concatenate prompts manually; use compile() for consistent hashing and validation.

2. **Use tier-appropriate variants** — Let Prompt select variants automatically based on tier.

3. **Monitor token usage** — Use `getTokenInfo()` to ensure prompts fit in context windows.

4. **Verify hashes in production** — Store and verify prompt hashes to detect drift.

5. **Use the CLI for debugging** — The CLI provides quick validation and inspection.

## Responsibilities

| Concern | Prompt | @harmony/prompts |
|---------|--------|------------------|
| Template storage | No | Yes |
| Schema validation | Delegates | Yes |
| Golden tests | No | Yes |
| Rendering | **Yes** | No |
| Hashing | **Yes** | No |
| Variant selection | **Yes** | No |
| Token management | **Yes** | No |

## Common Questions

**Q: Programmatic prompts?**
A: Yes — use Nunjucks partials and filters, or compile templates with computed variables.

**Q: Per-environment variants?**
A: Yes — configure variants with `enabled_when` conditions including flags.

**Q: A/B testing?**
A: Yes — use flag conditions for variant selection with fallback.

**Q: How do I add a new prompt?**
A: Add the template to `@harmony/prompts`, register in `catalog.yaml`, then use via Prompt.

**Q: What if I need to change a prompt?**
A: Update the template, bump the version, and update golden tests. Hashes will automatically change.

## Implementation Choices (Opinionated)

- **nunjucks:** Jinja2-like templating with powerful filters and partials
- **crypto (Node.js):** SHA-256 hashing for deterministic prompt identification
- **@harmony/prompts:** Static layer integration for templates, schemas, and validation
