import boundaries from "eslint-plugin-boundaries";

/** @type {import('eslint').Linter.Config[]} */
export default [{
  ignores: [
    "node_modules",
    "dist",
    "build",
    ".turbo",
    ".next"
  ],
  plugins: { boundaries },
  languageOptions: {
    ecmaVersion: "latest",
    sourceType: "module"
  },
  settings: {
    'boundaries/elements': [
      { type: 'domain',   pattern: 'packages/domain/**' },
      { type: 'adapters', pattern: 'packages/adapters/**' },
      { type: 'contracts',pattern: 'packages/contracts/**' },
      { type: 'ui',       pattern: 'packages/ui-kit/**' },
      { type: 'app',      pattern: 'apps/**' }
    ]
  },
  rules: {
    'boundaries/element-types': [ 'error', {
      default: 'disallow',
      rules: [
        { from: 'domain',   allow: [] },
        { from: 'adapters', allow: ['domain','contracts'] },
        { from: 'ui',       allow: [] },
        { from: 'app',      allow: ['domain','adapters','contracts','ui'] }
      ]
    }]
  }
}];
