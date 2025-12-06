/**
 * Workflow orchestration for the Harmony CLI.
 *
 * This module maps human intents to AI agent operations.
 * It's the bridge between simple commands and complex kit orchestration.
 */

import type {
  HarmonyTask,
  RiskTier,
  SpecSummary,
  PRSummary,
  CommonOptions,
  CommandResult,
} from "../types/index.js";
import {
  createTask,
  updateTask,
  getTask,
  getSystemStatus,
  findTaskByTitle,
} from "./state.js";

/**
 * Get the workspace root (project directory).
 */
export function getWorkspaceRoot(): string {
  return process.env.HARMONY_WORKSPACE_ROOT ?? process.cwd();
}

/**
 * Determine risk tier based on intent and files.
 *
 * In a full implementation, this would use AI to analyze the intent
 * and affected code paths. For now, we use simple heuristics.
 */
export function assessRiskTier(
  intent: string,
  _options?: CommonOptions
): { tier: RiskTier; reason: string } {
  const lowerIntent = intent.toLowerCase();

  // T3: High-risk keywords
  const t3Keywords = [
    "auth",
    "authentication",
    "oauth",
    "login",
    "password",
    "security",
    "billing",
    "payment",
    "stripe",
    "migration",
    "database",
    "schema",
    "delete",
    "remove user",
    "admin",
    "permissions",
    "role",
    "encrypt",
    "decrypt",
    "secret",
    "api key",
    "token",
  ];

  for (const keyword of t3Keywords) {
    if (lowerIntent.includes(keyword)) {
      return {
        tier: "T3",
        reason: `Contains high-risk keyword: "${keyword}"`,
      };
    }
  }

  // T1: Trivial keywords
  const t1Keywords = [
    "typo",
    "comment",
    "readme",
    "docs",
    "documentation",
    "style",
    "format",
    "lint",
    "logging",
    "log message",
  ];

  for (const keyword of t1Keywords) {
    if (lowerIntent.includes(keyword)) {
      return {
        tier: "T1",
        reason: `Trivial change: "${keyword}"`,
      };
    }
  }

  // Default to T2
  return {
    tier: "T2",
    reason: "Standard feature or fix",
  };
}

/**
 * Generate a feature flag name from the task title.
 */
export function generateFlagName(title: string): string {
  const slug = title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "")
    .slice(0, 40);

  return `feature.${slug}`;
}

/**
 * Start a new spec workflow.
 *
 * This creates a task and initiates AI spec generation.
 * In a full implementation, this would call SpecKit.
 */
export async function startSpec(
  intent: string,
  options?: CommonOptions
): Promise<CommandResult> {
  const workspaceRoot = getWorkspaceRoot();

  // Assess risk tier (AI or heuristic)
  const { tier: autoTier, reason: tierReason } = assessRiskTier(intent, options);
  const tier = options?.tier ?? autoTier;

  // Generate flag name
  const flagName = generateFlagName(intent);

  // Create the task
  const task = createTask(workspaceRoot, {
    title: intent,
    description: `Spec: ${intent}`,
    tier,
    status: "planning",
    flagName,
  });

  // TODO: Call SpecKit to generate actual spec
  // For now, return a placeholder

  // Simulate AI generating a spec summary
  const specSummary: SpecSummary = {
    description: `AI will implement: ${intent}`,
    tier,
    tierReason,
    surfaces: detectSurfaces(intent),
    threatSummary: tier !== "T1" ? "Threat analysis pending..." : undefined,
    tests: estimateTests(tier),
    flag: flagName,
    rollback: "Disable flag or promote prior preview",
  };

  // Update task with summary
  updateTask(workspaceRoot, task.id, {
    summary: specSummary.description,
  });

  return {
    success: true,
    message: `Spec created for: ${intent}`,
    task,
    data: { specSummary },
    nextAction:
      tier === "T1"
        ? "Run `harmony build` to proceed, or `harmony status` to check progress"
        : "Review the spec summary above, then run `harmony build` to proceed",
  };
}

/**
 * Start a bug fix workflow.
 */
export async function startFix(
  description: string,
  options?: CommonOptions
): Promise<CommandResult> {
  // Bug fixes are typically T1 or T2
  const modifiedOptions = {
    ...options,
    tier: options?.tier ?? ("T1" as RiskTier),
  };

  const result = await startSpec(`Fix: ${description}`, modifiedOptions);
  if (result.task) {
    result.message = `Bug fix started: ${description}`;
  }
  return result;
}

/**
 * Start a feature workflow.
 */
export async function startFeature(
  description: string,
  options?: CommonOptions
): Promise<CommandResult> {
  const result = await startSpec(description, options);
  if (result.task) {
    result.message = `Feature started: ${description}`;
  }
  return result;
}

/**
 * Build (implement) a task.
 *
 * This triggers AI code generation based on the spec.
 */
export async function buildTask(
  taskIdOrTitle?: string,
  options?: CommonOptions
): Promise<CommandResult> {
  const workspaceRoot = getWorkspaceRoot();

  // Find the task
  let task: HarmonyTask | null = null;

  if (taskIdOrTitle) {
    task = getTask(workspaceRoot, taskIdOrTitle);
    if (!task) {
      task = findTaskByTitle(workspaceRoot, taskIdOrTitle);
    }
  } else {
    // Get most recent active task
    const status = getSystemStatus(workspaceRoot);
    task = status.activeTasks[0] ?? null;
  }

  if (!task) {
    return {
      success: false,
      message: "No active task found. Run `harmony feature` or `harmony fix` first.",
    };
  }

  if (task.status !== "planning" && task.status !== "paused") {
    return {
      success: false,
      message: `Task "${task.title}" is ${task.status}, not ready to build.`,
      task,
    };
  }

  // Update status to building
  updateTask(workspaceRoot, task.id, { status: "building" });

  // TODO: Call AgentKit/FlowKit to actually build
  // For now, simulate progress

  // Simulate AI building...
  await simulateDelay(500);

  // Move to testing
  updateTask(workspaceRoot, task.id, { status: "testing" });

  // Simulate tests...
  await simulateDelay(300);

  // Move to reviewing (needs human)
  const updatedTask = updateTask(workspaceRoot, task.id, {
    status: "reviewing",
    prNumber: Math.floor(Math.random() * 1000) + 100, // Simulated PR number
    previewUrl: `https://preview-${task.id.slice(0, 8)}.vercel.app`,
  });

  return {
    success: true,
    message: `Build complete for: ${task.title}`,
    task: updatedTask ?? task,
    nextAction: "Review the PR summary and approve when ready.",
  };
}

/**
 * Ship (deploy) a task.
 */
export async function shipTask(
  taskIdOrTitle?: string,
  _options?: CommonOptions
): Promise<CommandResult> {
  const workspaceRoot = getWorkspaceRoot();

  // Find the task
  let task: HarmonyTask | null = null;

  if (taskIdOrTitle) {
    task = getTask(workspaceRoot, taskIdOrTitle);
    if (!task) {
      task = findTaskByTitle(workspaceRoot, taskIdOrTitle);
    }
  } else {
    // Get most recent task ready to ship
    const status = getSystemStatus(workspaceRoot);
    task = status.pendingReview[0] ?? status.activeTasks.find((t) => t.status === "ready") ?? null;
  }

  if (!task) {
    return {
      success: false,
      message: "No task ready to ship. Run `harmony status` to see available tasks.",
    };
  }

  if (task.status !== "reviewing" && task.status !== "ready") {
    return {
      success: false,
      message: `Task "${task.title}" is ${task.status}, not ready to ship.`,
      task,
    };
  }

  // TODO: Call PatchKit to merge PR and Vercel to promote
  // For now, simulate

  const updatedTask = updateTask(workspaceRoot, task.id, {
    status: "shipped",
  });

  return {
    success: true,
    message: `Shipped: ${task.title}`,
    task: updatedTask ?? task,
    data: {
      prNumber: task.prNumber,
      flagName: task.flagName,
    },
    nextAction: task.flagName
      ? `Feature is behind flag "${task.flagName}". Enable when ready.`
      : "Deployment complete. Monitor for any issues.",
  };
}

/**
 * Pause a running task.
 */
export async function pauseTask(
  taskIdOrTitle?: string,
  _options?: CommonOptions
): Promise<CommandResult> {
  const workspaceRoot = getWorkspaceRoot();

  let task: HarmonyTask | null = null;

  if (taskIdOrTitle) {
    task = getTask(workspaceRoot, taskIdOrTitle);
    if (!task) {
      task = findTaskByTitle(workspaceRoot, taskIdOrTitle);
    }
  } else {
    const status = getSystemStatus(workspaceRoot);
    task = status.activeTasks.find(
      (t) => t.status === "building" || t.status === "testing"
    ) ?? null;
  }

  if (!task) {
    return {
      success: false,
      message: "No running task found to pause.",
    };
  }

  const updatedTask = updateTask(workspaceRoot, task.id, {
    status: "paused",
  });

  return {
    success: true,
    message: `Paused: ${task.title}`,
    task: updatedTask ?? task,
    nextAction: "Run `harmony build` to resume, or `harmony retry` with new guidance.",
  };
}

/**
 * Retry a failed or paused task with optional new constraints.
 */
export async function retryTask(
  taskIdOrTitle?: string,
  options?: CommonOptions
): Promise<CommandResult> {
  const workspaceRoot = getWorkspaceRoot();

  let task: HarmonyTask | null = null;

  if (taskIdOrTitle) {
    task = getTask(workspaceRoot, taskIdOrTitle);
    if (!task) {
      task = findTaskByTitle(workspaceRoot, taskIdOrTitle);
    }
  } else {
    const status = getSystemStatus(workspaceRoot);
    task = status.activeTasks.find(
      (t) => t.status === "failed" || t.status === "paused"
    ) ?? null;
  }

  if (!task) {
    return {
      success: false,
      message: "No failed or paused task found to retry.",
    };
  }

  // Apply any new constraints to the task description
  let newDescription = task.description;
  if (options?.constraint) {
    newDescription = `${task.description} [Constraint: ${options.constraint}]`;
  }
  if (options?.context) {
    newDescription = `${newDescription} [Context: ${options.context}]`;
  }

  updateTask(workspaceRoot, task.id, {
    status: "planning",
    description: newDescription,
    warnings: undefined, // Clear previous warnings
  });

  // Start the build again
  return buildTask(task.id, options);
}

/**
 * Get explanation for a task or decision.
 */
export async function explainTask(
  taskIdOrTitle: string,
  question?: string
): Promise<CommandResult> {
  const workspaceRoot = getWorkspaceRoot();

  let task = getTask(workspaceRoot, taskIdOrTitle);
  if (!task) {
    task = findTaskByTitle(workspaceRoot, taskIdOrTitle);
  }

  if (!task) {
    return {
      success: false,
      message: `No task found matching: ${taskIdOrTitle}`,
    };
  }

  // TODO: Call AI to explain the task/decisions
  // For now, return structured information

  const explanation = [
    `Task: ${task.title}`,
    `Tier: ${task.tier}`,
    `Status: ${task.status}`,
    "",
    "AI would explain:",
    question ? `- Your question: "${question}"` : "- Why this approach was chosen",
    "- What files are affected",
    "- What risks were considered",
    "- What alternatives were evaluated",
  ].join("\n");

  return {
    success: true,
    message: explanation,
    task,
    nextAction: "Ask a follow-up question or run `harmony retry --constraint '...'` to adjust.",
  };
}

/**
 * Get PR summary for a task.
 */
export function getPRSummary(task: HarmonyTask): PRSummary {
  // TODO: Get actual PR data from GitHub
  // For now, return placeholder

  return {
    description: `Implements ${task.title}`,
    filesChanged: Math.floor(Math.random() * 10) + 1,
    linesAdded: Math.floor(Math.random() * 200) + 10,
    linesRemoved: Math.floor(Math.random() * 50),
    testsStatus: "passing",
    ciStatus: "passing",
    warnings: task.warnings ?? [],
    recommendation: task.tier === "T1" ? "approve" : "review",
  };
}

// Helper functions

function detectSurfaces(intent: string): string[] {
  const surfaces: string[] = [];
  const lower = intent.toLowerCase();

  if (lower.includes("api") || lower.includes("endpoint")) surfaces.push("api");
  if (lower.includes("ui") || lower.includes("page") || lower.includes("component")) surfaces.push("ui");
  if (lower.includes("database") || lower.includes("model") || lower.includes("schema")) surfaces.push("data");
  if (lower.includes("auth") || lower.includes("login")) surfaces.push("auth");

  if (surfaces.length === 0) surfaces.push("code");

  return surfaces;
}

function estimateTests(tier: RiskTier): { unit: number; contract: number; e2e: number } {
  switch (tier) {
    case "T1":
      return { unit: 1, contract: 0, e2e: 0 };
    case "T2":
      return { unit: 4, contract: 1, e2e: 1 };
    case "T3":
      return { unit: 8, contract: 3, e2e: 2 };
  }
}

function simulateDelay(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

