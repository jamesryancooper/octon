# PromptKit

Runtime prompt compiler for Harmony AI agents. PromptKit transforms static prompt templates from `@harmony/prompts` into ready-to-use prompts with determinism guarantees.

## Interfaces

PromptKit provides three interfaces:

| Interface | Consumers | Use For |
|-----------|-----------|---------|
| **Programmatic API** (primary) | AI agents, services | Production prompt compilation |
| **HTTP Runner** | Python agents, microservices | Cross-language, distributed systems |
| **CLI** | Humans, CI/CD | Debugging, testing prompts |

## Programmatic API (Primary)

The programmatic API is the **source of truth** for PromptKit functionality.

### Quick Start

```typescript
import { PromptKit } from '@harmony/promptkit';

const promptKit = new PromptKit();

// Compile a prompt with variables
const compiled = await promptKit.compile('spec-from-intent', {
  intent: 'Add user authentication',
  tier: 'T2',
});

console.log(compiled.prompt);       // Rendered prompt text
console.log(compiled.prompt_hash);  // sha256:abc123... (deterministic)
console.log(compiled.metadata.model); // Recommended model
```

### Configuration

```typescript
interface PromptKitConfig {
  /** Path to the prompts package root (auto-detected if not provided) */
  promptsRoot?: string;

  /** Path to the catalog file (defaults to catalog.yaml in promptsRoot) */
  catalogPath?: string;

  /** Enable observability spans */
  enableTracing?: boolean;

  /** Default model to use when tier doesn't specify */
  defaultModel?: string;

  /** Enable run record generation (default: true) */
  enableRunRecords?: boolean;

  /** Directory to write run records */
  runsDir?: string;
}
```

### Key Methods

#### `compile(promptId, variables, options?): CompiledPrompt`

Compile a prompt with variables:

```typescript
const compiled = await promptKit.compile('spec-from-intent', {
  intent: 'Add user authentication with Google OAuth',
  context: { codebase: 'Node.js/TypeScript' },
  tier: 'T2',
}, {
  variantId: 'concise',       // Specific variant
  maxTokens: 4000,            // Token budget
  model: 'gpt-4o',            // Override model
});

// CompiledPrompt structure
interface CompiledPrompt {
  prompt: string;               // The rendered prompt
  prompt_hash: string;          // Deterministic hash
  metadata: PromptMetadata;     // Model, tokens, variant info
  variables_used: Record<string, unknown>;  // Inputs (secrets redacted)
}
```

#### `validate(promptId, variables): ValidationResult`

Validate variables against prompt schema:

```typescript
const validation = await promptKit.validate('spec-from-intent', {
  intent: '',  // Empty - should fail
});

if (!validation.valid) {
  console.error('Errors:', validation.errors);
  console.error('Missing:', validation.missingVariables);
}
```

#### `info(promptId): PromptInfo`

Get information about a prompt:

```typescript
const info = await promptKit.info('spec-from-intent');
console.log('Name:', info.name);
console.log('Variants:', info.variants);
console.log('Supported tiers:', info.tierSupport);
```

#### `list(category?): PromptInfo[]`

List available prompts:

```typescript
const prompts = await promptKit.list();
const specPrompts = await promptKit.list('specification');
```

### Token Management

```typescript
import { estimateTokens, applyTokenBudget } from '@harmony/promptkit';

// Estimate tokens
const count = estimateTokens('Your prompt text here', 'gpt-4o');

// Apply token budget with truncation
const result = applyTokenBudget(longText, {
  maxTokens: 4000,
  reserveOutputTokens: 1000,
  strategy: 'prioritize_recent',
});

if (result.truncated) {
  console.log(`Truncated from ${result.originalTokens} to ${result.finalTokens}`);
}
```

### Prompt Assembly

Assemble role-based prompts for chat models:

```typescript
import { assemble, toOpenAIFormat } from '@harmony/promptkit';

const assembled = assemble({
  system: compiledSystemPrompt,
  user: compiledUserPrompt,
  tools: [toolPrompt1, toolPrompt2],
});

// Convert to provider format
const messages = toOpenAIFormat(assembled);  // For OpenAI
const anthropicMessages = toAnthropicFormat(assembled);  // For Anthropic
```

## HTTP Interface (Cross-Language)

For Python agents, microservices, or distributed systems:

```typescript
import { createHttpPromptRunner } from '@harmony/promptkit';

const prompt = createHttpPromptRunner({
  baseUrl: 'http://promptkit-service:8083',
  timeoutMs: 30000,
  defaultModel: 'gpt-4o',
});

// Same interface as programmatic API
const compiled = await prompt.compile('spec-from-intent', {
  intent: 'Add user authentication',
  tier: 'T2',
});

const validation = await prompt.validate('spec-from-intent', { intent: '' });
const info = await prompt.info('spec-from-intent');
const list = await prompt.list('specification');
const tokens = await prompt.tokens('Text to count', 'gpt-4o');
```

### HTTP Protocol

The HTTP runner expects a service implementing:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/prompt/compile` | POST | Compile a prompt with variables |
| `/prompt/validate` | POST | Validate variables against schema |
| `/prompt/info/:id` | GET | Get prompt information |
| `/prompt/list` | GET | List available prompts |
| `/prompt/tokens` | POST | Count tokens in text |

## CLI (Debugging and CI/CD)

The CLI is a **thin wrapper** around the programmatic API for human debugging and CI/CD.

```bash
# Compile a prompt
promptkit compile spec-from-intent --vars '{"intent":"Add authentication"}'

# Validate variables
promptkit validate spec-from-intent --vars '{"intent":"Add authentication"}'

# Get token count
promptkit tokens spec-from-intent --vars '{"intent":"Add authentication"}'

# List available prompts
promptkit list -v

# Get prompt info
promptkit info spec-from-intent

# JSON output
promptkit compile spec-from-intent --vars '{"intent":"..."}' --format json

# Dry-run mode
promptkit compile spec-from-intent --vars '{"intent":"..."}' --dry-run
```

### CLI Commands

| Command | Description |
|---------|-------------|
| `compile` | Compile a prompt with variables |
| `validate` | Validate variables against schema |
| `tokens` | Get token count for compiled prompt |
| `list` | List available prompts |
| `info` | Get information about a prompt |

### CLI Options

| Option | Description |
|--------|-------------|
| `--vars, -V` | Variables as JSON string |
| `--variant` | Specific variant to use |
| `--model, -m` | Override model selection |
| `--max-tokens` | Maximum tokens (triggers truncation) |

Plus all [standard kit flags](../README.md#standard-cli-flags).

## Features

### Template Rendering

Nunjucks-based (Jinja2-like) variable substitution:

```nunjucks
You are analyzing a {{ context.codebase }} project.

The user wants to: {{ intent }}

{% if constraints %}
Constraints:
{% for constraint in constraints %}
- {{ constraint }}
{% endfor %}
{% endif %}
```

### Prompt Hashing

Deterministic SHA-256 hashes for reproducibility:

```typescript
const compiled = await promptKit.compile('my-prompt', vars);
console.log(compiled.prompt_hash);  // sha256:a1b2c3d4...

// Same inputs always produce the same hash
const compiled2 = await promptKit.compile('my-prompt', vars);
assert(compiled.prompt_hash === compiled2.prompt_hash);
```

### Variant Selection

Automatic variant selection based on tier, stage, flags:

```typescript
// Variants can be defined in prompt config
const variants = {
  default: { template_path: './default.md' },
  concise: { 
    template_path: './concise.md',
    enabled_when: [{ tier: ['T1'] }]
  },
  detailed: {
    template_path: './detailed.md',
    enabled_when: [{ tier: ['T3'] }]
  }
};

// PromptKit selects automatically based on context
const compiled = await promptKit.compile('my-prompt', { tier: 'T3' });
// Will use 'detailed' variant
```

## Architecture

```
@harmony/prompts (static)     →     PromptKit (runtime)     →     LLM
├── Templates                       ├── compile()
├── Schemas                         ├── computeHash()
├── Examples                        ├── selectVariant()
└── Catalog                         └── assemble()
```

## Testing

```bash
# Run PromptKit tests
pnpm --filter @harmony/promptkit test
```

## See Also

- **@harmony/prompts** — Static prompt library (templates, schemas, validation)
- **CostKit** — LLM cost estimation and tracking
- **GuardKit** — AI output validation and safety checks
- [@harmony/kit-base](../kit-base/README.md) — Shared infrastructure

## License

Private — part of the Harmony monorepo.
