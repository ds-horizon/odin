import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
  site: 'https://ds-horizon.github.io/odin/',
  base: '/odin/',
  integrations: [
    starlight({
      title: 'Odin',
      description: 'Odin - CLI-based platform to accelerate your software development lifecycle',
      favicon: '/odin-logo.png',
      logo: {
        src: './src/assets/odin-logo.png',
      },
      head: [
        {
          tag: 'script',
          attrs: {
            src: 'https://www.googletagmanager.com/gtag/js?id=G-SJ0LD5F754',
            async: true,
          },
        },
        {
          tag: 'script',
          content: `
            window.dataLayer = window.dataLayer || [];
            function gtag(){dataLayer.push(arguments);}
            gtag('js', new Date());
            gtag('config', 'G-SJ0LD5F754');
          `,
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
