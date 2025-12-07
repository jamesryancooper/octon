# @harmony/kits

Modular building blocks for Harmony AI agents. Kits provide reusable functionality that AI agents orchestrate to accomplish tasks.

## Philosophy

**Kits are tools for AI, not humans.**

Human developers orchestrate AI agents via the `harmony` CLI. AI agents use Kits to do the actual work. You rarely need to interact with Kits directly.

```
Human → harmony CLI → AI Agents → Kits → Results
```

## Package Structure

This is a multi-package workspace containing the following kits:

```
packages/kits/
├── kit-base/        # Shared infrastructure (types, errors, observability)
├── flowkit/         # Workflow orchestration and multi-step execution
├── guardkit/        # AI output protection (injection, hallucination, secrets)
├── promptkit/       # Runtime prompt compilation (templates, hashing, variants)
├── costkit/         # LLM cost management (estimation, tracking, budgeting)
├── package.json     # Workspace configuration
├── tsconfig.json    # Shared TypeScript config
└── README.md        # This file
```

## Available Kits

| Kit | Purpose | Status | Package |
|-----|---------|--------|---------|
| **kit-base** | Shared infrastructure (types, errors, observability) | ✅ Implemented | `@harmony/kit-base` |
| **FlowKit** | Workflow orchestration and multi-step execution | ✅ Implemented | `@harmony/flowkit` |
| **GuardKit** | AI output protection (injection, hallucination, secrets) | ✅ Implemented | `@harmony/guardkit` |
| **PromptKit** | Runtime prompt compilation (templates, hashing, variants) | ✅ Implemented | `@harmony/promptkit` |
| **CostKit** | LLM cost management and optimization | ✅ Implemented | `@harmony/costkit` |
| **SpecKit** | Specification generation and validation | 🔄 Planned | — |
| **PlanKit** | Implementation planning and ADR generation | 🔄 Planned | — |
| **TestKit** | Test generation and execution | 🔄 Planned | — |
| **PatchKit** | PR creation and code patches | 🔄 Planned | — |
| **EvalKit** | AI output evaluation and quality scoring | 🔄 Planned | — |
| **PolicyKit** | Policy enforcement and compliance | 🔄 Planned | — |
| **ObservaKit** | Observability and telemetry | 🔄 Planned | — |

## Quick Start

```bash
# Install dependencies
pnpm install

# Build all kits
pnpm build

# Run tests
pnpm test

# Type check
pnpm typecheck
```

## Usage

### GuardKit

Protects against AI failures and security risks:

- **Prompt Injection Detection**: Blocks attempts to manipulate AI behavior
- **Hallucination Detection**: Identifies fake imports, functions, APIs
- **Secret Scanning**: Catches leaked API keys, passwords, tokens
- **PII Detection**: Flags email addresses, phone numbers, SSNs
- **Code Safety**: Catches dangerous patterns (eval, SQL injection, XSS)

```typescript
import { GuardKit } from '@harmony/guardkit';

const guard = new GuardKit({
  projectRoot: process.cwd(),
  packageJson: require('./package.json'),
});

const result = guard.check(aiOutput);
if (!result.safe) {
  console.error('Issues:', result.checks.filter(c => !c.passed));
}
```

See [`guardkit/README.md`](./guardkit/README.md) for detailed documentation.

### FlowKit

Orchestrates multi-step AI workflows:

```typescript
import { createHttpFlowRunner, type FlowRunRequest } from '@harmony/flowkit';

const runner = createHttpFlowRunner({
  baseUrl: 'http://127.0.0.1:8410',
});

const result = await runner.run({
  config: {
    flowName: 'my_workflow',
    canonicalPromptPath: 'packages/prompts/my-prompt.md',
    workflowManifestPath: 'langgraph.json',
  },
  params: { targetPath: './src' },
});
```

See [`flowkit/README.md`](./flowkit/README.md) for detailed documentation.

### PromptKit

Runtime prompt compiler with determinism guarantees:

```typescript
import { PromptKit } from '@harmony/promptkit';

const promptKit = new PromptKit();

const compiled = await promptKit.compile('spec-from-intent', {
  intent: 'Add user authentication',
  tier: 'T2',
});

console.log(compiled.prompt);       // Rendered prompt
console.log(compiled.prompt_hash);  // sha256:abc123...
```

See [`promptkit/README.md`](./promptkit/README.md) for detailed documentation.

### CostKit

LLM cost management and optimization:

```typescript
import { CostKit } from '@harmony/costkit';

const costKit = new CostKit();

// Get pre-flight estimate
const estimate = await costKit.estimate({
  workflowType: 'code-from-plan',
  tier: 'T2',
  stage: 'final',
});

console.log(`Estimated cost: $${estimate.estimatedCostUsd.toFixed(4)}`);

// Check budget before proceeding
const budgetCheck = costKit.checkBudget(estimate.estimatedCostUsd);
if (!budgetCheck.allowed) {
  console.warn('Budget exceeded:', budgetCheck.reason);
}
```

See [`costkit/README.md`](./costkit/README.md) for detailed documentation.

## Shared Infrastructure (kit-base)

All kits share common infrastructure from `@harmony/kit-base`:

- **Types**: Common types like `KitState`, `LifecycleStage`, `RiskTier`
- **Errors**: Typed errors (`InputValidationError`, `PolicyViolationError`, etc.)
- **Observability**: Tracing helpers (`createKitSpan`, `withKitSpan`, `emitStateTransition`)
- **Run Records**: Standardized audit trail creation
- **CLI Flags**: Standard flag parsing (`--dry-run`, `--stage`, `--risk`)

```typescript
import { 
  InputValidationError,
  PolicyViolationError,
  createKitSpan,
  parseStandardFlags,
} from '@harmony/kit-base';
```

See [`kit-base/README.md`](./kit-base/README.md) for detailed documentation.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Human Developer                           │
│  ┌─────────────────┐  ┌──────────────────┐  ┌────────────────┐  │
│  │  harmony CLI    │  │ AI-GUARDRAILS.md │  │ Review Prompts │  │
│  └────────┬────────┘  └──────────────────┘  └────────────────┘  │
└───────────┼─────────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────┐
│                         AI Agents                                │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────────┐  │
│  │   FlowKit    │  │   CostKit    │  │      PromptKit        │  │
│  │  Workflows   │  │ Cost Mgmt    │  │  Prompt Compilation   │  │
│  └──────────────┘  └──────────────┘  └───────────────────────┘  │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                      GuardKit                              │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐  │   │
│  │  │  Sanitizer   │  │   Detector   │  │    Patterns     │  │   │
│  │  │ - Injection  │  │ - Hallucin.  │  │ - Injection (8) │  │   │
│  │  │ - Secrets    │  │ - Imports    │  │ - Secrets (8)   │  │   │
│  │  │ - PII        │  │ - APIs       │  │ - PII (5)       │  │   │
│  │  └──────────────┘  └──────────────┘  │ - Code Safety   │  │   │
│  │                                       └─────────────────┘  │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────┐
│                   kit-base (Shared Infrastructure)               │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────────┐  │
│  │    Types     │  │    Errors    │  │    Observability      │  │
│  │ - KitState   │  │ - Typed      │  │ - Tracing             │  │
│  │ - Lifecycle  │  │ - Exit Codes │  │ - Run Records         │  │
│  └──────────────┘  └──────────────┘  └───────────────────────┘  │
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
import { GuardKit } from '@harmony/guardkit';

// Orchestrate multi-step workflows  
import { createHttpFlowRunner } from '@harmony/flowkit';

// Compile prompts with determinism
import { PromptKit } from '@harmony/promptkit';

// Manage costs
import { CostKit } from '@harmony/costkit';
```

## Development

```bash
# Type check all kits
pnpm typecheck

# Run all tests
pnpm test

# Run specific kit tests
pnpm --filter @harmony/guardkit test
pnpm --filter @harmony/flowkit test
pnpm --filter @harmony/promptkit test
pnpm --filter @harmony/costkit test

# Build all kits
pnpm build
```

## Integration with Other Packages

| Package | Relationship |
|---------|--------------|
| `@harmony/prompts` | Kits use prompts for AI generation |
| `@harmony/harmony-cli` | CLI orchestrates kits via AI agents |
| `@harmony/adapters` | Kits use adapters for external services |

## License

Private — part of the Harmony monorepo.
