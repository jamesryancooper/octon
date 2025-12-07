/**
 * PromptKit Token Management
 *
 * Token estimation and budget management for prompts.
 * Integrates with CostKit for accurate token counting.
 */

import type {
  TokenBudgetOptions,
  TokenBudgetResult,
  TruncationStrategy,
} from "./types";

/**
 * Model context window sizes (approximate).
 */
export const MODEL_CONTEXT_WINDOWS: Record<string, number> = {
  // OpenAI
  "gpt-4o": 128000,
  "gpt-4o-mini": 128000,
  "gpt-4-turbo": 128000,
  "gpt-4": 8192,
  "gpt-3.5-turbo": 16385,
  o1: 128000,
  "o1-mini": 128000,

  // Anthropic
  "claude-opus": 200000,
  "claude-sonnet": 200000,
  "claude-haiku": 200000,
  "claude-3-opus": 200000,
  "claude-3-sonnet": 200000,
  "claude-3-haiku": 200000,

  // Google
  "gemini-2.0-flash": 1000000,
  "gemini-1.5-pro": 2000000,
  "gemini-1.5-flash": 1000000,

  // Default fallback
  default: 8192,
};

/**
 * Get the context window size for a model.
 */
export function getContextWindow(model: string): number {
  // Normalize model name for lookup
  const normalized = model.toLowerCase().replace(/[_\s]/g, "-");

  // Try exact match first
  if (MODEL_CONTEXT_WINDOWS[normalized]) {
    return MODEL_CONTEXT_WINDOWS[normalized];
  }

  // Try prefix match (e.g., "gpt-4o-2024-05-13" → "gpt-4o")
  for (const [key, value] of Object.entries(MODEL_CONTEXT_WINDOWS)) {
    if (normalized.startsWith(key)) {
      return value;
    }
  }

  return MODEL_CONTEXT_WINDOWS.default;
}

/**
 * Simple token counter based on character approximation.
 * For more accurate counting, consider using tiktoken.
 *
 * @param text - Text to estimate tokens for
 * @returns Estimated token count
 */
export function estimateTokenCount(text: string): number {
  if (!text) return 0;

  // Rough approximation: 1 token ≈ 4 characters for English text
  // This is a simplification; real tokenization varies by model
  return Math.ceil(text.length / 4);
}

/**
 * Estimate tokens with model-specific adjustments.
 *
 * @param text - Text to estimate tokens for
 * @param model - Model name for adjustments (optional)
 * @returns Estimated token count
 */
export function estimateTokens(text: string, model?: string): number {
  const baseEstimate = estimateTokenCount(text);

  // Apply model-specific adjustments (some tokenizers are more efficient)
  if (model) {
    const normalized = model.toLowerCase();

    // Claude tends to have slightly more efficient tokenization
    if (normalized.includes("claude")) {
      return Math.ceil(baseEstimate * 0.9);
    }

    // GPT tokenization is our baseline
    if (normalized.includes("gpt")) {
      return baseEstimate;
    }
  }

  return baseEstimate;
}

/**
 * Apply a token budget to text, truncating if necessary.
 *
 * @param text - The text to potentially truncate
 * @param options - Budget options including max tokens and strategy
 * @returns Result with possibly truncated text and metadata
 */
export function applyTokenBudget(
  text: string,
  options: TokenBudgetOptions
): TokenBudgetResult {
  const { maxTokens, reserveOutputTokens = 0, strategy = "balanced", model } = options;

  const originalTokens = estimateTokens(text, model);
  const availableTokens = maxTokens - reserveOutputTokens;

  // If within budget, return as-is
  if (originalTokens <= availableTokens) {
    return {
      text,
      truncated: false,
      originalTokens,
      finalTokens: originalTokens,
      strategy,
    };
  }

  // Need to truncate
  const truncatedText = truncateToTokens(text, availableTokens, strategy, model);
  const finalTokens = estimateTokens(truncatedText, model);

  return {
    text: truncatedText,
    truncated: true,
    originalTokens,
    finalTokens,
    strategy,
  };
}

/**
 * Truncate text to fit within a token limit.
 *
 * @param text - Text to truncate
 * @param targetTokens - Target token count
 * @param strategy - Truncation strategy
 * @param model - Model for token estimation
 * @returns Truncated text
 */
export function truncateToTokens(
  text: string,
  targetTokens: number,
  strategy: TruncationStrategy = "balanced",
  model?: string
): string {
  if (targetTokens <= 0) {
    return "";
  }

  // Approximate character count from token target
  // Using 4 chars/token as base, then adjust for overhead
  const targetChars = targetTokens * 4 - 50; // Reserve some for safety

  if (text.length <= targetChars) {
    return text;
  }

  switch (strategy) {
    case "prioritize_start":
      return truncateFromEnd(text, targetChars);

    case "prioritize_recent":
      return truncateFromStart(text, targetChars);

    case "balanced":
    default:
      return truncateBalanced(text, targetChars);
  }
}

/**
 * Truncate from the end, keeping the start.
 */
function truncateFromEnd(text: string, targetChars: number): string {
  const truncationMarker = "\n\n[...content truncated...]\n";
  const availableChars = targetChars - truncationMarker.length;

  if (availableChars <= 0) {
    return truncationMarker;
  }

  // Try to truncate at a paragraph or sentence boundary
  const truncatePoint = findGoodTruncationPoint(text, availableChars);

  return text.slice(0, truncatePoint) + truncationMarker;
}

/**
 * Truncate from the start, keeping the end (recent content).
 */
function truncateFromStart(text: string, targetChars: number): string {
  const truncationMarker = "[...earlier content truncated...]\n\n";
  const availableChars = targetChars - truncationMarker.length;

  if (availableChars <= 0) {
    return truncationMarker;
  }

  // Start from the end and work backwards
  const startPoint = text.length - availableChars;

  // Try to start at a paragraph or sentence boundary
  const actualStart = findGoodStartPoint(text, startPoint);

  return truncationMarker + text.slice(actualStart);
}

/**
 * Truncate from the middle, keeping start and end.
 */
function truncateBalanced(text: string, targetChars: number): string {
  const truncationMarker = "\n\n[...middle content truncated...]\n\n";
  const availableChars = targetChars - truncationMarker.length;

  if (availableChars <= 0) {
    return truncationMarker;
  }

  // Split available space between start and end (60/40 favoring start)
  const startChars = Math.floor(availableChars * 0.6);
  const endChars = availableChars - startChars;

  // Find good truncation points
  const startTruncatePoint = findGoodTruncationPoint(text, startChars);
  const endStartPoint = findGoodStartPoint(text, text.length - endChars);

  // Avoid overlap
  if (startTruncatePoint >= endStartPoint) {
    // Just use prioritize_start as fallback
    return truncateFromEnd(text, targetChars);
  }

  return (
    text.slice(0, startTruncatePoint) +
    truncationMarker +
    text.slice(endStartPoint)
  );
}

/**
 * Find a good point to truncate (prefer paragraph/sentence boundaries).
 */
function findGoodTruncationPoint(text: string, targetPos: number): number {
  // Look backwards from target for a good break point
  const searchStart = Math.max(0, targetPos - 200);
  const searchEnd = Math.min(text.length, targetPos);
  const searchArea = text.slice(searchStart, searchEnd);

  // Try to find paragraph break
  const lastParagraph = searchArea.lastIndexOf("\n\n");
  if (lastParagraph !== -1 && lastParagraph > searchArea.length * 0.5) {
    return searchStart + lastParagraph;
  }

  // Try to find sentence break
  const lastSentence = searchArea.lastIndexOf(". ");
  if (lastSentence !== -1 && lastSentence > searchArea.length * 0.5) {
    return searchStart + lastSentence + 1;
  }

  // Try newline
  const lastNewline = searchArea.lastIndexOf("\n");
  if (lastNewline !== -1 && lastNewline > searchArea.length * 0.5) {
    return searchStart + lastNewline;
  }

  // Fall back to word boundary
  const lastSpace = searchArea.lastIndexOf(" ");
  if (lastSpace !== -1) {
    return searchStart + lastSpace;
  }

  // Give up and use target position
  return targetPos;
}

/**
 * Find a good point to start from (prefer paragraph/sentence boundaries).
 */
function findGoodStartPoint(text: string, targetPos: number): number {
  // Look forward from target for a good start point
  const searchStart = targetPos;
  const searchEnd = Math.min(text.length, targetPos + 200);
  const searchArea = text.slice(searchStart, searchEnd);

  // Try to find paragraph break
  const firstParagraph = searchArea.indexOf("\n\n");
  if (firstParagraph !== -1 && firstParagraph < searchArea.length * 0.5) {
    return searchStart + firstParagraph + 2;
  }

  // Try to find sentence start
  const firstSentence = searchArea.indexOf(". ");
  if (firstSentence !== -1 && firstSentence < searchArea.length * 0.5) {
    return searchStart + firstSentence + 2;
  }

  // Try newline
  const firstNewline = searchArea.indexOf("\n");
  if (firstNewline !== -1 && firstNewline < searchArea.length * 0.5) {
    return searchStart + firstNewline + 1;
  }

  // Fall back to word boundary
  const firstSpace = searchArea.indexOf(" ");
  if (firstSpace !== -1) {
    return searchStart + firstSpace + 1;
  }

  // Give up and use target position
  return targetPos;
}

/**
 * Calculate the maximum tokens available for output given input and context.
 *
 * @param inputTokens - Tokens used by input
 * @param model - Model name for context window lookup
 * @param reserveBuffer - Safety buffer to reserve (default: 100)
 * @returns Maximum tokens available for output
 */
export function calculateAvailableOutputTokens(
  inputTokens: number,
  model: string,
  reserveBuffer = 100
): number {
  const contextWindow = getContextWindow(model);
  const available = contextWindow - inputTokens - reserveBuffer;
  return Math.max(0, available);
}

/**
 * Check if a prompt fits within a model's context window.
 *
 * @param text - The prompt text
 * @param model - The model to check against
 * @param reserveForOutput - Tokens to reserve for output
 * @returns Whether the prompt fits
 */
export function fitsInContext(
  text: string,
  model: string,
  reserveForOutput = 0
): boolean {
  const tokens = estimateTokens(text, model);
  const contextWindow = getContextWindow(model);
  return tokens + reserveForOutput <= contextWindow;
}

/**
 * Information about token usage.
 */
export interface TokenInfo {
  /** Estimated token count */
  tokens: number;

  /** Model's context window size */
  contextWindow: number;

  /** Percentage of context used */
  usagePercent: number;

  /** Whether it fits in context */
  fitsInContext: boolean;

  /** Tokens remaining for output */
  availableForOutput: number;
}

/**
 * Get detailed token information for a prompt.
 *
 * @param text - The prompt text
 * @param model - The model name
 * @param reserveForOutput - Tokens to reserve for output (default: 4096)
 * @returns Detailed token information
 */
export function getTokenInfo(
  text: string,
  model: string,
  reserveForOutput = 4096
): TokenInfo {
  const tokens = estimateTokens(text, model);
  const contextWindow = getContextWindow(model);
  const usagePercent = (tokens / contextWindow) * 100;

  // Calculate available tokens for output, accounting for:
  // - The input tokens already used
  // - A small safety buffer (100 tokens)
  const safetyBuffer = 100;
  const availableForOutput = Math.max(0, contextWindow - tokens - safetyBuffer);

  // fitsInContext checks if input + reserved output fits within context window
  const fitsInContext = tokens + reserveForOutput <= contextWindow;

  return {
    tokens,
    contextWindow,
    usagePercent,
    fitsInContext,
    availableForOutput,
  };
}

