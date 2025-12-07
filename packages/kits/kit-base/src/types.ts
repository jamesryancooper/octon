/**
 * Shared type definitions for Harmony Kits.
 */

/**
 * Harmony methodology pillars.
 */
export type HarmonyPillar =
  | "speed_with_safety"
  | "simplicity_over_complexity"
  | "quality_through_determinism"
  | "guided_agentic_autonomy"
  | "evolvable_modularity";

/**
 * Lifecycle stages in the Harmony methodology.
 */
export type LifecycleStage =
  | "spec"
  | "plan"
  | "implement"
  | "verify"
  | "ship"
  | "operate"
  | "learn";

/**
 * Risk tier classification.
 */
export type RiskTier = "T1" | "T2" | "T3";

/**
 * Risk level for HITL gates.
 */
export type RiskLevel = "trivial" | "low" | "medium" | "high";

/**
 * Run status.
 */
export type RunStatus = "success" | "failure";

/**
 * Kit state in the lifecycle state machine.
 */
export type KitState =
  | "idle"
  | "planning"
  | "executing"
  | "verifying"
  | "completed"
  | "failed";

/**
 * HITL checkpoint states.
 */
export type HITLState =
  | "planned"
  | "requested"
  | "approved"
  | "rejected"
  | "waived";

/**
 * HITL checkpoint names.
 */
export type HITLCheckpoint =
  | "pre-implement"
  | "pre-merge"
  | "pre-promote"
  | "post-promote";

