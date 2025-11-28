import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';

// https://astro.build/config
export default defineConfig({
  site: 'https://ds-horizon.github.io/odin/',
  base: '/odin/',
  build: {
    format: 'directory', // Ensures clean URLs
  },
  integrations: [mdx()],
  markdown: {
    syntaxHighlight: 'shiki',
    shikiConfig: {
      theme: 'github-light',
      themes: {
        light: 'github-light',
        dark: 'github-dark',
      },
    },
  },
  server: {
    port: 4321,
    host: true,
  },
});
