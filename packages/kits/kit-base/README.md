# @harmony/kit-base

Shared infrastructure for Harmony Kits providing foundational utilities for:

- **Typed Errors** — Semantic error classes with standard exit codes
- **Run Records** — Structured audit logs for every kit operation
- **Observability** — OpenTelemetry helpers for consistent tracing
- **CLI Flags** — Standard flag parsing across all kit CLIs
- **Metadata** — Kit metadata types and loading utilities

## Installation

```bash
pnpm add @harmony/kit-base
```

## Error Taxonomy

All kits use typed errors with semantic exit codes for deterministic behavior:

| Exit Code | Error Class | Description | HTTP Status |
|-----------|-------------|-------------|-------------|
| 0 | — | Success | 200 |
| 1 | `GenericKitError` | Unexpected failure | 500 |
| 2 | `PolicyViolationError` | Policy gate blocked operation | 403 |
| 3 | `EvaluationFailureError` | Eval/test gate failed | 422 |
| 4 | `GuardViolationError` | Secret/PII/injection detected | 400 |
| 5 | `InputValidationError` | Schema validation failed | 400 |
| 6 | `UpstreamProviderError` | External service failure | 502 |
| 7 | `IdempotencyConflictError` | Duplicate operation conflict | 409 |
| 8 | `CacheIntegrityError` | Cache corruption detected | 500 |

### Usage

```typescript
import {
  PolicyViolationError,
  InputValidationError,
  UpstreamProviderError,
  isKitError,
  wrapError,
  ExitCodes,
} from "@harmony/kit-base";

// Throw typed errors
throw new PolicyViolationError("Budget exceeded", {
  ruleset: "cost-policy",
  violatedPolicies: ["monthly-budget"],
});

throw new InputValidationError("Invalid config", {
  schema: "flowkit.inputs.v1",
  validationErrors: [
    { path: "config.flowName", message: "Required field" },
  ],
});

// Check error type
if (isKitError(error)) {
  console.log(`Exit code: ${error.code}`);
  console.log(`Suggested action: ${error.suggestedAction}`);
}

// Wrap unknown errors
const kitError = wrapError(unknownError);
process.exit(kitError.code);
```

## Run Records

Run records capture the full context of every kit operation for reproducibility, governance, and observability.

### Format

```typescript
interface RunRecord {
  runId: string;           // Stable ID: 2025-12-07T10-30-00Z-flowkit-a1b2
  kit: { name: string; version: string };
  inputs: Record<string, unknown>;  // Secrets redacted
  ai?: AIConfig;           // Model, provider, temperature, etc.
  artifacts?: RunArtifact[];
  policy?: PolicyResult;
  eval?: EvalResult;
  telemetry: { trace_id: string; spans?: string[] };
  status: "success" | "failure";
  summary: string;
  stage: LifecycleStage;   // spec|plan|implement|verify|ship|operate|learn
  risk: RiskLevel;         // trivial|low|medium|high
  hitl?: HITLInfo;         // HITL checkpoint state
  determinism?: DeterminismInfo;  // prompt_hash, idempotencyKey
  createdAt: string;       // ISO8601
  durationMs?: number;
}
```

### Usage

```typescript
import {
  createRunRecord,
  writeRunRecord,
  generateRunId,
  getRunsDirectory,
} from "@harmony/kit-base";

// Generate run ID
const runId = generateRunId({
  kitName: "flowkit",
  stableInputs: JSON.stringify(inputs),
  gitSha: process.env.GIT_SHA,
});
// => "2025-12-07T10-30-00Z-flowkit-a1b2"

// Create run record
const record = createRunRecord({
  kit: { name: "flowkit", version: "0.1.0" },
  inputs: { flowName: "architecture_assessment" },
  status: "success",
  summary: "Flow completed successfully",
  stage: "implement",
  risk: "low",
  traceId: getCurrentTraceId() || randomUUID(),
  durationMs: 1250,
});

// Write to disk
const runsDir = getRunsDirectory(process.cwd());
const path = writeRunRecord(record, runsDir);
// => ./runs/flowkit/2025-12-07T10-30-00Z-flowkit-a1b2.json
```

## Observability

OpenTelemetry helpers for consistent span naming and attributes across kits.

### Span Naming Convention

```
kit.<kitName>.<action>
```

Examples:
- `kit.flowkit.run`
- `kit.guardkit.check`
- `kit.promptkit.compile`
- `kit.costkit.estimate`

### Required Span Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `run.id` | string | Stable run identifier |
| `kit.name` | string | Kit name (flowkit, guardkit, etc.) |
| `kit.version` | string | Semantic version |
| `stage` | string | Lifecycle stage |

### Usage

```typescript
import {
  getKitTracer,
  withKitSpan,
  createKitSpan,
  emitStateTransition,
  emitGateResult,
  emitArtifactWrite,
  type KitSpanContext,
} from "@harmony/kit-base";

// Create tracer context
const ctx: KitSpanContext = {
  tracer: getKitTracer({ kitName: "flowkit", kitVersion: "0.1.0" }),
  kitName: "flowkit",
  kitVersion: "0.1.0",
};

// Use withKitSpan for automatic error handling
const result = await withKitSpan(
  ctx,
  "run",
  { "run.id": runId, stage: "implement" },
  async (span) => {
    emitStateTransition(span, "pending", "executing");
    
    const result = await executeFlow();
    
    emitGateResult(span, "http_response", true);
    emitArtifactWrite(span, "report.json", "assessment");
    
    return result;
  }
);

// Or use createKitSpan for manual control
const span = createKitSpan(ctx, "check", attributes);
try {
  // ... operation
  span.setStatus({ code: SpanStatusCode.OK });
} catch (error) {
  span.setStatus({ code: SpanStatusCode.ERROR, message: error.message });
  span.recordException(error);
  throw error;
} finally {
  span.end();
}
```

### Span Events

| Event Type | Description |
|------------|-------------|
| `state.enter` | State machine transition |
| `inputs.validated` | Input validation passed |
| `artifact.write` | File/artifact written |
| `gate.pass` | Gate check passed |
| `gate.block` | Gate check blocked |
| `hitl.requested` | HITL approval requested |
| `hitl.approved` | HITL approved |
| `hitl.rejected` | HITL rejected |
| `policy.fail` | Policy violation |
| `eval.fail` | Evaluation threshold not met |

## CLI Flags

Standard flags parsed consistently across all kit CLIs.

### Supported Flags

| Flag | Short | Type | Default | Description |
|------|-------|------|---------|-------------|
| `--dry-run` | `-n` | boolean | true (local) | Validate without side effects |
| `--stage` | `-s` | enum | — | Lifecycle stage |
| `--risk` | `-r` | enum | — | Risk tier (T1/T2/T3) |
| `--risk-level` | — | enum | — | Risk level |
| `--idempotency-key` | `-i` | string | — | Idempotency key for mutations |
| `--cache-key` | `-c` | string | — | Cache key for pure operations |
| `--trace` | `-t` | boolean | false | Enable trace linking |
| `--trace-parent` | — | string | — | Parent trace ID |
| `--verbose` | `-v` | boolean | false | Verbose output |
| `--format` | `-f` | enum | text | Output format (json/text) |

### Usage

```typescript
import {
  parseStandardFlags,
  getStandardFlagsHelp,
  validateFlagsForRisk,
  type StandardKitFlags,
} from "@harmony/kit-base";

// Parse flags
const { flags, remaining } = parseStandardFlags(process.argv.slice(2));
// flags: StandardKitFlags
// remaining: string[] (non-flag arguments)

// Validate flags for operation type
const validation = validateFlagsForRisk(flags, "mutating");
if (!validation.valid) {
  console.error(validation.errors.join("\n"));
  process.exit(5);
}

// Print help
console.log(getStandardFlagsHelp());
```

## Metadata

Kit metadata types and loading utilities.

### kit.metadata.json Format

```json
{
  "name": "flowkit",
  "version": "0.1.0",
  "description": "Workflow orchestration for AI-powered workflows",
  "pillars": ["speed_with_safety", "guided_agentic_autonomy"],
  "lifecycleStages": ["implement"],
  "inputsSchema": "schema/flowkit.inputs.v1.json",
  "outputsSchema": "schema/flowkit.outputs.v1.json",
  "observability": {
    "serviceName": "harmony.kit.flowkit",
    "requiredSpans": ["kit.flowkit.run"],
    "logRedaction": true
  },
  "determinism": {
    "artifactNaming": "{flowName}-{runId}"
  },
  "safety": {
    "hitl": { "requiredFor": ["high"] }
  },
  "dryRun": { "supported": true },
  "compatibility": {
    "contracts": ["flowkit.inputs.v1"],
    "kits": ["promptkit", "guardkit"]
  }
}
```

### Usage

```typescript
import {
  loadKitMetadata,
  validateKitMetadata,
  type KitMetadata,
} from "@harmony/kit-base";

// Load metadata
const metadata = loadKitMetadata("./packages/kits/flowkit/metadata");

// Validate
const validation = validateKitMetadata(metadata);
if (!validation.valid) {
  console.error(validation.errors);
}
```

## Types

Common types used across all kits:

```typescript
// Lifecycle stages
type LifecycleStage = 
  | "spec" | "plan" | "implement" 
  | "verify" | "ship" | "operate" | "learn";

// Risk tiers
type RiskTier = "T1" | "T2" | "T3";

// Risk levels
type RiskLevel = "trivial" | "low" | "medium" | "high";

// Run status
type RunStatus = "success" | "failure";

// HITL checkpoints
type HITLCheckpoint = 
  | "pre-implement" | "pre-merge" 
  | "pre-promote" | "post-promote";

// Kit operational states
type KitState = 
  | "pending" | "validating" | "executing" 
  | "awaiting_hitl" | "completed" | "failed";
```

## Related Packages

- **@harmony/flowkit** — Workflow orchestration
- **@harmony/guardkit** — AI output guardrails
- **@harmony/promptkit** — Prompt compilation
- **@harmony/costkit** — Cost management

