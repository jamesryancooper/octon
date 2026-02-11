# Harmony CLI

Human-friendly command interface for orchestrating AI agents in the Harmony methodology.

## Philosophy

**You orchestrate. AI executes. Complexity is hidden.**

The Harmony CLI abstracts away the kit ecosystem (SpecKit, PlanKit, AgentKit, etc.) and provides simple, intuitive commands for human developers. You think in terms of "I want to build a feature" — AI handles the specs, code, tests, and deployment.

## Quick Start

```bash
# Check what's happening
harmony status

# Start a new feature
harmony feature "Add user profile endpoint"

# AI implements it
harmony build

# Ship to production
harmony ship
```

## Commands

### Core Workflow

| Command | Description | Example |
|---------|-------------|---------|
| `status` | Show current tasks and AI progress | `harmony status` |
| `feature` | Start a new feature | `harmony feature "Dark mode"` |
| `fix` | Start a bug fix | `harmony fix "Login button broken"` |
| `build` | AI implements the current task | `harmony build` |
| `ship` | Deploy to production | `harmony ship` |

### Control Commands

| Command | Description | Example |
|---------|-------------|---------|
| `explain` | Get AI explanation for decisions | `harmony explain abc123 "Why this approach?"` |
| `retry` | Retry with new guidance | `harmony retry --constraint "Use existing auth"` |
| `pause` | Pause a running task | `harmony pause` |
| `rollback` | Rollback production | `harmony rollback` |

### Verification Commands

| Command | Description | Example |
|---------|-------------|---------|
| `check` | Run guardrail checks on AI output | `harmony check output.ts` |
| `check --verify-imports` | Verify imports against package.json | `harmony check --verify-imports src/` |

### Onboarding Commands

| Command | Description | Example |
|---------|-------------|---------|
| `onboard` | Show onboarding status or start | `harmony onboard` |
| `onboard start` | Begin guided onboarding | `harmony onboard start --name "Alice"` |
| `onboard next` | Advance to next step | `harmony onboard next` |
| `onboard fix` | Guided bug fix | `harmony onboard fix "Fix typo"` |
| `onboard feature` | Guided feature | `harmony onboard feature "Add log"` |
| `onboard skip` | Skip current step | `harmony onboard skip` |
| `onboard reset` | Start fresh | `harmony onboard reset` |

### Harness Commands

| Command | Description | Example |
|---------|-------------|---------|
| `harness install` | Install `.harmony` portable assets into a repo | `harmony harness install --target ../my-service` |
| `harness update` | Update existing `.harmony` portable assets | `harmony harness update --target ../my-service` |
| `init` | Alias for `harmony harness install` | `harmony init --target ../my-service` |

## Risk Tiers

AI automatically assigns risk tiers. You can override with `--tier`.

| Tier | What it is | Your role | AI's role |
|------|------------|-----------|-----------|
| T1 | Bug fix, tiny change | Skim summary, approve | Full spec, code, tests |
| T2 | Standard feature | Review spec summary, approve | Full work + threat check |
| T3 | Auth/data/security | Review full spec, watch deployment | Full work + deep analysis |

## Options

Most commands support these options:

```
--tier T1|T2|T3     Override the auto-assigned risk tier
--context <text>    Provide additional context to AI
--constraint <text> Add a constraint AI must follow
--model <name>      Use a specific AI model
--dry-run          Preview without creating anything
--verbose          Show detailed output
```

## Examples

### Start a feature with extra context
```bash
harmony feature "OAuth login" --context "Use our existing auth service"
```

### Fix a bug referenced by issue number
```bash
harmony fix "#423"
```

### Retry with a different approach
```bash
harmony retry --constraint "Don't modify the database schema"
```

### Rollback production
```bash
harmony rollback
# Then follow the printed instructions
```

### Check AI output for issues
```bash
# Full guardrail check
harmony check generated-code.ts

# Verify imports only
harmony check --verify-imports src/

# Check with specific tier
harmony check --file output.ts --tier T3

# Check inline content
harmony check "const x = eval(input)"
```

### Onboard a new developer
```bash
# Start guided onboarding (~15-20 minutes)
harmony onboard start
harmony onboard start --name "Alice"

# Follow the guided flow
harmony onboard next          # Advance to next step
harmony onboard fix "Fix typo in README"
harmony onboard build
harmony onboard approve

# Control flow
harmony onboard status        # Check progress
harmony onboard skip          # Skip current step
harmony onboard reset         # Start over
```

### Install Harmony harness into another repository
```bash
# From the source Harmony repo
harmony harness install --target ../my-service

# Or explicitly provide source and target
harmony harness install --source ~/repos/harmony --target ../my-service

# Update portable assets later
harmony harness update --target ../my-service
```

## Onboarding: How It Works

The onboarding flow guides new developers through their first tasks:

```
┌──────────────────────────────────────────────────────────────┐
│  ONBOARDING FLOW (~15-20 minutes total)                      │
├──────────────────────────────────────────────────────────────┤
│  1. Welcome (2m)           - Mental model overview           │
│  2. Environment Check (1m) - Verify setup                    │
│  3. First Status (1m)      - Learn `harmony status`          │
│  4. Guided Bug Fix (5m)    - Complete a T1 fix               │
│  5. Guided Feature (8m)    - Add a small T1/T2 feature       │
│  6. PR Review (3m)         - How to review AI work           │
│  7. Ship (2m)              - Deploy with flags/rollback      │
│  8. Complete! (1m)         - Summary and quick reference     │
└──────────────────────────────────────────────────────────────┘
```

After onboarding, developers know:
- ✓ How to start features and fixes
- ✓ The T1/T2/T3 tier system
- ✓ How to review AI summaries
- ✓ How to ship with feature flags
- ✓ How to rollback if needed

Onboarding state is stored in `.harmony/onboarding.json` for progress tracking.

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│  Your Commands                                               │
│  harmony feature "..." → harmony build → harmony ship       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Orchestrator Layer                                          │
│  - Assigns risk tier                                         │
│  - Manages task state                                        │
│  - Coordinates AI agents                                     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Kit Layer (Hidden from you)                                │
│  SpecKit → PlanKit → AgentKit → TestKit → PatchKit         │
│  EvalKit, PolicyKit, GuardKit, ObservaKit...               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  AI Agents + LLMs                                           │
│  Generate specs, code, tests, docs, PRs                     │
└─────────────────────────────────────────────────────────────┘
```

## Configuration

The CLI looks for configuration in:
- Environment variables (`HARMONY_*`)
- `.harmony/config.json` in your workspace

### Environment Variables

```bash
HARMONY_WORKSPACE_ROOT    # Override workspace root detection
HARMONY_RUNNER_URL        # AI runner service URL
HARMONY_DEFAULT_MODEL     # Default AI model
```

## Package Structure

```
packages/harmony-cli/
├── package.json              # Package config with "harmony" bin entry
├── tsconfig.json             # TypeScript configuration
├── README.md                 # This file
└── src/
    ├── cli.ts                # Main CLI entry point & argument parser
    ├── index.ts              # Public API exports
    ├── types/
    │   └── index.ts          # Core types (RiskTier, HarmonyTask, CommandResult, etc.)
    ├── ui/
    │   ├── colors.ts         # Terminal colors (respects NO_COLOR)
    │   ├── spinner.ts        # Async spinner for progress indication
    │   ├── format.ts         # Output formatters (tasks, specs, PRs, status)
    │   └── index.ts          # UI module exports
    ├── orchestrator/
    │   ├── state.ts          # Task persistence (.harmony/state.json)
    │   ├── workflow.ts       # Maps human commands to kit operations
    │   ├── guardrails.ts     # AI guardrail integration (GuardKit)
    │   ├── onboarding.ts     # Onboarding state and workflows
    │   └── index.ts          # Orchestrator exports
    └── commands/
        ├── status.ts         # harmony status
        ├── feature.ts        # harmony feature "..."
        ├── fix.ts            # harmony fix "..."
        ├── build.ts          # harmony build
        ├── ship.ts           # harmony ship
        ├── explain.ts        # harmony explain
        ├── retry.ts          # harmony retry
        ├── pause.ts          # harmony pause
        ├── rollback.ts       # harmony rollback
        ├── check.ts          # harmony check (guardrails)
        ├── onboard.ts        # harmony onboard (guided onboarding)
        ├── help.ts           # harmony help
        └── index.ts          # Command exports
```

## Command Aliases

For faster typing, most commands have short aliases:

| Command | Aliases |
|---------|---------|
| `status` | `s` |
| `feature` | `f`, `feat` |
| `fix` | `bug` |
| `build` | `b` |
| `ship` | `d`, `deploy` |
| `explain` | `why` |
| `retry` | `r` |
| `pause` | `stop` |
| `rollback` | `revert` |
| `check` | `verify` |
| `onboard` | `onboarding` |
| `help` | `h`, `--help`, `-h` |

## Key Design Decisions

1. **Zero external dependencies for UI** - Colors and spinner use ANSI codes directly to avoid dependency bloat
2. **Respects `NO_COLOR`** - Follows the NO_COLOR standard for accessibility and CI environments
3. **Persists state locally** - Task state stored in `.harmony/state.json` for cross-session continuity
4. **Risk tier auto-detection** - Keywords trigger tier assignment (auth, billing → T3; typo, docs → T1; else → T2)
5. **Placeholder orchestrator** - The workflow layer is ready to wire to real kits with clear integration points
6. **Programmatic API** - All functions are exported for use in scripts or extensions

## Development

```bash
# Run locally (development mode)
pnpm --filter @harmony/cli harmony status

# Build the package
pnpm --filter @harmony/cli build

# Type check
pnpm --filter @harmony/cli typecheck

# Run tests
pnpm --filter @harmony/cli test
```

### From Monorepo Root

```bash
# Using the root script
pnpm harmony status
pnpm harmony feature "Add user profile"
pnpm harmony build
```

## Integration with Kits

This CLI is built on top of the Harmony kit ecosystem:

| Kit | Role | Integration Point |
|-----|------|-------------------|
| **SpecKit** | Spec generation and validation | `startSpec()` in `workflow.ts` |
| **PlanKit** | Planning and ADR generation | `startSpec()` in `workflow.ts` |
| **AgentKit/FlowKit** | AI agent orchestration | `buildTask()` in `workflow.ts` |
| **TestKit** | Test generation and execution | `buildTask()` in `workflow.ts` |
| **PatchKit** | PR creation and management | `shipTask()` in `workflow.ts` |
| **ObservaKit** | Observability and tracing | Throughout orchestrator |
| **PolicyKit** | Policy enforcement | Gate checks in workflow |
| **GuardKit** | AI output protection | `check` command, `guardrails.ts` |

Humans don't need to interact with these directly — the CLI handles it all.

## Integration Points (for developers)

The orchestrator layer (`src/orchestrator/workflow.ts`) contains placeholder implementations ready to wire to real kits:

### `startSpec()` - Spec Generation
Currently returns mock spec summaries. Wire to **SpecKit** for real spec generation:

```typescript
// TODO: Replace mock with real SpecKit call
import { generateSpec } from '@harmony/speckit';
const spec = await generateSpec(intent, tier);
```

### `buildTask()` - Code Generation
Currently simulates AI building. Wire to **AgentKit/FlowKit**:

```typescript
// TODO: Replace mock with real AgentKit/FlowKit call
import { executeFlow } from '@harmony/flowkit';
const result = await executeFlow('implement', { spec, plan });
```

### `shipTask()` - Deployment
Currently simulates shipping. Wire to **PatchKit** and Vercel:

```typescript
// TODO: Replace mock with real PatchKit + Vercel calls
import { mergePR } from '@harmony/patchkit';
await mergePR(task.prNumber);
await exec('vercel promote', [previewUrl]);
```

### `getHealthChecks()` - System Status
Currently returns static health data. Wire to real services:

```typescript
// TODO: Check actual runner, git, and CI status
const runnerHealth = await checkRunner();
const gitHealth = await checkGitStatus();
const ciHealth = await checkCIStatus();
```

## Next Steps to Wire to Real Kits

1. **SpecKit Integration**
   - Import SpecKit in `startSpec()`
   - Replace mock `SpecSummary` with real spec generation
   - Wire spec validation

2. **FlowKit/AgentKit Integration**
   - Import FlowKit in `buildTask()`
   - Create flow configs for `implement`, `test`, `review` workflows
   - Wire to the shared LangGraph runtime

3. **GitHub API Integration**
   - Wire `getPRSummary()` to real GitHub PR data
   - Add PR creation in `buildTask()` completion
   - Add PR merge in `shipTask()`

4. **Vercel Integration**
   - Wire preview URL detection to actual Vercel deployments
   - Add `vercel promote` execution in `shipTask()`
   - Wire rollback to `vercel promote <previous>`

5. **ObservaKit Integration**
   - Add trace IDs to all operations
   - Wire health checks to actual telemetry
   - Add cost tracking integration

## State Persistence

The CLI persists state in the `.harmony/` directory:

### Task State (`.harmony/state.json`)

```json
{
  "version": 1,
  "tasks": [
    {
      "id": "uuid",
      "title": "Add user profile endpoint",
      "description": "...",
      "tier": "T2",
      "status": "reviewing",
      "createdAt": "2025-01-01T00:00:00Z",
      "updatedAt": "2025-01-01T01:00:00Z",
      "prNumber": 123,
      "flagName": "feature.add-user-profile-endpoint",
      "previewUrl": "https://preview-xxx.vercel.app"
    }
  ],
  "lastUpdated": "2025-01-01T01:00:00Z"
}
```

### Onboarding State (`.harmony/onboarding.json`)

```json
{
  "version": 1,
  "startedAt": "2025-01-01T00:00:00Z",
  "currentStep": "guided_fix",
  "userName": "Alice",
  "isComplete": false,
  "totalMinutesSpent": 5,
  "steps": [
    {
      "id": "welcome",
      "title": "Welcome to Harmony",
      "status": "completed",
      "startedAt": "2025-01-01T00:00:00Z",
      "completedAt": "2025-01-01T00:02:00Z"
    },
    {
      "id": "guided_fix",
      "title": "Guided Bug Fix",
      "status": "in_progress",
      "taskId": "abc123-..."
    }
  ]
}
```

Add `.harmony/` to your `.gitignore` to keep local state out of version control.

## Programmatic Usage

The CLI exports its functions for use in scripts or custom tooling:

```typescript
import {
  statusCommand,
  featureCommand,
  buildCommand,
  shipCommand,
  onboardCommand,
  getSystemStatus,
  createTask,
  updateTask,
  getOrCreateOnboarding,
  loadOnboardingProgress,
} from '@harmony/cli';

// Check system status programmatically
const status = getSystemStatus('/path/to/workspace');
console.log(status.activeTasks);

// Run a command
const result = await featureCommand('Add dark mode', { tier: 'T2' });
if (result.success) {
  console.log('Task created:', result.task?.id);
}

// Start onboarding programmatically
const onboardResult = await onboardCommand('start', [], { name: 'Alice' });

// Check onboarding progress
const progress = loadOnboardingProgress('/path/to/workspace');
if (progress) {
  console.log(`Onboarding: ${progress.currentStep}`);
}
```

## License

Private — part of the Harmony monorepo.
