# @harmony/kits

Modular building blocks for Harmony AI agents. Kits provide reusable functionality that AI agents orchestrate to accomplish tasks.

## Philosophy

**Kits are designed primarily for AI/automated use via the programmatic API.**

Human developers orchestrate AI agents via the `harmony` CLI. AI agents use Kits to do the actual work. We also provide CLIs so humans (and shell-based agents) can experiment, debug, and integrate quickly.

```
Human → harmony CLI → AI Agents → Kits (Programmatic API) → Results
```

## Methodology-as-Code

Kits implement **Methodology-as-Code**: methodology constraints (pillars, lifecycle stages, policy rules) are encoded into machine-readable schemas. AI agents consume these schemas as contracts; humans read documentation.

### Current Versions

| Component | Version | Description |
|-----------|---------|-------------|
| **Schema** | 1.2.0 | Kit metadata schema with versioning and enforcement |
| **Methodology** | 0.2.0 | Harmony methodology (5 pillars, 7 stages) |

### Key Features

- **Version tracking** — All metadata includes `schemaVersion` and `methodologyVersion`
- **Enforcement modes** — `block`, `warn`, or `off` for graceful transitions
- **Deprecation tracking** — Migration guidance for evolving schemas
- **CI validation** — `pnpm --filter @harmony/kit-base validate:methodology`

See [Methodology-as-Code Policy](../../docs/harmony/ai/methodology/methodology-as-code.md) for full documentation.

## Interface Hierarchy

Kits expose three interfaces to serve different consumers. All interfaces share the same underlying implementation and return consistent data structures.

| Interface | Primary | Consumers | Use Cases |
|-----------|---------|-----------|-----------|
| **Programmatic API** | Yes | AI agents, services, batch jobs | Production traffic, high-volume automation |
| **HTTP/RPC** | — | Python/cross-language clients | Distributed systems, microservices |
| **CLI** | — | Humans, CI/CD, shell-based agents | Debugging, scripts, simple integrations |

### Consumer Matrix

| Consumer | Preferred Interface | CLI Okay? |
|----------|---------------------|-----------|
| Production web app / API | Programmatic API | Only for ops/debug |
| CI/CD pipelines | CLI or API | Yes |
| Developer at terminal | CLI | Yes |
| Early experimental AI agent | CLI or API | Yes |
| Long-lived internal kaizen agent | Programmatic API | CLI only as fallback |
| Python/cross-language agent | HTTP Interface | — |

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

### Programmatic API (Primary)

The programmatic API is the **source of truth** for all kit functionality. Use it for production traffic, AI agents, and any automated systems.

#### GuardKit

```typescript
import { GuardKit } from '@harmony/guardkit';

// Create instance
const guard = new GuardKit({
  projectRoot: process.cwd(),
  packageJson: require('./package.json'),
});

// Check AI output before using
const result = guard.check(aiOutput);
if (!result.safe) {
  console.error('Issues detected:', result.checks.filter(c => !c.passed));
}

// Sanitize user input before including in prompts
const sanitized = guard.sanitizeInput(userInput);
```

#### FlowKit

```typescript
import { createHttpFlowRunner, type FlowRunRequest } from '@harmony/flowkit';

// Create runner connected to flow service
const runner = createHttpFlowRunner({
  baseUrl: 'http://127.0.0.1:8410',
});

// Execute a workflow
const result = await runner.run({
  config: {
    flowName: 'my_workflow',
    canonicalPromptPath: 'packages/prompts/my-prompt.md',
    workflowManifestPath: 'langgraph.json',
  },
  params: { targetPath: './src' },
});
```

#### PromptKit

```typescript
import { PromptKit } from '@harmony/promptkit';

const promptKit = new PromptKit();

// Compile a prompt with variables
const compiled = await promptKit.compile('spec-from-intent', {
  intent: 'Add user authentication',
  tier: 'T2',
});

console.log(compiled.prompt);       // Rendered prompt
console.log(compiled.prompt_hash);  // sha256:abc123... (deterministic)
```

#### CostKit

```typescript
import { CostKit } from '@harmony/costkit';

const costKit = new CostKit();

// Get pre-flight estimate
const estimate = await costKit.estimate({
  workflowType: 'code-from-plan',
  tier: 'T2',
  stage: 'final',
});

// Check budget before proceeding
const budgetCheck = costKit.checkBudget(estimate.estimatedCostUsd);
if (!budgetCheck.allowed) {
  console.warn('Budget exceeded:', budgetCheck.reason);
}
```

### HTTP Interface (Cross-Language)

For Python agents, microservices, or any cross-language consumption, use the HTTP runners:

```typescript
import { createHttpGuardRunner } from '@harmony/guardkit';
import { createHttpCostRunner } from '@harmony/costkit';
import { createHttpPromptRunner } from '@harmony/promptkit';

// GuardKit HTTP runner
const guard = createHttpGuardRunner({ baseUrl: 'http://guardkit:8081' });
const result = await guard.check('AI content');

// CostKit HTTP runner
const cost = createHttpCostRunner({ baseUrl: 'http://costkit:8082' });
const estimate = await cost.estimate({ workflowType: 'code-from-plan', tier: 'T2' });

// PromptKit HTTP runner
const prompt = createHttpPromptRunner({ baseUrl: 'http://promptkit:8083' });
const compiled = await prompt.compile('spec-from-intent', { intent: 'Add auth' });
```

### CLI (Debugging and CI/CD)

CLIs are provided for human debugging, CI/CD pipelines, and shell-based tools.

```bash
# FlowKit - run workflows
flowkit run flows/my-workflow.flow.json --dry-run
flowkit run flows/my-workflow.flow.json --risk T2 --stage implement

# PromptKit - compile prompts
promptkit compile spec-from-intent --vars '{"intent":"Add auth"}'
promptkit list
promptkit validate spec-from-intent --vars '{"intent":"Add auth"}'

# GuardKit - check AI output
guardkit check "AI generated content"
guardkit sanitize "User input to sanitize"
guardkit quick-check "Content to check"

# CostKit - manage costs
costkit estimate --workflow code-from-plan --tier T2
costkit status --period monthly
costkit summary
```

### Standard CLI Flags

All kit CLIs support these standard flags:

| Flag | Short | Default | Description |
|------|-------|---------|-------------|
| `--dry-run` | `-n` | true (local) | Validate without side effects |
| `--stage` | `-s` | — | Lifecycle stage: spec\|plan\|implement\|verify\|ship\|operate\|learn |
| `--risk` | `-r` | — | Risk tier: T1\|T2\|T3 |
| `--risk-level` | — | — | Risk level: trivial\|low\|medium\|high |
| `--idempotency-key` | `-i` | — | Idempotency key for mutating operations |
| `--cache-key` | `-c` | — | Cache key for pure/expensive operations |
| `--trace` | `-t` | false | Enable trace linking |
| `--trace-parent` | — | — | Parent trace ID for correlation |
| `--verbose` | `-v` | false | Enable verbose output |
| `--format` | `-f` | text | Output format: json\|text |
| `--enable-run-records` | — | true | Enable run record generation |
| `--runs-dir` | — | — | Directory to write run records |

## Shared Infrastructure (kit-base)

All kits share common infrastructure from `@harmony/kit-base`:

- **Types**: Common types like `KitState`, `LifecycleStage`, `RiskTier`, `HarmonyPillar`
- **Errors**: Typed errors (`InputValidationError`, `PolicyViolationError`, `IdempotencyConflictError`, etc.)
- **Observability**: Tracing helpers (`createKitSpan`, `withKitSpan`, `emitStateTransition`)
- **Run Records**: Standardized audit trail creation (default: enabled)
- **CLI Base**: Standard CLI scaffolding and flag parsing
- **Validation**: Zod-based schema validation utilities
- **Idempotency**: Key generation and conflict detection
- **HTTP Client**: Shared HTTP client utilities for runners

```typescript
import { 
  // Errors
  InputValidationError,
  PolicyViolationError,
  IdempotencyConflictError,
  
  // Observability
  createKitSpan,
  withKitSpan,
  
  // CLI
  parseStandardFlags,
  runKitCli,
  
  // Validation
  validateWithSchema,
  z,
  
  // Idempotency
  deriveIdempotencyKey,
  withIdempotency,
  
  // HTTP
  createKitHttpClient,
} from '@harmony/kit-base';
```

See [`kit-base/README.md`](./kit-base/README.md) for detailed documentation.

## Configuration Precedence

Configuration is resolved differently depending on the interface:

**CLI Operations:**
1. CLI flags — highest priority
2. Environment variables
3. Kit defaults

**Programmatic API:**
1. Constructor/method config — highest priority
2. Environment variables
3. Kit defaults

See [`kit-base/README.md`](./kit-base/README.md) for detailed documentation on configuration precedence.

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

For debugging and development, use kit CLIs directly. See [KITS.md](/docs/harmony/human/KITS.md) for a human-friendly guide.

## For AI Agents

Kits are your primary tools. Import and use the programmatic API directly:

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

For cross-language agents (Python, etc.), use HTTP runners:

```typescript
import { createHttpGuardRunner } from '@harmony/guardkit';
import { createHttpCostRunner } from '@harmony/costkit';
import { createHttpPromptRunner } from '@harmony/promptkit';
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
