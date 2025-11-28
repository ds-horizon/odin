/**
 * Documentation Navigation Configuration
 * Defines the sidebar structure for documentation pages
 */

export interface NavItem {
  title: string;
  href: string;
}

export interface NavSection {
  title: string;
  items: NavItem[];
}

export const navigation: NavSection[] = [
  {
    title: 'Introduction',
    items: [
      { title: 'Overview', href: '/odin/docs/introduction/overview' },
      { title: 'Getting Started', href: '/odin/docs/introduction/getting-started' },
      { title: 'Installation FAQ', href: '/odin/docs/introduction/installation-faq' },
      { title: 'Helm Parameters', href: '/odin/docs/introduction/helm-parameters' },
    ],
  },
  {
    title: 'Key Concepts',
    items: [
      { title: 'Overview', href: '/odin/docs/concepts/overview' },
      { title: 'Service', href: '/odin/docs/concepts/service' },
      { title: 'Component', href: '/odin/docs/concepts/component' },
      { title: 'Environment', href: '/odin/docs/concepts/environment' },
      { title: 'Provisioning', href: '/odin/docs/concepts/provisioning' },
    ],
  },
  {
    title: 'CLI Reference',
    items: [
      { title: 'Command Reference', href: '/odin/docs/cli/reference' },
    ],
  },
  {
    title: 'How-To Guides',
    items: [
      { title: 'Overview', href: '/odin/docs/howto/overview' },
      { title: 'Deploy First Service', href: '/odin/docs/howto/deploy-first-service' },
      { title: 'Dev/QA Iteration', href: '/odin/docs/howto/dev-qa-iteration' },
    ],
  },
  {
    title: 'Reference',
    items: [
      { title: 'Troubleshooting', href: '/odin/docs/reference/troubleshooting' },
      { title: 'FAQ', href: '/odin/docs/faq' },
      { title: 'Roadmap', href: '/odin/docs/roadmap' },
    ],
  },
];

