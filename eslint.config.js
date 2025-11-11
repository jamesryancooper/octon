// Flat config for ESLint with boundaries enforcement.
// Install deps: eslint, eslint-plugin-boundaries, @typescript-eslint/parser (optional).
// Lint scripts in each package create JSON reports under reports/ for Turbo caching.

// eslint-disable-next-line import/no-extraneous-dependencies
import boundaries from 'eslint-plugin-boundaries';

export default [
  {
    files: ['**/*.{ts,tsx,js,jsx}'],
    plugins: { boundaries },
    settings: {
      'boundaries/elements': [
        { type: 'domain', pattern: 'packages/domain/**' },
        { type: 'adapters', pattern: 'packages/adapters/**' },
        { type: 'contracts', pattern: 'packages/contracts/**' },
        { type: 'config', pattern: 'packages/config/**' },
        { type: 'ui', pattern: 'packages/ui/**' },
        { type: 'app', pattern: 'apps/**' }
      ]
    },
    rules: {
      'boundaries/element-types': [
        'error',
        {
          default: 'disallow',
          rules: [
            { from: 'domain', allow: [] },
            { from: 'adapters', allow: ['domain', 'contracts', 'config'] },
            { from: 'ui', allow: ['config'] },
            { from: 'app', allow: ['domain', 'adapters', 'contracts', 'ui', 'config'] },
            { from: 'contracts', allow: [] },
            { from: 'config', allow: [] }
          ]
        }
      ]
    }
  }
];

