#!/usr/bin/env node
// Makes .repo-links/ hold a symlink to every top-level folder of the repo except website/, site/ and
// node_modules/. Docusaurus serves it as a second static directory (see staticDirectories in
// docusaurus.config.js), so /starters/p5/pipsqueak/ and /midi-helpers/p5/midi-helpers.js resolve in
// `npm start` exactly as they do on the live host. Runs before start. Before build it runs with --empty
// and leaves the folder empty: Docusaurus would copy every linked folder into build/ wholesale, local
// build output and the private planning folder included. build-site.sh lays the folders beside the
// built site instead, with its exclusions. .repo-links is git-ignored.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..');
const links = path.join(here, '.repo-links');
fs.rmSync(links, {recursive: true, force: true});
fs.mkdirSync(links);
const skip = new Set(['devices', 'website', 'site', 'node_modules', 'docs', 'pcd2026']);
if (process.argv.includes('--empty')) { console.log('.repo-links: empty (build)'); process.exit(0); }
for (const name of fs.readdirSync(root).sort()) {
  if (name.startsWith('.') || skip.has(name)) continue;
  const target = path.join(root, name);
  if (!fs.statSync(target).isDirectory()) continue;
  fs.symlinkSync(path.relative(links, target), path.join(links, name));
}
console.log(`.repo-links: ${fs.readdirSync(links).length} folders linked`);
