import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'

export default withMermaid(defineConfig({
  title: 'Brief — working docs',
  description: 'Highlight take-home — design docs',
  lang: 'en-US',
  cleanUrls: true,
  lastUpdated: true,

  vite: {
    server: {
      host: '0.0.0.0',
      port: 5180,
      strictPort: true,
    },
  },

  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Brief', link: '/brief/ONSITE' },
    ],

    sidebar: {
      '/brief/': [
        {
          text: 'Start here',
          items: [
            { text: 'Ilwon Yoon · onsite', link: '/brief/ONSITE' },
          ],
        },
        {
          text: 'Prototype',
          items: [
            { text: 'Screen gallery', link: '/brief/gallery' },
          ],
        },
        {
          text: 'Design & scope',
          items: [
            { text: 'Assignment (original brief)', link: '/brief/ASSIGNMENT' },
            { text: 'Priorities (P0 / P1 / P2)', link: '/brief/PRIORITIES' },
            { text: 'Privacy model', link: '/brief/PRIVACY_MODEL' },
            { text: 'Privacy execution (chat panel)', link: '/brief/PRIVACY_EXECUTION' },
            { text: 'Privacy user control (filters)', link: '/brief/PRIVACY_USER_CONTROL' },
            { text: 'Privacy chat flow (the conversation)', link: '/brief/PRIVACY_CHAT_FLOW' },
            { text: 'Onboarding & trust', link: '/brief/ONBOARDING' },
          ],
        },
        {
          text: 'Scenario & data',
          items: [
            { text: 'Research dossier', link: '/brief/research-dossier' },
            { text: 'Scenario spine', link: '/brief/scenario-spine' },
            { text: '2-month history', link: '/brief/history-2mo' },
          ],
        },
        {
          text: 'Reference',
          items: [
            { text: 'Build / README', link: '/brief/README' },
          ],
        },
      ],
    },

    search: {
      provider: 'local',
    },

    outline: {
      label: 'On this page',
      level: [2, 3],
    },

    docFooter: {
      prev: 'Previous',
      next: 'Next',
    },

    lastUpdatedText: 'Last updated',
    darkModeSwitchLabel: 'Dark mode',
    sidebarMenuLabel: 'Menu',
    returnToTopLabel: 'Back to top',

    socialLinks: [
      { icon: 'github', link: 'https://github.com/ilwonyoon/markdown-preview' },
    ],
  },
}))
