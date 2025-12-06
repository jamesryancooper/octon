import { fileURLToPath } from "node:url";
import { dirname, join, resolve } from "node:path";

/**
 * Root file path of this module (ESM-friendly).
 * Avoids reliance on __dirname in ESM and centralizes path derivation.
 */
const __filename: string = fileURLToPath(import.meta.url);
const __dirname: string = dirname(__filename);

/**
 * Centralized directory names to avoid magic strings.
 */
const ASSESSMENTS_DIR_NAME = "assessments";
const METHODOLOGY_DIR_NAME = "methodology";

/**
 * Absolute path to this package root and the assessments directory.
 */
const PACKAGE_ROOT: string = resolve(__dirname, "..");
export const PROMPTS_ROOT: string = join(PACKAGE_ROOT, ASSESSMENTS_DIR_NAME);

/**
 * Paths for the methodology prompt suite files.
 */
export interface MethodologyPaths {
  root: string;
  readme: string;
  methodologyAssessment: string;
  toolkitAssessment: string;
  implementationGuideAssessment: string;
  suiteConfig: string;
}

/**
 * Top-level prompt suite paths.
 */
export interface PromptSuitePaths {
  root: string;
  methodology: MethodologyPaths;
}

/**
 * Methodology suite absolute path constants.
 * These are used by agents to locate prompt assets deterministically.
 */
export const methodology: MethodologyPaths = {
  root: join(PROMPTS_ROOT, METHODOLOGY_DIR_NAME),
  readme: join(PROMPTS_ROOT, METHODOLOGY_DIR_NAME, "README.md"),
  methodologyAssessment: join(PROMPTS_ROOT, METHODOLOGY_DIR_NAME, "methodology-assessment.md"),
  toolkitAssessment: join(PROMPTS_ROOT, METHODOLOGY_DIR_NAME, "toolkit-assessment.md"),
  implementationGuideAssessment: join(PROMPTS_ROOT, METHODOLOGY_DIR_NAME, "implementation-guide-assessment.md"),
  suiteConfig: join(PROMPTS_ROOT, METHODOLOGY_DIR_NAME, "assessment.yaml")
};

/**
 * Resolve an absolute path within the prompts suite root (assessments/).
 * @param segments - Path segments relative to the assessments root
 * @returns Absolute path joined from `PROMPTS_ROOT` and provided segments
 */
export function resolvePromptPath(...segments: string[]): string {
  return join(PROMPTS_ROOT, ...segments);
}

/**
 * Default export bundles common paths for convenience.
 */
const prompts: PromptSuitePaths = {
  root: PROMPTS_ROOT,
  methodology
};

export default prompts;

