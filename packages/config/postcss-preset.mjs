import tailwindcss from '@tailwindcss/postcss';
import autoprefixer from 'autoprefixer';
import postcssPresetEnv from 'postcss-preset-env';

/**
 * Shared PostCSS plugin chain for Harmony projects.
 *
 * Consumers can import this file directly to keep Tailwind + PostCSS
 * configuration consistent across the monorepo.
 */
export default {
  plugins: [postcssPresetEnv(), tailwindcss(), autoprefixer()]
};


