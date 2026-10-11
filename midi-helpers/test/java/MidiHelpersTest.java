// Hardware-free tests for the Java helper tabs. Run with midi-helpers/test/java/build.sh.
// The tabs are compiled into a PApplet subclass called Sketch (see build.sh); a Sketch that is never
// run is enough to exercise the decode / encode logic because messages are injected by hand.
import processing.core.PApplet;
import processing.data.JSONObject;
import java.util.*;

public class MidiHelpersTest {
  static int passed = 0, failed = 0;
  static void check(String what, boolean ok) {
    if (ok) passed++; else { failed++; System.out.println("FAIL " + what); }
  }
  static void eq(String what, Object a, Object b) { check(what + " expected " + b + " got " + a, Objects.equals(a, b)); }
  static void near(String what, float a, float b) { check(what + " expected " + b + " got " + a, Math.abs(a - b) < 1e-4); }

  /** A sketch whose output port is a list we can inspect. */
  public static class Spy extends Sketch {   // public like a real sketch class: the library calls back by reflection
    ArrayList<int[]> sent = new ArrayList<>();
    ArrayList<byte[]> sysexSent = new ArrayList<>();
    ArrayList<String> calls = new ArrayList<>();
    public void noteOn(int ch, int n, int v) { calls.add("noteOn " + ch + " " + n + " " + v); }
    public void noteOff(int ch, int n, int v, String dev) { calls.add("noteOff " + ch + " " + n + " " + v + " from " + dev); }
    public void controlChange(int ch, int n, int v, String dev) { calls.add("cc " + ch + " " + n + " " + v + " from " + dev); }
    public void midiMessage(int s, int a, int b, String dev) { calls.add("raw " + s + " from " + dev); }
    public void padPressed(int i) { calls.add("padPressed " + i); }
    public void padReleased(int i) { calls.add("padReleased " + i); }
    public void bankChanged(int b) { calls.add("bank " + b); }
    public void stickPressed() { calls.add("stickPressed"); }
    public void padPressed(int x, int y) { calls.add("padPressed " + x + "," + y); }
    public void buttonPressed(String id) { calls.add("buttonPressed " + id); }
    public void sliderChanged(float v) { calls.add("sliderChanged " + v); }
    public void knobTurned(int d) { calls.add("knobTurned " + d); }
    public void knobPressed() { calls.add("knobPressed"); }
    public void touchPressed() { calls.add("touchPressed"); }
    void spyOn(MidiCore core) {
      core.verbose = false;
      core.out = new javax.sound.midi.Receiver() {
        public void send(javax.sound.midi.MidiMessage m, long t) {
          if (m instanceof javax.sound.midi.ShortMessage) {
            javax.sound.midi.ShortMessage s = (javax.sound.midi.ShortMessage) m;
            sent.add(new int[] { s.getStatus(), s.getData1(), s.getData2() });
          } else sysexSent.add(m.getMessage());
        }
        public void close() {}
      };
    }
    int[] last() { return sent.get(sent.size() - 1); }
    byte[] lastSysex() { return sysexSent.get(sysexSent.size() - 1); }
  }

  static String hex(byte[] b) { StringBuilder sb = new StringBuilder(); for (byte x : b) sb.append(String.format("%02x ", x & 0xff)); return sb.toString().trim(); }
  static String hex(int[] b) { StringBuilder sb = new StringBuilder(); for (int x : b) sb.append(String.format("%02x ", x & 0xff)); return sb.toString().trim(); }

  public static void main(String[] args) {
    testMidiMsg();
    testPipSqueak();
    testMidiFighter();
    testLaunchpad();
    testAnyMidi();
    testCircuitPlayground();
    testPipSqueakLed();
    testTrinkeys();
    System.out.println(passed + " passed, " + failed + " failed");
    System.exit(failed == 0 ? 0 : 1);
  }

  static void testMidiMsg() {
    Spy s = new Spy();
    Sketch.MidiMsg m = s.new MidiMsg(0x92, 48, 127, 0);
    eq("channel", m.channel, 3); eq("type", m.type, 0x90); check("noteOn", m.isNoteOn() && !m.isNoteOff());
    m = s.new MidiMsg(0x90, 48, 0, 0);
    check("velocity 0 is note off", m.isNoteOff() && !m.isNoteOn());
    m = s.new MidiMsg(0xE0, 0, 64, 0);
    eq("pitch bend centre", m.pitchBend(), 0);
    Sketch.MidiCore core = s.new MidiCore(s, "nothing-matches-this");
    s.spyOn(core);
    core.noteOn(3, 48, 127); eq("noteOn bytes", hex(s.last()), "92 30 7f");
    core.noteOff(3, 48); eq("noteOff bytes", hex(s.last()), "82 30 00");
    core.controlChange(1, 7, 200); eq("cc clamps to 7 bits", hex(s.last()), "b0 07 48");
    core.pitchBend(1, 0); eq("pitch bend centre bytes", hex(s.last()), "e0 00 40");
    core.sysex(new int[] { 0xF0, 0x7E, 0xF7 }); eq("sysex passthrough", hex(s.lastSysex()), "f0 7e f7");
  }

  static void testPipSqueak() {
    Spy s = new Spy();
    Sketch.PipSqueakConfig c = s.new PipSqueakConfig();
    near("axis centre", c.normalizeAxis(60, 60, 0, 126, false), 0);
    near("axis max", c.normalizeAxis(126, 60, 0, 126, false), 1);
    near("axis min", c.normalizeAxis(0, 60, 0, 126, false), -1);
    near("axis half below", c.normalizeAxis(30, 60, 0, 126, false), -0.5f);
    near("axis invert", c.normalizeAxis(126, 60, 0, 126, true), -1);
    float[] n = c.normalize(60, 68);
    check("rest is deadzone: angle NaN", Float.isNaN(n[2]) && n[0] == 0 && n[1] == 0 && n[3] == 0);
    n = c.normalize(126, 68);
    near("full right x", n[0], 1); near("full right y", n[1], 0); near("full right angle", n[2], 0); near("full right magnitude", n[3], 1);
    n = c.normalize(60, 126);
    near("full up angle", n[2], (float) (Math.PI / 2));
    n = c.normalize(93, 68); // halfway right: (0.5 - 0.1) / 0.9
    near("half right magnitude", n[3], 0.4444444f);
    JSONObject json = JSONObject.parse("{\"x\": {\"cc\": 1, \"center\": 64}, \"button\": {\"note\": 60}, \"smoothing\": 0.5}");
    Sketch.PipSqueakConfig j = s.new PipSqueakConfig(json);
    eq("json x cc", j.xCC, 1); eq("json x center", j.xCenter, 64); eq("json x max default", j.xMax, 126);
    eq("json y untouched", j.yCC, 20); eq("json button note", j.buttonNote, 60); near("json smoothing", j.smoothing, 0.5f);

    Sketch.PipSqueak stick = s.new PipSqueak(s);
    s.spyOn(stick.core);
    stick.core.input = null;
    stick.core.inject(0xB0, 17, 126); stick.core.inject(0xB0, 20, 68); stick.core.inject(0xB0, 25, 127);
    // the keyboard stand-in only kicks in when nothing is connected; pretend the input is open
    stick.core.input = fakeDevice();
    stick.pre();
    near("stick x", stick.x, 1); near("stick y", stick.y, 0); check("pressed", stick.pressed && stick.justPressed() && !stick.justReleased());
    eq("stickPressed callback", s.calls.contains("stickPressed"), true);
    stick.pre();
    check("justPressed lasts one frame", stick.pressed && !stick.justPressed());
    stick.core.inject(0xB0, 25, 0); stick.pre();
    check("released", !stick.pressed && stick.justReleased());
    stick.core.inject(0xB0, 17, 60); stick.pre();
    near("back to centre", stick.magnitude, 0); check("angle NaN at rest", Float.isNaN(stick.angle));
    eq("still the stock profile", stick.config.profile, "stock");

    // a unit on the usemidi default map (CC 10 / CC 7 / note 60, measured 2026-10-02) is adopted on its first message
    Sketch.PipSqueak u = s.new PipSqueak(s); u.core.verbose = false; u.core.input = fakeDevice();
    u.core.inject(0xB0, 7, 70); u.pre();                       // first y message at rest: profile switches, centre snaps to 70
    eq("usemidi profile adopted", u.config.profile, "usemidi"); eq("y centre learned", u.config.yCenter, 70);
    near("rest after switch", u.magnitude, 0);
    u.core.inject(0xB0, 10, 126); u.pre();
    near("usemidi x full right", u.x, 1); near("usemidi y", u.y, 0);
    eq("x centre kept (first value was not near rest)", u.config.xCenter, 67);
    u.core.inject(0x90, 60, 127); u.pre(); check("note button pressed", u.pressed && u.justPressed());
    u.core.inject(0x80, 60, 127); u.pre(); check("note button released", !u.pressed && u.justReleased());
    u.core.inject(0xB0, 25, 127); u.pre(); check("stock button cc ignored once on usemidi", !u.pressed);

    // an explicit config is taken literally: no auto-switching
    Sketch.PipSqueak fixed = s.new PipSqueak(s, "pipsqueak", json); fixed.core.verbose = false; fixed.core.input = fakeDevice();
    fixed.core.inject(0xB0, 10, 126); fixed.pre();
    check("explicit config does not switch profiles", !fixed.config.auto && fixed.config.profile.equals("custom") && fixed.x == 0);
  }

  static javax.sound.midi.MidiDevice fakeDevice() {
    return (javax.sound.midi.MidiDevice) java.lang.reflect.Proxy.newProxyInstance(MidiHelpersTest.class.getClassLoader(),
      new Class[] { javax.sound.midi.MidiDevice.class }, (p, m, a) -> { if (m.getReturnType() == boolean.class) return true; if (m.getReturnType() == int.class) return 1; return null; });
  }

  static void testMidiFighter() {
    Spy s = new Spy();
    Sketch.MidiFighter mf = s.new MidiFighter(s);
    s.spyOn(mf.core);
    mf.core.input = fakeDevice();
    eq("default top-left", mf.noteForIndex(0), 48); eq("default top-right", mf.noteForIndex(3), 51);
    eq("default bottom-left", mf.noteForIndex(12), 36); eq("default bottom-right", mf.noteForIndex(15), 39);
    eq("48 -> index 0", mf.indexForNote(48)[0], 0); eq("39 -> index 15", mf.indexForNote(39)[0], 15);
    eq("64 -> external bank 1 top-left", Arrays.toString(mf.indexForNote(64)), "[0, 1, 0]");
    eq("35 -> null", mf.indexForNote(35), null);
    mf.led(0, true); eq("led on bytes", hex(s.last()), "92 30 7f");
    int before = s.sent.size(); mf.led(0, true); eq("led dedupe", s.sent.size(), before);
    mf.led(0, false); eq("led off bytes", hex(s.last()), "82 30 00");
    mf.core.inject(0x92, 48, 127); mf.pre();
    check("pad 0 pressed", mf.pressed(0) && mf.justPressed(0));
    eq("padPressed callback", s.calls.get(s.calls.size() - 1), "padPressed 0");
    mf.pre(); check("justPressed cleared", mf.pressed(0) && !mf.justPressed(0));
    mf.core.inject(0x82, 48, 0); mf.pre(); check("released", !mf.pressed(0) && mf.justReleased(0));
    mf.core.inject(0x91, 48, 127); mf.pre(); check("other channel ignored", !mf.pressed(0));
    // internal mode auto-detect: bank 4 selected (note 3), then note 74 = index 14 in bank 3 (0-based)
    mf.core.inject(0x92, 3, 127); mf.core.inject(0x92, 74, 127); mf.core.inject(0x82, 74, 0); mf.pre();
    eq("mode internal", mf.mode, "internal"); eq("bank 3", mf.bank, 3);
    check("bank callback", s.calls.contains("bank 3"));
    check("index 14 pressed then released", s.calls.contains("padPressed 14") && s.calls.contains("padReleased 14") && mf.justReleased(14));
    eq("internal top row note", mf.noteForIndex(0), 0);
    eq("internal bottom-left bank 0", mf.noteForIndex(12, 0), 36);
    eq("internal bottom-left bank 3", mf.noteForIndex(12, 3), 72);
    eq("internal row 2 right bank 3", mf.noteForIndex(7, 3), 83);
    mf.led(12, true); eq("led bottom-left bank 3", hex(s.last()), "92 48 7f");
    before = s.sent.size(); mf.led(0, true); eq("bank buttons LEDs are owned by the device", s.sent.size(), before);
    mf.led(4, true, 0); eq("address another bank", hex(s.last()), "92 2c 7f");
    // learned map
    Sketch.MidiFighter mapped = s.new MidiFighter(s);
    s.spyOn(mapped.core); mapped.core.input = fakeDevice();
    mapped.setMap(JSONObject.parse("{\"buttons\": [{\"index\": 0, \"channel\": 1, \"note\": 60}, {\"index\": 15, \"channel\": 1, \"note\": 61}]}"));
    mapped.core.inject(0x90, 61, 100); mapped.pre(); check("mapped note 61 -> 15", mapped.pressed(15));
    mapped.led(0, true); eq("mapped led", hex(s.last()), "90 3c 7f");
  }

  static void testPipSqueakLed() {
    Spy s = new Spy();
    Sketch.PipSqueak stick = s.new PipSqueak(s, "no-such-device-" + System.nanoTime());
    stick.core.verbose = false;
    stick.flash(); // no output matching: silent no-op (a real stick may be plugged in while tests run)
    eq("flash without output sends nothing", s.sent.size(), 0);
    check("warned once", stick.outputWarned);
    s.spyOn(stick.core); stick.core.output = fakeDevice();
    stick.flash();
    eq("flash = note on 60 then note off", hex(s.sent.get(0)) + " / " + hex(s.sent.get(1)), "90 3c 7f / 80 3c 00");
    stick.send(0xB0, 20, 5); eq("send passes through", hex(s.last()), "b0 14 05");
  }

  static void testTrinkeys() {
    Spy s = new Spy();
    Sketch.SlideTrinkey slide = s.new SlideTrinkey(s);
    s.spyOn(slide.core); slide.core.input = fakeDevice();
    eq("raw before any message", slide.raw, -1);
    slide.core.inject(0xB0, 1, 127); slide.core.inject(0x90, 60, 127); slide.pre();
    near("slider value", slide.value, 1); eq("slider raw", slide.raw, 127);
    check("touched + justTouched", slide.touched && slide.justTouched());
    check("callbacks", s.calls.contains("sliderChanged 1.0") && s.calls.contains("touchPressed"));
    slide.core.inject(0x80, 60, 0); slide.pre(); check("touch released", !slide.touched && slide.justReleased());
    slide.core.inject(0xB0, 2, 50); slide.pre(); eq("other cc ignored", slide.raw, 127);
    slide.pixel(64); eq("pixel note on", hex(s.sent.get(s.sent.size() - 2)), "90 40 7f"); eq("pixel note off", hex(s.last()), "80 40 00");

    Sketch.RotaryTrinkey knob = s.new RotaryTrinkey(s);
    s.spyOn(knob.core); knob.core.input = fakeDevice();
    eq("relative 1", knob.relative(1), 1); eq("relative 127", knob.relative(127), -1); eq("relative 125", knob.relative(125), -3);
    knob.core.inject(0xB0, 2, 64); knob.core.inject(0xB0, 3, 1); knob.core.inject(0xB0, 3, 1); knob.core.inject(0xB0, 3, 127); knob.pre();
    eq("knob raw", knob.raw, 64); near("knob value", knob.value, 64 / 127f); eq("delta sums clicks", knob.delta, 1);
    check("knobTurned callback", s.calls.contains("knobTurned 1"));
    knob.pre(); eq("delta resets", knob.delta, 0);
    knob.core.inject(0x90, 61, 127); knob.core.inject(0x90, 62, 127); knob.pre();
    check("pressed + touched", knob.pressed && knob.justPressed() && knob.touched && knob.justTouched());
    check("knobPressed callback", s.calls.contains("knobPressed"));
    knob.core.inject(0x80, 61, 0); knob.pre(); check("released", !knob.pressed && knob.justReleased() && knob.touched);
  }

  static void testLaunchpad() {
    Spy s = new Spy();
    Sketch.Launchpad pad = s.new Launchpad(s);
    s.spyOn(pad.core); pad.core.input = fakeDevice();
    eq("bottom-left note", pad.xyToNote(0, 7), 11); eq("top-right note", pad.xyToNote(7, 0), 88); eq("3,2 note", pad.xyToNote(3, 2), 64);
    eq("64 -> 3,2", Arrays.toString(pad.noteToXY(64)), "[3, 2]"); eq("19 is not a pad", pad.noteToXY(19), null);
    for (int y = 0; y < 8; y++) for (int x = 0; x < 8; x++) { int[] r = pad.noteToXY(pad.xyToNote(x, y)); check("roundtrip " + x + "," + y, r[0] == x && r[1] == y); }
    eq("top0", pad.buttonToCC("top0"), 91); eq("top7", pad.buttonToCC("top7"), 98); eq("right0", pad.buttonToCC("right0"), 89);
    eq("right7", pad.buttonToCC("right7"), 19); eq("logo", pad.buttonToCC("logo"), 99); eq("bogus", pad.buttonToCC("nope"), -1);
    for (String id : new String[] { "top0", "top5", "right0", "right3", "right7", "logo" }) eq("cc roundtrip " + id, pad.ccToButton(pad.buttonToCC(id)), id);
    eq("cc 64 is a pad", pad.ccToButton(64), null);
    pad.set(0, 0, 5); eq("palette note", hex(s.last()), "90 51 05");
    int before = s.sent.size(); pad.set(0, 0, 5); eq("palette dedupe", s.sent.size(), before);
    pad.pulse(0, 0, 21); eq("pulse on channel 3", hex(s.last()), "92 51 15");
    pad.set(0, 7, 0xFFFF0080); eq("rgb sysex", hex(s.lastSysex()), "f0 00 20 29 02 0d 03 03 0b 7f 00 40 f7");
    pad.setRGB(0, 7, 255, 0, 128); eq("setRGB same colour deduped", hex(s.lastSysex()), "f0 00 20 29 02 0d 03 03 0b 7f 00 40 f7");
    int sx = s.sysexSent.size(); pad.setRGB(0, 7, 254, 0, 128); eq("setRGB 254 is a new value", s.sysexSent.size(), sx + 1);
    pad.button("logo", 3); eq("button palette cc", hex(s.last()), "b0 63 03");
    pad.button("top3", 0xFF00FF00); eq("button rgb sysex", hex(s.lastSysex()), "f0 00 20 29 02 0d 03 03 5e 00 7f 00 f7");
    pad.flash(1, 1, 5, 0); eq("flash sysex", hex(s.lastSysex()), "f0 00 20 29 02 0d 03 01 48 05 00 f7");
    pad.clear(); byte[] c = s.lastSysex(); eq("clear length", c.length, 7 + 81 * 3 + 1); eq("clear first led", c[8] & 0xff, 11); eq("clear last led", c[c.length - 3] & 0xff, 99);
    pad.text("hi", 37); eq("text sysex", hex(s.lastSysex()), "f0 00 20 29 02 0d 07 00 07 00 25 68 69 f7");
    pad.text("A", 0xFFFF0000, -7, true); eq("text rgb looping backwards", hex(s.lastSysex()), "f0 00 20 29 02 0d 07 01 79 01 7f 00 00 41 f7");
    pad.programmerMode(true); eq("programmer mode", hex(s.lastSysex()), "f0 00 20 29 02 0d 0e 01 f7");
    pad.core.inject(0x90, 64, 127); pad.core.inject(0xB0, 91, 127); pad.pre();
    check("pad 3,2 pressed", pad.pressed(3, 2) && pad.justPressed(3, 2));
    check("top0 pressed", pad.buttonPressed("top0") && pad.buttonJustPressed("top0"));
    check("callbacks", s.calls.contains("padPressed 3,2") && s.calls.contains("buttonPressed top0"));
    pad.core.inject(0x90, 64, 0); pad.core.inject(0xB0, 91, 0); pad.pre();
    check("released", !pad.pressed(3, 2) && pad.justReleased(3, 2) && !pad.buttonPressed("top0") && pad.buttonJustReleased("top0"));
  }

  static void testAnyMidi() {
    Spy s = new Spy();
    Sketch.AnyMidi m = s.new AnyMidi(s);
    s.spyOn(m.core); m.core.input = fakeDevice();
    eq("never seen note", m.note(60), -1); eq("never seen cc", m.cc(1), -1);
    m.core.inject(0x90, 60, 100); m.core.inject(0xB5, 7, 42); m.core.inject(0xE0, 0, 0); m.pre();
    eq("note velocity", m.note(60), 100); check("down", m.down(60)); eq("cc", m.cc(7), 42); eq("last channel", m.lastChannel, 1);
    eq("pitch bend min", m.pitchBend, -8192); eq("count", m.count, 3);
    eq("noteOn callback", s.calls.get(0), "noteOn 1 60 100");
    m.core.inject(0x80, 60, 0); m.pre(); eq("note off -> 0", m.note(60), 0); check("not down", !m.down(60));
    m.core.inject(0xB0, 1, 5, "Slide Trinkey M0"); m.core.inject(0x90, 61, 9, "Rotary Trinkey M0"); m.core.inject(0x80, 61, 0, "Rotary Trinkey M0"); m.core.inject(0xC0, 2, 0, "Other"); m.pre();
    eq("message carries its device", m.last.device, "Other"); eq("lastDevice", m.lastDevice, "Other");
    check("4-arg cc callback gets the device", s.calls.contains("cc 1 1 5 from Slide Trinkey M0"));
    check("3-arg noteOn still called (device dropped)", s.calls.contains("noteOn 1 61 9"));
    check("4-arg noteOff gets the device", s.calls.contains("noteOff 1 61 0 from Rotary Trinkey M0"));
    check("midiMessage gets the device", s.calls.contains("raw 192 from Other"));
    eq("status before connect", m.status(), "not connected");
    m.noteOn(16, 1, 2); eq("send ch16", hex(s.last()), "9f 01 02");
    m.send(0xC0, 5, 0); eq("raw send", hex(s.last()), "c0 05 00");
  }

  static void testCircuitPlayground() {
    Spy s = new Spy();
    Sketch.CircuitPlayground cpx = s.new CircuitPlayground(s);
    s.spyOn(cpx.core); cpx.core.input = fakeDevice();
    eq("pad 0 is pin 3", cpx.noteForPad(0), 4); eq("note 11 is pad 7", cpx.padForNote(11), 7); eq("note 5 is nothing", cpx.padForNote(5), -1);
    near("note 30 is +1g", cpx.accelFromNote(30), 1); near("note 20 is 0g", cpx.accelFromNote(20), 0); near("note 15 is about -0.5g", cpx.accelFromNote(15), -0.509684f);
    // touch: note on / note off
    cpx.core.inject(0x91, 4, 127); cpx.pre();
    check("touch 0 pressed", cpx.touch(0) && cpx.touchJustPressed(0)); eq("mode touch", cpx.mode, "touch");
    cpx.core.inject(0x81, 4, 0); cpx.pre(); check("touch 0 released", !cpx.touch(0) && cpx.touchJustReleased(0));
    // sensors
    cpx.core.inject(0xB1, 1, 64); cpx.pre(); near("light", cpx.light, 64 / 127f); eq("temperature raw", (int) cpx.temperature, 64); eq("sensor", cpx.sensor, 64); eq("mode sensor", cpx.mode, "sensor");
    // accelerometer burst: X, Y, Z at the same millis
    cpx.core.queue.add(s.new MidiMsg(0x91, 20, 127, 1000)); cpx.core.queue.add(s.new MidiMsg(0x91, 10, 127, 1001)); cpx.core.queue.add(s.new MidiMsg(0x91, 30, 127, 1002));
    cpx.pre();
    eq("mode accel", cpx.mode, "accel"); near("accel x", cpx.accel.x, 0); near("accel y", cpx.accel.y, -1); near("accel z", cpx.accel.z, 1);
    check("burst does not leave a touch (note 10 is pad 7)", !cpx.touch(7));
    // a lone note 4 two seconds later is a touch again only after a note off resets the mode
    cpx.core.queue.add(s.new MidiMsg(0x91, 4, 127, 3000)); cpx.pre(); check("still accel: no touch", !cpx.touch(0));
    cpx.core.queue.add(s.new MidiMsg(0x81, 4, 0, 3100)); cpx.core.queue.add(s.new MidiMsg(0x91, 4, 127, 3200)); cpx.pre();
    check("touch after note off", cpx.touch(0));
    // colour mixer output
    cpx.pixels(255, 0, 130);
    eq("three notes sent", s.sent.size(), 3);
    eq("red = 127 + 127", hex(s.sent.get(0)), "90 7f 7f"); eq("green 0", hex(s.sent.get(1)), "91 00 00"); eq("blue 130 = 127 + 3", hex(s.sent.get(2)), "92 7f 03");
    cpx.pixels(255, 0, 130); eq("unchanged colour not re-sent", s.sent.size(), 3);
    cpx.clear(); eq("clear re-sends only red and blue", s.sent.size(), 5);
  }
}
