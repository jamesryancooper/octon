import tailwindPreset from '@harmony/config/tailwind-preset';
import type { Config } from 'tailwindcss';

const config: Config = {
  presets: [tailwindPreset],
  content: ['./src/**/*.{ts,tsx}'],
  darkMode: tailwindPreset.darkMode ?? 'class'
};

export default config;


