import pino from 'pino';
import { context, trace } from '@opentelemetry/api';

export const log = pino({ level: process.env.LOG_LEVEL || 'info' });

export function withTrace(fields: Record<string, unknown> = {}) {
  const span = trace.getSpan(context.active());
  const traceId = span?.spanContext().traceId;
  return log.child(traceId ? { traceId, ...fields } : fields);
}
