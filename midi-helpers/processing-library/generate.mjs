#!/usr/bin/env node
// Turns the drop-in tabs in ../java into package sources for the Processing library. The tabs stay the
// source of truth and are never edited. On the way:
//   - every class gets its own file with `package midihelpers;` and the imports a sketch gives a tab for free
//   - the sketch-level functions in MidiCore.pde (midiInputs, midiOutputs, printMidiDevices, midiDeviceNames)
//     become public static methods of MidiCore, so a sketch calls MidiCore.printMidiDevices()
//   - constructors, fields and methods declared with no access modifier become public, because a sketch in
//     the default package cannot reach package-private members of a library class
//   node generate.mjs [outDir]      default: build/src/midihelpers
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const javaDir = path.join(here, "..", "java");
const outDir = process.argv[2] || path.join(here, "build", "src", "midihelpers");
fs.rmSync(outDir, { recursive: true, force: true });
fs.mkdirSync(outDir, { recursive: true });

const imports = new Set(["processing.core.*", "processing.data.*", "processing.event.*", "java.util.*"]);
const classes = [];       // { name, tab, lines }
const sketchFunctions = []; // lines of top-level functions, already indented for a class body

const declStart = /^  (?!public |private |protected |\/\/|\/\*|\*|@|\}|\{|return |if |for |while |else|try|catch|synchronized|switch|case |do |throw |new )[A-Za-z_<]/;
const endsStatement = (line) => /(;|\{|\}|\*\/)\s*$/.test(line.replace(/\s*\/\/.*$/, "")) || /^\s*(\/\/|\*|\/\*)/.test(line);

function publicize(body) {
  const out = [];
  let prev = "";
  for (const line of body) {
    let l = line;
    if (declStart.test(l) && (prev === "" || endsStatement(prev))) l = "  public " + l.slice(2);
    out.push(l);
    if (l.trim() !== "") prev = l;
  }
  return out;
}

for (const tab of fs.readdirSync(javaDir).filter((f) => f.endsWith(".pde")).sort()) {
  const lines = fs.readFileSync(path.join(javaDir, tab), "utf8").split("\n");
  let pending = [];   // comment lines waiting to attach to the next declaration
  let i = 0;
  while (i < lines.length) {
    const line = lines[i];
    const imp = line.match(/^import\s+([^;]+);/);
    if (imp) { imports.add(imp[1].trim()); i++; continue; }
    if (/^\s*$/.test(line)) { pending = []; i++; continue; }
    if (/^(\/\/|\/\*|\s\*)/.test(line)) { pending.push(line); i++; continue; }
    const cls = line.match(/^(?:public\s+)?(?:class|interface)\s+(\w+)/);
    if (cls || /^[A-Za-z].*\)\s*\{/.test(line)) {
      let end = i;
      if (!/\}\s*$/.test(line) || cls) while (end < lines.length && !/^\}/.test(lines[end])) end++;   // one-liners close on their own line
      if (end >= lines.length) throw new Error(`${tab}: no closing brace for ${line}`);
      const block = lines.slice(i, end + 1);
      if (cls) {
        const head = block[0].startsWith("public ") ? block[0] : "public " + block[0];
        classes.push({ name: cls[1], tab, lines: [...pending, head, ...publicize(block.slice(1, -1)), block[block.length - 1]] });
      } else {
        for (const c of pending) sketchFunctions.push("  " + c);
        sketchFunctions.push("  public static " + block[0]);
        for (const b of block.slice(1)) sketchFunctions.push("  " + b);
      }
      pending = [];
      i = end + 1;
      continue;
    }
    throw new Error(`${tab}:${i + 1}: unexpected top-level line: ${line}`);
  }
}

const core = classes.find((c) => c.name === "MidiCore");
if (!core) throw new Error("MidiCore class not found");
core.lines.splice(core.lines.length - 1, 0, "", "  // ---- sketch-level helpers from MidiCore.pde, static here: MidiCore.printMidiDevices() ----", ...sketchFunctions);

const header = (c) => [
  `// Generated from midi-helpers/java/${c.tab} by processing-library/generate.mjs. Edit the tab, not this file.`,
  "package midihelpers;",
  "",
  ...[...imports].map((im) => `import ${im};`),
  "import static processing.core.PApplet.*;",
  "import static midihelpers.MidiCore.*;",
  "",
];
for (const c of classes) fs.writeFileSync(path.join(outDir, `${c.name}.java`), [...header(c), ...c.lines, ""].join("\n"));
console.log(`generated ${classes.length} classes into ${path.relative(process.cwd(), outDir)}: ${classes.map((c) => c.name).join(" ")}`);
