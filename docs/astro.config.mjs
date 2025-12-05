import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';

// https://astro.build/config
export default defineConfig({
  site: 'https://dream-horizon-org.github.io/odin/',
  base: '/odin/',
  build: {
    format: 'directory', // Ensures clean URLs
  },
  integrations: [mdx()],
  server: {
    port: 4321,
    host: true,
  },
});
