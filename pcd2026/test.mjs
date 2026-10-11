// node pcd2026/test.mjs: the redirect Worker sends every old URL to morethanmusic.dev with a 301.
import worker from './worker.js';
const go = async (url) => { const r = await worker.fetch(new Request(url)); return [r.status, r.headers.get('location')]; };
const cases = [
  ['https://pcd2026.mand.is/', [301, 'https://morethanmusic.dev/talks/pcd-2026-nyc/']],
  ['https://pcd2026.mand.is/your-device/pipsqueak/', [301, 'https://morethanmusic.dev/your-device/pipsqueak/']],
  ['https://pcd2026.mand.is/explorer/web/?connect=1', [301, 'https://morethanmusic.dev/explorer/web/?connect=1']],
  ['https://pcd2026.mand.is/midi-helpers/p5/midi-helpers.js', [301, 'https://morethanmusic.dev/midi-helpers/p5/midi-helpers.js']],
];
let bad = 0;
for (const [url, want] of cases) {
  const got = await go(url);
  const ok = got[0] === want[0] && got[1] === want[1];
  if (!ok) bad++;
  console.log(`${ok ? 'ok  ' : 'FAIL'} ${url} -> ${got.join(' ')}`);
}
process.exit(bad ? 1 : 0);
