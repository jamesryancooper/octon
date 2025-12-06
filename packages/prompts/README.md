# @harmony/prompts

Canonical prompt library for Harmony AI agents. Provides structured prompts with schemas, validation, and versioning to make AI behavior predictable and improvable.

## Quick Start

```bash
# Install dependencies
cd packages/prompts
pnpm install

# Build the package
pnpm build

# Validate all prompts
pnpm validate
```

## Key Features

1. **Tiered Output Schemas**: Each prompt adapts output detail to the risk tier
   - T1: Minimal specs for trivial changes (bug fixes, typos)
   - T2: Standard specs for typical features
   - T3: Comprehensive specs with full STRIDE analysis for high-risk changes

2. **Schema Validation**: All inputs and outputs validated against JSON Schema with AJV

3. **Golden Test Infrastructure**: Framework for testing AI output consistency over time

4. **Model Selection**: Catalog provides tier-based model recommendations
   - T1: `gpt-4o-mini` (fast, cheap)
   - T2 draft: `gpt-4o-mini`
   - T2 final: `gpt-4o`
   - T3: `gpt-4o`

5. **Validation Checklists**: Each prompt includes automated and human validation rules

6. **Examples**: Concrete input/output examples for each tier

7. **Versioning**: Prompts are semantically versioned with changelogs

8. **Hallucination Detection**: Built-in checks for fake imports, APIs, and placeholders

9. **Quality Monitoring**: Track AI output quality over time with drift detection and alerts

## Overview

This package contains the core prompts used by Harmony AI agents to generate specifications, plans, code, tests, and threat models. Each prompt includes:

- **Template** (`prompt.md`): The actual prompt with instructions and formatting rules
- **Input Schema** (`*.input.json`): JSON Schema defining valid inputs
- **Output Schema** (`*.output.json`): JSON Schema defining expected outputs
- **Examples**: Sample inputs and outputs for testing and reference
- **Validation**: Checklist for both automated and human validation

## Core Prompts

| Prompt | Category | Description |
|--------|----------|-------------|
| `spec-from-intent` | Planning | Generate specifications from natural language descriptions |
| `plan-from-spec` | Planning | Create implementation plans from validated specs |
| `code-from-plan` | Implementation | Generate code following plan steps |
| `test-from-contract` | Verification | Generate tests from OpenAPI contracts and schemas |
| `threat-model-from-spec` | Security | Generate STRIDE threat analysis from specifications |

## Directory Structure

```
packages/prompts/
├── catalog.yaml              # Central registry of all prompts
├── core/                     # Core workflow prompts
│   ├── spec-from-intent/
│   │   ├── prompt.md         # The prompt template
│   │   ├── examples/         # Example inputs/outputs
│   │   └── validation.md     # Validation checklist
│   ├── plan-from-spec/
│   ├── code-from-plan/
│   ├── test-from-contract/
│   └── threat-model-from-spec/
├── schemas/                  # JSON Schemas for all prompts
│   ├── spec-from-intent.input.json
│   ├── spec-from-intent.output.json
│   └── ...
└── src/                      # TypeScript utilities
    ├── catalog.ts            # Catalog management
    ├── loader.ts             # Prompt loading
    ├── validator.ts          # Schema validation
    ├── golden.ts             # Golden test infrastructure
    ├── hallucination.ts      # Hallucination detection
    └── monitoring.ts         # Quality monitoring
```

## Usage

### Loading Prompts

```typescript
import { loadCatalog, PromptLoader, PromptValidator } from '@harmony/prompts';

// Load the catalog
const catalog = loadCatalog();

// Create a loader and validator
const loader = new PromptLoader(catalog);
const validator = new PromptValidator();

// Load a specific prompt
const prompt = loader.load('spec-from-intent');

// Register for validation
validator.registerPrompt(prompt);

// Validate input before sending to LLM
const inputResult = validator.validateInput('spec-from-intent', {
  intent: 'Add a user profile endpoint',
  tier: 'T2'
});

if (!inputResult.valid) {
  console.error('Invalid input:', inputResult.errors);
}

// Validate output after receiving from LLM
const outputResult = validator.validateOutput('spec-from-intent', llmOutput);
```

### Using the Prompt Template

The prompt template is a markdown file that can be used directly with any LLM:

```typescript
// Get the prompt template
const template = prompt.template;

// Combine with your input to form the full prompt
const fullPrompt = `
${template}

---

## Your Input

${JSON.stringify(input, null, 2)}
`;

// Send to LLM
const response = await llm.generate(fullPrompt);
```

### Model Selection

The catalog provides tier-based model recommendations:

```typescript
const catalog = loadCatalog();

// Get recommended model for a tier
const model = catalog.getModelForTier('T2', 'final'); // gpt-4o
const draftModel = catalog.getModelForTier('T2', 'draft'); // gpt-4o-mini

// Check if a prompt supports a tier
if (catalog.supportsTier('threat-model-from-spec', 'T1')) {
  // T1 not supported for threat modeling
}
```

### Golden Tests

Golden tests ensure AI output remains consistent over time:

```typescript
import { GoldenTestManager } from '@harmony/prompts';

const manager = new GoldenTestManager(
  'spec-from-intent',
  prompt.directory,
  validator
);

// Add a golden test
manager.addTestCase({
  id: 'simple-api-endpoint',
  description: 'Should generate T2 spec for simple API endpoint',
  input: { intent: 'Add GET /api/users endpoint', tier: 'T2' },
  expected: { /* expected output shape */ },
  comparison: 'schema', // Use schema validation
});

// Run golden tests
const results = await manager.runAllTests(async (input) => {
  return await generateWithLLM(input);
});

console.log(`Passed: ${results.passed}/${results.total}`);
```

### Hallucination Detection

Check AI outputs for common hallucination patterns:

```typescript
import { 
  checkForHallucinations, 
  quickHallucinationCheck,
  formatHallucinationReport 
} from '@harmony/prompts';

// Quick check (fast, less thorough)
if (quickHallucinationCheck(aiOutput)) {
  console.log('Possible hallucination detected');
}

// Full check with context
const result = checkForHallucinations(aiOutput, {
  knownPackages: ['react', 'zod', 'express'],  // From package.json
  knownFiles: ['src/utils.ts', 'src/api.ts'],   // Project files
  originalIntent: 'Add user login',             // What was requested
  tier: 'T2',                                    // Risk tier
});

if (result.detected) {
  console.log(formatHallucinationReport(result));
  // Shows: indicators found, confidence score, recommendations
}
```

#### Hallucination Indicators

| Indicator | Severity | Description |
|-----------|----------|-------------|
| `unknown_import` | High | Import from package not in dependencies |
| `suspicious_helper` | Medium | Generic `utils/helpers` imports |
| `nonexistent_api` | High | APIs that don't exist (e.g., `localStorage.getAsync()`) |
| `todo_placeholder` | Low | TODO/FIXME/placeholder markers |
| `empty_catch` | Medium | Error handling that swallows errors |
| `generic_variable` | Low | Overly generic variable names |
| `scope_creep` | Medium | Generated code exceeds request scope |
| `confident_assertion` | Medium | Comments asserting incorrect facts |

### Quality Monitoring

Track AI output quality over time:

```typescript
import { GoldenTestMonitor, generateWeeklySummary } from '@harmony/prompts';

// Create monitor with thresholds
const monitor = new GoldenTestMonitor('./monitoring-data', {
  minPassRate: 0.9,        // Alert if pass rate < 90%
  maxDrift: 0.15,          // Alert if drift > 15%
  minConsistency: 0.85,    // Alert if consistency < 85%
  consecutiveFailuresAlert: 2,
});

// Record a golden test run
const record = monitor.recordRun(
  'spec-from-intent',      // Prompt ID
  testSummary,              // GoldenTestSummary from runAllTests
  'gpt-4o',                 // Model used
  0.2                       // Temperature
);

// Check for alerts
const alerts = monitor.checkAlerts('spec-from-intent');
for (const alert of alerts) {
  console.log(`${alert.severity}: ${alert.message}`);
  console.log(`Action: ${alert.action}`);
}

// Generate monitoring report
const report = monitor.generateReport('spec-from-intent');
console.log(report);

// Weekly summary across all prompts
const weeklySummary = generateWeeklySummary(monitor, [
  'spec-from-intent',
  'plan-from-spec',
  'code-from-plan',
]);
```

#### Alert Types

| Type | Severity | Trigger |
|------|----------|---------|
| `pass_rate_drop` | Warning/Critical | Pass rate below threshold |
| `drift_detected` | Warning/Critical | Significant change from previous run |
| `consistency_low` | Warning | High variance in results |
| `new_failure` | Warning | Consecutive runs with failures |

#### Metrics Tracked

- **Pass Rate**: Percentage of golden tests passing
- **Trend**: Is quality improving or declining?
- **Consistency**: How stable are the results?
- **Drift**: How much did output change from baseline?
- **Recent Failures**: Which tests are failing and why?

## Prompt Catalog

The `catalog.yaml` file is the central registry:

```yaml
version: "1.0.0"

defaults:
  temperature: 0.2
  max_tokens: 4096
  model_tier_mapping:
    T1: "gpt-4o-mini"
    T2_draft: "gpt-4o-mini"
    T2_final: "gpt-4o"
    T3: "gpt-4o"

core_prompts:
  spec-from-intent:
    name: "Spec from Intent"
    version: "1.0.0"
    status: stable
    path: "./core/spec-from-intent"
    tier_support: [T1, T2, T3]
    # ...
```

## Validation

Run validation on all prompts:

```bash
pnpm validate
```

This checks:

- Schema compilation
- Template structure
- Required sections present
- Examples loadable

## Versioning

Prompts are versioned semantically:

- **Major**: Breaking changes to input/output schemas
- **Minor**: New optional fields or capabilities
- **Patch**: Bug fixes and clarifications

Check the `changelog` in each prompt's catalog entry for history.

## Adding New Prompts

1. Create a new directory in `core/` (or a new category)
2. Add `prompt.md` with required sections
3. Add JSON schemas in `schemas/`
4. Add examples in `examples/`
5. Add validation checklist in `validation.md`
6. Register in `catalog.yaml`
7. Run `pnpm validate` to verify

## Tier Definitions

| Tier | Risk Level | Model | Human Oversight |
|------|------------|-------|-----------------|
| T1 | Trivial | Fast/cheap (gpt-4o-mini) | Skim summary, approve |
| T2 | Standard | Quality (gpt-4o) | Review spec + PR |
| T3 | Elevated | Best (gpt-4o) | Full review at each stage |

See the methodology docs for detailed tier definitions.

## Integration with Harmony CLI

The `@harmony/prompts` package integrates with the Harmony CLI (`@harmony/harmony-cli`):

```typescript
// In harmony-cli or other packages
import { loadCatalog, PromptLoader, PromptValidator } from '@harmony/prompts';

// Load and validate prompts for use in workflows
const catalog = loadCatalog();
const loader = new PromptLoader(catalog);
const validator = new PromptValidator();

// Get the right model for the task
const model = catalog.getModelForTier('T2', 'final');

// Load the prompt
const specPrompt = loader.load('spec-from-intent');
validator.registerPrompt(specPrompt);

// Use in your workflow
const input = { intent: 'Add user authentication', tier: 'T3' };
const validation = validator.validateInput('spec-from-intent', input);
if (validation.valid) {
  // Send to LLM with specPrompt.template
}
```

## Package Exports

```typescript
// Main exports
import { 
  // Catalog and loading
  PromptCatalog,        // Catalog management class
  loadCatalog,          // Load catalog from default location
  PromptLoader,         // Load prompts with templates and schemas
  LoadedPrompt,         // Type for loaded prompt
  
  // Validation
  PromptValidator,      // Schema validation
  ValidationResult,     // Validation result type
  validateInput,        // Standalone input validation
  validateOutput,       // Standalone output validation
  getPromptPath,        // Get path to prompt directory
  listPrompts,          // List all available prompts
  
  // Golden tests
  GoldenTestManager,    // Golden test infrastructure
  createGoldenFromOutput, // Helper to create golden tests from output
  
  // Hallucination detection
  checkForHallucinations,      // Full hallucination check
  quickHallucinationCheck,     // Fast preliminary check
  validateWithHallucinationCheck, // Combine validation + hallucination
  formatHallucinationReport,   // Human-readable report
  HALLUCINATION_INDICATORS,    // Built-in indicators
  
  // Quality monitoring
  GoldenTestMonitor,           // Track quality over time
  generateWeeklySummary,       // Weekly summary across prompts
} from '@harmony/prompts';

// Type exports
import type { 
  PromptConfig,         // Prompt configuration
  PromptMetadata,       // Prompt metadata
  PromptCategory,       // Category types
  GoldenTestCase,       // Golden test case structure
  GoldenTestResult,     // Result of running a golden test
  GoldenTestSummary,    // Summary of a golden test run
  
  // Hallucination types
  HallucinationIndicator,
  HallucinationContext,
  HallucinationMatch,
  HallucinationCheckResult,
  
  // Monitoring types
  MonitoringRecord,
  MonitoringMetrics,
  MonitoringAlert,
  MonitoringThresholds,
} from '@harmony/prompts';
```

## File Inventory

| Path | Description |
|------|-------------|
| `catalog.yaml` | Central registry with versioning and metrics |
| `core/*/prompt.md` | Prompt templates with instructions |
| `core/*/validation.md` | Validation checklists |
| `core/*/examples/*.yaml` | Example inputs and outputs |
| `schemas/*.input.json` | Input validation schemas |
| `schemas/*.output.json` | Output validation schemas |
| `src/catalog.ts` | Catalog management utilities |
| `src/loader.ts` | Prompt loading utilities |
| `src/validator.ts` | Schema validation with AJV |
| `src/golden.ts` | Golden test infrastructure |
| `src/hallucination.ts` | Hallucination detection utilities |
| `src/monitoring.ts` | Quality monitoring infrastructure |
| `src/types.ts` | TypeScript type definitions |

## License

MIT - See repository root for full license.
