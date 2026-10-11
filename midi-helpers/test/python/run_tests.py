# -*- coding: utf-8 -*-
"""Hardware-free tests for the Python Mode modules. Runs under CPython 3 and under the Jython 2.7 that
ships with Processing's Python Mode (see run.sh). Messages are injected by hand; sends are captured."""
from __future__ import division, print_function
import math
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "python"))

from midicore import MidiMsg, MidiCore  # noqa: E402
import pipsqueak, midifighter, launchpad, anymidi, circuitplayground, trinkeys  # noqa: E402

passed = [0]
failed = [0]


def check(what, ok):
    if ok:
        passed[0] += 1
    else:
        failed[0] += 1
        print("FAIL " + what)


def eq(what, a, b):
    check("%s expected %r got %r" % (what, b, a), a == b)


def near(what, a, b):
    check("%s expected %r got %r" % (what, b, a), a is not None and abs(a - b) < 1e-4)


class FakeApplet(object):
    """Just enough of PApplet: a frame counter the helpers watch and a clock."""

    def __init__(self):
        self.frameCount = 0
        self.ms = 0

    def millis(self):
        return self.ms

    def frame(self):
        self.frameCount += 1


CALLS = []
CALLBACKS = {
    "note_on": lambda ch, n, v: CALLS.append("note_on %d %d %d" % (ch, n, v)),
    "note_off": lambda ch, n, v, dev: CALLS.append("note_off %d %d %d from %s" % (ch, n, v, dev)),
    "control_change": lambda ch, n, v, dev: CALLS.append("cc %d %d %d from %s" % (ch, n, v, dev)),
    "midi_message": lambda s, a, b, dev: CALLS.append("raw %d from %s" % (s, dev)),
    "pad_pressed": lambda *a: CALLS.append("pad_pressed " + ",".join(str(x) for x in a)),
    "pad_released": lambda *a: CALLS.append("pad_released " + ",".join(str(x) for x in a)),
    "bank_changed": lambda b: CALLS.append("bank %d" % b),
    "stick_pressed": lambda: CALLS.append("stick_pressed"),
    "button_pressed": lambda name: CALLS.append("button_pressed " + name),
    "touch_pressed": lambda *a: CALLS.append("touch_pressed" + ("".join(" %d" % x for x in a))),
    "slider_changed": lambda v: CALLS.append("slider_changed %.3f" % v),
    "knob_turned": lambda d: CALLS.append("knob_turned %d" % d),
    "knob_pressed": lambda: CALLS.append("knob_pressed"),
}


def spy(core):
    """Capture everything the helper would send."""
    sent = []
    core._emit = sent.append
    core.verbose = False
    core.input = object()  # pretend an input is open so keyboard stand-ins stay out of the way
    return sent


def hexs(data):
    return " ".join("%02x" % b for b in data)


def test_midicore():
    m = MidiMsg(0x92, 48, 127)
    eq("channel", m.channel, 3)
    eq("type", m.type, 0x90)
    check("note on", m.is_note_on() and not m.is_note_off())
    check("velocity 0 is note off", MidiMsg(0x90, 48, 0).is_note_off())
    eq("pitch bend centre", MidiMsg(0xE0, 0, 64).pitch_bend(), 0)
    core = MidiCore(None, "x")
    sent = spy(core)
    core.note_on(3, 48, 127)
    eq("note on bytes", hexs(sent[-1]), "92 30 7f")
    core.note_off(3, 48)
    eq("note off bytes", hexs(sent[-1]), "82 30 00")
    core.control_change(1, 7, 200)
    eq("cc clamps", hexs(sent[-1]), "b0 07 48")
    core.pitch_bend(1, 0)
    eq("pitch bend bytes", hexs(sent[-1]), "e0 00 40")
    core.sysex([0xF0, 0x7E, 0xF7])
    eq("sysex passthrough", hexs(sent[-1]), "f0 7e f7")
    core.callbacks = None


def test_pipsqueak():
    cfg = pipsqueak.merge_config(None)
    near("axis centre", pipsqueak.normalize_axis(60, cfg["x"]), 0)
    near("axis max", pipsqueak.normalize_axis(126, cfg["x"]), 1)
    near("axis min", pipsqueak.normalize_axis(0, cfg["x"]), -1)
    near("axis half below", pipsqueak.normalize_axis(30, cfg["x"]), -0.5)
    x, y, angle, mag = pipsqueak.normalize(60, 68, cfg)
    check("rest is deadzone", x == 0 and y == 0 and angle is None and mag == 0)
    x, y, angle, mag = pipsqueak.normalize(126, 68, cfg)
    near("full right x", x, 1)
    near("full right angle", angle, 0)
    near("full right magnitude", mag, 1)
    near("full up angle", pipsqueak.normalize(60, 126, cfg)[2], math.pi / 2)
    near("half right magnitude", pipsqueak.normalize(93, 68, cfg)[3], 0.4444444)
    merged = pipsqueak.merge_config({"x": {"cc": 1}, "smoothing": 0.5})
    eq("merged x cc", merged["x"]["cc"], 1)
    eq("merged x center kept", merged["x"]["center"], 60)
    eq("merged smoothing", merged["smoothing"], 0.5)

    app = FakeApplet()
    stick = pipsqueak.PipSqueak(app, callbacks=CALLBACKS)
    sent = spy(stick.core)
    stick.core.inject(0xB0, 17, 126)
    stick.core.inject(0xB0, 20, 68)
    stick.core.inject(0xB0, 25, 127)
    app.frame()
    near("stick x", stick.x, 1)
    near("stick y", stick.y, 0)
    check("pressed", stick.pressed and stick.just_pressed() and not stick.just_released())
    check("stick_pressed callback", "stick_pressed" in CALLS)
    eq("events", stick.events(), ["press"])
    app.frame()
    check("just_pressed lasts one frame", stick.pressed and not stick.just_pressed())
    stick.core.inject(0xB0, 25, 0)
    app.frame()
    check("released", not stick.pressed and stick.just_released())
    stick.core.inject(0xB0, 17, 60)
    app.frame()
    near("back to centre", stick.magnitude, 0)
    check("angle None at rest", stick.angle is None)
    old = pipsqueak.PipSqueak({"smoothing": 0.5})
    eq("old form keeps config", old.config["smoothing"], 0.5)
    check("old form has no applet", old.applet is None)
    old.update()
    eq("old form update", old.x, 0.0)


def test_midifighter():
    eq("default top-left", midifighter.note_for_index(0), 48)
    eq("default bottom-right", midifighter.note_for_index(15), 39)
    eq("48 -> 0", midifighter.index_for_note(48), (0, 0, False))
    eq("64 -> external bank 1", midifighter.index_for_note(64), (0, 1, False))
    eq("35 -> None", midifighter.index_for_note(35), None)
    eq("internal top row", midifighter.note_for_index(0, "internal"), 0)
    eq("internal bottom-left bank 3", midifighter.note_for_index(12, "internal", 3), 72)
    eq("internal 74 -> 14 bank 3", midifighter.index_for_note(74, "internal"), (14, 3, False))
    eq("internal 2 -> select", midifighter.index_for_note(2, "internal"), (2, None, True))

    app = FakeApplet()
    mf = midifighter.MidiFighter(app, callbacks=CALLBACKS)
    sent = spy(mf.core)
    mf.led(0, True)
    eq("led on", hexs(sent[-1]), "92 30 7f")
    n = len(sent)
    mf.led(0, True)
    eq("led dedupe", len(sent), n)
    mf.led(0, False)
    eq("led off", hexs(sent[-1]), "82 30 00")
    mf.core.inject(0x92, 48, 127)
    app.frame()
    check("pad 0 pressed", mf.pressed(0) and mf.just_pressed(0))
    eq("pad_pressed callback", CALLS[-1], "pad_pressed 0")
    app.frame()
    check("just_pressed cleared", mf.pressed(0) and not mf.just_pressed(0))
    mf.core.inject(0x82, 48, 0)
    app.frame()
    check("released", not mf.pressed(0) and mf.just_released(0))
    mf.core.inject(0x91, 48, 127)
    app.frame()
    check("other channel ignored", not mf.pressed(0))
    mf.core.inject(0x92, 3, 127)
    mf.core.inject(0x92, 74, 127)
    mf.core.inject(0x82, 74, 0)
    app.frame()
    eq("mode internal", mf.mode, "internal")
    eq("bank 3", mf.bank, 3)
    check("bank callback", "bank 3" in CALLS)
    check("14 pressed and released", "pad_pressed 14" in CALLS and mf.just_released(14))
    mf.led(12, True)
    eq("led bottom-left bank 3", hexs(sent[-1]), "92 48 7f")
    n = len(sent)
    mf.led(0, True)
    eq("bank button LED untouched", len(sent), n)
    mf.led(4, True, 0)
    eq("address another bank", hexs(sent[-1]), "92 2c 7f")
    mapped = midifighter.MidiFighter(app)
    sent2 = spy(mapped.core)
    mapped.set_map({"buttons": [{"index": 0, "channel": 1, "note": 60}, {"index": 15, "channel": 1, "note": 61}]})
    mapped.core.inject(0x90, 61, 100)
    app.frame()
    check("mapped 61 -> 15", mapped.pressed(15))
    mapped.led(0, True)
    eq("mapped led", hexs(sent2[-1]), "90 3c 7f")


def test_launchpad():
    eq("bottom-left", launchpad.xy_to_note(0, 7), 11)
    eq("top-right", launchpad.xy_to_note(7, 0), 88)
    eq("64 -> 3,2", launchpad.note_to_xy(64), (3, 2))
    eq("19 not a pad", launchpad.note_to_xy(19), None)
    for y in range(8):
        for x in range(8):
            eq("roundtrip", launchpad.note_to_xy(launchpad.xy_to_note(x, y)), (x, y))
    eq("top0", launchpad.button_to_cc("top0"), 91)
    eq("right7", launchpad.button_to_cc("right7"), 19)
    eq("logo", launchpad.button_to_cc("logo"), 99)
    eq("bogus", launchpad.button_to_cc("nope"), None)
    for name in ["top0", "top5", "right0", "right3", "right7", "logo"]:
        eq("cc roundtrip " + name, launchpad.cc_to_button(launchpad.button_to_cc(name)), name)
    app = FakeApplet()
    pad = launchpad.Launchpad(app, callbacks=CALLBACKS)
    sent = spy(pad.core)
    pad.set(0, 0, 5)
    eq("palette note", hexs(sent[-1]), "90 51 05")
    n = len(sent)
    pad.set(0, 0, 5)
    eq("palette dedupe", len(sent), n)
    pad.pulse(0, 0, 21)
    eq("pulse", hexs(sent[-1]), "92 51 15")
    pad.set(0, 7, -65408)  # 0xFFFF0080 as Processing hands it over (a negative int)
    eq("rgb sysex", hexs(sent[-1]), "f0 00 20 29 02 0d 03 03 0b 7f 00 40 f7")
    n = len(sent)
    pad.set_rgb(0, 7, 255, 0, 128)
    eq("set_rgb same colour deduped", len(sent), n)
    pad.button("logo", 3)
    eq("button cc", hexs(sent[-1]), "b0 63 03")
    pad.flash(1, 1, 5, 0)
    eq("flash", hexs(sent[-1]), "f0 00 20 29 02 0d 03 01 48 05 00 f7")
    pad.clear()
    eq("clear length", len(sent[-1]), 7 + 81 * 3 + 1)
    eq("clear first led", sent[-1][8], 11)
    eq("clear last led", sent[-1][-3], 99)
    pad.text("hi", 37)
    eq("text", hexs(sent[-1]), "f0 00 20 29 02 0d 07 00 07 00 25 68 69 f7")
    pad.text("A", -65536, -7, True)
    eq("text rgb backwards loop", hexs(sent[-1]), "f0 00 20 29 02 0d 07 01 79 01 7f 00 00 41 f7")
    pad.programmer_mode(True)
    eq("programmer mode", hexs(sent[-1]), "f0 00 20 29 02 0d 0e 01 f7")
    pad.core.inject(0x90, 64, 127)
    pad.core.inject(0xB0, 91, 127)
    app.frame()
    check("pad 3,2 pressed", pad.pressed(3, 2) and pad.just_pressed(3, 2))
    check("top0 pressed", pad.button_pressed("top0") and pad.button_just_pressed("top0"))
    check("callbacks", "pad_pressed 3,2" in CALLS and "button_pressed top0" in CALLS)
    pad.core.inject(0x90, 64, 0)
    pad.core.inject(0xB0, 91, 0)
    app.frame()
    check("released", not pad.pressed(3, 2) and pad.just_released(3, 2) and pad.button_just_released("top0"))


def test_anymidi():
    app = FakeApplet()
    m = anymidi.AnyMidi(app, callbacks=CALLBACKS)
    sent = spy(m.core)
    eq("never seen", m.note(60), -1)
    m.core.inject(0x90, 60, 100)
    m.core.inject(0xB5, 7, 42)
    m.core.inject(0xE0, 0, 0)
    app.frame()
    eq("note", m.note(60), 100)
    check("down", m.down(60))
    eq("cc", m.cc(7), 42)
    eq("last channel", m.last_channel, 1)
    eq("pitch bend min", m.pitch_bend, -8192)
    eq("count", m.count, 3)
    check("note_on callback", "note_on 1 60 100" in CALLS)
    m.core.inject(0x80, 60, 0)
    app.frame()
    eq("note off -> 0", m.note(60), 0)
    m.core.inject(0xB0, 1, 5, device="Slide Trinkey M0")
    m.core.inject(0x90, 61, 9, device="Rotary Trinkey M0")
    m.core.inject(0x80, 61, 0, device="Rotary Trinkey M0")
    m.core.inject(0xC0, 2, 0, device="Other")
    app.frame()
    eq("message carries its device", m.last.device, "Other")
    eq("last_device", m.last_device, "Other")
    check("4-arg cc callback gets the device", "cc 1 1 5 from Slide Trinkey M0" in CALLS)
    check("3-arg note_on still called", "note_on 1 61 9" in CALLS)
    check("4-arg note_off gets the device", "note_off 1 61 0 from Rotary Trinkey M0" in CALLS)
    check("midi_message gets the device", "raw 192 from Other" in CALLS)
    eq("status before connect", m.status, "not connected")
    eq("devices before connect", m.devices(), [])
    m.note_on(16, 1, 2)
    eq("send ch16", hexs(sent[-1]), "9f 01 02")


def test_circuitplayground():
    eq("pad 0 is pin 3", circuitplayground.note_for_pad(0), 4)
    eq("note 11 is pad 7", circuitplayground.pad_for_note(11), 7)
    eq("note 5 is nothing", circuitplayground.pad_for_note(5), -1)
    near("note 30 is +1g", circuitplayground.accel_from_note(30), 1)
    near("note 15", circuitplayground.accel_from_note(15), -0.509684)
    app = FakeApplet()
    cpx = circuitplayground.CircuitPlayground(app, callbacks=CALLBACKS)
    sent = spy(cpx.core)
    cpx.core.inject(0x91, 4, 127)
    app.frame()
    check("touch 0", cpx.touch(0) and cpx.touch_just_pressed(0))
    eq("mode touch", cpx.mode, "touch")
    check("touch callback", "touch_pressed 0" in CALLS)
    cpx.core.inject(0x81, 4, 0)
    app.frame()
    check("touch 0 released", not cpx.touch(0) and cpx.touch_just_released(0))
    cpx.core.inject(0xB1, 1, 64)
    app.frame()
    near("light", cpx.light, 64 / 127.0)
    eq("temperature", cpx.temperature, 64.0)
    eq("mode sensor", cpx.mode, "sensor")
    cpx.core.inject(0x91, 20, 127, millis=1000)
    cpx.core.inject(0x91, 10, 127, millis=1001)
    cpx.core.inject(0x91, 30, 127, millis=1002)
    app.frame()
    eq("mode accel", cpx.mode, "accel")
    near("accel x", cpx.accel.x, 0)
    near("accel y", cpx.accel.y, -1)
    near("accel z", cpx.accel.z, 1)
    check("burst leaves no touch", not cpx.touch(7))
    cpx.core.inject(0x91, 4, 127, millis=3000)
    app.frame()
    check("still accel: no touch", not cpx.touch(0))
    cpx.core.inject(0x81, 4, 0, millis=3100)
    cpx.core.inject(0x91, 4, 127, millis=3200)
    app.frame()
    check("touch after note off", cpx.touch(0))
    cpx.pixels(255, 0, 130)
    eq("three notes", len(sent), 3)
    eq("red", hexs(sent[0]), "90 7f 7f")
    eq("green", hexs(sent[1]), "91 00 00")
    eq("blue", hexs(sent[2]), "92 7f 03")
    cpx.pixels(255, 0, 130)
    eq("unchanged not re-sent", len(sent), 3)
    cpx.clear()
    eq("clear re-sends red and blue", len(sent), 5)


def test_pipsqueak_led():
    app = FakeApplet()
    stick = pipsqueak.PipSqueak(app, "no-such-device-xyzzy")
    stick.core.verbose = False
    sent = []
    stick.core._emit = sent.append
    stick.flash()  # no output matching: silent no-op (a real stick may be plugged in while tests run)
    eq("flash without output sends nothing", sent, [])
    stick.core.output = object()
    stick.flash()
    eq("flash = note on 60 then note off", [hexs(b) for b in sent], ["90 3c 7f", "80 3c 00"])
    stick.send(0xB0, 20, 5)
    eq("send passes through", hexs(sent[-1]), "b0 14 05")


def test_trinkeys():
    eq("relative 1", trinkeys.relative(1), 1)
    eq("relative 127", trinkeys.relative(127), -1)
    eq("relative 125", trinkeys.relative(125), -3)
    app = FakeApplet()
    slide = trinkeys.SlideTrinkey(app, callbacks=CALLBACKS)
    sent = spy(slide.core)
    eq("raw before any message", slide.raw, -1)
    slide.core.inject(0xB0, 1, 127)
    slide.core.inject(0x90, 60, 127)
    app.frame()
    near("slider value", slide.value, 1)
    check("touched + just_touched", slide.touched and slide.just_touched())
    check("callbacks", "slider_changed 1.000" in CALLS and "touch_pressed" in CALLS)
    slide.core.inject(0x80, 60, 0)
    app.frame()
    check("touch released", not slide.touched and slide.just_released())
    slide.pixel(64)
    eq("pixel", [hexs(b) for b in sent[-2:]], ["90 40 7f", "80 40 00"])
    knob = trinkeys.RotaryTrinkey(app, callbacks=CALLBACKS)
    spy(knob.core)
    knob.core.inject(0xB0, 2, 64)
    for v in (1, 1, 127):
        knob.core.inject(0xB0, 3, v)
    app.frame()
    eq("knob raw", knob.raw, 64)
    eq("delta sums clicks", knob.delta, 1)
    check("knob_turned callback", "knob_turned 1" in CALLS)
    app.frame()
    eq("delta resets", knob.delta, 0)
    knob.core.inject(0x90, 61, 127)
    knob.core.inject(0x90, 62, 127)
    app.frame()
    check("pressed + touched", knob.pressed and knob.just_pressed() and knob.touched and knob.just_touched())
    check("knob_pressed callback", "knob_pressed" in CALLS)
    knob.core.inject(0x80, 61, 0)
    app.frame()
    check("released", not knob.pressed and knob.just_released() and knob.touched)


if __name__ == "__main__":
    for t in (test_midicore, test_pipsqueak, test_midifighter, test_launchpad, test_anymidi, test_circuitplayground,
              test_pipsqueak_led, test_trinkeys):
        t()
    print("%s: %d passed, %d failed" % (sys.platform if sys.platform.startswith("java") else "python " + sys.version.split()[0], passed[0], failed[0]))
    sys.exit(1 if failed[0] else 0)
