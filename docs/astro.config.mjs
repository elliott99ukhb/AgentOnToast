import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://elliott99ukhb.github.io/AgentOnToast',
  base: '/AgentOnToast',
  integrations: [
    starlight({
      title: 'AgentOnToast 🍞',
      description: 'Native macOS notifications for GitHub Copilot CLI and Claude Code — get notified when your agent finishes, needs approval, is waiting, or hits an error.',
      social: [
        { icon: 'github', label: 'GitHub', href: 'https://github.com/elliott99ukhb/AgentOnToast' },
      ],
      editLink: {
        baseUrl: 'https://github.com/elliott99ukhb/AgentOnToast/edit/macos/docs/',
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
          attrs: { property: 'og:image', content: 'https://raw.githubusercontent.com/elliott99ukhb/AgentOnToast/macos/docs/src/assets/copilot-icon.png' },
        },
      ],
    }),
  ],
});
