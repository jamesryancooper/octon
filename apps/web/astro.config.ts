import { defineConfig } from 'astro/config';
import react from '@astrojs/react';

// https://docs.astro.build/reference/configuration-reference/
export default defineConfig({
  integrations: [react()]
});

