/**
 * PromptKit Assembler
 *
 * Role-based prompt assembly for chat-format LLM APIs.
 * Combines system prompts, user prompts, and tool descriptions.
 */

import type {
  AssembleComponents,
  AssembledPrompt,
  AssembledMessage,
  CompiledPrompt,
  PromptMetadata,
} from "./types";
import { combineHashes, computePromptHash } from "./hasher";
import { estimateTokens } from "./tokens";

/**
 * Assemble components into a chat-format prompt.
 *
 * @param components - The prompt components to assemble
 * @param model - Model for token estimation
 * @returns Assembled prompt ready for LLM API
 */
export function assemble(
  components: AssembleComponents,
  model = "gpt-4o"
): AssembledPrompt {
  const messages: AssembledMessage[] = [];
  const hashes: string[] = [];
  const componentMetadata: AssembledPrompt["components"] = {
    user: { source: "string" },
  };

  // Add system message if provided
  if (components.system) {
    const { content, hash, metadata } = extractContent(
      components.system,
      "system"
    );
    messages.push({
      role: "system",
      content,
    });
    hashes.push(hash);
    if (metadata && "promptId" in metadata) {
      componentMetadata.system = metadata;
    }
  }

  // Add user message (required)
  const { content: userContent, hash: userHash, metadata: userMeta } =
    extractContent(components.user, "user");
  messages.push({
    role: "user",
    content: userContent,
  });
  hashes.push(userHash);
  componentMetadata.user = userMeta || { source: "string" };

  // Add assistant context if provided (for multi-turn)
  if (components.assistant) {
    messages.push({
      role: "assistant",
      content: components.assistant,
    });
    hashes.push(computePromptHash(components.assistant, {}));
  }

  // Add tool descriptions if provided
  if (components.tools && components.tools.length > 0) {
    componentMetadata.tools = [];

    for (const tool of components.tools) {
      const { content, hash, metadata } = extractContent(tool, "tool");
      messages.push({
        role: "system",
        content: `Tool: ${content}`,
      });
      hashes.push(hash);
      componentMetadata.tools.push(metadata || { source: "string" });
    }
  }

  // Calculate combined hash
  const promptHash = combineHashes(hashes);

  // Estimate total tokens
  const totalContent = messages.map((m) => m.content).join("\n");
  const tokensEstimated = estimateTokens(totalContent, model);

  return {
    messages,
    prompt_hash: promptHash,
    tokens_estimated: tokensEstimated,
    components: componentMetadata,
  };
}

/**
 * Extract content from a compiled prompt or string.
 */
function extractContent(
  input: CompiledPrompt | string,
  role: string
): {
  content: string;
  hash: string;
  metadata: PromptMetadata | { source: "string" } | undefined;
} {
  if (typeof input === "string") {
    return {
      content: input,
      hash: computePromptHash(input, {}),
      metadata: { source: "string" },
    };
  }

  return {
    content: input.prompt,
    hash: input.prompt_hash,
    metadata: input.metadata,
  };
}

/**
 * Format assembled prompt for debugging/logging.
 *
 * @param assembled - The assembled prompt
 * @returns Formatted string representation
 */
export function formatAssembled(assembled: AssembledPrompt): string {
  const lines: string[] = [];

  lines.push("═══════════════════════════════════════");
  lines.push("Assembled Prompt");
  lines.push("═══════════════════════════════════════");
  lines.push(`Hash: ${assembled.prompt_hash}`);
  lines.push(`Tokens: ~${assembled.tokens_estimated.toLocaleString()}`);
  lines.push("");

  for (const message of assembled.messages) {
    lines.push(`┌─ ${message.role.toUpperCase()} ─────────────────`);
    lines.push(indentContent(message.content, 2));
    lines.push("└───────────────────────────────────");
    lines.push("");
  }

  return lines.join("\n");
}

/**
 * Indent content for display.
 */
function indentContent(content: string, spaces: number): string {
  const indent = " ".repeat(spaces);
  return content
    .split("\n")
    .map((line) => indent + line)
    .join("\n");
}

/**
 * Convert assembled prompt to OpenAI API format.
 *
 * @param assembled - The assembled prompt
 * @returns Messages array for OpenAI API
 */
export function toOpenAIFormat(
  assembled: AssembledPrompt
): Array<{ role: string; content: string }> {
  return assembled.messages.map((m) => ({
    role: m.role,
    content: m.content,
  }));
}

/**
 * Convert assembled prompt to Anthropic API format.
 *
 * @param assembled - The assembled prompt
 * @returns Object with system and messages for Anthropic API
 */
export function toAnthropicFormat(assembled: AssembledPrompt): {
  system?: string;
  messages: Array<{ role: "user" | "assistant"; content: string }>;
} {
  const systemMessages: string[] = [];
  const messages: Array<{ role: "user" | "assistant"; content: string }> = [];

  for (const m of assembled.messages) {
    if (m.role === "system") {
      systemMessages.push(m.content);
    } else if (m.role === "user" || m.role === "assistant") {
      messages.push({
        role: m.role,
        content: m.content,
      });
    }
  }

  return {
    system: systemMessages.length > 0 ? systemMessages.join("\n\n") : undefined,
    messages,
  };
}

/**
 * Create a simple assembled prompt from a single string.
 *
 * @param prompt - The prompt string
 * @param model - Model for token estimation
 * @returns Assembled prompt
 */
export function fromString(prompt: string, model = "gpt-4o"): AssembledPrompt {
  return assemble({ user: prompt }, model);
}

/**
 * Merge multiple assembled prompts into one.
 * Useful for multi-turn conversations.
 *
 * @param prompts - Array of assembled prompts to merge
 * @param model - Model for token estimation
 * @returns Merged assembled prompt
 */
export function merge(
  prompts: AssembledPrompt[],
  model = "gpt-4o"
): AssembledPrompt {
  if (prompts.length === 0) {
    throw new Error("Cannot merge empty prompt array");
  }

  if (prompts.length === 1) {
    return prompts[0];
  }

  const allMessages: AssembledMessage[] = [];
  const allHashes: string[] = [];

  for (const prompt of prompts) {
    allMessages.push(...prompt.messages);
    allHashes.push(prompt.prompt_hash);
  }

  const combinedHash = combineHashes(allHashes);
  const totalContent = allMessages.map((m) => m.content).join("\n");
  const tokensEstimated = estimateTokens(totalContent, model);

  return {
    messages: allMessages,
    prompt_hash: combinedHash,
    tokens_estimated: tokensEstimated,
    components: prompts[0].components, // Use first prompt's components
  };
}

/**
 * Split an assembled prompt if it exceeds token limit.
 * Returns chunks that can be processed separately.
 *
 * @param assembled - The assembled prompt
 * @param maxTokens - Maximum tokens per chunk
 * @param model - Model for token estimation
 * @returns Array of prompt chunks
 */
export function splitIfNeeded(
  assembled: AssembledPrompt,
  maxTokens: number,
  model = "gpt-4o"
): AssembledPrompt[] {
  if (assembled.tokens_estimated <= maxTokens) {
    return [assembled];
  }

  // Simple split: try to keep system message, split user content
  const systemMessages = assembled.messages.filter((m) => m.role === "system");
  const otherMessages = assembled.messages.filter((m) => m.role !== "system");

  const chunks: AssembledPrompt[] = [];
  let currentChunk: AssembledMessage[] = [...systemMessages];
  let currentTokens = estimateTokens(
    systemMessages.map((m) => m.content).join("\n"),
    model
  );

  for (const message of otherMessages) {
    const messageTokens = estimateTokens(message.content, model);

    if (currentTokens + messageTokens > maxTokens && currentChunk.length > 0) {
      // Save current chunk and start new one
      chunks.push(
        createChunkAssembledPrompt(currentChunk, assembled.components, model)
      );
      currentChunk = [...systemMessages]; // Each chunk gets system messages
      currentTokens = estimateTokens(
        systemMessages.map((m) => m.content).join("\n"),
        model
      );
    }

    currentChunk.push(message);
    currentTokens += messageTokens;
  }

  // Don't forget the last chunk
  if (currentChunk.length > systemMessages.length) {
    chunks.push(
      createChunkAssembledPrompt(currentChunk, assembled.components, model)
    );
  }

  return chunks;
}

/**
 * Create an assembled prompt from a chunk of messages.
 */
function createChunkAssembledPrompt(
  messages: AssembledMessage[],
  components: AssembledPrompt["components"],
  model: string
): AssembledPrompt {
  const content = messages.map((m) => m.content).join("\n");
  const hash = computePromptHash(content, {});
  const tokens = estimateTokens(content, model);

  return {
    messages,
    prompt_hash: hash,
    tokens_estimated: tokens,
    components,
  };
}

