import type { Config } from 'tailwindcss';
import tailwindPreset from '@harmony/config/tailwind-preset';

const config: Config = {
  presets: [tailwindPreset],
  darkMode: 'class',
  content: [
    './src/**/*.{astro,md,mdx,ts,tsx}',
    '../../packages/ui/src/**/*.{ts,tsx}'
  ]
};

export default config;


