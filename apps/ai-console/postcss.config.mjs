import autoprefixer from 'autoprefixer';
import postcssPresetEnv from 'postcss-preset-env';

// Tailwind processing is disabled for this app; styles come from prebuilt ui-kit CSS.
export default {
  plugins: [postcssPresetEnv(), autoprefixer()]
};
