# PromptKit

Runtime prompt compiler for Harmony AI agents.

## Overview

PromptKit transforms static prompt templates from `@harmony/prompts` into ready-to-use prompts with determinism guarantees.

## Features

- **Template Rendering** — Nunjucks-based (Jinja2-like) variable substitution
- **Prompt Hashing** — Deterministic SHA-256 hashes for reproducibility
- **Variant Selection** — Automatic selection based on tier, stage, flags
- **Token Management** — Estimation, truncation, context window handling
- **Role Assembly** — Combine system, user, tool prompts into chat format

## Quick Start

```typescript
import { PromptKit } from '@harmony/kits/promptkit';

const promptKit = new PromptKit();

// Compile a prompt
const compiled = promptKit.compile('spec-from-intent', {
  intent: 'Add user authentication',
  tier: 'T2',
});

console.log(compiled.prompt);       // Rendered prompt
console.log(compiled.prompt_hash);  // sha256:abc123...
```

## Modules

| Module | Purpose |
|--------|---------|
| `compiler.ts` | Nunjucks template rendering |
| `hasher.ts` | Deterministic prompt hashing |
| `tokens.ts` | Token estimation and budget management |
| `variants.ts` | Variant selection logic |
| `assembler.ts` | Role-based prompt assembly |
| `index.ts` | Main PromptKit class |
| `cli.ts` | Command-line interface |

## CLI

```bash
# Compile
promptkit compile spec-from-intent --vars '{"intent":"..."}'

# Validate
promptkit validate spec-from-intent --vars '{"intent":"..."}'

# Tokens
promptkit tokens spec-from-intent --vars '{"intent":"..."}'

# List
promptkit list -v
```

## Architecture

```
@harmony/prompts (static)     →     PromptKit (runtime)     →     LLM
├── Templates                       ├── compile()
├── Schemas                         ├── computeHash()
├── Examples                        ├── selectVariant()
└── Catalog                         └── assemble()
```

## Related

- **@harmony/prompts** — Static prompt library (templates, schemas, validation)
- **CostKit** — LLM cost estimation and tracking
- **GuardKit** — AI output validation and safety checks

