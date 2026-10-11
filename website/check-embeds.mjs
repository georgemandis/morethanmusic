#!/usr/bin/env node
// Load pages in headless Chrome over the DevTools protocol and fail on anything the console would show.
//
//   node check-embeds.mjs URL...        # each page must fire its load event and log nothing within the window
//   node check-embeds.mjs --self-test   # three data: pages: clean passes, console.log fails, a dead script fails
//   node check-embeds.mjs --expect-request plausible.io URL...   # each page must also request a URL containing that
//
// Chrome's --dump-dom never returns on this machine's Chrome 154 (see check-links.sh), so this attaches
// to Chrome with --remote-debugging-port and listens for Runtime.consoleAPICalled, Runtime.exceptionThrown
// and Log.entryAdded between navigation and load + SETTLE_MS. A page that never fires load fails too, so a
// silent page cannot pass by not loading. CHROME overrides the binary. Exit code 1 on any failure.
import {spawn} from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const CHROME = process.env.CHROME || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const LOAD_MS = 15000, SETTLE_MS = 3000;

let chrome = null, port = 0, profile = null;
async function startChrome() {
  if (chrome) return;
  profile = fs.mkdtempSync(path.join(os.tmpdir(), 'check-embeds-'));
  chrome = spawn(CHROME, ['--headless=new', '--disable-gpu', '--no-first-run', '--no-default-browser-check',
    '--remote-debugging-port=0', `--user-data-dir=${profile}`, 'about:blank'], {stdio: ['ignore', 'ignore', 'pipe']});
  port = await new Promise((resolve, reject) => {
    let buf = '';
    chrome.stderr.on('data', (d) => {
      buf += d;
      const m = buf.match(/DevTools listening on ws:\/\/127\.0\.0\.1:(\d+)\//);
      if (m) resolve(Number(m[1]));
    });
    chrome.on('exit', (c) => reject(new Error(`chrome exited with ${c}`)));
    setTimeout(() => reject(new Error('chrome gave no DevTools port in 15 s')), 15000);
  });
}
async function stopChrome() {
  if (chrome) { const gone = new Promise((r) => chrome.on('exit', r)); chrome.kill(); await gone; chrome = null; }
  if (profile) { try { fs.rmSync(profile, {recursive: true, force: true}); } catch {} }
}
process.on('exit', () => chrome?.kill());

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// checkPage(url) -> {ok, messages: [string]}: open a tab, navigate, collect what the console would show
// until the load event plus SETTLE_MS. No load event within LOAD_MS is itself a failure.
async function checkPage(url) {
  await startChrome();
  const target = await (await fetch(`http://127.0.0.1:${port}/json/new?about:blank`, {method: 'PUT'})).json();
  const ws = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((r, j) => { ws.onopen = r; ws.onerror = j; });
  const messages = [], requests = [];
  let id = 0, loaded = false;
  const pending = new Map();
  ws.onmessage = (e) => {
    const msg = JSON.parse(e.data);
    if (msg.id && pending.has(msg.id)) { pending.get(msg.id)(msg); pending.delete(msg.id); return; }
    const p = msg.params || {};
    if (msg.method === 'Page.loadEventFired') loaded = true;
    else if (msg.method === 'Network.requestWillBeSent') requests.push(p.request.url);
    else if (msg.method === 'Runtime.consoleAPICalled')
      messages.push(`console.${p.type}: ${p.args.map((a) => a.value ?? a.description ?? a.type).join(' ')}`);
    else if (msg.method === 'Runtime.exceptionThrown')
      messages.push(`exception: ${p.exceptionDetails.exception?.description ?? p.exceptionDetails.text}`);
    else if (msg.method === 'Log.entryAdded')
      messages.push(`${p.entry.level} ${p.entry.source}: ${p.entry.text}${p.entry.url ? ' ' + p.entry.url : ''}`);
  };
  const send = (method, params = {}) => new Promise((r) => { pending.set(++id, r); ws.send(JSON.stringify({id, method, params})); });
  await send('Runtime.enable'); await send('Log.enable'); await send('Page.enable'); await send('Network.enable');
  await send('Page.navigate', {url});
  const t0 = Date.now();
  while (!loaded && Date.now() - t0 < LOAD_MS) await sleep(50);
  if (!loaded) messages.push(`no load event within ${LOAD_MS / 1000} s`);
  else await sleep(SETTLE_MS);
  ws.close();
  await fetch(`http://127.0.0.1:${port}/json/close/${target.id}`).catch(() => {});
  if (expectRequest && !requests.some((u) => u.includes(expectRequest)))
    messages.push(`no request to a URL containing "${expectRequest}" (${requests.length} requests seen)`);
  return {ok: messages.length === 0, messages};
}

async function selfTest() {
  const cases = [
    ['data:text/html,<p>clean</p>', true],
    ['data:text/html,<script>console.log("hello-control")</script>', false],
    ['data:text/html,<script src="http://127.0.0.1:1/missing.js"></script>', false],
  ];
  let bad = 0;
  for (const [url, expectOk] of cases) {
    const r = await checkPage(url);
    const pass = r.ok === expectOk;
    if (!pass) bad++;
    console.log(`${pass ? 'ok  ' : 'FAIL'} self-test ${url.slice(0, 60)} -> ${r.ok ? 'clean' : r.messages.join(' | ').slice(0, 120)}`);
  }
  return bad === 0;
}

const args = process.argv.slice(2);
let expectRequest = null;
if (args[0] === '--expect-request') { expectRequest = args[1]; args.splice(0, 2); }
if (args[0] === '--self-test') {
  const ok = await selfTest();
  await stopChrome();
  process.exit(ok ? 0 : 1);
}
let fail = 0;
for (const url of args) {
  const r = await checkPage(url);
  if (r.ok) console.log(`ok   ${url}`);
  else { fail++; console.log(`FAIL ${url}`); for (const m of r.messages) console.log(`     ${m}`); }
}
await stopChrome();
process.exit(fail ? 1 : 0);
