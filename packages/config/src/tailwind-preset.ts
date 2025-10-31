import type { Config } from 'tailwindcss';

/**
 * Shared Tailwind preset used by Harmony applications and UI packages.
 *
 * @remarks
 *  - Centralizes tokens (colors, radii) to keep styling consistent.
 *  - Consumers should extend this preset rather than redefining tokens locally.
 */
const tailwindPreset: Config = {
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        background: 'rgb(var(--background))',
        foreground: 'rgb(var(--foreground))'
      },
      borderRadius: {
        sm: 'var(--radius-sm)',
        DEFAULT: 'var(--radius-md)',
        lg: 'var(--radius-lg)'
      }
    }
  }
};

export default tailwindPreset;


