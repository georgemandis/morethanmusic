// Run from the repo root:  node --test devices/test/
// Spawns the real generator so the test sees exactly what a contributor sees.
import {test} from 'node:test';
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const run = (...args) => spawnSync(process.execPath, ['website/refresh.mjs', 'devices', '--check', ...args], {cwd: ROOT, encoding: 'utf8'});

test('a device.md missing a required field fails and names the file and the field', () => {
  const r = run('devices/test/broken-sample');
  assert.equal(r.status, 1, `expected exit 1, got ${r.status}\nstdout: ${r.stdout}\nstderr: ${r.stderr}`);
  assert.match(r.stderr, /devices\/test\/broken-sample\/device\.md/);
  assert.match(r.stderr, /missing required field "usb_name"/);
});

test('a front-matter value with a table pipe, < or { outside backticks fails and names the file and the field', () => {
  const r = run('devices/test/unsafe-value');
  assert.equal(r.status, 1, `expected exit 1, got ${r.status}\nstdout: ${r.stdout}\nstderr: ${r.stderr}`);
  assert.match(r.stderr, /devices\/test\/unsafe-value\/device\.md/);
  assert.match(r.stderr, /field "sends"/);
});

test('the template folder renders without error', () => {
  const r = run('devices/_template');
  assert.equal(r.status, 0, r.stderr);
});

test('every device in the catalog renders without error', () => {
  const r = run();
  assert.equal(r.status, 0, r.stderr);
  assert.match(r.stdout, /pipsqueak/);
});
