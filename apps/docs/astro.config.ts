import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import type { AstroIntegration } from 'astro';
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import starlight from '@astrojs/starlight';

import starlightConfig from './starlight.config';

const OPENAPI_SOURCE_RELATIVE_PATH = '../../packages/contracts/openapi.yaml';
const OPENAPI_PUBLIC_RELATIVE_PATH = './public/openapi/openapi.yaml';

/**
 * Copy the OpenAPI specification so Scalar can load it from the built docs site.
 */
const copyOpenApiSpec = (): void => {
  const sourcePath = fileURLToPath(new URL(OPENAPI_SOURCE_RELATIVE_PATH, import.meta.url));
  const destinationPath = fileURLToPath(new URL(OPENAPI_PUBLIC_RELATIVE_PATH, import.meta.url));
  fs.mkdirSync(path.dirname(destinationPath), { recursive: true });
  fs.copyFileSync(sourcePath, destinationPath);
};

/**
 * Astro integration ensuring the OpenAPI spec is present under the docs public directory.
 */
const harmonyOpenApiIntegration = (): AstroIntegration => {
  let watcher: fs.FSWatcher | undefined;
  return {
    name: 'harmony-openapi-copy',
    hooks: {
      'astro:config:setup': (hookContext) => {
        const sourcePath = fileURLToPath(new URL(OPENAPI_SOURCE_RELATIVE_PATH, import.meta.url));
        copyOpenApiSpec();
        hookContext.addWatchFile(sourcePath);
      },
      'astro:server:setup': (hookContext) => {
        const sourcePath = fileURLToPath(new URL(OPENAPI_SOURCE_RELATIVE_PATH, import.meta.url));
        watcher = fs.watch(sourcePath, () => {
          copyOpenApiSpec();
          hookContext.logger.info('Copied latest OpenAPI spec for docs.');
        });
      },
      'astro:server:done': () => {
        watcher?.close();
      },
      'astro:build:start': () => {
        copyOpenApiSpec();
      },
    },
  };
};


/**
 * Astro configuration for the Harmony documentation app.
 * Starlight keeps content Markdown-first while enabling robust nav and search.
 */
export default defineConfig({
  site: 'https://docs.example.com',
  integrations: [react(), starlight(starlightConfig), harmonyOpenApiIntegration()],
});

