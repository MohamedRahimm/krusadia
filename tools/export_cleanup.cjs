const fs = require('fs');
const path = require('path');
const { rimraf } = require('rimraf');
const EXPORT_DIR = path.join(__dirname, '../godot/export');
const CLIENT_DIR = path.join(__dirname, '../src/client');
const PUBLIC_DIR = path.join(__dirname, '../src/client/public');

const directories = [EXPORT_DIR, CLIENT_DIR, PUBLIC_DIR];
for (const directory of directories) {
  if (!fs.existsSync(directory)) throw Error('Missing Directory');
}
if (fs.readdirSync(EXPORT_DIR).length === 0) {
  console.log('Export Directory Empty, Skipping Export Process');
  process.exit(0);
}
//Clean Client Directory
rimraf.rimraf('"src/client/*.*" "src/client/public/*.*"', { glob: true });

/*
Move Files Into Client Directory and Format them
*/
let inlineJsContent = '';
function processHtmlFile(srcPath) {
  let html = fs.readFileSync(srcPath, 'utf-8');

  const scriptRegex = /<script\b([^>]*)>([\s\S]*?)<\/script>/gi;

  html = html.replace(scriptRegex, (match, attrs, code) => {
    const hasSrc = /src\s*=\s*["'][^"']+["']/.test(attrs);
    const hasType = /type\s*=\s*["'][^"']+["']/.test(attrs);

    let newAttrs = attrs;
    if (!hasType) {
      newAttrs = attrs.trim() + ' type="module"';
    }

    if (hasSrc) {
      return `<script ${newAttrs}>${code}</script>`;
    }

    const trimmed = code.trim();
    if (trimmed.length > 0) {
      inlineJsContent += trimmed + '\n\n';
    }

    return `<script src="inlinejs.js" type="module"></script>`;
  });

  const destHtmlPath = path.join(CLIENT_DIR, 'index.html');
  fs.writeFileSync(destHtmlPath, html, 'utf-8');

  if (inlineJsContent.length > 0) {
    const inlineJsPath = path.join(CLIENT_DIR, 'inlinejs.js');
    fs.writeFileSync(inlineJsPath, inlineJsContent, 'utf-8');
  }
}

const files = fs.readdirSync(EXPORT_DIR);
files.forEach((file) => {
  const srcPath = path.join(EXPORT_DIR, file);
  const ext = path.extname(file).toLowerCase();

  if (ext === '.js') {
    if(file.includes(".worklet")) fs.renameSync(srcPath,path.join(PUBLIC_DIR,file))
    else fs.renameSync(srcPath, path.join(CLIENT_DIR, file));
  } else if (ext === '.html') {
    processHtmlFile(srcPath);
    fs.unlinkSync(srcPath);
  } else {
    fs.renameSync(srcPath, path.join(PUBLIC_DIR, file));
  }
});
function writeViteConfig() {
  const viteConfig = `
import { defineConfig } from 'vite';

// https://vitejs.dev/config/
export default defineConfig({
  base:"./",
  build: {
    outDir: '../../dist/client',
    assetsDir: "", 
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
`;

  fs.writeFileSync(path.join(CLIENT_DIR, 'vite.config.ts'), viteConfig.trim(), 'utf-8');
}
writeViteConfig();
//Clean Export Directory
rimraf.rimraf('rimraf godot/export/*', { glob: true });
console.log('Files moved');
