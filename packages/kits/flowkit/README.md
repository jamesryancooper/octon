# FlowKit

Workflow orchestration and multi-step execution for AI-powered workflows.

## Overview

FlowKit provides the orchestration layer for running AI-powered workflows, abstracting runtime details (LangGraph, HTTP services, etc.) behind a consistent TypeScript interface.

### Pillar Alignment

- **Speed with Safety**: Enables rapid workflow execution with built-in safeguards
- **Guided Agentic Autonomy**: Coordinates AI agents through structured workflows

## Installation

```bash
pnpm add @harmony/flowkit
```

## Quick Start

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
    canonicalPromptPath: 'packages/prompts/assessment/architecture/architecture-assessment.md',
    workflowManifestPath: 'langgraph.json',
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

### Core Concepts

- **FlowRunner**: The port (interface) that all runtime adapters implement
- **FlowConfig**: Configuration for a specific flow execution
- **FlowRunRequest**: Request object containing config and parameters
- **FlowRunResult**: Result containing output, artifacts, and metadata

## FlowRunner Interface

```typescript
interface FlowRunner {
  run(request: FlowRunRequest): Promise<FlowRunResult>;
}
```

All runtime adapters must implement this interface. FlowKit ships with:

- `createHttpFlowRunner()` - For HTTP-based flow services
- `notImplementedFlowRunner` - Placeholder for type-only usage

## HTTP Runner

The HTTP runner connects to a remote flow execution service:

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
});
```

### HTTP Protocol

The runner sends POST requests to `{baseUrl}/flows/run` with the following payload:

```json
{
  "runId": "uuid",
  "flowName": "architecture_assessment",
  "canonicalPromptPath": "packages/prompts/...",
  "workflowManifestPath": "langgraph.json",
  "workflowEntrypoint": "optional_entrypoint",
  "workspaceRoot": "/path/to/workspace",
  "observability": { "spanPrefix": "..." },
  "params": {}
}
```

## Types

### FlowConfig

```typescript
interface FlowConfig {
  flowName: string;                    // Flow identifier
  canonicalPromptPath: string;         // Path to defining prompt
  workspaceRoot?: string;              // Optional workspace root
  workflowManifestPath: string;        // Path to workflow manifest
  workflowEntrypoint?: string;         // Optional entrypoint
  observability?: FlowObservabilityConfig;
}
```

### FlowRunResult

```typescript
interface FlowRunResult {
  result: unknown;                     // Flow output
  runId: string;                       // Run identifier
  artifacts?: string[];                // Produced artifacts
  metadata?: FlowRunMetadata;          // Run metadata
}
```

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

## CLI Usage

FlowKit includes a CLI for running flows from the command line:

```bash
npx flowkit run \
  --flow architecture_assessment \
  --manifest langgraph.json \
  --prompt packages/prompts/assessment/architecture/architecture-assessment.md \
  --param targetPath=./src
```

See `flowkit --help` for all options.

## Observability

FlowKit supports OpenTelemetry for tracing:

```typescript
const request: FlowRunRequest = {
  config: {
    flowName: 'my_flow',
    // ... other config
    observability: {
      spanPrefix: 'my-app',
      serviceName: 'harmony.kit.flowkit',
      enableTracing: true,
    },
  },
};
```

## Error Handling

FlowKit throws descriptive errors for common failure scenarios:

```typescript
try {
  const result = await runner.run(request);
} catch (error) {
  if (error.message.includes('HTTP runner request failed')) {
    // Handle HTTP errors
  }
  throw error;
}
```

## Related Kits

- **PromptKit**: Compile prompts referenced by flows
- **GuardKit**: Validate flow inputs/outputs
- **CostKit**: Estimate and track flow execution costs
- **ObservaKit**: Telemetry and monitoring

