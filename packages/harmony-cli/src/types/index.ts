/**
 * Core types for the Harmony CLI.
 *
 * These types define the interface between human commands and AI orchestration.
 */

/**
 * Risk tiers determine the level of human oversight required.
 * AI assigns these automatically; humans can override upward.
 */
export type RiskTier = "T1" | "T2" | "T3";

/**
 * Workflow status indicates the current state of an AI-driven task.
 */
export type WorkflowStatus =
  | "pending"
  | "planning"
  | "building"
  | "testing"
  | "reviewing"
  | "ready"
  | "shipped"
  | "failed"
  | "paused";

/**
 * Represents a task being worked on by AI agents.
 */
export interface HarmonyTask {
  /** Unique identifier for the task */
  id: string;

  /** Human-readable title */
  title: string;

  /** Brief description of what's being done */
  description: string;

  /** Risk tier (T1, T2, T3) */
  tier: RiskTier;

  /** Current status */
  status: WorkflowStatus;

  /** When the task was created */
  createdAt: Date;

  /** When the task was last updated */
  updatedAt: Date;

  /** Associated PR number, if any */
  prNumber?: number;

  /** Feature flag name, if applicable */
  flagName?: string;

  /** Preview URL, if deployed */
  previewUrl?: string;

  /** AI-generated summary for human review */
  summary?: string;

  /** Any warnings or issues AI has flagged */
  warnings?: string[];
}

/**
 * Result of a CLI command execution.
 */
export interface CommandResult {
  /** Whether the command succeeded */
  success: boolean;

  /** Human-readable message */
  message: string;

  /** Associated task, if any */
  task?: HarmonyTask;

  /** Additional data (command-specific) */
  data?: Record<string, unknown>;

  /** Suggested next action for the human */
  nextAction?: string;
}

/**
 * Options that can be passed to most commands.
 */
export interface CommonOptions {
  /** Force a specific tier (normally AI-assigned) */
  tier?: RiskTier;

  /** Additional context to provide to AI */
  context?: string;

  /** Constraint to apply to AI generation */
  constraint?: string;

  /** Use a specific AI model */
  model?: string;

  /** Run in dry-run mode (no side effects) */
  dryRun?: boolean;

  /** Enable verbose output */
  verbose?: boolean;

  /** Run non-interactively */
  nonInteractive?: boolean;
}

/**
 * Configuration for the Harmony CLI.
 */
export interface HarmonyConfig {
  /** Path to the workspace root */
  workspaceRoot: string;

  /** Default AI model for each tier */
  models: {
    T1: string;
    T2Draft: string;
    T2Final: string;
    T3: string;
  };

  /** Feature flag configuration */
  flags: {
    prefix: string;
    defaultOff: boolean;
  };

  /** Runner configuration */
  runner: {
    url: string;
    autoStart: boolean;
  };
}

/**
 * AI-generated spec summary for human review.
 */
export interface SpecSummary {
  /** One-paragraph description */
  description: string;

  /** Risk tier and reason */
  tier: RiskTier;
  tierReason: string;

  /** Surfaces affected (api, ui, data, etc.) */
  surfaces: string[];

  /** Threat summary (for T2/T3) */
  threatSummary?: string;

  /** Estimated tests */
  tests: {
    unit: number;
    contract: number;
    e2e: number;
  };

  /** Proposed feature flag */
  flag?: string;

  /** Rollback strategy */
  rollback: string;
}

/**
 * AI-generated PR summary for human review.
 */
export interface PRSummary {
  /** One-paragraph description of changes */
  description: string;

  /** Files changed */
  filesChanged: number;

  /** Lines added/removed */
  linesAdded: number;
  linesRemoved: number;

  /** Test status */
  testsStatus: "passing" | "failing" | "pending";

  /** CI gate status */
  ciStatus: "passing" | "failing" | "pending";

  /** Any warnings for human attention */
  warnings: string[];

  /** Recommended action */
  recommendation: "approve" | "review" | "block";
}

/**
 * Represents a status check item.
 */
export interface StatusItem {
  /** Name of the item */
  name: string;

  /** Current status */
  status: "ok" | "warning" | "error" | "pending";

  /** Human-readable message */
  message: string;

  /** Link for more details */
  link?: string;
}

/**
 * Overall system status.
 */
export interface SystemStatus {
  /** Active tasks being worked on */
  activeTasks: HarmonyTask[];

  /** Tasks awaiting human action */
  pendingReview: HarmonyTask[];

  /** Recent completions */
  recentlyCompleted: HarmonyTask[];

  /** System health checks */
  health: StatusItem[];

  /** Cost summary for current period */
  cost?: {
    periodStart: Date;
    periodEnd: Date;
    spent: number;
    budget: number;
    currency: string;
  };
}

