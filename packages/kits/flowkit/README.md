# FlowKit

Workflow orchestration and multi-step execution for AI-powered workflows.

## Interfaces

FlowKit provides three interfaces:

| Interface | Consumers | Use For |
|-----------|-----------|---------|
| **Programmatic API** (primary) | AI agents, services | Production workflow execution |
| **HTTP Runner** | Python agents, microservices | Cross-language, distributed systems |
| **CLI** | Humans, CI/CD | Debugging, manual workflow runs |

## Programmatic API (Primary)

FlowKit provides the orchestration layer for running AI-powered workflows, abstracting runtime details (LangGraph, HTTP services, etc.) behind a consistent TypeScript interface.

### Quick Start

```typescript
import { createHttpFlowRunner, type FlowRunRequest } from '@harmony/flowkit';

// Create a runner connected to your flow execution service
const runner = createHttpFlowRunner({
  baseUrl: 'http://127.0.0.1:8410',
});

// Define a flow run request
const request: FlowRunRequest = {
  config: {
    flowName: 'architecture_assessment',
    canonicalPromptPath: 'packages/workflows/architecture_assessment/00-overview.md',
    workflowManifestPath: 'packages/workflows/architecture_assessment/manifest.yaml',
  },
  params: {
    targetPath: './src',
  },
};

// Execute the flow
const result = await runner.run(request);
console.log('Run ID:', result.runId);
console.log('Result:', result.result);
```

### FlowRunner Interface

```typescript
interface FlowRunner {
  run(request: FlowRunRequest): Promise<FlowRunResult>;
}
```

All runtime adapters implement this interface. FlowKit ships with:
- `createHttpFlowRunner()` — For HTTP-based flow services
- `notImplementedFlowRunner` — Placeholder for type-only usage

### Configuration

```typescript
// FlowConfig - configuration for a specific flow execution
interface FlowConfig {
  flowName: string;                    // Flow identifier
  canonicalPromptPath: string;         // Path to defining prompt
  workspaceRoot?: string;              // Optional workspace root
  workflowManifestPath: string;        // Path to workflow manifest
  workflowEntrypoint?: string;         // Optional entrypoint
  observability?: FlowObservabilityConfig;
}

// HTTP Runner options
interface HttpFlowRunnerOptions {
  baseUrl: string;           // Base URL of the flow service
  fetchImpl?: typeof fetch;  // Custom fetch implementation
  timeoutMs?: number;        // Request timeout
  headers?: Record<string, string>;  // Custom headers
  enableRunRecords?: boolean;  // Enable run records (default: true)
  runsDir?: string;          // Directory to write run records (default: $HARMONY_RUNS_DIR or ./runs)
}
```

> **Tip:** Set `HARMONY_RUNS_DIR` environment variable for centralized run records across all kits. See [kit-base/README.md](../kit-base/README.md#run-records) for setup.

### FlowRunResult

```typescript
interface FlowRunResult {
  result: unknown;           // Flow output
  runId: string;             // Run identifier
  artifacts?: string[];      // Produced artifacts
  metadata?: FlowRunMetadata;  // Run metadata
}
```

## HTTP Runner

The HTTP runner connects to a remote flow execution service (e.g., LangGraph):

```typescript
import { createHttpFlowRunner } from '@harmony/flowkit';

const runner = createHttpFlowRunner({
  // Required: Base URL of the flow service
  baseUrl: 'http://127.0.0.1:8410',

  // Optional: Custom fetch implementation
  fetchImpl: customFetch,

  // Optional: Request timeout in milliseconds
  timeoutMs: 60000,

  // Optional: Custom headers
  headers: {
    'X-Api-Key': 'your-api-key',
  },

  // Optional: Enable run records (default: true)
  enableRunRecords: true,
});
```

### HTTP Protocol

The runner sends POST requests to `{baseUrl}/flows/run` with the following payload:

```json
{
  "runId": "uuid",
  "flowName": "architecture_assessment",
  "canonicalPromptPath": "packages/workflows/architecture_assessment/00-overview.md",
  "workflowManifestPath": "packages/workflows/architecture_assessment/manifest.yaml",
  "workflowEntrypoint": "optional_entrypoint",
  "workspaceRoot": "/path/to/workspace",
  "observability": { "spanPrefix": "..." },
  "params": {}
}
```

## CLI (Debugging and CI/CD)

The CLI is a **thin wrapper** around the programmatic API for human debugging and CI/CD.

```bash
# Run a flow
flowkit run flows/my-workflow.flow.json

# With parameters
flowkit run flows/my-workflow.flow.json --param targetPath=./src

# Dry-run mode (validate without executing)
flowkit run flows/my-workflow.flow.json --dry-run

# With risk tier and stage
flowkit run flows/my-workflow.flow.json --risk T2 --stage implement

# JSON output
flowkit run flows/my-workflow.flow.json --format json

# Custom runner URL
flowkit run flows/my-workflow.flow.json --runner-url http://localhost:8410
```

### CLI Options

| Option | Description |
|--------|-------------|
| `--flow, -f` | Flow name |
| `--manifest, -m` | Workflow manifest path |
| `--prompt, -p` | Canonical prompt path |
| `--param` | Flow parameter (can be repeated) |
| `--runner-url` | Override runner base URL |

Plus all [standard kit flags](../README.md#standard-cli-flags).

## Integration with LangGraph

FlowKit is designed to work with Python LangGraph runtimes. The typical setup:

1. Define flows in LangGraph (Python)
2. Run the LangGraph server
3. Connect FlowKit to the server via HTTP runner

```bash
# Start LangGraph server
cd agents/runner/runtime
python -m uvicorn server:app --port 8410

# In TypeScript
const runner = createHttpFlowRunner({ baseUrl: 'http://127.0.0.1:8410' });
```

## Architecture

FlowKit uses the **Hexagonal Architecture** (Ports & Adapters) pattern:

```
┌─────────────────────────────────────────────────┐
│                   FlowKit                        │
│  ┌─────────────────────────────────────────┐    │
│  │            FlowRunner (Port)            │    │
│  │  - run(request: FlowRunRequest)         │    │
│  └─────────────────────────────────────────┘    │
│                      │                           │
│    ┌─────────────────┼─────────────────┐        │
│    ▼                 ▼                 ▼        │
│ ┌──────────┐  ┌──────────────┐  ┌───────────┐  │
│ │HTTP      │  │LangGraph     │  │Local      │  │
│ │Runner    │  │Runner        │  │Runner     │  │
│ │(Adapter) │  │(Adapter)     │  │(Adapter)  │  │
│ └──────────┘  └──────────────┘  └───────────┘  │
└─────────────────────────────────────────────────┘
```

## Pillar Alignment

- **Speed with Safety**: Enables rapid workflow execution with built-in safeguards
- **Guided Agentic Autonomy**: Coordinates AI agents through structured workflows
- **Evolvable Modularity**: Clean adapter pattern allows swapping runtimes

## Observability

FlowKit supports OpenTelemetry for tracing:

```typescript
const request: FlowRunRequest = {
  config: {
    flowName: 'my_flow',
    canonicalPromptPath: '...',
    workflowManifestPath: '...',
    observability: {
      spanPrefix: 'my-app',
      serviceName: 'harmony.kit.flowkit',
      enableTracing: true,
    },
  },
  params: {},
};
```

## Error Handling

FlowKit throws typed errors:

```typescript
import { UpstreamProviderError, InputValidationError } from '@harmony/kit-base';

try {
  const result = await runner.run(request);
} catch (error) {
  if (error instanceof UpstreamProviderError) {
    console.error(`HTTP error: ${error.statusCode}`);
  } else if (error instanceof InputValidationError) {
    console.error('Invalid request:', error.validationErrors);
  }
}
```

## Testing

```bash
# Run FlowKit tests
pnpm --filter @harmony/flowkit test
```

## Related Kits

- **PromptKit**: Compile prompts referenced by flows
- **GuardKit**: Validate flow inputs/outputs
- **CostKit**: Estimate and track flow execution costs
- **ObservaKit**: Telemetry and monitoring

## See Also

- [@harmony/kit-base](../kit-base/README.md) — Shared infrastructure
- [FlowKit metadata](./metadata/kit.metadata.json) — Kit metadata schema

## License

Private — part of the Harmony monorepo.
