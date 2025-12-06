/**
 * State management for the Harmony CLI.
 *
 * Tracks active tasks, their status, and provides persistence.
 * This is the "memory" that allows humans to check on AI progress.
 */

import { readFileSync, writeFileSync, existsSync, mkdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { randomUUID } from "node:crypto";
import type { HarmonyTask, RiskTier, WorkflowStatus, SystemStatus, StatusItem } from "../types/index.js";

const STATE_DIR = ".harmony";
const STATE_FILE = "state.json";

interface PersistedState {
  version: number;
  tasks: HarmonyTask[];
  lastUpdated: string;
}

const DEFAULT_STATE: PersistedState = {
  version: 1,
  tasks: [],
  lastUpdated: new Date().toISOString(),
};

/**
 * Get the state file path for the current workspace.
 */
export function getStatePath(workspaceRoot: string): string {
  return join(workspaceRoot, STATE_DIR, STATE_FILE);
}

/**
 * Load state from disk.
 */
export function loadState(workspaceRoot: string): PersistedState {
  const statePath = getStatePath(workspaceRoot);

  if (!existsSync(statePath)) {
    return { ...DEFAULT_STATE };
  }

  try {
    const raw = readFileSync(statePath, "utf8");
    const parsed = JSON.parse(raw) as PersistedState;

    // Convert date strings back to Date objects
    parsed.tasks = parsed.tasks.map((task) => ({
      ...task,
      createdAt: new Date(task.createdAt),
      updatedAt: new Date(task.updatedAt),
    }));

    return parsed;
  } catch {
    // If state is corrupted, start fresh
    return { ...DEFAULT_STATE };
  }
}

/**
 * Save state to disk.
 */
export function saveState(workspaceRoot: string, state: PersistedState): void {
  const statePath = getStatePath(workspaceRoot);
  const stateDir = dirname(statePath);

  if (!existsSync(stateDir)) {
    mkdirSync(stateDir, { recursive: true });
  }

  const toSave: PersistedState = {
    ...state,
    lastUpdated: new Date().toISOString(),
  };

  writeFileSync(statePath, JSON.stringify(toSave, null, 2), "utf8");
}

/**
 * Create a new task.
 */
export function createTask(
  workspaceRoot: string,
  params: {
    title: string;
    description: string;
    tier: RiskTier;
    status?: WorkflowStatus;
    flagName?: string;
  }
): HarmonyTask {
  const state = loadState(workspaceRoot);
  const now = new Date();

  const task: HarmonyTask = {
    id: randomUUID(),
    title: params.title,
    description: params.description,
    tier: params.tier,
    status: params.status ?? "pending",
    createdAt: now,
    updatedAt: now,
    flagName: params.flagName,
  };

  state.tasks.push(task);
  saveState(workspaceRoot, state);

  return task;
}

/**
 * Update an existing task.
 */
export function updateTask(
  workspaceRoot: string,
  taskId: string,
  updates: Partial<Omit<HarmonyTask, "id" | "createdAt">>
): HarmonyTask | null {
  const state = loadState(workspaceRoot);
  const taskIndex = state.tasks.findIndex((t) => t.id === taskId);

  if (taskIndex === -1) {
    return null;
  }

  state.tasks[taskIndex] = {
    ...state.tasks[taskIndex],
    ...updates,
    updatedAt: new Date(),
  };

  saveState(workspaceRoot, state);

  return state.tasks[taskIndex];
}

/**
 * Get a task by ID.
 */
export function getTask(workspaceRoot: string, taskId: string): HarmonyTask | null {
  const state = loadState(workspaceRoot);
  return state.tasks.find((t) => t.id === taskId) ?? null;
}

/**
 * Get all active tasks (not shipped/failed).
 */
export function getActiveTasks(workspaceRoot: string): HarmonyTask[] {
  const state = loadState(workspaceRoot);
  return state.tasks.filter(
    (t) => t.status !== "shipped" && t.status !== "failed"
  );
}

/**
 * Get tasks awaiting human review.
 */
export function getPendingReviewTasks(workspaceRoot: string): HarmonyTask[] {
  const state = loadState(workspaceRoot);
  return state.tasks.filter((t) => t.status === "reviewing");
}

/**
 * Get recently completed tasks.
 */
export function getRecentlyCompletedTasks(
  workspaceRoot: string,
  limit = 5
): HarmonyTask[] {
  const state = loadState(workspaceRoot);
  return state.tasks
    .filter((t) => t.status === "shipped")
    .sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime())
    .slice(0, limit);
}

/**
 * Remove old completed tasks (cleanup).
 */
export function pruneOldTasks(
  workspaceRoot: string,
  maxAgeDays = 30
): number {
  const state = loadState(workspaceRoot);
  const cutoff = Date.now() - maxAgeDays * 24 * 60 * 60 * 1000;

  const before = state.tasks.length;
  state.tasks = state.tasks.filter((t) => {
    // Keep active tasks
    if (t.status !== "shipped" && t.status !== "failed") {
      return true;
    }
    // Keep recent completed tasks
    return t.updatedAt.getTime() > cutoff;
  });

  saveState(workspaceRoot, state);
  return before - state.tasks.length;
}

/**
 * Get system health status checks.
 */
export function getHealthChecks(_workspaceRoot: string): StatusItem[] {
  // TODO: Wire to actual health checks (runner, git, ci status, etc.)
  return [
    {
      name: "AI Runner",
      status: "ok",
      message: "Connected",
    },
    {
      name: "Git",
      status: "ok",
      message: "Clean working tree",
    },
    {
      name: "CI",
      status: "ok",
      message: "All checks passing",
    },
  ];
}

/**
 * Get the full system status.
 */
export function getSystemStatus(workspaceRoot: string): SystemStatus {
  return {
    activeTasks: getActiveTasks(workspaceRoot),
    pendingReview: getPendingReviewTasks(workspaceRoot),
    recentlyCompleted: getRecentlyCompletedTasks(workspaceRoot),
    health: getHealthChecks(workspaceRoot),
    // TODO: Wire to actual cost tracking
    cost: undefined,
  };
}

/**
 * Find the most recent task by title pattern.
 */
export function findTaskByTitle(
  workspaceRoot: string,
  pattern: string
): HarmonyTask | null {
  const state = loadState(workspaceRoot);
  const lowerPattern = pattern.toLowerCase();

  return (
    state.tasks
      .filter((t) => t.title.toLowerCase().includes(lowerPattern))
      .sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime())[0] ?? null
  );
}

