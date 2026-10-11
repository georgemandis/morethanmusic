# mtm-midi-helpers

One class per MIDI device for p5.js and the browser, from More than Music with MIDI. PipSqueak, Midi
Fighter Classic, Launchpad Mini MK3, Circuit Playground (multi-tool firmware), Slide and Rotary
Trinkey, and AnyMidi for anything else. Web MIDI, no dependencies. Chrome, Edge or Opera, or Firefox 108 and
later after its site-permission prompt; Safari has no Web MIDI.

One tag, no build:

```html
<script src="https://cdn.jsdelivr.net/npm/p5@1/lib/p5.min.js"></script>
<script src="https://morethanmusic.dev/mtm-midi-helpers/latest/midi-helpers.js"></script>
<script>
const stick = new PipSqueak();            // never touches hardware until connect()
function setup() { createCanvas(600, 600); stick.connectOnClick(); }
function draw() {
  background(20);
  circle(300 + stick.x * 250, 300 - stick.y * 250, stick.pressed ? 60 : 30);
}
function stickPressed() { console.log("click"); }
</script>
```

In the p5.js web editor, add that second script tag to `index.html` after the p5 one. Press Play, click
the canvas once, allow MIDI.

As a module:

```sh
npx jsr add @georgemandis/mtm-midi-helpers    # or: npm install mtm-midi-helpers
```

```js
import { PipSqueak } from "@georgemandis/mtm-midi-helpers";   // npm: "mtm-midi-helpers"
const stick = new PipSqueak({ callbacks: { stickPressed() { console.log("click"); } } });
```

A module cannot find your global `stickPressed()`, so pass `callbacks`. Everything else is the same.
`pipsqueak.js`, `launchpad.js` and the other per-device scripts in the package carry one class each
with the plumbing inside, for pages that only want one.

Reference, Processing Java and Python Mode versions, device message maps and the Explorer:
https://morethanmusic.dev/helpers/
