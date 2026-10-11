#!/usr/bin/env node
// Re-pulls every  {/* include: SPEC */} … {/* /include */}  block in docs/**/*.md from its source file,
// so starters/, midi-helpers/README.md, explorer/README.md and IDEAS.md stay the single source of truth.
//
//   node website/refresh.mjs            # rewrite the docs, list what is still pending
//   node website/refresh.mjs --check    # report only
//   node website/refresh.mjs devices [--check] [devices/<slug> ...]
//                                       # render the device catalog (devices/<slug>/device.md + map.md) into
//                                       # docs/03-devices/<slug>.md, then refresh the includes inside those pages.
//                                       # A missing required field fails with the file name. See devices/CONTRIBUTING.md.
//   node website/refresh.mjs talks [--check] [talks/<yyyy>-<slug> ...]
//                                       # render the talks compendium (talks/<yyyy>-<slug>/talk.md, transcript.md,
//                                       # assets/, site/) into docs/07-talks/ and static/img/talks/, and rebuild the
//                                       # timeline in docs/07-talks/index.md. See talks/INDEX.md.
//
// SPEC is a path relative to the repo root, may be a glob (first match wins), and for Markdown may end
// in "#Heading text" to pull just that section. Write % instead of * when a glob would put "*/" inside the comment. Sources that do not exist yet are left alone, so the
// hand-written "pending" admonitions stay until the real file lands.
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(here, '..');
const DOCS = path.join(here, 'docs');
const CHECK = process.argv.includes('--check');
const OPEN = /\{\/\*\s*include:\s*(.+?)\s*\*\/\}/g;
const CLOSE = '{/* /include */}';
const LANG = { '.ino': 'cpp','.pde': 'java', '.java': 'java', '.py': 'python', '.pyde': 'python', '.js': 'javascript', '.html': 'html', '.sh': 'bash'};

function walk(dir) {
  return fs.readdirSync(dir, {withFileTypes: true}).flatMap((e) =>
    e.isDirectory() ? walk(path.join(dir, e.name)) : /\.mdx?$/.test(e.name) ? [path.join(dir, e.name)] : []);
}

// Tiny glob: * and ** on posix paths, relative to ROOT. Returns sorted matching files.
function glob(pattern) {
  const parts = pattern.split('/');
  let paths = [ROOT];
  for (const part of parts) {
    const next = [];
    for (const p of paths) {
      if (!fs.existsSync(p) || !fs.statSync(p).isDirectory()) continue;
      if (part.includes('*')) {
        const re = new RegExp('^' + part.split('*').map((s) => s.replace(/[.+?^${}()|[\]\\]/g, '\\$&')).join('.*') + '$');
        for (const name of fs.readdirSync(p).sort()) if (re.test(name)) next.push(path.join(p, name));
      } else {
        next.push(path.join(p, part));
      }
    }
    paths = next;
  }
  return paths.filter((p) => fs.existsSync(p) && fs.statSync(p).isFile()).sort();
}

function findSource(spec) {
  // % is an alias for * so a spec can live inside an MDX comment without forming "*/"
  const [pattern, section = ''] = spec.replace(/%/g, '*').split('#');
  const files = glob(pattern);
  return {file: files[0] || null, section};
}

// ---- Markdown → MDX-safe Markdown ---------------------------------------------------------------
function extractSection(lines, section) {
  let start = -1, level = 0, end = lines.length;
  for (let i = 0; i < lines.length; i++) {
    const m = /^(#{1,6})\s+(.*)$/.exec(lines[i]);
    if (!m) continue;
    if (start < 0) {
      if (m[2].toLowerCase().includes(section.toLowerCase())) { start = i + 1; level = m[1].length; }
    } else if (m[1].length <= level) { end = i; break; }
  }
  return start < 0 ? null : {lines: lines.slice(start, end), level};
}

function mdxSafe(md, srcDir, shift) {
  const out = [];
  let inFence = false;
  for (let line of md.split('\n')) {
    if (/^\s*(```|~~~)/.test(line)) { inFence = !inFence; out.push(line); continue; }
    if (inFence) { out.push(line); continue; }
    const h = /^(#{1,6})(\s+.*)$/.exec(line);
    if (h) line = '#'.repeat(Math.min(6, Math.max(2, h[1].length + shift))) + h[2];
    // protect inline code, then fix up the prose around it
    const spans = [];
    line = line.replace(/`[^`]*`/g, (s) => { spans.push(s); return `\u0000${spans.length - 1}\u0000`; });
    line = line.replace(/<!--.*?-->/g, '');
    line = line.replace(/<(https?:\/\/[^>\s]+)>/g, '[$1]($1)');
    line = line.replace(/\[([^\]]*)\]\(([^)\s]+)\)/g, (s, label, href) => {
      if (/^(https?:|mailto:|#|\/|pathname:)/.test(href)) return s;
      const rel = path.posix.normalize(path.posix.join(srcDir, href));
      return `[${label}](pathname:///${rel})`;
    });
    line = line.replace(/<(?!\/?(br|kbd|sub|sup)\b)/g, '\\<').replace(/\{/g, '\\{');
    line = line.replace(/\u0000(\d+)\u0000/g, (s, i) => spans[+i]);
    out.push(line);
  }
  return out.join('\n').replace(/\n{3,}/g, '\n\n').trim();
}

function render(file, section) {
  const rel = path.relative(ROOT, file).split(path.sep).join('/');
  const ext = path.extname(file).toLowerCase();
  const text = fs.readFileSync(file, 'utf8');
  if (ext === '.md' || ext === '.markdown') {
    let lines = text.split('\n'), shift = 1;
    if (section) {
      const s = extractSection(lines, section);
      if (!s) return null;
      lines = s.lines; shift = 2 - s.level;   // subsections of the pulled heading land as h3
    }
    const body = mdxSafe(lines.join('\n'), path.posix.dirname(rel), shift);
    return `{/* pulled from ${rel} by website/refresh.mjs; edit the source, not this */}\n\n${body}`;
  }
  const lang = LANG[ext] || '';
  const fence = text.includes('```') ? '````' : '```';
  return `${fence}${lang} title="${path.basename(file)}"\n${text.replace(/\s+$/, '')}\n${fence}`;
}

// ---- devices mode -------------------------------------------------------------------------------
// devices/<slug>/device.md: front matter (one `key: value` per line, nested maps indented by two
// spaces, no lists) and a body with slots. map.md: the message map. devices/links.json: the site pages
// a body may point at as [text](@name) or [text](@name#anchor), so a site restructure edits one file.
const DEVICES = path.join(ROOT, 'devices');
const DEVICE_DOCS = path.join(DOCS, '03-devices');
const REQUIRED = ['name', 'maker', 'usb_name', 'ports', 'sends', 'receives', 'buy', 'photo', 'firmware'];
const SLOTS = ['facts', 'map', 'starters', 'helper', 'raw'];

function fail(msg) { console.error(msg); process.exit(1); }

function parseFrontMatter(text, file) {
  const m = /^---\n([\s\S]*?)\n---\n?([\s\S]*)$/.exec(text);
  if (!m) fail(`${file}: no front matter (a --- block at the top)`);
  const data = {};
  let parent = null;
  for (const [i, raw] of m[1].split('\n').entries()) {
    if (!raw.trim() || raw.trim().startsWith('#')) continue;
    const nested = /^  (\S.*)$/.exec(raw);
    const line = nested ? nested[1] : raw;
    if (nested && !parent) fail(`${file}: line ${i + 2} is indented but nothing above it opens a map`);
    const kv = /^([A-Za-z_][\w-]*):(?:\s+(.*))?$/.exec(line);
    if (!kv) fail(`${file}: line ${i + 2} is not "key: value": ${raw}`);
    let value = (kv[2] || '').trim();
    if (/^(".*"|'.*')$/.test(value)) value = value.slice(1, -1);
    if (nested) data[parent][kv[1]] = value;
    else if (value === '') { parent = kv[1]; data[parent] = {}; }
    else { data[kv[1]] = value; parent = null; }
  }
  return {data, body: m[2]};
}

function loadDevice(dir) {
  const file = path.join(dir, 'device.md');
  const rel = (p) => path.relative(ROOT, p).split(path.sep).join('/');
  if (!fs.existsSync(file)) fail(`${rel(dir)}: no device.md`);
  const {data, body} = parseFrontMatter(fs.readFileSync(file, 'utf8'), rel(file));
  for (const key of REQUIRED) {
    if (!(key in data) || data[key] === '' || typeof data[key] !== 'string') fail(`${rel(file)}: missing required field "${key}"`);
  }
  // Facts values land in a table cell of an MDX page, so a bare |, < or { would add a column or break the build
  for (const key of [...REQUIRED, 'title']) {
    if (typeof data[key] === 'string' && /[|<{]/.test(data[key].replace(/`[^`]*`/g, ''))) fail(`${rel(file)}: field "${key}" has |, < or { outside backticks; wrap it in backticks or leave it out`);
  }
  const mapFile = path.join(dir, 'map.md');
  if (!fs.existsSync(mapFile)) fail(`${rel(dir)}: no map.md (the message map)`);
  for (const group of ['starters', 'raw']) {
    if (group in data && typeof data[group] !== 'object') fail(`${rel(file)}: "${group}" must be a map of p5, python and java paths`);
    for (const p of Object.values(data[group] || {})) {
      if (!fs.existsSync(path.join(ROOT, p))) fail(`${rel(file)}: ${group} path does not exist: ${p}`);
    }
  }
  return {slug: path.basename(dir), file: rel(file), data, body, map: fs.readFileSync(mapFile, 'utf8').trim()};
}

function loadLinks() {
  const file = path.join(DEVICES, 'links.json');
  return fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, 'utf8')) : {};
}

function resolveLinks(text, links, file) {
  return text.replace(/\]\(@([\w-]+)(#[^)]*)?\)/g, (s, name, anchor = '') => {
    if (!(name in links)) fail(`${file}: unknown site link @${name} (add it to devices/links.json)`);
    return `](${links[name]}${anchor})`;
  });
}

const mdLink = (v) => /^https?:\/\//.test(v) ? `[${v.replace(/^https?:\/\/(www\.)?/, '').replace(/\/$/, '')}](${v})` : v;

function renderFacts(d) {
  const rows = [['Maker', d.maker], ['USB name', d.usb_name], ['Ports', d.ports], ['Sends', d.sends], ['Receives', d.receives], ['Buy', mdLink(d.buy)], ['Firmware', mdLink(d.firmware)]]
    .filter(([, v]) => v !== 'none');
  const photo = d.photo === 'none' ? '' : `![${d.name}](${d.photo})\n\n`;
  return photo + '| | |\n|---|---|\n' + rows.map(([k, v]) => `| ${k} | ${v} |`).join('\n');
}

const includeBlock = (spec) => `{/* include: ${spec} */}\n\n{/* /include */}`;

function renderStarters(d, file) {
  const s = d.starters;
  if (!s || !s.p5 || !s.python || !s.java) fail(`${file}: the starters slot needs starters.p5, starters.python and starters.java`);
  const notes = d.starter_notes || {};
  const title = `${d.helper || d.name} starter, p5.js`;
  const p5 = s.p5.replace(/\/$/, '');
  return [
    '<Tabs groupId="lang" queryString>',
    '<TabItem value="p5" label="p5.js" default>',
    '',
    `<LiveSketch src="/${p5}/" title="${title}" />`,
    '',
    `${notes.p5 ? notes.p5 + ' ' : ''}Code: \`${p5}/sketch.js\`. Paste it into the`,
    '[p5.js web editor](@p5-editor) with the helper script tag, or',
    'download the folder and double-click `index.html`.',
    '',
    includeBlock(`${p5}/sketch.js`),
    '',
    '</TabItem>',
    '<TabItem value="python" label="Python Mode">',
    '',
    `Open \`${s.python}\`.${notes.python ? ' ' + notes.python : ''}`,
    '',
    includeBlock(s.python),
    '',
    '</TabItem>',
    '<TabItem value="java" label="Java">',
    '',
    `Open \`${s.java}\`.${notes.java ? ' ' + notes.java : ''}`,
    '',
    includeBlock(s.java),
    '',
    '</TabItem>',
    '</Tabs>',
  ].join('\n');
}

function renderHelper(d, file) {
  if (!d.helper) fail(`${file}: the helper slot needs "helper", the heading of its section in midi-helpers/README.md`);
  return `### From the helpers' README\n\n${includeBlock(`midi-helpers/README.md#${d.helper}`)}`;
}

function renderRaw(d, file) {
  const r = d.raw;
  if (!r || !r.java || !r.python || !r.p5) fail(`${file}: the raw slot needs raw.java, raw.python and raw.p5`);
  const dir = (p) => path.posix.dirname(p) + '/';
  const p5 = r.p5.replace(/\/$/, '') + '/';
  return [
    `- Java mode: [\`${dir(r.java)}\`](pathname:///${r.java})`,
    `- Python Mode: [\`${dir(r.python)}\`](pathname:///${r.python})`,
    `- p5.js: [\`${p5}\`](pathname:///${p5}), or its [sketch.js](pathname:///${p5}sketch.js)`,
  ].join('\n');
}

function renderDevice(dev, links) {
  const {data: d, file} = dev;
  const parts = {
    facts: () => renderFacts(d),
    map: () => dev.map,
    starters: () => renderStarters(d, file),
    helper: () => renderHelper(d, file),
    raw: () => renderRaw(d, file),
  };
  let body = dev.body.trim();
  if (!body.includes('<!-- facts -->')) {
    const h2 = body.search(/^## /m);
    body = h2 < 0 ? body + '\n\n<!-- facts -->' : body.slice(0, h2) + '<!-- facts -->\n\n' + body.slice(h2);
  }
  body = body.replace(/<!--\s*([\w-]+)\s*-->/g, (s, slot) => {
    if (!SLOTS.includes(slot)) fail(`${file}: unknown slot <!-- ${slot} --> (one of ${SLOTS.join(', ')})`);
    return parts[slot]();
  });
  body = resolveLinks(body, links, file);
  if (body.includes('<!--')) fail(`${file}: HTML comments are not valid in the generated MDX; remove the <!-- ... --> outside the slots`);
  const fm = [`title: ${JSON.stringify(d.name)}`];
  if (d.description) fm.push(`description: ${JSON.stringify(d.description)}`);
  if (d.order) fm.push(`sidebar_position: ${d.order}`);
  return [
    '---', ...fm, '---', '',
    `{/* generated from ${file} by \`node website/refresh.mjs devices\`; edit the source, not this */}`, '',
    "import Tabs from '@theme/Tabs';",
    "import TabItem from '@theme/TabItem';",
    "import LiveSketch from '@site/src/components/LiveSketch';", '',
    `# ${d.title || d.name}`, '',
    body, '',
  ].join('\n');
}

// ---- include pass -------------------------------------------------------------------------------
const totals = {pending: 0, updated: 0, current: 0};

// Fills every include block in `text`. `doc` is the file the log lines name; `log` false keeps quiet.
function fillIncludes(text, doc, log = true) {
  let pos = 0, out = '', changed = false, m;
  OPEN.lastIndex = 0;
  while ((m = OPEN.exec(text))) {
    const close = text.indexOf(CLOSE, m.index + m[0].length);
    if (close < 0) { console.error(`${doc}: unterminated include for ${m[1]}`); process.exit(1); }
    const {file, section} = findSource(m[1]);
    const old = text.slice(m.index + m[0].length, close);
    let next = old, state = 'pending', detail = 'no file matches yet';
    if (file) {
      const body = render(file, section);
      if (body === null) detail = `section not found in ${path.relative(ROOT, file)}`;
      else { next = `\n\n${body}\n\n`; state = next === old ? 'current' : 'updated'; detail = path.relative(ROOT, file); }
    }
    if (state === 'updated') changed = true;
    if (log) { totals[state]++; console.log(`${state.padEnd(8)} ${path.relative(here, doc).padEnd(36)} ${m[1]}  (${detail})`); }
    else if (state === 'pending') fail(`${path.relative(here, doc)}: include ${m[1]} ${detail}`);
    out += text.slice(pos, m.index + m[0].length) + next;
    pos = close;
    OPEN.lastIndex = close;
  }
  out += text.slice(pos);
  return {out, changed};
}

function devicesMode(args) {
  const dirs = args.length ? args.map((a) => path.resolve(ROOT, a))
    : fs.readdirSync(DEVICES).sort().filter((n) => !n.startsWith('_') && n !== 'test' && fs.statSync(path.join(DEVICES, n)).isDirectory()).map((n) => path.join(DEVICES, n));
  const links = loadLinks();
  const pages = {new: 0, updated: 0, current: 0};
  for (const dir of dirs) {
    const dev = loadDevice(dir);
    const out = path.join(DEVICE_DOCS, `${dev.slug}.md`);
    const page = fillIncludes(renderDevice(dev, links), out, false).out;
    const state = !fs.existsSync(out) ? 'new' : fs.readFileSync(out, 'utf8') === page ? 'current' : 'updated';
    pages[state]++;
    console.log(`${state.padEnd(8)} ${path.relative(here, out).padEnd(36)} from ${dev.file}`);
    if (!CHECK && state !== 'current') { fs.mkdirSync(DEVICE_DOCS, {recursive: true}); fs.writeFileSync(out, page); }
  }
  console.log(`\n${pages.new} new, ${pages.updated} updated, ${pages.current} current${CHECK ? '  [check only, nothing written]' : ''}`);
}

// ---- talks mode ---------------------------------------------------------------------------------
// talks/<yyyy>-<slug>/talk.md: front matter (title, date, date_end, venue, city, kind, summary,
// video, links: {slides, video, demos, site, repo, article, event}) and a body written by hand.
// transcript.md beside it is appended, collapsed. assets/*.jpg|png are copied to
// static/img/talks/<slug>/ and the first one is the thumbnail. site/ is a workshop site re-hosted
// as it was: its pages land in docs/07-talks/<slug>/ with a banner line, images and links fixed.
// The timeline in docs/07-talks/index.md is rebuilt between the {/* talks:timeline */} markers.
const TALKS = path.join(ROOT, 'talks');
const TALK_DOCS = path.join(DOCS, '07-talks');
const TALK_IMG = path.join(here, 'static', 'img', 'talks');
const KINDS = ['talk', 'workshop', 'article', 'video', 'demo'];
const LINK_LABELS = {slides: 'Slides', video: 'Video', demos: 'Demos', site: 'Site', repo: 'Repo', article: 'Article', event: 'Event page', transcript: 'Transcript'};
const MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

function loadTalk(dir) {
  const file = path.join(dir, 'talk.md');
  const rel = (p) => path.relative(ROOT, p).split(path.sep).join('/');
  if (!fs.existsSync(file)) fail(`${rel(dir)}: no talk.md`);
  const {data, body} = parseFrontMatter(fs.readFileSync(file, 'utf8'), rel(file));
  for (const key of ['title', 'date', 'venue', 'kind', 'summary']) {
    if (!data[key] || typeof data[key] !== 'string') fail(`${rel(file)}: missing required field "${key}"`);
  }
  if (!KINDS.includes(data.kind)) fail(`${rel(file)}: kind must be one of ${KINDS.join(', ')}`);
  if (!/^\d{4}(-\d{2}(-\d{2})?)?$/.test(data.date)) fail(`${rel(file)}: date must be YYYY, YYYY-MM or YYYY-MM-DD`);
  if (data.links && typeof data.links !== 'object') fail(`${rel(file)}: links must be a map`);
  const has = (name) => fs.existsSync(path.join(dir, name));
  const assets = has('assets') ? fs.readdirSync(path.join(dir, 'assets')).filter((n) => /\.(jpe?g|png|gif|webp)$/i.test(n)).sort() : [];
  const site = has('site') ? loadSite(path.join(dir, 'site'), rel) : null;
  return {
    slug: path.basename(dir), dir, file: rel(file), data, body: body.trim(), assets, site,
    transcript: has('transcript.md') ? fs.readFileSync(path.join(dir, 'transcript.md'), 'utf8').trim() : null,
  };
}

// A re-hosted VuePress site: README.md is the home page, vuepress-config.js names the sidebar order.
function loadSite(dir, rel) {
  const config = path.join(dir, 'vuepress-config.js');
  if (!fs.existsSync(config)) fail(`${rel(dir)}: no vuepress-config.js (the sidebar order comes from it)`);
  const order = [...fs.readFileSync(config, 'utf8').matchAll(/^\s*\["([^"]+)",\s*"([^"]+)"\]/gm)].map((m) => ({name: m[1], label: m[2]}));
  if (!order.length) fail(`${rel(config)}: no sidebar entries found`);
  for (const {name} of order) if (!fs.existsSync(path.join(dir, `${name}.md`))) fail(`${rel(dir)}: sidebar names ${name}.md but it is not there`);
  const home = path.join(dir, 'README.md');
  if (!fs.existsSync(home)) fail(`${rel(dir)}: no README.md (the home page)`);
  const images = fs.existsSync(path.join(dir, 'images')) ? fs.readdirSync(path.join(dir, 'images')).sort() : [];
  return {dir, order, home: parseFrontMatter(fs.readFileSync(home, 'utf8'), rel(home)).data, images};
}

function longDate(d, end) {
  const [y, m, day] = d.split('-').map(Number);
  if (!m) return String(y);
  if (!day) return `${MONTHS[m - 1]} ${y}`;
  if (end) {
    const [ey, em, eday] = end.split('-').map(Number);
    if (ey === y && em === m) return `${MONTHS[m - 1]} ${day} to ${eday}, ${y}`;
    if (ey === y) return `${MONTHS[m - 1]} ${day} to ${MONTHS[em - 1]} ${eday}, ${y}`;
    return `${MONTHS[m - 1]} ${day}, ${y} to ${MONTHS[em - 1]} ${eday}, ${ey}`;
  }
  return `${MONTHS[m - 1]} ${day}, ${y}`;
}

const youtubeId = (url) => (/(?:youtu\.be\/|[?&]v=|\/embed\/)([\w-]{11})/.exec(url || '') || [])[1];

function videoEmbed(url, title) {
  const id = youtubeId(url);
  if (!id) return '';
  return `<iframe src="https://www.youtube-nocookie.com/embed/${id}" title=${JSON.stringify(title)} style={{width: '100%', aspectRatio: '16 / 9', border: 0}} allow="encrypted-media; picture-in-picture" allowFullScreen />`;
}

// Markdown body written by hand: only { needs escaping for MDX; HTML comments go.
const mdxBody = (text) => text.replace(/<!--[\s\S]*?-->/g, '').replace(/\{/g, '\\{');

function renderTalk(t) {
  const d = t.data;
  const links = Object.entries(d.links || {}).filter(([k, v]) => v && LINK_LABELS[k]);
  const video = d.video || (d.links && d.links.video);
  const rows = [
    ['When', longDate(d.date, d.date_end)],
    ['Where', [d.venue, d.city].filter(Boolean).join(', ')],
    ['What', d.kind],
    ...links.map(([k, v]) => [LINK_LABELS[k], mdLink(v)]),
  ];
  const missing = [];
  if (['talk', 'workshop'].includes(d.kind) && !video) missing.push('No recording of this one turned up in the sources.');
  if (d.kind === 'talk' && !(d.links && d.links.slides)) missing.push('No slides for this one are published.');
  if (d.kind === 'workshop' && !(d.links && d.links.site) && !t.site) missing.push('Its site is gone and nothing is re-hosted here.');
  if (t.site) missing.push(`Its original site is offline. The pages are re-hosted below, [as given](./${t.slug}/index.md).`);
  if (t.transcript) missing.push('A transcript is at the bottom of the page.');
  const embed = video ? videoEmbed(video, `${d.title}, ${d.venue}`) : '';
  // assets/youtube-<id>.jpg are thumbnails of that video; the embedded one is not repeated. Anything else is a photo.
  const thumb = (a) => { const id = (/^youtube-(.+)\.\w+$/.exec(a) || [])[1]; return id ? `[![${d.title}](/img/talks/${t.slug}/${a})](https://www.youtube.com/watch?v=${id})` : `![${d.title}](/img/talks/${t.slug}/${a})`; };
  const img = t.assets.filter((a) => !embed || !a.includes(youtubeId(video))).map(thumb).join(' ') + (t.assets.length ? '\n\n' : '');
  const fm = [
    `title: ${JSON.stringify(d.title)}`,
    `description: ${JSON.stringify(d.summary)}`,
    `slug: /talks/${t.slug}/`,
    `sidebar_label: ${JSON.stringify(d.sidebar_label || d.title)}`,
    `sidebar_position: ${d.date.replace(/-/g, '').padEnd(8, '0')}`,
  ];
  const out = [
    '---', ...fm, '---', '',
    `{/* generated from ${t.file} by \`node website/refresh.mjs talks\`; edit the source, not this */}`, '',
    `# ${d.title}`, '',
    d.summary, '',
    '| | |', '|---|---|', ...rows.map(([k, v]) => `| ${k} | ${v} |`), '',
    ...(missing.length ? [missing.join(' '), ''] : []),
    ...(embed ? [embed, ''] : []),
    ...(img.trim() ? [img] : []),
    mdxBody(t.body), '',
  ];
  if (t.transcript) {
    out.push(
      '## Transcript', '',
      "YouTube's automatic captions, deduplicated and broken into paragraphs by `talks/vtt2md.py`. Not",
      'corrected, so names and the technical words come out wrong now and then.', '',
      '<details>', '<summary>Read the transcript</summary>', '', mdxBody(t.transcript), '', '</details>', '',
    );
  }
  return out.join('\n');
}

// A page of a re-hosted site, as it was, with the image and page links pointed at their new homes.
function renderSitePage(t, name, label, position, year) {
  const src = path.join(t.site.dir, `${name}.md`);
  let text = fs.readFileSync(src, 'utf8');
  text = text.replace(/\]\(\/images\//g, `](/img/talks/${t.slug}/`);
  text = text.replace(/\]\(\/([\w-]+)\.html\)/g, (s, page) => fs.existsSync(path.join(t.site.dir, `${page}.md`)) ? `](./${page}.md)` : s);
  text = text.replace(/\{/g, '\\{');   // MDX; done before the style attributes below add their own braces
  // an <iframe> with fallback text inside breaks MDX; self-close it and keep the text as markdown after it
  text = text.replace(/<iframe([^>]*)>([\s\S]*?)<\/iframe>/g, (s, attrs, inner) => {
    const fallback = inner.replace(/<a [^>]*href=['"]([^'"]*)['"][^>]*>(.*?)<\/a>/g, '[$2]($1)').replace(/\s+/g, ' ').trim();
    return `<iframe${attrs.replace(/\s+/g, ' ').trimEnd()} />\n\n${fallback}`;
  });
  // the CodePen iframes: HTML attributes as JSX
  text = text.replace(/ style='([^']*)'/g, (s, css) => ` style={{${css.split(';').filter((r) => r.trim()).map((r) => { const [k, v] = r.split(':'); return `${k.trim().replace(/-(\w)/g, (x, c) => c.toUpperCase())}: '${v.trim()}'`; }).join(', ')}}}`)
    .replace(/ frameborder=/g, ' frameBorder=').replace(/ allowfullscreen=/g, ' allowFullScreen=').replace(/ allowtransparency=/g, ' allowTransparency=');
  const banner = `:::note\nAs given in ${year}, kept as it was. Only the links and images were pointed at this site. [The entry](../${t.slug}.md) says where it was given and why.\n:::`;
  return [
    '---', `sidebar_label: ${JSON.stringify(label)}`, `sidebar_position: ${position}`, `slug: /talks/${t.slug}/${name.replace(/^\d+-/, '')}/`, '---', '',
    `{/* copied from ${path.relative(ROOT, src).split(path.sep).join('/')} by \`node website/refresh.mjs talks\`; edit the source, not this */}`, '',
    banner, '', text.trim(), '',
  ].join('\n');
}

function renderSiteIndex(t, year) {
  const h = t.site.home;
  const hero = h.heroImage ? `![${h.heroText || h.title}](${h.heroImage.replace(/^\/images\//, `/img/talks/${t.slug}/`)})\n\n` : '';
  const pages = t.site.order.map(({name, label}) => `- [${label}](./${name}.md)`).join('\n');
  return [
    '---', `title: ${JSON.stringify(h.title || h.heroText || t.data.title)}`, `sidebar_label: "Site, as given"`, 'sidebar_position: 0', `slug: /talks/${t.slug}/site/`, '---', '',
    `{/* copied from ${path.relative(ROOT, path.join(t.site.dir, 'README.md')).split(path.sep).join('/')} by \`node website/refresh.mjs talks\`; edit the source, not this */}`, '',
    `:::note\nAs given in ${year}, kept as it was. This was the home page. [The entry](../${t.slug}.md) says where it was given and why.\n:::`, '',
    hero + (h.description ? `${h.description}\n\n` : '') + pages, '',
  ].join('\n');
}

function writeIfChanged(out, text, pages, from) {
  const state = !fs.existsSync(out) ? 'new' : fs.readFileSync(out, 'utf8') === text ? 'current' : 'updated';
  pages[state]++;
  console.log(`${state.padEnd(8)} ${path.relative(here, out).padEnd(52)} from ${from}`);
  if (!CHECK && state !== 'current') { fs.mkdirSync(path.dirname(out), {recursive: true}); fs.writeFileSync(out, text); }
}

function copyIfChanged(src, dst, pages) {
  const same = fs.existsSync(dst) && fs.readFileSync(src).equals(fs.readFileSync(dst));
  pages[same ? 'current' : fs.existsSync(dst) ? 'updated' : 'new']++;
  if (!CHECK && !same) { fs.mkdirSync(path.dirname(dst), {recursive: true}); fs.copyFileSync(src, dst); }
}

function renderTimeline(talks) {
  const byYear = new Map();
  for (const t of talks) { const y = t.data.date.slice(0, 4); if (!byYear.has(y)) byYear.set(y, []); byYear.get(y).push(t); }
  const out = [];
  for (const [y, list] of byYear) {
    out.push(`### ${y}`, '', '| When | What | Where | Kind | Recording |', '|---|---|---|---|---|');
    for (const t of list) {
      const d = t.data;
      const video = d.video || (d.links && d.links.video);
      const rec = video ? `[watch](${video})` : t.site ? 'site re-hosted' : 'none';
      out.push(`| ${longDate(d.date, d.date_end)} | [${d.title}](./${t.slug}.md) | ${[d.venue, d.city].filter(Boolean).join(', ')} | ${d.kind} | ${rec} |`);
    }
    out.push('');
  }
  return out.join('\n').trim();
}

function talksMode(args) {
  const dirs = args.length ? args.map((a) => path.resolve(ROOT, a))
    : fs.readdirSync(TALKS).sort().filter((n) => /^\d{4}-/.test(n) && fs.statSync(path.join(TALKS, n)).isDirectory()).map((n) => path.join(TALKS, n));
  const talks = dirs.map(loadTalk).sort((a, b) => a.data.date.localeCompare(b.data.date) || a.slug.localeCompare(b.slug));
  const pages = {new: 0, updated: 0, current: 0};
  for (const t of talks) {
    writeIfChanged(path.join(TALK_DOCS, `${t.slug}.md`), renderTalk(t), pages, t.file);
    for (const a of t.assets) copyIfChanged(path.join(t.dir, 'assets', a), path.join(TALK_IMG, t.slug, a), pages);
    if (t.site) {
      const year = t.data.date.slice(0, 4);
      const docDir = path.join(TALK_DOCS, t.slug);
      writeIfChanged(path.join(docDir, '_category_.json'), JSON.stringify({label: `${t.data.sidebar_label || t.data.title}, the site`, position: Number(t.data.date.replace(/-/g, '').padEnd(8, '0')) + 0.5, collapsed: true}, null, 2) + '\n', pages, 'talks mode');   // index.md inside is the category page by convention
      writeIfChanged(path.join(docDir, 'index.md'), renderSiteIndex(t, year), pages, `${t.slug}/site/README.md`);
      t.site.order.forEach(({name, label}, i) => writeIfChanged(path.join(docDir, `${name}.md`), renderSitePage(t, name, label, i + 1, year), pages, `${t.slug}/site/${name}.md`));
      for (const img of t.site.images) copyIfChanged(path.join(t.site.dir, 'images', img), path.join(TALK_IMG, t.slug, img), pages);
    }
  }
  if (!args.length) {
    const index = path.join(TALK_DOCS, 'index.md');
    if (!fs.existsSync(index)) fail(`${path.relative(here, index)} is missing; the timeline page is written by hand with {/* talks:timeline */} markers`);
    const text = fs.readFileSync(index, 'utf8');
    const open = '{/* talks:timeline */}', close = '{/* /talks:timeline */}';
    const a = text.indexOf(open), b = text.indexOf(close);
    if (a < 0 || b < a) fail(`${path.relative(here, index)}: needs ${open} … ${close} markers`);
    writeIfChanged(index, text.slice(0, a + open.length) + '\n\n' + renderTimeline(talks) + '\n\n' + text.slice(b), pages, 'the entries');
  }
  console.log(`\n${pages.new} new, ${pages.updated} updated, ${pages.current} current${CHECK ? '  [check only, nothing written]' : ''}`);
}

const ARGS = process.argv.slice(2).filter((a) => !a.startsWith('--'));
if (ARGS[0] === 'devices') devicesMode(ARGS.slice(1));
else if (ARGS[0] === 'talks') talksMode(ARGS.slice(1));
else {
  for (const doc of walk(DOCS)) {
    const {out, changed} = fillIncludes(fs.readFileSync(doc, 'utf8'), doc);
    if (changed && !CHECK) fs.writeFileSync(doc, out);
  }
  console.log(`\n${totals.updated} updated, ${totals.current} current, ${totals.pending} pending${CHECK ? '  [check only, nothing written]' : ''}`);
}
