# @harmony/kits

Modular building blocks for Harmony AI agents. Kits provide reusable functionality that AI agents orchestrate to accomplish tasks.

## Philosophy

**Kits are tools for AI, not humans.**

Human developers orchestrate AI agents via the `harmony` CLI. AI agents use Kits to do the actual work. You rarely need to interact with Kits directly.

```
Human → harmony CLI → AI Agents → Kits → Results
```

## Available Kits

| Kit | Purpose | Status |
|-----|---------|--------|
| **FlowKit** | Workflow orchestration and multi-step execution | ✅ Implemented |
| **GuardKit** | AI output protection (injection, hallucination, secrets) | ✅ Implemented |
| **SpecKit** | Specification generation and validation | 🔄 Planned |
| **PlanKit** | Implementation planning and ADR generation | 🔄 Planned |
| **TestKit** | Test generation and execution | 🔄 Planned |
| **PatchKit** | PR creation and code patches | 🔄 Planned |
| **EvalKit** | AI output evaluation and quality scoring | 🔄 Planned |
| **PolicyKit** | Policy enforcement and compliance | 🔄 Planned |
| **ObservaKit** | Observability and telemetry | 🔄 Planned |

## Quick Start

```bash
# Install dependencies
pnpm install

# Build
pnpm build

# Run tests
pnpm test
```

## GuardKit

Protects against AI failures and security risks:

- **Prompt Injection Detection**: Blocks attempts to manipulate AI behavior
- **Hallucination Detection**: Identifies fake imports, functions, APIs
- **Secret Scanning**: Catches leaked API keys, passwords, tokens
- **PII Detection**: Flags email addresses, phone numbers, SSNs
- **Code Safety**: Catches dangerous patterns (eval, SQL injection, XSS)

```typescript
import { GuardKit } from '@harmony/kits/guardkit';

const guard = new GuardKit({
  projectRoot: process.cwd(),
  packageJson: require('./package.json'),
});

const result = guard.check(aiOutput);
if (!result.safe) {
  console.error('Issues:', result.checks.filter(c => !c.passed));
}
```

See [`src/guardkit/README.md`](./src/guardkit/README.md) for detailed documentation.

## FlowKit

Orchestrates multi-step AI workflows:

```typescript
import { FlowKit } from '@harmony/kits/flowkit';

const flow = new FlowKit();

// Define and execute a workflow
const result = await flow.execute({
  steps: [
    { id: 'spec', prompt: specPrompt, input: intent },
    { id: 'plan', prompt: planPrompt, depends: ['spec'] },
    { id: 'code', prompt: codePrompt, depends: ['plan'] },
  ],
});
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Human Developer                           │
│  ┌─────────────────┐  ┌──────────────────┐  ┌────────────────┐  │
│  │  harmony check  │  │ AI-GUARDRAILS.md │  │ Review Prompts │  │
│  └────────┬────────┘  └──────────────────┘  └────────────────┘  │
└───────────┼─────────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      GuardKit (kits package)                     │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────────┐    │
│  │  Sanitizer   │  │   Detector   │  │      Patterns       │    │
│  │ - Injection  │  │ - Hallucin.  │  │ - Injection (8)     │    │
│  │ - Secrets    │  │ - Imports    │  │ - Secrets (8)       │    │
│  │ - PII        │  │ - APIs       │  │ - PII (5)           │    │
│  └──────────────┘  └──────────────┘  │ - Code Safety (8)   │    │
│                                       │ - Hallucination (7) │    │
│                                       └─────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Prompts Package Integration                    │
│  ┌──────────────────┐  ┌──────────────────────────────────────┐ │
│  │ Hallucination    │  │ Golden Test Monitoring                │ │
│  │ - 8 indicators   │  │ - Record runs                         │ │
│  │ - Confidence     │  │ - Drift detection                     │ │
│  │ - Reports        │  │ - Alerts (4 types)                    │ │
│  └──────────────────┘  │ - Weekly summaries                    │ │
│                        └──────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## For Human Developers

You typically interact with Kits through the `harmony` CLI:

```bash
# GuardKit powers this command
harmony check output.ts
harmony verify-imports

# FlowKit orchestrates these
harmony feature "Add user login"
harmony build
```

## For AI Agents

Kits are your primary tools. Import and use them directly:

```typescript
// Guard AI-generated content
import { GuardKit } from '@harmony/kits/guardkit';

// Orchestrate multi-step workflows  
import { FlowKit } from '@harmony/kits/flowkit';

// Validate specs (when implemented)
import { SpecKit } from '@harmony/kits/speckit';
```

## Package Structure

```
packages/kits/
├── package.json
├── tsconfig.json
├── README.md
└── src/
    ├── index.ts              # Main exports
    ├── flowkit/              # Workflow orchestration
    │   ├── index.ts
    │   ├── cli.ts
    │   └── __tests__/
    └── guardkit/             # AI guardrails
        ├── README.md         # Detailed docs
        ├── index.ts          # Main class
        ├── types.ts          # Type definitions
        ├── patterns.ts       # Detection patterns
        ├── sanitizer.ts      # Input sanitization
        ├── detector.ts       # Hallucination detection
        └── __tests__/
```

## Development

```bash
# Type check
pnpm typecheck

# Run all tests
pnpm test

# Run specific kit tests
pnpm test src/guardkit/__tests__/
```

## Integration with Other Packages

| Package | Relationship |
|---------|--------------|
| `@harmony/prompts` | Kits use prompts for AI generation |
| `@harmony/harmony-cli` | CLI orchestrates kits via AI agents |
| `@harmony/adapters` | Kits use adapters for external services |

## License

Private — part of the Harmony monorepo.

