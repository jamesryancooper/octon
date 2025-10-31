import type { StarlightUserConfig } from '@astrojs/starlight/types';

/**
 * Minimal Starlight configuration. Sidebar items link to existing docs content.
 */
const starlightConfig: StarlightUserConfig = {
  title: 'Harmony Docs',
  description: 'Guides, architecture, and references for the Harmony monorepo.',
  customCss: ['/src/styles/tailwind.css'],
  sidebar: [
    {
      label: 'Getting Started',
      items: [{ label: 'Overview', link: '/index' }],
    },
    {
      label: 'Handbook',
      autogenerate: { directory: 'handbook' },
    },
    {
      label: 'References',
      items: [{ label: 'OpenAPI', link: '/reference/api' }],
    },
  ],
  social: [{ label: 'GitHub', icon: 'github', href: 'https://github.com/your-org/harmony' }],
};

export default starlightConfig;

