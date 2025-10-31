import type { Config } from 'tailwindcss';
import tailwindPreset from '@harmony/config/tailwind-preset';

const config: Config = {
  presets: [tailwindPreset],
  darkMode: 'class',
  content: [
    './app/**/*.{ts,tsx,js,jsx}',
    './actions/**/*.{ts,tsx,js,jsx}',
    '../../packages/ui-kit/src/**/*.{ts,tsx}'
  ]
};

export default config;


