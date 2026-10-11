// Hardware-free tests for the p5 scripts. Each script is loaded into a fake window with a fake
// navigator.requestMIDIAccess; messages come in through the fake input's onmidimessage and what the
// helpers send is captured from the fake output. Run with midi-helpers/test/p5/run.sh (node, no deps).
const vm = require("vm");
const fs = require("fs");
const path = require("path");

const P5 = path.join(__dirname, "..", "..", "p5");
let passed = 0, failed = 0;
const check = (what, ok) => { if (ok) passed++; else { failed++; console.log("FAIL " + what); } };
const eq = (what, a, b) => check(`${what} expected ${JSON.stringify(b)} got ${JSON.stringify(a)}`, JSON.stringify(a) === JSON.stringify(b));
const near = (what, a, b) => check(`${what} expected ${b} got ${a}`, a != null && Math.abs(a - b) < 1e-4);
const hex = (bytes) => Array.from(bytes).map((b) => b.toString(16).padStart(2, "0")).join(" ");

/** A browser-ish global scope with fake Web MIDI. */
function fakeWindow(ports) {
  const w = { console: { log() {}, warn() {}, error() {} }, performance, setTimeout, clearTimeout };
  w.window = w;
  w.listeners = {};
  w.addEventListener = (ev, fn) => { (w.listeners[ev] = w.listeners[ev] || []).push(fn); };
  w.removeEventListener = (ev, fn) => { w.listeners[ev] = (w.listeners[ev] || []).filter((f) => f !== fn); };
  w.fire = (ev, payload) => { for (const fn of (w.listeners[ev] || []).slice()) fn(payload || {}); };
  w.rafQueue = [];
  w.requestAnimationFrame = (fn) => { w.rafQueue.push(fn); return w.rafQueue.length; };
  w.cancelAnimationFrame = () => {};
  w.frame = () => { const q = w.rafQueue; w.rafQueue = []; for (const fn of q) fn(performance.now()); };
  const mkPort = (name, kind) => {
    const p = { name, manufacturer: "", type: kind, sent: [], onmidimessage: null };
    p.send = (bytes) => p.sent.push(Array.from(bytes));
    p.receive = (bytes) => p.onmidimessage && p.onmidimessage({ data: Uint8Array.from(bytes), timeStamp: performance.now() });
    return p;
  };
  w.ports = { inputs: new Map(), outputs: new Map() };
  for (const name of ports || []) { w.ports.inputs.set(name + "-in", mkPort(name, "input")); w.ports.outputs.set(name + "-out", mkPort(name, "output")); }
  w.midiRequests = [];
  w.denySysex = false;
  w.navigator = {
    requestMIDIAccess: async (opts) => {
      w.midiRequests.push(opts);
      if (opts && opts.sysex && w.denySysex) throw new Error("SysEx denied");
      return { inputs: w.ports.inputs, outputs: w.ports.outputs, sysexEnabled: !!(opts && opts.sysex) };
    },
  };
  w.input = (name) => [...w.ports.inputs.values()].find((p) => p.name === name);
  w.output = (name) => [...w.ports.outputs.values()].find((p) => p.name === name);
  vm.createContext(w);
  return w;
}
function load(w, file) { vm.runInContext(fs.readFileSync(path.join(P5, file), "utf8"), w, { filename: file }); return w; }
const calls = (w) => (w.calls = w.calls || []);

async function testLoading() {
  for (const f of ["pipsqueak", "midifighter", "launchpad", "circuitplayground", "anymidi", "trinkeys"]) {
    const w = load(fakeWindow(), f + ".js");
    check(f + ".js defines its constructor", typeof w[{ pipsqueak: "PipSqueak", midifighter: "MidiFighter", launchpad: "Launchpad", circuitplayground: "CircuitPlayground", anymidi: "AnyMidi", trinkeys: "SlideTrinkey" }[f]] === "function");
    check(f + ".js defines MidiCore", typeof w.MidiCore === "function");
  }
  const w = fakeWindow();
  load(w, "midi-helpers.js");
  for (const k of ["MidiCore", "PipSqueak", "MidiFighter", "Launchpad", "CircuitPlayground", "AnyMidi", "SlideTrinkey", "RotaryTrinkey"]) check("bundle defines " + k, typeof w[k] === "function");
  const core = w.MidiCore;
  load(w, "pipsqueak.js"); load(w, "launchpad.js");
  check("loading a second script keeps the same MidiCore", w.MidiCore === core);
  // bundle is current
  const bundle = fs.readFileSync(path.join(P5, "midi-helpers.js"), "utf8");
  for (const f of ["midicore", "pipsqueak", "midifighter", "launchpad", "circuitplayground", "anymidi", "trinkeys"]) check("bundle contains current src/" + f + ".js", bundle.includes(fs.readFileSync(path.join(P5, "src", f + ".js"), "utf8").trim()));
}

async function testCore() {
  const w = load(fakeWindow(["PipSqueak", "Midi Fighter Classic"]), "midi-helpers.js");
  const m = new w.MidiMsg(0x92, 48, 127, 0);
  eq("channel", m.channel, 3); eq("type", m.type, 0x90); check("noteOn", m.isNoteOn() && !m.isNoteOff());
  check("vel 0 is note off", new w.MidiMsg(0x90, 48, 0, 0).isNoteOff());
  eq("pitch bend centre", new w.MidiMsg(0xe0, 0, 64, 0).pitchBend(), 0);
  const core = new w.MidiCore({ name: "midi fighter", verbose: false });
  eq("connect finds both ports", await core.connect(), true);
  eq("input name", core.inputName, "Midi Fighter Classic"); eq("output name", core.outputName, "Midi Fighter Classic");
  eq("asked without sysex", w.midiRequests[0], { sysex: false });
  const out = w.output("Midi Fighter Classic");
  core.noteOn(3, 48, 127); eq("noteOn bytes", hex(out.sent.at(-1)), "92 30 7f");
  core.noteOff(3, 48); eq("noteOff bytes", hex(out.sent.at(-1)), "82 30 00");
  core.controlChange(1, 7, 200); eq("cc clamps", hex(out.sent.at(-1)), "b0 07 48");
  core.pitchBend(1, 0); eq("pitch bend bytes", hex(out.sent.at(-1)), "e0 00 40");
  const n = out.sent.length; core.sysex([0xf0, 0x7e, 0xf7]); eq("sysex skipped without permission", out.sent.length, n);
  w.input("Midi Fighter Classic").receive([0x92, 48, 100]); w.input("Midi Fighter Classic").receive([0xf8]);
  const got = []; core.poll({ midi: (msg) => got.push(String(msg)) });
  eq("queued and decoded, clock dropped", got, ["noteOn ch3 48 100"]);
  const none = new w.MidiCore({ name: "nothing here", verbose: false });
  eq("no device resolves false", await none.connect(), false);
  check("status says so", none.status.includes("no MIDI device"));
  const noWebMidi = load(fakeWindow(), "midi-helpers.js"); noWebMidi.navigator = {};
  const c2 = new noWebMidi.MidiCore({ name: "x", verbose: false });
  eq("no Web MIDI resolves false", await c2.connect(), false);
  check("no Web MIDI status", c2.status.includes("Web MIDI unavailable"));
  eq("inputs list", w.MidiCore.inputs(), ["PipSqueak", "Midi Fighter Classic"]);
}

async function testPipSqueak() {
  const w = load(fakeWindow(["PipSqueak"]), "pipsqueak.js");
  const P = w.PipSqueak;
  near("axis centre", P.normalizeAxis(60, P.DEFAULTS.x), 0); near("axis max", P.normalizeAxis(126, P.DEFAULTS.x), 1);
  near("axis min", P.normalizeAxis(0, P.DEFAULTS.x), -1); near("axis half below", P.normalizeAxis(30, P.DEFAULTS.x), -0.5);
  const cfg = P.mergeConfig({ x: { cc: 1 }, smoothing: 0.5 });
  eq("merge x cc", cfg.x.cc, 1); eq("merge x center kept", cfg.x.center, 60); eq("merge smoothing", cfg.smoothing, 0.5);
  const rest = P.normalize(60, 68, P.DEFAULTS); check("rest is deadzone", rest.x === 0 && rest.angle === null && rest.magnitude === 0);
  near("full right", P.normalize(126, 68, P.DEFAULTS).x, 1); near("full up angle", P.normalize(60, 126, P.DEFAULTS).angle, Math.PI / 2);
  near("half right magnitude", P.normalize(93, 68, P.DEFAULTS).magnitude, 0.4444444);
  w.stickPressed = () => calls(w).push("stickPressed");
  w.controlChange = (ch, n, v) => calls(w).push(`cc ${ch} ${n} ${v}`);
  const stick = new P();
  eq("connect", await stick.connect(), true);
  const inp = w.input("PipSqueak");
  inp.receive([0xb0, 17, 126]); inp.receive([0xb0, 20, 68]); inp.receive([0xb0, 25, 127]);
  w.frame();
  near("x", stick.x, 1); near("y", stick.y, 0); check("pressed + justPressed", stick.pressed && stick.justPressed() && !stick.justReleased());
  check("callbacks", calls(w).includes("stickPressed") && calls(w).includes("cc 1 17 126"));
  w.frame(); check("justPressed lasts one frame", stick.pressed && !stick.justPressed());
  inp.receive([0xb0, 25, 0]); w.frame(); check("released", !stick.pressed && stick.justReleased());
  inp.receive([0xb0, 17, 60]); w.frame(); near("back to rest", stick.magnitude, 0); eq("angle null", stick.angle, null);
  // keyboard stand-in when nothing is connected
  const w2 = load(fakeWindow(), "pipsqueak.js");
  const s2 = new w2.PipSqueak(); await s2.connect();
  w2.fire("keydown", { key: "ArrowUp" }); w2.fire("keydown", { key: " " }); w2.frame();
  near("key up", s2.y, 1); check("key space", s2.pressed && s2.justPressed());
  w2.fire("keyup", { key: "ArrowUp" }); w2.fire("keyup", { key: " " }); w2.frame(); near("key released", s2.y, 0); check("space released", !s2.pressed);
  // connectOnClick
  const w3 = load(fakeWindow(["PipSqueak"]), "pipsqueak.js");
  const s3 = new w3.PipSqueak(); s3.connectOnClick();
  eq("hint status", s3.status, "click to connect MIDI"); check("not connected yet", !s3.connected());
  w3.fire("pointerdown"); await new Promise((r) => setTimeout(r, 0));
  check("connected after click", s3.connected()); eq("click listeners removed", (w3.listeners.pointerdown || []).length, 0);
}

async function testPipSqueakLed() {
  // stick with an output port: flash() opens it lazily and sends note on / off
  const w = load(fakeWindow(["PipSqueak"]), "pipsqueak.js");
  const stick = new w.PipSqueak(); await stick.connect();
  check("connect opens no output", !stick.core.hasOutput());
  stick.flash(); await new Promise((r) => setTimeout(r, 0));
  const out = w.output("PipSqueak");
  eq("flash = note on 60 then note off", out.sent.map(hex), ["90 3c 7f", "80 3c 00"]);
  stick.send(0xb0, 20, 5); eq("send passes through", hex(out.sent.at(-1)), "b0 14 05");
  // stick with no output: no-op
  const w2 = load(fakeWindow(), "pipsqueak.js"); w2.ports.inputs.set("x", { name: "PipSqueak", onmidimessage: null });
  const s2 = new w2.PipSqueak(); await s2.connect(); check("input only", s2.connected() && !s2.core.hasOutput());
  s2.flash(); await new Promise((r) => setTimeout(r, 0)); check("no output: nothing sent, no throw", !s2.core.hasOutput());
}

async function testTrinkeys() {
  const w = load(fakeWindow(["Slide Trinkey M0", "Rotary Trinkey M0"]), "trinkeys.js");
  eq("relative 1", w.RotaryTrinkey.relative(1), 1); eq("relative 127", w.RotaryTrinkey.relative(127), -1); eq("relative 125", w.RotaryTrinkey.relative(125), -3);
  w.sliderChanged = (v) => calls(w).push("sliderChanged " + v); w.touchPressed = () => calls(w).push("touchPressed");
  w.knobTurned = (d) => calls(w).push("knobTurned " + d); w.knobPressed = () => calls(w).push("knobPressed");
  const slide = new w.SlideTrinkey(); eq("slide connects", await slide.connect(), true); eq("slide port", slide.core.inputName, "Slide Trinkey M0");
  const knob = new w.RotaryTrinkey(); eq("knob connects", await knob.connect(), true); eq("knob port", knob.core.inputName, "Rotary Trinkey M0");
  const sin = w.input("Slide Trinkey M0"), sout = w.output("Slide Trinkey M0"), kin = w.input("Rotary Trinkey M0");
  eq("raw before any message", slide.raw, -1);
  sin.receive([0xb0, 1, 127]); sin.receive([0x90, 60, 127]); w.frame();
  near("slider value", slide.value, 1); check("touched + justTouched", slide.touched && slide.justTouched());
  check("slide callbacks", calls(w).includes("sliderChanged 1") && calls(w).includes("touchPressed"));
  sin.receive([0x80, 60, 0]); w.frame(); check("touch released", !slide.touched && slide.justReleased());
  slide.pixel(64); eq("pixel", sout.sent.map(hex), ["90 40 7f", "80 40 00"]);
  kin.receive([0xb0, 2, 64]); kin.receive([0xb0, 3, 1]); kin.receive([0xb0, 3, 1]); kin.receive([0xb0, 3, 127]); w.frame();
  eq("knob raw", knob.raw, 64); eq("delta sums clicks", knob.delta, 1); check("knobTurned", calls(w).includes("knobTurned 1"));
  w.frame(); eq("delta resets", knob.delta, 0);
  kin.receive([0x90, 61, 127]); kin.receive([0x90, 62, 127]); w.frame();
  check("pressed + touched", knob.pressed && knob.justPressed() && knob.touched && knob.justTouched()); check("knobPressed", calls(w).includes("knobPressed"));
  kin.receive([0x80, 61, 0]); w.frame(); check("released", !knob.pressed && knob.justReleased() && knob.touched);
  // keyboard stand-in
  const w2 = load(fakeWindow(), "trinkeys.js"); const k2 = new w2.RotaryTrinkey(); await k2.connect();
  w2.fire("keydown", { key: "ArrowRight" }); w2.fire("keydown", { key: "Enter" }); w2.frame();
  eq("key click", k2.delta, 1); eq("key raw from 64", k2.raw, 65); check("key press", k2.pressed);
}

async function testMidiFighter() {
  const w = load(fakeWindow(["Midi Fighter Classic"]), "midifighter.js");
  const M = w.MidiFighter;
  eq("default top-left", M.noteForIndex(0), 48); eq("default bottom-right", M.noteForIndex(15), 39);
  eq("48 -> 0", M.indexForNote(48), { index: 0, bank: 0, select: false }); eq("64 -> ext bank 1", M.indexForNote(64), { index: 0, bank: 1, select: false });
  eq("35 -> null", M.indexForNote(35), null);
  eq("internal top row", M.noteForIndex(0, "internal"), 0); eq("internal bottom-left bank 3", M.noteForIndex(12, "internal", 3), 72);
  eq("internal 74", M.indexForNote(74, "internal"), { index: 14, bank: 3, select: false }); eq("internal 2 select", M.indexForNote(2, "internal"), { index: 2, bank: null, select: true });
  w.padPressed = (i) => calls(w).push("padPressed " + i); w.padReleased = (i) => calls(w).push("padReleased " + i); w.bankChanged = (b) => calls(w).push("bank " + b);
  const mf = new M(); await mf.connect();
  const out = w.output("Midi Fighter Classic"), inp = w.input("Midi Fighter Classic");
  mf.led(0, true); eq("led on", hex(out.sent.at(-1)), "92 30 7f");
  let n = out.sent.length; mf.led(0, true); eq("led dedupe", out.sent.length, n);
  mf.led(0, false); eq("led off", hex(out.sent.at(-1)), "82 30 00");
  inp.receive([0x92, 48, 127]); w.frame(); check("pad 0 pressed", mf.pressed(0) && mf.justPressed(0)); eq("callback", calls(w).at(-1), "padPressed 0");
  w.frame(); check("justPressed cleared", mf.pressed(0) && !mf.justPressed(0));
  inp.receive([0x82, 48, 0]); w.frame(); check("released", !mf.pressed(0) && mf.justReleased(0));
  inp.receive([0x91, 48, 127]); w.frame(); check("other channel ignored", !mf.pressed(0));
  inp.receive([0x92, 3, 127]); inp.receive([0x92, 74, 127]); inp.receive([0x82, 74, 0]); w.frame();
  eq("mode internal", mf.mode, "internal"); eq("bank 3", mf.bank, 3); check("bank callback", calls(w).includes("bank 3"));
  check("14 pressed/released", calls(w).includes("padPressed 14") && mf.justReleased(14));
  mf.led(12, true); eq("led bottom-left bank 3", hex(out.sent.at(-1)), "92 48 7f");
  n = out.sent.length; mf.led(0, true); eq("bank button LED untouched", out.sent.length, n);
  mf.led(4, true, 0); eq("address another bank", hex(out.sent.at(-1)), "92 2c 7f");
  n = out.sent.length; mf.leds([5]);
  const sinceLeds = out.sent.slice(n).map(hex);
  check("leds(): 5 on (note 81 in bank 3)", sinceLeds.includes("92 51 7f")); check("leds(): 12 off", sinceLeds.includes("82 48 00"));
  check("leds(): bank buttons untouched", !sinceLeds.some((b) => b.endsWith(" 00 7f") || b.endsWith(" 01 7f") || b.endsWith(" 02 7f") || b.endsWith(" 03 7f")));
  const mapped = new M({ map: { buttons: [{ index: 0, channel: 1, note: 60 }, { index: 15, channel: 1, note: 61 }] } }); await mapped.connect();
  inp.receive([0x90, 61, 100]); w.frame(); check("mapped 61 -> 15", mapped.pressed(15));
  mapped.led(0, true); eq("mapped led", hex(out.sent.at(-1)), "90 3c 7f");
  // keyboard stand-in
  const w2 = load(fakeWindow(), "midifighter.js"); const m2 = new w2.MidiFighter(); await m2.connect();
  w2.fire("keydown", { key: "q" }); w2.frame(); check("key q = index 4", m2.pressed(4) && m2.justPressed(4));
}

async function testLaunchpad() {
  const w = load(fakeWindow(["LPMiniMK3 MIDI"]), "launchpad.js");
  const L = w.Launchpad;
  eq("bottom-left", L.xyToNote(0, 7), 11); eq("top-right", L.xyToNote(7, 0), 88); eq("64", L.noteToXY(64), { x: 3, y: 2 }); eq("19 not a pad", L.noteToXY(19), null);
  for (let y = 0; y < 8; y++) for (let x = 0; x < 8; x++) eq("roundtrip", L.noteToXY(L.xyToNote(x, y)), { x, y });
  eq("top0", L.buttonToCC("top0"), 91); eq("right7", L.buttonToCC("right7"), 19); eq("logo", L.buttonToCC("logo"), 99); eq("bogus", L.buttonToCC("nope"), null);
  for (const id of ["top0", "top5", "right0", "right3", "right7", "logo"]) eq("cc roundtrip " + id, L.ccToButton(L.buttonToCC(id)), id);
  eq("palette number", L.toColor(5), { palette: 5 }); eq("hex string", L.toColor("#ff0080"), { rgb: [255, 0, 128] }); eq("short hex", L.toColor("#f00"), { rgb: [255, 0, 0] });
  eq("name", L.toColor("cyan"), { palette: 37 }); eq("array", L.toColor([1, 2, 300]), { rgb: [1, 2, 255] }); eq("p5 color levels", L.toColor({ levels: [10, 20, 30, 255] }), { rgb: [10, 20, 30] });
  eq("packed int", L.toColor(0xff0080), { rgb: [255, 0, 128] }); eq("nearest palette red", L.nearestPalette([250, 10, 10]), 5); eq("nearest palette off", L.nearestPalette([0, 0, 0]), 0);
  w.padPressed = (x, y) => calls(w).push(`padPressed ${x},${y}`); w.buttonPressed = (id) => calls(w).push("buttonPressed " + id);
  const pad = new L(); await pad.connect();
  eq("asked for sysex", w.midiRequests[0], { sysex: true }); check("sysex enabled", pad.core.sysexEnabled);
  const out = w.output("LPMiniMK3 MIDI"), inp = w.input("LPMiniMK3 MIDI");
  eq("programmer mode on connect", hex(out.sent[0]), "f0 00 20 29 02 0d 0e 01 f7"); eq("clear on connect", out.sent[1].length, 7 + 81 * 3 + 1);
  pad.set(0, 0, 5); eq("palette note", hex(out.sent.at(-1)), "90 51 05");
  let n = out.sent.length; pad.set(0, 0, 5); eq("palette dedupe", out.sent.length, n);
  pad.pulse(0, 0, 21); eq("pulse", hex(out.sent.at(-1)), "92 51 15");
  pad.set(0, 7, "#ff0080"); eq("rgb sysex", hex(out.sent.at(-1)), "f0 00 20 29 02 0d 03 03 0b 7f 00 40 f7");
  n = out.sent.length; pad.setRGB(0, 7, 255, 0, 128); eq("setRGB same colour deduped", out.sent.length, n);
  pad.set(1, 1, { levels: [0, 255, 0, 255] }); eq("p5 color goes as rgb", hex(out.sent.at(-1)), "f0 00 20 29 02 0d 03 03 48 00 7f 00 f7");
  pad.button("logo", 3); eq("button cc", hex(out.sent.at(-1)), "b0 63 03");
  pad.flash(1, 1, 5, 0); eq("flash", hex(out.sent.at(-1)), "f0 00 20 29 02 0d 03 01 48 05 00 f7");
  pad.clear(); eq("clear first led", out.sent.at(-1)[8], 11); eq("clear last led", out.sent.at(-1).at(-3), 99);
  pad.text("hi", 37); eq("text", hex(out.sent.at(-1)), "f0 00 20 29 02 0d 07 00 07 00 25 68 69 f7");
  pad.text("A", "#ff0000", -7, true); eq("text rgb backwards loop", hex(out.sent.at(-1)), "f0 00 20 29 02 0d 07 01 79 01 7f 00 00 41 f7");
  inp.receive([0x90, 64, 127]); inp.receive([0xb0, 91, 127]); w.frame();
  check("pad 3,2 pressed", pad.pressed(3, 2) && pad.justPressed(3, 2)); check("top0", pad.buttonPressed("top0") && pad.buttonJustPressed("top0"));
  check("callbacks", calls(w).includes("padPressed 3,2") && calls(w).includes("buttonPressed top0"));
  inp.receive([0x90, 64, 0]); inp.receive([0xb0, 91, 0]); w.frame(); check("released", !pad.pressed(3, 2) && pad.justReleased(3, 2) && pad.buttonJustReleased("top0"));
  pad.close(); eq("close restores live mode", hex(out.sent.at(-1)), "f0 00 20 29 02 0d 0e 00 f7");
  // no sysex permission: RGB snaps to palette, clear uses notes
  const w2 = load(fakeWindow(["LPMiniMK3 MIDI"]), "launchpad.js"); w2.denySysex = true;
  const p2 = new w2.Launchpad(); await p2.connect();
  check("fell back without sysex", p2.connected() && !p2.core.sysexEnabled);
  const o2 = w2.output("LPMiniMK3 MIDI");
  p2.set(0, 0, "#ff0000"); eq("rgb snapped to palette red", hex(o2.sent.at(-1)), "90 51 05");
  check("no sysex bytes were sent", o2.sent.every((b) => b[0] !== 0xf0));
}

async function testCircuitPlayground() {
  const w = load(fakeWindow(["Circuit Playground Express"]), "circuitplayground.js");
  const C = w.CircuitPlayground;
  eq("pad 0 is pin 3", C.noteForPad(0), 4); eq("note 11 is pad 7", C.padForNote(11), 7); eq("note 5 is nothing", C.padForNote(5), -1);
  near("note 30 is +1g", C.accelFromNote(30), 1); near("note 15", C.accelFromNote(15), -0.509684);
  w.touchPressed = (p) => calls(w).push("touchPressed " + p); w.accelChanged = () => calls(w).push("accel");
  const cpx = new C(); await cpx.connect();
  const inp = w.input("Circuit Playground Express"), out = w.output("Circuit Playground Express");
  inp.receive([0x91, 4, 127]); w.frame(); check("touch 0", cpx.touch(0) && cpx.touchJustPressed(0)); eq("mode touch", cpx.mode, "touch"); check("callback", calls(w).includes("touchPressed 0"));
  inp.receive([0x81, 4, 0]); w.frame(); check("released", !cpx.touch(0) && cpx.touchJustReleased(0));
  inp.receive([0xb1, 1, 64]); w.frame(); near("light", cpx.light, 64 / 127); eq("temperature", cpx.temperature, 64); eq("mode sensor", cpx.mode, "sensor");
  cpx.core.inject(0x91, 20, 127, 1000); cpx.core.inject(0x91, 10, 127, 1001); cpx.core.inject(0x91, 30, 127, 1002); w.frame();
  eq("mode accel", cpx.mode, "accel"); near("x", cpx.accel.x, 0); near("y", cpx.accel.y, -1); near("z", cpx.accel.z, 1);
  check("burst leaves no touch", !cpx.touch(7)); check("accelChanged", calls(w).includes("accel"));
  cpx.core.inject(0x91, 4, 127, 3000); w.frame(); check("still accel: no touch", !cpx.touch(0));
  cpx.core.inject(0x81, 4, 0, 3100); cpx.core.inject(0x91, 4, 127, 3200); w.frame(); check("touch after note off", cpx.touch(0));
  cpx.pixels(255, 0, 130); eq("three notes", out.sent.length, 3); eq("red", hex(out.sent[0]), "90 7f 7f"); eq("green", hex(out.sent[1]), "91 00 00"); eq("blue", hex(out.sent[2]), "92 7f 03");
  cpx.pixels(255, 0, 130); eq("unchanged not re-sent", out.sent.length, 3); cpx.clear(); eq("clear re-sends red and blue", out.sent.length, 5);
  const w2 = load(fakeWindow(), "circuitplayground.js"); const c2 = new w2.CircuitPlayground(); await c2.connect();
  w2.fire("keydown", { key: "3" }); w2.frame(); check("key 3 = pad 2", c2.touch(2));
}

async function testAnyMidiAll() {
  const w = load(fakeWindow(["PipSqueak", "Midi Fighter Classic", "Slide Trinkey M0", "Rotary Trinkey M0"]), "anymidi.js");
  w.noteOn = (ch, n, v, dev) => calls(w).push(`noteOn ${ch} ${n} ${v} from ${dev}`);
  w.controlChange = (ch, n, v) => calls(w).push(`cc ${ch} ${n} ${v}`);
  const m = new w.AnyMidi(); eq("no name connects", await m.connect(), true);
  eq("listens to all four", m.devices(), ["PipSqueak", "Midi Fighter Classic", "Slide Trinkey M0", "Rotary Trinkey M0"]);
  eq("status", m.status, "listening to 4 inputs: PipSqueak, Midi Fighter Classic, Slide Trinkey M0, Rotary Trinkey M0");
  eq("first output", m.core.outputName, "PipSqueak");
  w.input("Rotary Trinkey M0").receive([0x90, 61, 127]); w.input("PipSqueak").receive([0xb0, 17, 60]); w.frame();
  eq("message from the fourth input", m.last.device, "PipSqueak"); eq("lastDevice", m.lastDevice, "PipSqueak");
  check("4-arg callback gets the device", calls(w).includes("noteOn 1 61 127 from Rotary Trinkey M0"));
  check("3-arg callback still works", calls(w).includes("cc 1 17 60"));
  check("note from the knob counted", m.down(61));
  m.close(); check("close detaches every input", [...w.ports.inputs.values()].every((p) => p.onmidimessage === null));
  const one = new w.AnyMidi("rotary"); await one.connect(); eq("a name narrows to one", one.devices(), ["Rotary Trinkey M0"]);
  eq("named status", one.status, "connected to Rotary Trinkey M0");
}

async function testAnyMidi() {
  const w = load(fakeWindow(["Some Trinkey"]), "anymidi.js");
  w.noteOn = (ch, n, v) => calls(w).push(`noteOn ${ch} ${n} ${v}`); w.pitchBend = (ch, v) => calls(w).push(`bend ${ch} ${v}`); w.midiMessage = (s, a, b) => calls(w).push(`raw ${s}`);
  const m = new w.AnyMidi(); eq("first input", await m.connect(), true); eq("picked the trinkey", m.core.inputName, "Some Trinkey");
  const inp = w.input("Some Trinkey"), out = w.output("Some Trinkey");
  eq("never seen", m.note(60), -1);
  inp.receive([0x90, 60, 100]); inp.receive([0xb5, 7, 42]); inp.receive([0xe0, 0, 0]); inp.receive([0xc0, 5]); w.frame();
  eq("note", m.note(60), 100); check("down", m.down(60)); eq("cc", m.cc(7), 42); eq("last channel", m.lastChannel, 1);
  eq("pitch bend min", m.pitchBend, -8192); eq("count", m.count, 4); eq("last", String(m.last), "program ch1 5 0");
  check("callbacks", calls(w).includes("noteOn 1 60 100") && calls(w).includes("bend 1 -8192") && calls(w).includes("raw 192"));
  inp.receive([0x80, 60, 0]); w.frame(); eq("note off -> 0", m.note(60), 0);
  m.noteOn(16, 1, 2); eq("send ch16", hex(out.sent.at(-1)), "9f 01 02"); m.send(0xc0, 5, 0); eq("raw send", hex(out.sent.at(-1)), "c0 05 00");
  const named = new w.AnyMidi("nothing"); eq("named miss", await named.connect(), false);
}

/** The ESM entry (midi-helpers.mjs): the same bundle as a module with named exports, importable with no window. */
async function testEsm() {
  const mod = await import(path.join(P5, "midi-helpers.mjs"));
  for (const n of ["MidiCore", "MidiMsg", "PipSqueak", "MidiFighter", "Launchpad", "CircuitPlayground", "AnyMidi", "SlideTrinkey", "RotaryTrinkey"]) check(`esm exports ${n}`, typeof mod[n] === "function");
  const stick = new mod.PipSqueak({ callbacks: {} });
  eq("esm constructor never touches hardware", stick.x, 0);
  eq("esm status before connect", stick.status, "not connected");
  eq("esm status when there is no Web MIDI", await stick.connect(), false);
  const mf = new mod.MidiFighter({ callbacks: {} });
  eq("esm statics", mod.MidiFighter.noteForIndex(0, "default", 0), 48);
  check("esm no global leak", typeof globalThis.PipSqueak === "undefined");
  // a page that already has the classic bundle: the module must hand back the same classes, statics intact
  const w = load(fakeWindow([]), "midi-helpers.js");
  globalThis.window = w;
  try {
    const again = await import(path.join(P5, "midi-helpers.mjs") + "?with-classic-bundle");
    check("esm shares the page's plumbing", again.MidiCore === w.MidiCore && again.MidiHelper === w.MidiHelper);   // midicore.js guards; device scripts redefine
    eq("esm statics intact (classes are not bound)", again.MidiFighter.noteForIndex(0, "default", 0), 48);
    check("esm classes construct on the page's MidiHelper", new again.PipSqueak({ callbacks: {} }) instanceof w.MidiHelper);
  } finally { delete globalThis.window; }
}

(async () => {
  for (const t of [testLoading, testCore, testPipSqueak, testPipSqueakLed, testTrinkeys, testMidiFighter, testLaunchpad, testCircuitPlayground, testAnyMidi, testAnyMidiAll, testEsm]) {
    try { await t(); } catch (e) { failed++; console.log("FAIL " + t.name + " threw " + (e.stack || e)); }
  }
  console.log(`node ${process.version}: ${passed} passed, ${failed} failed`);
  process.exit(failed ? 1 : 0);
})();
