const otlpEndpoint = process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4318';

let initializationPromise: Promise<void> | null = null;

/**
 * Boots the OpenTelemetry Node SDK exactly once for the current process.
 *
 * Consumers must `await` this function before initializing HTTP servers so
 * instrumentation is registered prior to handling traffic.
 */
export async function initializeInstrumentation(): Promise<void> {
  if (!initializationPromise) {
    initializationPromise = (async () => {
      try {
        // eslint-disable-next-line no-new-func
        const dynImport = new Function('m', 'return import(m)');

        const [{ NodeSDK }, { getNodeAutoInstrumentations }, { OTLPTraceExporter }, { OTLPMetricExporter }, { PeriodicExportingMetricReader }] = await Promise.all([
          dynImport('@opentelemetry/sdk-node'),
          dynImport('@opentelemetry/auto-instrumentations-node'),
          dynImport('@opentelemetry/exporter-trace-otlp-proto'),
          dynImport('@opentelemetry/exporter-metrics-otlp-proto'),
          dynImport('@opentelemetry/sdk-metrics')
        ]);

        const sdk = new NodeSDK({
          traceExporter: new OTLPTraceExporter({ url: `${otlpEndpoint}/v1/traces` }),
          metricReader: new PeriodicExportingMetricReader({
            exporter: new OTLPMetricExporter({ url: `${otlpEndpoint}/v1/metrics` })
          }),
          instrumentations: [getNodeAutoInstrumentations()]
        });

        // Some versions of @opentelemetry/sdk-node expose start() returning void rather than Promise.
        await Promise.resolve(sdk.start() as unknown as Promise<void>);
      } catch (err) {
        // eslint-disable-next-line no-console
        console.error('OTel init error', err);
        initializationPromise = null;
      }
    })();
  }

  const activeInitialization = initializationPromise;
  if (!activeInitialization) {
    return;
  }

  await activeInitialization;
}

export default initializeInstrumentation;

