import Fastify from 'fastify';
import { withTrace } from './log.js';
import { hello } from '@domain/index.js';

const app = Fastify({ logger: false });

app.get('/health', async () => ({ ok: true }));
app.get('/hello', async (req, reply) => {
  const msg = hello('world');
  withTrace().info({ route: '/hello' }, 'hello invoked');
  return reply.send({ message: msg });
});

const port = Number(process.env.PORT || 3001);
app.listen({ port, host: '0.0.0.0' }).then(() => {
  withTrace().info({ port }, `api listening`);
}).catch((err) => {
  withTrace().error({ err }, 'api failed to start');
  process.exit(1);
});
