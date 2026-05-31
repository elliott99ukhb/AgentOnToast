import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://elliott99ukhb.github.io/CopilotOnToast',
  base: '/CopilotOnToast',
  integrations: [
    starlight({
      title: 'CopilotOnToast 🍞 macOS',
      description: 'Native macOS notifications for GitHub Copilot CLI — get notified when your agent finishes, needs approval, hits an error, and more.',
      social: {
        github: 'https://github.com/elliott99ukhb/CopilotOnToast',
      },
      editLink: {
        baseUrl: 'https://github.com/elliott99ukhb/CopilotOnToast/edit/macos/docs/',
      },
      sidebar: [
        { label: 'Getting Started', slug: 'getting-started' },
        {
          label: 'Guides',
          items: [
            { label: 'Configuration', slug: 'guides/configuration' },
          ],
        },
        {
          label: 'Reference',
          items: [
            { label: 'Events', slug: 'reference/events' },
          ],
        },
      ],
      head: [
        {
          tag: 'meta',
          attrs: { property: 'og:image', content: 'https://raw.githubusercontent.com/elliott99ukhb/CopilotOnToast/macos/docs/src/assets/copilot-icon.png' },
        },
      ],
    }),
  ],
});
