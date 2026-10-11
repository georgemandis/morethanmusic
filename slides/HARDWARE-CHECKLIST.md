# Slides — hardware checklist

The Obsidian deck needs nothing. This list is for `slides/ProcessingDeck/`, the Processing version
steered by a PipSqueak. Ten minutes with one stick, ideally the one you will hold on stage.

## 0. What this unit actually sends (measured 2026-10-02, the unit named `PipSqueaker`)

Captured with the Java helper path, a bare `javax.sound.midi` listener on every port and a native
CoreMIDI client, 2397 messages, all identical across the three:

| Control | Message | Range | Rest |
| --- | --- | --- | --- |
| stick, taken as **x** | `[176, 10, v]` CC 10 on channel 1 | 0 to 126 | about 67 |
| stick, taken as **y** | `[176, 7, v]` CC 7 on channel 1 | 0 to 126 | about 70 |
| button down | `[144, 60, 127]` note 60 on | | |
| button up | `[128, 60, 127]` note 60 off, velocity 127 | | |

USB: vendor `useMidi`, product `PipSqueaker`, serial 288485674934, one USB-MIDI interface, two
endpoints, driven by `AppleMIDIUSBDriver`. It enumerates as two Java `MidiDevice.Info` entries with the
same name (the output is listed first); `MidiCore.connect()` skips the output because it has no
transmitters, so the input is the one that gets opened. No reply to a SysEx identity request.

**Why the deck did nothing on the first try:** the helper's defaults were the `stock` map from the
2026-09-12 unit (CC 17 = x, CC 20 = y, CC 25 = button). Every message from this unit fell through the
helper's handler, so x, y and pressed never changed. The helper now knows both maps as profiles and
adopts the one the unit speaks on its first message; the console prints
`PipSqueak: this unit speaks the 'usemidi' map (x cc10, y cc7, button note 60)`.

**Orientation:** CC 10 was taken as x (pan) and CC 7 as y (volume). George's horizontal flicks on the
live deck registered as slide changes, which confirms it. Direction (whether right is +x) still wants a
glance in step 2.

## 1. Connect

- [ ] Plug the stick in, then open `slides/ProcessingDeck/ProcessingDeck.pde` and press Run. The
      console prints `PipSqueak: connected, input '…'` and `Deck: 16 slides, 39 fragments`.
      Press `h`: the overlay's first line says `connected`.
- [ ] Press `d` and move the stick. `received` counts up, the raw lines show `CC ch 1 #10` and `#7`,
      the profile line says `usemidi`, and `x` / `y` move between -1 and 1. If `received` counts but
      x / y stay at 0.00, the map is a third one: read the CC numbers off the raw lines and write a
      `data/pipsqueak.json`.
- [ ] If it says `no MIDI device matching 'pipsqueak'`: run the Explorer, read the exact name, and
      either rename the default in `midi-helpers/java/PipSqueak.pde` (then `midi-helpers/sync.sh`)
      or make a `data/pipsqueak.json` with a `"name"` key.
- [ ] Hands off the stick for two seconds after launch. The slide counter must not move on its own.
      If it does, the rest position is off: press `z` (hands off, half a second). If that fixes it,
      write the unit's calibration into `data/pipsqueak.json` (format in `midi-helpers/README.md`).

## 2. NAVIGATE

- [ ] Flick right: exactly one slide forward. Hold it right: still only one. Release, flick again: next.
      If flicking right changes **fragments** instead, x and y are swapped on this unit: swap `xCC` and
      `yCC` in the `usemidi` profile in `midi-helpers/java/PipSqueak.pde` and run `midi-helpers/sync.sh`.
      If right goes to the **previous** slide, set `xInvert` in the same place.
- [ ] Flick left: one slide back. On slide 1 nothing happens; on slide 16 right does nothing.
- [ ] On slide 3 ("1983"): flick up five times, one fragment appears each time; a sixth up does
      nothing; down hides the last one.
- [ ] Diagonal pushes: whichever axis is further wins, and only one thing happens.
- [ ] If flicks sometimes register twice or not at all, tune the two thresholds in `handleStick()`
      (`0.6` to trigger, `0.3` to re-arm).

## 3. The button and the modes

- [ ] Click once: the corner reads **LASER** with a red dot. Click again: **INTERACTIVE**, green dot,
      the background brightens. Click a third time: back to **NAVIGATE**.
- [ ] A single click never skips a mode (debounce lives in the helper: the CC crossing 64 once).
- [ ] The stick usually wobbles when you click. The sketch disarms navigation on each mode change,
      so a click in NAVIGATE must not also change the slide.

## 4. LASER

- [ ] The dot follows the stick position (not velocity) and springs back to centre when released.
      Full deflection reaches about the screen edge. If it feels sluggish or bouncy, change the two
      numbers in `drawLaser()` (`0.14` spring, `0.72` damping).
- [ ] Draw a circle around the table on slide 12; the trail fades in about two seconds.
- [ ] Flick to the next slide from the keyboard (right arrow): the trail clears.

## 5. INTERACTIVE

- [ ] Slide 12 (Game of Life, `v` cycles if it isn't): push up, it speeds up; push down, it crawls;
      hold left or right, cells get sprinkled on that side.
- [ ] Slide 14 (L-system tree): up/down bends the tree, left/right stretches it.
- [ ] Slide 1 or 17 (Julia): up zooms in, left/right spins the shape.
- [ ] Slide 7 (418, the teapot): it spins slowly on its own. In INTERACTIVE a left/right flick spins it
      and it keeps turning after you let go; up/down tilts it; a hard full push kicks the speed; holding
      full deflection for a second flips to wireframe (and back). `w` does the same from the keyboard.
- [ ] Text stays readable on every slide in this mode. If not, raise the panel alpha in
      `drawSlide()` (`170`) or lower `VIZ_LOUD`.

## 6. On the projector

- [ ] Mirror the displays (simplest) or run `slides/ProcessingDeck/run.sh --display=2`. Check the
      corner indicator is visible and the body text is readable from the back row.
- [ ] Watch the frame counter: `--shot` prints fps, or just see that the Life slide animates
      smoothly. The target is 60 fps at 1920x1080; see the README's Performance section if not.
- [ ] Rehearse a full pass with the stick only, then decide: stick deck or Obsidian deck. Both read
      the same markdown.
