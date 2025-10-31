// Import OpenTelemetry bootstrap early so it instruments the process.
import initializeInstrumentation from '@infra/otel/instrumentation';

import fastify from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';

import { log, withTrace } from './log';
import { listFlags } from '@harmony/config';
import { HealthAdapter } from '@adapters/src/index';

const DEFAULT_PORT = 3000;

type HealthOkDTO = { ok: true; uptimeMs: number };
type HealthErrorDTO = { ok: false; error: string };
type HealthResponseDTO = HealthOkDTO | HealthErrorDTO;

type FlagsResponseDTO = Readonly<Record<string, boolean>>;
type VersionResponseDTO = { version: string };

/**
 * Builds and starts the HTTP API server.
 *
 * Responsibilities:
 * - HTTP concerns (routing, security headers, CORS).
 * - Application orchestration (wire Domain + Adapters).
 * - Cross-cutting (logging with trace correlation, metrics via OTel).
 *
 * Business logic and integration details are delegated to Domain/Adapters layers.
 *
 * @param port - The port to bind to (defaults to `DEFAULT_PORT`).
 */
async function startServer(port: number = DEFAULT_PORT): Promise<void> {
  await initializeInstrumentation();
  const app = fastify({ logger: false });

  await app.register(helmet, { global: true });
  await app.register(cors, { origin: true });

  app.get('/health', async (_, reply): Promise<HealthResponseDTO> => {
    const l = withTrace({ route: 'GET /health' });
    try {
      const health = new HealthAdapter();
      const ok = await health.check();
      if (!ok) {
        l.warn('Health check failed');
        reply.code(503);
        return { ok: false, error: 'unhealthy' };
      }
      const uptimeMs = Math.round(process.uptime() * 1000);
      l.info({ uptimeMs }, 'Health check OK');
      return { ok: true, uptimeMs };
    } catch (err) {
      l.error({ err }, 'Health check error');
      reply.code(500);
      return { ok: false, error: 'internal_error' };
    }
  });

  app.get('/flags', async (): Promise<FlagsResponseDTO> => {
    const l = withTrace({ route: 'GET /flags' });
    const flags = listFlags();
    l.debug({ flags }, 'Flags snapshot');
    return flags;
  });

  app.get('/version', async (): Promise<VersionResponseDTO> => {
    const version = process.env.APP_VERSION || process.env.npm_package_version || '0.0.0-dev';
    return { version };
  });

  app.get('/v1/ping', async () => ({ pong: true as const }));

  const host = process.env.HOST || '0.0.0.0';
  await app.listen({ port, host });

  const l = withTrace({ svc: 'api' });
  l.info({ port, host }, 'API server listening');

  const shutdown = async (signal: string) => {
    const sLog = withTrace({ signal });
    sLog.info('Shutting down...');
    try {
      await app.close();
      sLog.info('Shutdown complete');
      process.exit(0);
    } catch (err) {
      sLog.error({ err }, 'Shutdown error');
      process.exit(1);
    }
  };
  process.on('SIGINT', () => void shutdown('SIGINT'));
  process.on('SIGTERM', () => void shutdown('SIGTERM'));
}

export default startServer;

// Auto-start in typical runtime.
startServer(Number(process.env.PORT) || DEFAULT_PORT).catch((err) => {
  // eslint-disable-next-line no-console
  console.error(err);
  process.exit(1);
});
