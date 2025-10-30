export async function register(): Promise<void> {
  // Only initialize Node OTel SDK in the Node.js runtime to avoid bundling
  // Node-only deps into Edge instrumentation.
  if (process.env.NEXT_RUNTIME === 'nodejs') {
    try {
      // Use a dynamic import that the bundler can still analyze and rewrite
      // path aliases for. This ensures '@infra/*' resolves correctly while
      // keeping the import behind the Node.js runtime guard to avoid pulling
      // Node-only deps into Edge instrumentation bundles.
      const { default: initializeInstrumentation } = await import('@infra/otel/instrumentation');
      await initializeInstrumentation();
    } catch (err) {
      // eslint-disable-next-line no-console
      console.warn('OTel not initialized for ai-console:', err);
    }
  }
}


