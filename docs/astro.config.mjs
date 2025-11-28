import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
  site: 'https://ds-horizon.github.io/odin/',
  base: '/odin/',
  build: {
    format: 'directory', // Ensures clean URLs
  },
  integrations: [
    starlight({
      title: 'Odin',
      description: 'Odin - CLI-based platform to accelerate your software development lifecycle',
      favicon: '/odin-logo.png',
      logo: {
        src: './src/assets/odin-logo.png',
      },
      components: {
        Head: './src/components/starlight/Head.astro',
        Header: './src/components/starlight/Header.astro',
        PageFrame: './src/components/starlight/PageFrame.astro',
      },
      head: [
        {
          tag: 'link',
          attrs: {
            rel: 'stylesheet',
            href: 'https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Plus+Jakarta+Sans:wght@600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap',
          },
        },
      ],
      social: [
        {
          icon: 'github',
          label: 'GitHub',
          href: 'https://github.com/ds-horizon/odin',
        },
      ],
      sidebar: [
        {
          label: 'Introduction',
          items: [
            'introduction/overview',
            'introduction/getting-started',
          ],
        },
        {
          label: 'Key Concepts',
          items: [
            'concepts/overview',
            'concepts/environment',
            'concepts/service',
            'concepts/component',
            'concepts/provisioning',
          ],
        },
        {
          label: 'CLI Reference',
          items: [
            'cli/reference',
          ],
        },
        {
          label: 'How-To Guides',
          items: [
            'howto/overview',
            'howto/deploy-first-service',
            'howto/dev-qa-iteration',
          ],
        },
      ],
      customCss: ['./src/styles/custom.css'],
      tableOfContents: {
        minHeadingLevel: 2,
        maxHeadingLevel: 4,
      },
      pagination: true,
    }),
  ],
  server: {
    port: 4321,
    host: true,
  },
});
