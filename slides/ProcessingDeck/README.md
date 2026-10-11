# ProcessingDeck

The ten-minute intro deck as a Processing 4 sketch, driven by a useMIDI PipSqueak. It reads the
same markdown the Obsidian deck is made from. The Obsidian deck is the fallback on stage.

Every slide has a cheap generative background. Click the stick and it is a laser pointer. Click
again and the stick plays the background. The deck is a MIDI sketch, so the first demo starts
before the first slide.

| File | What it is |
| --- | --- |
| `ProcessingDeck.pde` | setup, modes, stick and keyboard, slide rendering, overlays, flags |
| `Deck.pde` | the markdown parser |
| `Visuals.pde` | the `Visual` interface, five seeded backgrounds, the teapot |
| `TeapotData.pde` | the Newell teapot's 32 patches and control points (public domain, via three.js) |
| `Pinned.pde` | slide-specific visuals (bytes, bananas, Hot Hand, QR code) and a small QR encoder |
| `Inputs.pde` | a tap on every MIDI input, for the device picker on the bytes slides |
| `code/coremidi4j-1.6.jar` | CoreMidi4J, Apache-2.0, copied from the Explorer. Live device list, so a device plugged in after launch shows up. Optional. |
| `MidiCore.pde`, `PipSqueak.pde` | copies from `midi-helpers/java/`, placed by `midi-helpers/sync.sh`. Do not edit here. |
| `.midi-helpers` | tells `sync.sh` which helpers this sketch wants |
| `run.sh` | build with the Processing CLI, run with Processing's own Java |

## Run it

Plug the PipSqueak in. Open `ProcessingDeck.pde` in Processing 4, press Run. It opens as a window
and goes full screen on the main display a frame later. With no stick the console says so once and
the keyboard takes over.

From a terminal, with Processing.app in `/Applications`:

```sh
slides/ProcessingDeck/run.sh                    # full screen
slides/ProcessingDeck/run.sh --display=2        # full screen on the second display
slides/ProcessingDeck/run.sh --window           # 1280x720 window
slides/ProcessingDeck/run.sh --window=1920x1080 --slide=14 --frags=3 --mode=laser --shot=/tmp/deck.png
```

`--shot=path` saves a screenshot after 2.5 seconds, prints the frame rate and a per-stage profile,
and quits. Flags are command-line only. Esc does nothing; quit with shift-Q or Cmd-Q.

## The stick

| Mode | Stick | What happens |
| --- | --- | --- |
| any | click | NAVIGATE, LASER, INTERACTIVE, round again. The corner shows which. |
| NAVIGATE | left / right | previous / next slide. A new slide starts with no fragments. |
| NAVIGATE | up / down | reveal the next fragment / hide the last |
| LASER | move | a red dot follows the stick (position, not velocity) and leaves a trail that fades in two seconds. Leaving LASER or changing slide stops the drawing. The trail keeps fading. `c` clears it. |
| INTERACTIVE | up / down | the background's main parameter |
| INTERACTIVE | left / right | its second parameter. The background brightens and the text gets a dim panel. |

Navigation is edge-triggered. A push past 60 percent moves one step. The stick has to come back
inside 30 percent before the next one, so holding it does not run through the deck. On a diagonal
the bigger axis wins.

## Keyboard

Always works, stick or no stick.

| Key | Does |
| --- | --- |
| arrows | slide and fragment, one step per press, no auto-repeat. In INTERACTIVE they play the visual. |
| space | cycle the mode |
| mouse | the stick in LASER and INTERACTIVE, once it has moved over the window (no device only) |
| Home / End, PageUp / PageDown | first / last slide, previous / next slide |
| `v` | another visual for this slide |
| `r` | reload the markdown now. It also reloads by itself: the file's mtime is polled twice a second and re-parsed once it has sat still for 300 ms. Slide and fragment stay, visuals re-pin, a green toast says so. A file that fails to parse, or is missing mid-save, gets a red toast and the old deck stays. |
| `w` | teapot wireframe / solid |
| Tab | bytes slides: next device in the picker. A click on the list does the same. |
| `d` | stick debug overlay: input, profile and map, raw and normalised x / y, pressed, last edge, last eight messages |
| `f` | fullscreen toggle. This is also how the deck goes full screen at launch, see Decisions. |
| `h` or `?` | help |
| `z` | recenter the stick. Hands off for half a second. |
| `c` | clear the laser trail |
| shift-`Q` | quit |

With no stick the PipSqueak helper turns the arrows into stick motion, which is how the keyboard
steers the laser and the interactive parameters. Stick navigation only runs with a real stick, so an
arrow press never counts twice.

## The markdown

`Deck.pde` reads `../Processing Day MIDI Workshop Slides.md` from the sketch folder, then `data/`,
then the working directory. `--md=path` overrides. The rules follow `slides/README.md`:

- `---` alone on a line splits slides. Empty slides are dropped.
- `#`, `##`, `###` are titles at 96, 78 and 64 px (at 1080 rows), serif.
- `<p class="fragment">` and `<li class="fragment">` are the click-to-reveal items, in order. `<li>`
  gets a bullet. Hidden fragments keep their space so nothing jumps.
- `<strong>`, `<b>`, `<em>`, `<i>`, `<code>` and markdown `**bold**`, `*italic*`, `` `code` `` are
  styled. Other tags are stripped. Entities are decoded.
- A paragraph that is only italic is an image stand-in: small and faded.
- `![alt](img/file.jpg)` on its own line is a photo, relative to the markdown's folder. The text keeps
  the left half, the photo sits on the right, fitted to the content height, aspect kept, rounded
  corners. A missing file shows the alt text in italics. The file is read and resized once.
- `<!-- visual: NAME -->` pins the slide's background (`teapot`, `bytes`, `bananas`, `hothand`, `qr`,
  `life`, `tree`, `julia`, `lissajous`, `ant`). Other comments are dropped. Obsidian ignores them.
- Pipe tables render as tables. The `|---|` row is skipped. The first row is bold.
- Everything else is body text at 40 px.

Text is left-aligned and vertically centred. A slide taller than the screen is scaled down, never
below 60 percent. The console prints the slide and fragment count at startup and on every reload.

## Visuals

```java
interface Visual { String name(); void reset(int seed); void update(float p1, float p2); void draw(PGraphics pg, float alpha); }
```

Each visual draws into a 480x270 buffer that the sketch blends against the background colour and
scales up. The pick per slide is `VISUAL_ORDER[(slide + rerolls[slide]) % 5]`: consecutive slides
never share a kind, rehearsal is repeatable, `v` steps to the next. The seed comes from the slide
index, so the same slide grows the same tree. A pinned slide shows its pin; `v` cycles the others and
comes back round.

| Kind | Idle | up / down | left / right |
| --- | --- | --- | --- |
| Game of Life | 5 generations a second | speed, 0.5 to 40 a second | stir cells into that half |
| L-system tree | grows, sways | bend the joints | stretch / shrink |
| Julia zoom | `c` crawls round the cardioid | zoom | spin `c` |
| Lissajous doodle | two or three pens, fading | detune the ratio | slide the phase |
| Langton's ant | 1 to 3 ants, a seeded rule | 2 to 600 steps a frame | random turns, that side |
| Bytes (slides 5 and 6) | the three bytes, big, with their binary, plus a device picker: All inputs and every MIDI input on the bus. The digits show the last message from the picked device with its name and age. Default: the PipSqueak. Until the picked device has sent anything, the stick sweeps: | data 2 | data 1. 144 stays. |
| Bananas | three bananas wired to a board, or, when the slide has a photo, three touch spots along the photo's bottom edge | push up: touch the picked banana, a ripple and the bytes | pick a banana |
| Hot Hand (slide 11) | three CC bars drift and tint the slide | Y, green | X, red. How far you push is Z, blue. |
| QR code (slide 17) | one code per URL on the slide, with the line after each URL as its label. One sits bottom-right; two sit along the bottom in a strip the text leaves free. Always black on white at full contrast, in every mode, so phones can scan them. | size | tilt, with momentum |
| Teapot (slide 7) | slow spin | tilt, with momentum | spin, with momentum. A hard push kicks it. Hold full deflection a second for wireframe. |

Pinned visuals draw at full resolution through `drawHires(app, alpha)`, after the buffer and before
the text, because digits, bananas and QR modules blur through 480x270. The ones that never touch the
buffer say so with `usesBuffer()` and the composite is skipped.

The QR encoder lives in `Pinned.pde`: byte mode, level L, versions 1 to 5, Reed-Solomon over
GF(256), eight masks scored. It encodes every `http` token on the slide. Checked two ways: the
version-5 matrix matches the `qrcode` Python library bit for bit, and OpenCV's Aruco detector reads
both codes off a `--shot`. (OpenCV's older `QRCodeDetector` misses the denser version-5 code; that
is the detector, not the code.) `slides/img/qr-docs.png` and `qr-repo.png` were written by `--qr`
for the Obsidian deck, which embeds them as data URIs.

The teapot is software-rendered. Processing 4.5.6 will not create a P3D buffer inside a JAVA2D
sketch ("createGraphics() with P3D or OPENGL requires size() to use P2D or P3D"), and switching the
deck to P2D the night before was not worth it. The 32 patches are tessellated once at 8 segments a
side, 4096 triangles, projected, depth-sorted and flat-shaded into the shared buffer each frame. The
data is three.js's copy of the Newell set, 290 control points instead of 306 after de-duplication.

## Performance

`--shot` prints fps over frames 90 to 150 and milliseconds per frame per stage. Dev laptop,
1920x1080, density 1, 2026-10-03:

| Slide | Mode | fps | visual | composite | hires | text | draw() total |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 3, no visual (`--noviz`) | navigate | 60.0 | 0 | 0 | 0 | 0.4 | 1.1 ms |
| 3, Lissajous | navigate | 59.9 | 0.3 | 1.1 | 0 | 0.4 | 2.5 ms |
| 12, Game of Life | interactive | 60.1 | 0.4 | 1.2 | 0 | 1.4 | 3.6 ms |
| 7, teapot | interactive | 60.1 | 2.9 | 1.2 | 0 | 0.4 | 5.2 ms |
| 5, bytes | navigate | 59.5 | 0 | 0 | 0.3 | 0.4 | 1.5 ms |
| 5, bytes | interactive | 60 | 0 | 0 | 0.3 | 1.6 | 2.7 ms |
| 10, bananas | interactive | 59.8 | 0 | 0 | 0.8 | 1.3 | 2.8 ms |
| 11, Hot Hand | interactive | 59.1 | 0.2 | 2.3 | 1.7 | 2.4 | 7.9 ms |
| 17, QR code | navigate | 59.9 | 0 | 0 | 1.4 | 0.4 | 3.2 ms |
| 17, QR code | interactive | 60.1 | 0 | 0 | 2.0 | 1.9 | 5.3 ms |

What it took, in the order it was found:

- Pixel density is forced to 1. Processing 4 defaults to 2 on Retina, which renders 4K and gave
  16 fps. `--density=2` if you want crisp screenshots.
- The background is composited by hand with nearest-neighbour scaling. `tint()` plus `image()` of
  a translucent buffer is a software bicubic scale, 200 ms a frame at 4K. `blitViz()` blends the
  small buffer against the background colour in a pixel loop (1 ms) and draws it opaque. The hint
  matters: bilinear cost 28 ms for the one `drawImage`, nearest 2 ms. `--interp=1` to compare.
- Visuals that only draw at full resolution skip the buffer and the composite.
- The bytes block is cached and redrawn only when a digit, the mode or the window changes.
- The QR code is drawn as rects. 400 rects cost 1.5 ms. A cached image, scaled and tinted through
  JAVA2D, cost 14 to 17 ms.
- The teapot sorts a `long[]` of depth and index. 8.4 ms down to 2.9 ms against a boxed comparator.

## Self-test flags

Command-line only. Useful without hardware.

| Flag | Does |
| --- | --- |
| `--keys=R,R,U,U,D,S,E,L` | posts one key every 10 frames from frame 30, held 4 frames. `R L U D` arrows, `S` space, `H` home, `E` end, or a letter |
| `--midi=176:7:70,176:10:126` | injects one raw MIDI message every 10 frames from frame 30 |
| `--nostick` | does not open the PipSqueak, so the stand-ins get exercised |
| `--demo` | swings the stick in a circle by injecting CCs |
| `--test-f` | calls the fullscreen toggle at frame 30 |
| `--help`, `--debug` | start with that overlay open |
| `--qr=path` | writes the slide's QR codes to `path.png` and `path.txt`, or `path-1`, `path-2`, ... when the slide has several |
| `--noviz` | no background, for a baseline |
| `--navquiet=ms` | the no-navigation window after connect, default 500 |

## Decisions

- Up reveals, down hides. Left and right only change slides. One meaning per axis.
- The keyboard is unconditional. George's call after the first rehearsal.
- This unit sends x on CC 10 and y on CC 7. CC 10 is pan, so it is x. Confirmed live: horizontal
  flicks changed slides, not fragments. If right goes backwards on another unit, set `xInvert` in the
  `usemidi` profile in `midi-helpers/java/PipSqueak.pde` and run `sync.sh`.
- Mouse clicks do nothing except on the bytes slides' device list, so a stray click on stage cannot
  change the mode.
- Hot-plug of inputs comes from CoreMidi4J in `code/`, loaded by reflection like the Explorer does;
  the stock Java CoreMIDI provider lists devices once at JVM start. Every input is opened read-only
  alongside the PipSqueak helper; CoreMIDI shares ports. Without the jar the list is what was plugged
  in at launch.
- `run.sh` passes `-XstartOnFirstThread` only when the CoreMidi4J jar is absent. With both, the JVM
  deadlocks before the first frame (found 2026-10-03; each alone works). The deck does not call
  `fullScreen()`, so it does not need the flag.
- Esc is swallowed. A deck that dies on Esc is worse than one you quit with shift-Q.
- Fonts: Georgia, Helvetica Neue, Menlo, with fallbacks. Faces come from `java.awt.Font` so bold
  and italic work everywhere.
- The PipSqueak map comes from the helper, which knows two unit profiles and switches to the one it
  hears (`midi-helpers/README.md`). A third map goes in `data/pipsqueak.json`.
- The deck does not call Processing's `fullScreen()`. On macOS 26.6 it aborts the JVM ("API misuse:
  modification of a menu's items on a non-main thread") when launched from `run.sh`; George hit it
  twice with the Studio Display attached. `settings()` opens a 1280x720 window and `toggleFullscreen()`
  takes the display at frame 2 through `GraphicsDevice.setFullScreenWindow`, verified at 2560x1412
  and 60 fps. `run.sh` also passes `-XstartOnFirstThread`, which makes plain `fullScreen()` survive
  too. Mirror the displays on the day, or use `--display=2`.
- No stick navigation in the first 500 ms after connect. The helper is learning the unit's map and
  rest position then, and a hand on the stick at launch once landed the deck on slide 3.
- Hot reload polls. A `lastModified()` call twice a second needs no thread. The 300 ms settle is for
  editors that write in steps. If the deck starts with the file missing it keeps polling the path.
- No `data/` copy of the markdown. The sketch reads one folder up, in the IDE and from `run.sh`.
- Images, links, blockquotes and numbered lists are not special-cased. They render as body text, and a
  tag on its own (the `<img>` data URIs on the last slide) renders as nothing.

## The first bug, 2026-10-02

The stick was detected and the deck did nothing. Three listeners, the helper, a bare
`javax.sound.midi` client and a native CoreMIDI client, saw the same bytes once it moved:
`[176, 7, v]`, `[176, 10, v]`, `[144, 60, 127]`, `[128, 60, 127]`. This unit sends CC 7 and CC 10
and a note button. The helper expected CC 17, CC 20 and CC 25, so every message fell through. The
port and the Transmitter were fine. Fix: the helper carries both maps and adopts the one it hears;
the deck got the `d` overlay and the unconditional keyboard. Checked live afterwards: slides,
fragments, all three modes, and on the teapot slide spin, tilt and the wireframe hold. The measured
map is in `slides/HARDWARE-CHECKLIST.md`.
