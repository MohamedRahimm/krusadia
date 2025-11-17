import { defineConfig } from 'vite';

// https://vitejs.dev/config/
export default defineConfig({
  base:"./",
  build: {
    outDir: '../../dist/client',
    assetsDir: "", // don’t put files in /assets
    emptyOutDir: true,
    sourcemap: true,
    rollupOptions: {
      input:"index.html",
      output: {
        entryFileNames: '[name].js',
        chunkFileNames: '[name].js',
        assetFileNames: '[name][extname]',
        sourcemapFileNames: '[name].js.map',
      },
    },
  },
  assetsInclude: [
    "**/*.wasm",
    "**/*.pck",
    "**/*.worklet.js",
    "**/*.br"
  ],
});
