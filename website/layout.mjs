#!/usr/bin/env node
// Lays the repo's folders beside the built site, the way every Worker serves them: /explorer/,
// /starters/p5/..., /midi-helpers/... Merge without replacing: devices/ and talks/ share their path with
// the /devices/ and /talks/ doc pages, and the pages must win. Used by build-site.sh; plain Node so it
// runs where rsync is missing (Cloudflare's build image).
//   node website/layout.mjs            # from the repo root
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const out = path.join(root, 'website', 'build');
if (!fs.existsSync(path.join(out, 'index.html'))) { console.error('no website/build/index.html: build the site first'); process.exit(1); }

// Folders that are not pages: the site itself, planning notes, the redirect Worker, the retired site.
const skipDirs = new Set(['website', 'node_modules', 'docs', 'pcd2026', 'site']);
// Inside a folder: dependency and build output, caches, editor litter.
const skipNames = new Set(['node_modules', '__pycache__', '.DS_Store', 'build', 'dist']);
// Loose root files that are not for the site: configs, scripts, the retired front page, private notes, personal files.
const skipFile = (f) => /^wrangler.*\.jsonc$|\.sh$/.test(f) || ['index.html', 'PLAN.md', 'RELEASE.md', 'README.public.md', 'headshot.html', 'me.jpg'].includes(f) || /^split-life.*\.html$/.test(f);

let copied = 0;
function merge(src, dst) {
  for (const e of fs.readdirSync(src, {withFileTypes: true})) {
    if (skipNames.has(e.name) || e.name.endsWith('.class')) continue;
    const s = path.join(src, e.name), d = path.join(dst, e.name);
    if (e.isDirectory()) { fs.mkdirSync(d, {recursive: true}); merge(s, d); }
    else if (e.isFile() || e.isSymbolicLink()) { if (!fs.existsSync(d)) { fs.copyFileSync(s, d); copied++; } }
  }
}
for (const e of fs.readdirSync(root, {withFileTypes: true}).sort((a, b) => a.name.localeCompare(b.name))) {
  if (e.name.startsWith('.')) continue;
  if (e.isDirectory()) { if (!skipDirs.has(e.name)) { fs.mkdirSync(path.join(out, e.name), {recursive: true}); merge(path.join(root, e.name), path.join(out, e.name)); } }
  else if (e.isFile() && !skipFile(e.name) && !fs.existsSync(path.join(out, e.name))) { fs.copyFileSync(path.join(root, e.name), path.join(out, e.name)); copied++; }
}
fs.copyFileSync(path.join(root, '.assetsignore'), path.join(out, '.assetsignore'));
console.log(`laid out ${copied} files beside the site`);
