# Build-time ideas, by device

Fifty minutes. Start at the top of your device's list, get it on screen, then climb. Each idea names the
helper calls it needs (`midi-helpers/README.md`) and a "then" for when it works. Start from the matching
sketch in `starters/`.

The device is an input like any other. Anything the mouse or keyboard can do, the thing in your hand can do.

## PipSqueak (joystick + button)

Reads: `stick.x`, `stick.y` (-1..1, up is +1), `stick.angle`, `stick.magnitude`, `stick.pressed`,
`stick.justPressed()`. Every idea below is built, with its "then" step, in `projects/` (Java, Python
Mode and p5). Open one and change it.

1. **Cursor.** A dot the stick pushes; the button changes its colour. (The starter.) Then: a trail that fades.
2. **Compass.** Draw an arrow from the centre pointing where the stick points; its length is the
   magnitude. Then: colour by angle, the hue wheel under your thumb.
3. **Etch-a-sketch.** The pen never lifts: x and y are *velocities*, the button clears. Then: the
   button toggles between "move" and "draw".
4. **Thermostat / volume knob.** Pushing up and down nudges one number (a size, a speed, a
   frequency). Draw the number big. Then: the button latches it, and a second push unlatches.
5. **Visual timer.** Stick sets minutes (push up to add, down to remove), button starts. A disc drains
   as time passes, flashes at zero. Then: the button pauses and resumes.
6. **Bouncy ball.** The stick is gravity. A ball falls in whatever direction you push. Then: walls that
   it bounces off, then a target to steer it into.
7. **Snake.** The classic. The stick steers; it only turns on cardinal pushes. Then: the button
   speeds up while held.
8. **Maze.** Draw a maze from a text grid (`#` wall, `.` floor); the stick walks a dot through it, one
   cell per push. Then: a fog-of-war so you only see nearby cells.
9. **Obstacle course.** Scrolling obstacles come at you; the stick dodges, the button jumps. Then:
   speed up over time, keep a high score.
10. **Steering a flock.** Flocking boids follow a leader the stick drives. Then: the button scatters
    them.
11. **Kaleidoscope.** Mirror the stroke across symmetry axes; the button adds more. See
    `ports/java/PipSqueakKaleidoscope`.

## Circuit Playground (George's multi-tool firmware)

The firmware runs one mode at a time: pads send notes, light / sound / temperature send CC 1 once a
second, the accelerometer sends three notes every 200 ms. Slide switch plus the buttons pick the mode
(`starters/HARDWARE-CHECKLIST.md`). Reads: `cpx.touch(i)`,
`cpx.light`, `cpx.sound`, `cpx.temperature`, `cpx.accel.x/y/z`.

1. **Touch piano.** Eight pads, eight colours; touch one and it fills the screen. (The starter's ring.)
   Then: each pad sends a note to another device, or to the built-in synth (`ports/java/MidiFighterSequencer`
   shows how).
2. **Light meter.** Background brightness follows the light sensor. Cover it with your hand. Then: a
   history graph scrolling across the screen, one point a second.
3. **Sound-reactive blob.** Clap, and the blob jumps. Then: it grows a little every clap and shrinks
   over time.
4. **Thermometer.** A column of liquid; a reading every second. Then: log the readings to a file with
   `saveStrings` and plot them.
5. **Tilt ball.** Accelerometer x/y is the slope of a table; a ball rolls on it. Then: holes to avoid,
   like a wooden labyrinth. (Accelerometer mode.)
6. **Spirit level.** A bubble that drifts to the high side; turns green when level. Then: a sound (or a
   note out) when you hold it level for three seconds.
7. **Fruit drum kit.** Alligator clips from the pads to fruit; each one a drum hit on screen. Then:
   record the hits into a loop.
8. **Sing it back.** The pads play a short melody on screen and out to the synth; then the sketch waits for
   you to repeat it. Simon, with a Circuit Playground.
9. **Step counter / shake detector.** Watch the accelerometer magnitude for spikes; count them. Then: a
   pedometer face, or "shake to clear".

The six 2019 Circuit Playground projects are in `ports/java/CircuitPlayground*` (Python Mode and p5 too):
Colour Mixer (mode 10, with the 7-bit bug and its fix), Simple Synth (mode 8), Fruit Piano / Tactile
Flashcards (mode 1), Thermometer (mode 4), Quiz Buzzer (mode 1, several boards), Morse Code (mode 8). Each
under 80 lines. Give the Thermometer a weather face, add fruit to the piano, make the buzzer keep score.

## Midi Fighter Classic (16 arcade buttons, one LED each)

Reads: `mf.pressed(i)`, `mf.justPressed(i)` or `void padPressed(int i)`. Writes: `mf.led(i, on)`.
Index 0 is top-left, reading order.

1. **Toggle board.** Press a button, its cell and its LED toggle. (The starter.) Then: a colour per cell;
   the LEDs mirror a pattern you compute.
2. **Whack-a-mole.** A random LED lights; hit it before it moves. Then: it speeds up, and a wrong hit
   costs a life.
3. **Lights Out.** Pressing a button flips it and its four neighbours; turn them all off. Then: a
   scramble button and a move counter.
4. **Sixteen sounds.** Each button triggers a shape + a note on the built-in synth. Then: hold to sustain.
   `ports/java/MidiFighterFireworks` takes it further: every button a firework, hold to charge, LED lit while
   the shell is up.
5. **Step sequencer.** Buttons are steps, the LEDs are the playhead. See `ports/java/MidiFighterSequencer`.
6. **Simon.** The LEDs play a growing sequence; you repeat it. Then: a tone per button.
7. **Pixel art flipbook.** Each bank (or each of four keys) is a 4×4 frame; draw them, then play them as
   an animation on the LEDs and the screen.
8. **Two-player reaction.** Left half is player one, right half is player two; the LED tells you which
   button to hit first.
9. **Binary clock.** Rows are hours, minutes, seconds in binary on the LEDs. Press a button to set.

## Launchpad Mini MK3 (8×8 RGB pads + 16 buttons)

Reads: `pad.pressed(x, y)`, `pad.justPressed(x, y)` or `void padPressed(int x, int y)`,
`void buttonPressed(String id)`. Writes: `pad.set(x, y, c)`, `pad.setRGB(x, y, r, g, b)`,
`pad.button("top0", c)`, `pad.text("hi", c)`, `pad.clear()`.

1. **Paint.** Press a pad, it lights; a top button clears. (The starter.) Then: the right column picks the colour.
2. **Mirror.** Whatever you draw on screen with the mouse appears on the pads, downsampled to 8×8,
   and vice versa.
3. **Rain.** Pressing a pad drops a lit cell that falls to the bottom row and stacks. Then: it fades as
   it falls; the bottom row clears when full.
4. **Light ping-pong.** A lit cell bounces around the grid; press a pad to put a wall there. Then: two
   balls, then colour mixing where they cross.
5. **Game of Life.** Pads toggle cells; a button steps generations. See `ports/java/LaunchpadAutomata`
   for Life, Wolfram rules, Langton's Ant and an L-system turtle.
6. **Snake on the pads.** The 8×8 grid is the board, the top buttons are the arrows, the screen shows
   the score big. Then: food blinks.
7. **Eight-track sequencer.** Rows are instruments, columns are steps, the playhead sweeps left to
   right. Then: the right column mutes a row.
8. **Pixel scroller.** `pad.text()` scrolls a word; type on the keyboard and the pads show it. Then: a
   word a second from a list. `ports/java/LaunchpadMarquee` is the full version: a 5×7 font you own, every
   `<marquee>` attribute, and the stick for speed and colour.
9. **Spectrogram / data display.** Any live number (mouse speed, a sine wave, a sensor on another
   device) drawn as a bar graph across the pads, newest column on the right.
10. **Two-player territory.** Two colours; each press claims a pad; surrounded pads flip. Go.

## Trinkeys, NeoTrellis M4, and the things people brought

Start with `AnyMidiStarter`, which draws every note and CC it sees. The Explorer tells you which numbers
your device sends; hard-code them.

1. **One knob, one thing.** A slider or rotary Trinkey controls one parameter: a hue, a stroke weight,
   a rotation. Then: it controls a *rate* rather than a value.
2. **Cap-touch Trinkey as a button.** A note on/off = a toggle. Then: hold time = brush size.
3. **NeoTrellis M4 as a 4×8 Launchpad.** Same ideas as the Launchpad above; its pads send notes, its
   LEDs take notes back (check the Explorer for the layout).
4. **Hands-free.** A pedal, a breath controller, a ribbon: anything that sends CC can drive the
   PipSqueak ideas above with one axis instead of two.

## Two devices at once

Every helper is independent; a sketch can hold several.

1. **PipSqueak steers, Midi Fighter fires.** Asteroids.
2. **Launchpad is the board, Circuit Playground is the dice.** Shake to roll; the pads show the result.
3. **Circuit Playground light sensor sets the palette the Launchpad paints with.**
4. **Pass it on.** One device's input becomes another device's LEDs (`m.send(...)`). A pad press on the
   Launchpad lights a Midi Fighter button and vice versa.
