# @harmony/kit-base

Shared infrastructure for Harmony Kits providing foundational utilities for:

- **Typed Errors** — Semantic error classes with standard exit codes
- **Run Records** — Structured audit logs for every kit operation (default: enabled)
- **Observability** — OpenTelemetry helpers for consistent tracing
- **CLI Flags** — Standard flag parsing across all kit CLIs
- **CLI Base** — Scaffolding for building consistent kit CLIs
- **Validation** — Zod-based schema validation utilities with enforcement modes
- **Idempotency** — Key generation and conflict detection
- **Metadata** — Kit metadata types and loading utilities
- **Methodology-as-Code** — Versioned methodology constraints for AI consumption

## Methodology-as-Code

Harmony uses a **Methodology-as-Code** approach: methodology constraints (pillars, lifecycle stages, policy rules) are encoded directly into JSON schemas and runtime validation. This enables AI agents to consume methodology as machine-readable contracts.

### Version Tracking

All kit metadata includes explicit version fields:

```json
{
  "schemaVersion": "1.2.0",
  "methodologyVersion": "0.2.0",
  "name": "flowkit",
  "version": "0.1.0"
}
```

| Field | Current | Description |
|-------|---------|-------------|
| `schemaVersion` | 1.2.0 | Kit metadata schema version |
| `methodologyVersion` | 0.2.0 | Harmony methodology version |

### Enforcement Modes

Methodology validation supports graceful transitions:

| Mode | Behavior | Use Case |
|------|----------|----------|
| `block` | Fail on violations (default) | Production, CI |
| `warn` | Log warnings but proceed | Development, transitions |
| `off` | Skip validation | Testing, emergencies |

```typescript
import { validateWithEnforcement, KitMetadataSchema } from "@harmony/kit-base";

const result = validateWithEnforcement(KitMetadataSchema, metadata, {
  enforcementMode: "warn",
  checkDeprecations: true,
});
```

### CI Validation

Validate methodology alignment across all kits:

```bash
pnpm --filter @harmony/kit-base validate:methodology
```

See [Methodology-as-Code Policy](../../docs/harmony/ai/methodology/methodology-as-code.md) for full documentation.

## Installation

```bash
pnpm add @harmony/kit-base
```

## Interface Architecture

Kits expose three interfaces, each serving different consumers. All interfaces share the same underlying implementation and return consistent data structures.

### Interface Hierarchy

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

### Configuration Precedence

Configuration is resolved differently depending on the interface:

**CLI Operations:**
1. CLI flags (e.g., `--dry-run`, `--stage implement`) — highest priority
2. Environment variables (e.g., `HARMONY_DRY_RUN=true`)
3. Kit defaults — lowest priority

**Programmatic API:**
1. Constructor/method config object — highest priority
2. Environment variables
3. Kit defaults — lowest priority

This ensures CLI flags always win for command-line usage, while programmatic callers have full control via config objects. Environment variables provide a way to set defaults across both interfaces.

```typescript
// CLI: flags win
guardkit check "content" --dry-run  // dryRun=true, regardless of env

// Programmatic: config wins
new GuardKit({ dryRun: false });    // dryRun=false, regardless of env

// Both respect env vars when not explicitly set
// HARMONY_DRY_RUN=true
guardkit check "content"            // dryRun=true (from env)
new GuardKit({});                   // dryRun=true (from env)
```

### Error Contract

All interfaces return errors in the same canonical structure:

```typescript
interface KitErrorJSON {
  success: false;
  error: {
    code: string;           // Error class (e.g., "InputValidationError")
    exitCode: number;       // CLI exit code (0-8)
    message: string;        // Human-readable message
    details?: unknown;      // Structured context
    suggestedAction: string;
  };
  _kit?: {
    name: string;
    version: string;
  };
}
```

This ensures:
- CLI `--format json` output matches HTTP API responses
- Error parsing logic can be shared across interfaces
- AI agents get consistent, machine-readable errors

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
| `--enable-run-records` | — | boolean | true | Enable run record generation |
| `--runs-dir` | — | string | — | Directory to write run records |

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

### kit.metadata.json Format (v1.2)

```json
{
  "schemaVersion": "1.2.0",
  "methodologyVersion": "0.2.0",
  "name": "flowkit",
  "version": "0.1.0",
  "description": "Workflow orchestration for AI-powered workflows",
  "pillars": ["speed_with_safety", "guided_agentic_autonomy", "evolvable_modularity"],
  "lifecycleStages": ["implement"],
  "inputsSchema": "schema/flowkit.inputs.v1.json",
  "outputsSchema": "schema/flowkit.outputs.v1.json",
  "observability": {
    "serviceName": "harmony.kit.flowkit",
    "requiredSpans": ["kit.flowkit.run"],
    "logRedaction": true
  },
  "policy": {
    "rulesetRef": "harmony-policy-v1",
    "rules": ["workflow-exists", "workflow-valid"],
    "enforcement": "block",
    "failClosed": true
  },
  "determinism": {
    "artifactNaming": "{flowName}-{runId}"
  },
  "safety": {
    "hitl": { "requiredFor": ["high"] }
  },
  "idempotency": {
    "required": true,
    "idempotencyKeyFrom": ["flowName", "config.canonicalPromptPath"]
  },
  "dryRun": { "supported": true },
  "compatibility": {
    "minSchemaVersion": "1.1.0",
    "maxSchemaVersion": "1.2.0",
    "supportedMethodologyVersions": ["0.2.0"],
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

## Validation

Zod-based schema validation utilities for runtime type safety.

### Usage

```typescript
import {
  z,
  validateWithSchema,
  safeValidate,
  createValidator,
  BaseKitConfigSchema,
  KitMetadataSchema,
} from "@harmony/kit-base";

// Create a schema
const MyConfigSchema = z.object({
  name: z.string(),
  count: z.number().positive(),
});

// Validate with throwing
const config = validateWithSchema(MyConfigSchema, input, "MyConfig");
// Throws InputValidationError on failure

// Safe validation (no throw)
const result = safeValidate(MyConfigSchema, input);
if (!result.success) {
  console.error(result.errors);
}

// Create reusable validator
const validateMyConfig = createValidator(MyConfigSchema, "MyConfig");
const config = validateMyConfig(input);

// Extend base kit config
const ExtendedConfigSchema = BaseKitConfigSchema.merge(
  z.object({
    customOption: z.string(),
  })
);
```

### Built-in Schemas

| Schema | Description |
|--------|-------------|
| `BaseKitConfigSchema` | Base config (enableRunRecords, runsDir, dryRun, idempotencyKey, enforcementMode) |
| `KitMetadataSchema` | Kit metadata (v1.2 - with versioning and enforcement modes) |
| `RunRecordSchema` | Run record (v1.1 - with versioning and deprecation tracking) |
| `HarmonyPillarSchema` | Pillar enumeration (structural methodology) |
| `LifecycleStageSchema` | Lifecycle stage enumeration (structural methodology) |
| `RiskTierSchema` | Risk tier (T1/T2/T3) |
| `RiskLevelSchema` | Risk level enumeration |
| `EnforcementModeSchema` | Enforcement mode (block/warn/off) |
| `DeprecationSchema` | Deprecation notice with migration guidance |

### Version Constants

```typescript
import {
  CURRENT_SCHEMA_VERSION,      // "1.2.0"
  CURRENT_METHODOLOGY_VERSION, // "0.2.0"
  MIN_SUPPORTED_SCHEMA_VERSION // "1.0.0"
} from "@harmony/kit-base";
```

### Enforcement-Aware Validation

```typescript
import { validateWithEnforcement, KitMetadataSchema } from "@harmony/kit-base";

const result = validateWithEnforcement(KitMetadataSchema, metadata, {
  enforcementMode: "warn",  // "block" | "warn" | "off"
  checkDeprecations: true,
  schemaName: "kit.metadata.json",
});

if (!result.success) {
  console.error("Errors:", result.errors);
}

if (result.warnings?.length) {
  console.warn("Deprecations:", result.warnings);
}
```

## Idempotency

Key generation and conflict detection for deterministic operations.

### Usage

```typescript
import {
  deriveIdempotencyKey,
  hashInputs,
  withIdempotency,
  checkIdempotencyKey,
  IdempotencyManager,
} from "@harmony/kit-base";

// Derive a stable idempotency key
const key = deriveIdempotencyKey({
  kitName: "flowkit",
  operation: "run",
  stableInputs: { flowName: "my-flow", config: "..." },
  gitSha: "abc123",
  stage: "implement",
});
// => "flowkit:run:a1b2c3d4e5f6g7h8"

// Execute with idempotency protection
const { result, cached, runId } = await withIdempotency(
  key,
  "flowkit",
  "run",
  inputs,
  async () => {
    return await executeOperation();
  }
);

if (cached) {
  console.log("Operation already completed:", runId);
}

// Manual checking
const existing = checkIdempotencyKey(key, "flowkit", "run", inputs);
if (existing) {
  console.log("Already processed:", existing.runId);
}

// Direct manager access
const manager = new IdempotencyManager({
  pendingTtlMs: 60 * 60 * 1000,    // 1 hour
  completedTtlMs: 24 * 60 * 60 * 1000,  // 24 hours
});
```

### Key Derivation

Keys are derived from:
- Kit name
- Operation name
- Stable inputs (JSON stringified, keys sorted)
- Git SHA (optional)
- Lifecycle stage (optional)

Format: `<kitName>:<operation>:<hash>`

## CLI Base

Scaffolding for building consistent kit CLIs.

### Usage

```typescript
import {
  runKitCli,
  success,
  dryRunSuccess,
  failure,
  withKitMetadata,
  type CliCommand,
  type KitCliConfig,
} from "@harmony/kit-base";

// Define commands
const checkCommand: CliCommand = {
  name: "check",
  description: "Check content for issues",
  args: [{ name: "content", description: "Content to check", required: true }],
  options: [
    { name: "threshold", alias: "t", description: "Block threshold", type: "string" },
  ],
  async handler(args, options) {
    if (options.dryRun) {
      return dryRunSuccess({ status: "dry-run" }, "Would check content");
    }
    
    const result = await performCheck(args[0], options);
    
    return success(
      withKitMetadata(result, "mykit", "0.1.0", options),
      "Check completed"
    );
  },
};

// Configure CLI
const config: KitCliConfig = {
  name: "mykit",
  version: "0.1.0",
  description: "My custom kit",
  commands: [checkCommand],
};

// Run CLI
runKitCli(config).then((exitCode) => {
  process.exitCode = exitCode;
});
```

### Helper Functions

| Function | Description |
|----------|-------------|
| `success(data?, message?)` | Create success result |
| `dryRunSuccess(data?, message?)` | Create dry-run success result |
| `failure(message, exitCode?)` | Create failure result |
| `withKitMetadata(data, name, version, flags)` | Add `_kit` metadata block |

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

