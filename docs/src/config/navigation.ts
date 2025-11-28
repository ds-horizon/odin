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
      { title: 'Data Model', href: '/odin/docs/concepts/data-model' },
      { title: 'Advanced Concepts', href: '/odin/docs/concepts/advanced/overview' },
    ],
  },
  {
    title: 'CLI Reference',
    items: [
      { title: 'Command Reference', href: '/odin/docs/cli/reference' },
      { title: 'Datagen Reference', href: '/odin/docs/cli/datagen-reference' },
      { title: 'Datagenc Reference', href: '/odin/docs/cli/datagenc-reference' },
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
    title: 'Examples',
    items: [
      { title: 'Fields Overview', href: '/odin/docs/examples/1_fields/fields-overview' },
      {
        title: 'Single Field Model',
        href: '/odin/docs/examples/1_fields/single_field_model/single-field-model',
      },
      {
        title: 'Multi Field Model',
        href: '/odin/docs/examples/1_fields/multi_field_model/multi-field-model',
      },
      { title: 'Function Calls', href: '/odin/docs/examples/2_calls/calls' },
      { title: 'Miscellaneous', href: '/odin/docs/examples/3_misc/misc' },
      { title: 'Iter Variable', href: '/odin/docs/examples/4_iter/iter' },
      { title: 'References', href: '/odin/docs/examples/5_reference/reference' },
      { title: 'Metadata Overview', href: '/odin/docs/examples/6_metadata/metadata-overview' },
      { title: 'Tags', href: '/odin/docs/examples/6_metadata/tags/tags' },
      { title: 'Count', href: '/odin/docs/examples/6_metadata/count/count' },
    ],
  },
  {
    title: 'Language',
    items: [
      { title: 'DSL Specification', href: '/odin/docs/language/dsl-specification' },
      { title: 'Built-in Functions', href: '/odin/docs/language/built-in-functions' },
    ],
  },
  {
    title: 'Sinks',
    items: [
      { title: 'Overview', href: '/odin/docs/sinks/overview' },
      { title: 'MySQL', href: '/odin/docs/sinks/mysql' },
      { title: 'Configuration', href: '/odin/docs/sinks/config' },
    ],
  },
  {
    title: 'Reference',
    items: [
      { title: 'Datagenc vs Datagen', href: '/odin/docs/reference/datagenc-vs-datagen' },
      { title: 'Troubleshooting', href: '/odin/docs/reference/troubleshooting' },
      { title: 'FAQ', href: '/odin/docs/faq' },
      { title: 'Roadmap', href: '/odin/docs/roadmap' },
    ],
  },
];

