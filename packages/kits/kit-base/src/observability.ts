/**
 * Observability bootstrap helpers for Harmony Kits.
 *
 * Provides OpenTelemetry integration with:
 * - Standardized span naming (kit.<kit>.<action>)
 * - Required attributes per methodology
 * - Offline buffering support
 * - Span event helpers
 */

import {
  trace,
  context,
  SpanKind,
  SpanStatusCode,
  type Tracer,
  type Span,
  type SpanOptions,
  type Context,
} from "@opentelemetry/api";
import type { LifecycleStage, KitState } from "./types.js";

/**
 * Required resource attributes for kit observability.
 */
export interface KitResourceAttributes {
  "service.name": string;
  "service.version": string;
  "deployment.environment": string;
  "harmony.repo"?: string;
  "harmony.branch"?: string;
}

/**
 * Required span attributes for kit operations.
 */
export interface KitSpanAttributes {
  "run.id": string;
  "kit.name": string;
  "kit.version": string;
  stage: LifecycleStage;
  "git.sha"?: string;
  repo?: string;
  branch?: string;
}

/**
 * AI-specific span attributes.
 */
export interface AISpanAttributes {
  "ai.provider": string;
  "ai.model": string;
  "ai.version"?: string;
  "ai.temperature"?: number;
  "ai.top_p"?: number;
  "ai.seed"?: number | string;
  prompt_hash?: string;
}

/**
 * Policy/Eval span attributes.
 */
export interface PolicyEvalAttributes {
  "policy.ruleset"?: string;
  "policy.result"?: "pass" | "fail";
  "eval.suite"?: string;
  "eval.score"?: number;
  "eval.threshold"?: number;
}

/**
 * Span event types per methodology.
 */
export type SpanEventType =
  | "state.enter"
  | "inputs.validated"
  | "artifact.write"
  | "gate.pass"
  | "gate.block"
  | "hitl.requested"
  | "hitl.approved"
  | "hitl.rejected"
  | "hitl.waived"
  | "error"
  | "policy.fail"
  | "eval.fail"
  | "flag.toggle";

/**
 * Configuration for kit observability.
 */
export interface ObservabilityConfig {
  /** Kit name for service naming */
  kitName: string;

  /** Kit version */
  kitVersion: string;

  /** Enable offline buffering when OTLP endpoint is unreachable */
  enableOfflineBuffer?: boolean;

  /** Custom tracer name override */
  tracerName?: string;
}

/**
 * Get the standard service name for a kit.
 */
export function getServiceName(kitName: string): string {
  return `harmony.kit.${kitName}`;
}

/**
 * Get or create a tracer for a kit.
 */
export function getKitTracer(config: ObservabilityConfig): Tracer {
  const tracerName = config.tracerName || getServiceName(config.kitName);
  return trace.getTracer(tracerName, config.kitVersion);
}

/**
 * Create standard span options for kit operations.
 */
export function createSpanOptions(
  attributes: KitSpanAttributes,
  kind: SpanKind = SpanKind.INTERNAL
): SpanOptions {
  return {
    kind,
    attributes: {
      ...attributes,
    },
  };
}

/**
 * Context for kit span operations.
 */
export interface KitSpanContext {
  tracer: Tracer;
  parentContext?: Context;
  kitName: string;
  kitVersion: string;
}

/**
 * Create a kit span with standard naming.
 *
 * Span name format: kit.<kitName>.<action>
 */
export function createKitSpan(
  ctx: KitSpanContext,
  action: string,
  attributes: Partial<KitSpanAttributes> & Record<string, unknown>,
  options?: SpanOptions
): Span {
  const spanName = `kit.${ctx.kitName}.${action}`;
  const spanOptions: SpanOptions = {
    ...options,
    attributes: {
      "kit.name": ctx.kitName,
      "kit.version": ctx.kitVersion,
      ...attributes,
      ...options?.attributes,
    },
  };

  const parentContext = ctx.parentContext || context.active();
  return ctx.tracer.startSpan(spanName, spanOptions, parentContext);
}

/**
 * Execute a function within a kit span.
 */
export async function withKitSpan<T>(
  ctx: KitSpanContext,
  action: string,
  attributes: Partial<KitSpanAttributes> & Record<string, unknown>,
  fn: (span: Span) => Promise<T>
): Promise<T> {
  const span = createKitSpan(ctx, action, attributes);

  try {
    const result = await context.with(
      trace.setSpan(ctx.parentContext || context.active(), span),
      () => fn(span)
    );
    span.setStatus({ code: SpanStatusCode.OK });
    return result;
  } catch (error) {
    span.setStatus({
      code: SpanStatusCode.ERROR,
      message: error instanceof Error ? error.message : "Unknown error",
    });
    span.recordException(error instanceof Error ? error : new Error(String(error)));
    throw error;
  } finally {
    span.end();
  }
}

/**
 * Emit a standardized span event.
 */
export function emitSpanEvent(
  span: Span,
  eventType: SpanEventType,
  data: Record<string, unknown>
): void {
  span.addEvent(eventType, data as import("@opentelemetry/api").Attributes);
}

/**
 * Emit a state transition event.
 */
export function emitStateTransition(
  span: Span,
  from: KitState,
  to: KitState
): void {
  emitSpanEvent(span, "state.enter", { from, to });
  span.setAttribute("kit.state", to);
}

/**
 * Emit an artifact write event.
 */
export function emitArtifactWrite(
  span: Span,
  path: string,
  kind: string
): void {
  emitSpanEvent(span, "artifact.write", { path, kind });
}

/**
 * Emit a gate result event.
 */
export function emitGateResult(
  span: Span,
  gate: string,
  passed: boolean,
  reason?: string
): void {
  emitSpanEvent(span, passed ? "gate.pass" : "gate.block", {
    gate,
    reason: reason || (passed ? "passed" : "blocked"),
  });
}

/**
 * Emit a HITL event.
 */
export function emitHITLEvent(
  span: Span,
  eventType: "hitl.requested" | "hitl.approved" | "hitl.rejected" | "hitl.waived",
  checkpoint: string,
  approver?: string
): void {
  emitSpanEvent(span, eventType, { checkpoint, approver });
}

/**
 * Emit a policy failure event.
 */
export function emitPolicyFail(
  span: Span,
  ruleset: string,
  policyId: string
): void {
  emitSpanEvent(span, "policy.fail", { ruleset, id: policyId });
}

/**
 * Emit an evaluation failure event.
 */
export function emitEvalFail(
  span: Span,
  suite: string,
  score: number,
  threshold: number
): void {
  emitSpanEvent(span, "eval.fail", { suite, score, threshold });
}

/**
 * Get required span attributes for a kit operation.
 */
export function getRequiredAttributes(
  kitName: string,
  kitVersion: string,
  runId: string,
  stage: LifecycleStage
): KitSpanAttributes {
  return {
    "run.id": runId,
    "kit.name": kitName,
    "kit.version": kitVersion,
    stage,
  };
}

/**
 * Add AI attributes to a span.
 */
export function addAIAttributes(
  span: Span,
  attributes: AISpanAttributes
): void {
  span.setAttributes({
    "ai.provider": attributes["ai.provider"],
    "ai.model": attributes["ai.model"],
    ...(attributes["ai.version"] && { "ai.version": attributes["ai.version"] }),
    ...(attributes["ai.temperature"] !== undefined && {
      "ai.temperature": attributes["ai.temperature"],
    }),
    ...(attributes["ai.top_p"] !== undefined && {
      "ai.top_p": attributes["ai.top_p"],
    }),
    ...(attributes["ai.seed"] !== undefined && {
      "ai.seed": attributes["ai.seed"],
    }),
    ...(attributes.prompt_hash && { prompt_hash: attributes.prompt_hash }),
  });
}

/**
 * Add policy/eval attributes to a span.
 */
export function addPolicyEvalAttributes(
  span: Span,
  attributes: PolicyEvalAttributes
): void {
  if (attributes["policy.ruleset"]) {
    span.setAttribute("policy.ruleset", attributes["policy.ruleset"]);
  }
  if (attributes["policy.result"]) {
    span.setAttribute("policy.result", attributes["policy.result"]);
  }
  if (attributes["eval.suite"]) {
    span.setAttribute("eval.suite", attributes["eval.suite"]);
  }
  if (attributes["eval.score"] !== undefined) {
    span.setAttribute("eval.score", attributes["eval.score"]);
  }
  if (attributes["eval.threshold"] !== undefined) {
    span.setAttribute("eval.threshold", attributes["eval.threshold"]);
  }
}

/**
 * Buffer for offline telemetry storage.
 */
export interface OfflineBuffer {
  spans: Array<{
    name: string;
    attributes: Record<string, unknown>;
    events: Array<{ name: string; attributes: Record<string, unknown> }>;
    startTime: number;
    endTime: number;
    status: { code: number; message?: string };
  }>;
  logs: Array<Record<string, unknown>>;
}

/**
 * Create an empty offline buffer.
 */
export function createOfflineBuffer(): OfflineBuffer {
  return {
    spans: [],
    logs: [],
  };
}

/**
 * Check if OTLP endpoint is reachable.
 */
export async function isOTLPReachable(
  endpoint: string = process.env.OTEL_EXPORTER_OTLP_ENDPOINT || "http://localhost:4318"
): Promise<boolean> {
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 2000);

    const response = await fetch(endpoint, {
      method: "HEAD",
      signal: controller.signal,
    });

    clearTimeout(timeoutId);
    return response.ok || response.status === 405; // 405 is OK for HEAD on OTLP
  } catch {
    return false;
  }
}

/**
 * Get the current trace ID from context.
 */
export function getCurrentTraceId(): string | undefined {
  const span = trace.getActiveSpan();
  if (span) {
    return span.spanContext().traceId;
  }
  return undefined;
}

/**
 * Get the current span ID from context.
 */
export function getCurrentSpanId(): string | undefined {
  const span = trace.getActiveSpan();
  if (span) {
    return span.spanContext().spanId;
  }
  return undefined;
}

