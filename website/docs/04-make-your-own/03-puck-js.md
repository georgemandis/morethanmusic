---
title: Puck.js
description: A Bluetooth MIDI clicker in Espruino JavaScript, and the same button as a keyboard.
---

# Puck.js

A Puck.js is a button-sized Bluetooth board that runs JavaScript. Espruino's `ble_midi` module makes it
a Bluetooth MIDI device. I used one as a slide clicker for years: the deck listened for MIDI and nobody
in the room could tell what I was holding.

Source: [github.com/georgemandis/puck-js-midi-clicker](https://github.com/georgemandis/puck-js-midi-clicker),
refreshed copy in `firmware/puck-js-midi-clicker/`.

## What it sends

Clicks are counted; 350 ms of quiet ends the count. Status byte `0xBA`: a control change on channel 11
as the Explorer counts (the script's `CHANNEL = 10` is zero-based). Value 127.

| Clicks | Message | Bytes |
|---|---|---|
| 1 | CC 80 | `BA 50 7F` |
| 2 | CC 81 | `BA 51 7F` |
| 3 | CC 82 | `BA 52 7F` |
| 4 | CC 83, and two LEDs flash until the next four | `BA 53 7F` |

It also rewrites the Puck's NFC tag with a different URL per click count, which has nothing to do with
MIDI and everything to do with handing out a business card by holding a phone to it.

## Flash

Espruino Web IDE in Chrome, connect over Web Bluetooth, paste, Send to Espruino, `save()` in the
console. Then pair it as a MIDI device: on macOS, Audio MIDI Setup, MIDI Studio, the Bluetooth
button, Connect next to `PuckCC`. From then on it is a MIDI source like any USB one.

## The code

{/* include: firmware/puck-js-midi-clicker/puck-js-triple-click.js */}

```javascript title="puck-js-triple-click.js"
// Puck.js as a Bluetooth MIDI clicker. Espruino. One button, counted clicks, a CC per count.
//
//   1 click   -> CC 80, value 127   (and the NFC tag points at urls[0])
//   2 clicks  -> CC 81, value 127   (urls[1])
//   3 clicks  -> CC 82, value 127   (urls[2])
//   4 clicks  -> CC 83, value 127, and the red and green LEDs flash until the next 4 clicks
//
// CHANNEL is zero-based, as the ble_midi module wants it: 10 on the wire is status 0xBA, which a
// one-based display (the Explorer, a DAW) calls channel 11. The Puck advertises as "PuckCC".
//
// Load it with the Espruino Web IDE (https://www.espruino.com/ide/), Send to Espruino, then
// save() in the console so it survives a battery change. The ble_midi module is fetched by the IDE.
const CHANNEL = 10;       // change this: 0..15 on the wire, so one less than the channel you want to see
const CONTROLLER = 80;    // change this: the first CC number; two, three and four clicks add 1, 2, 3
const urls = ["https://midi.mand.is", "https://george.mand.is", "https://snaptortoise.com"];   // change this: what the NFC tag says after 1, 2, 3 clicks
const CLICK_GAP = 350;    // ms of quiet that ends a run of clicks

let clickcount = 0;
let clickevent = null;
let flashLEDState = false;
let flashLEDs = false;

const midi = require("ble_midi");
midi.init();

const setLEDS = (LED1on, LED2on, LED3on) => {
  LED1.reset();
  LED2.reset();
  LED3.reset();
  if (LED1on) LED1.set();
  if (LED2on) LED2.set();
  if (LED3on) LED3.set();
};

const disableFlashingLEDs = () => {
  if (flashLEDs) {
    try {
      clearInterval(flashLEDs);
    } catch (e) {
      console.log("Oops!", e);
    }
    flashLEDs = false;
    setLEDS(false, false, false);
  }
};

setWatch((e) => {
  clickcount++;
  try {
    if (clickevent !== null) clearTimeout(clickevent);
  } catch (e) {
    console.log("Oops!", e);
  }

  // Show the count while the button is down: green, red, blue, all three.
  switch (clickcount) {
    case 1:
      setLEDS(false, true, false);
      break;
    case 2:
      setLEDS(true, false, false);
      break;
    case 3:
      setLEDS(false, false, true);
      break;
    default:
      setLEDS(true, true, true);
      break;
  }

  clickevent = setTimeout(() => {
    if (clickcount === 1) {
      console.log("Click 1");
      NRF.nfcURL(urls[0]);
      midi.send(CHANNEL, CONTROLLER, 127);
      disableFlashingLEDs();
    } else if (clickcount === 2) {
      console.log("Click 2");
      NRF.nfcURL(urls[1]);
      midi.send(CHANNEL, CONTROLLER + 1, 127);
      disableFlashingLEDs();
    } else if (clickcount === 3) {
      console.log("Click 3");
      NRF.nfcURL(urls[2]);
      midi.send(CHANNEL, CONTROLLER + 2, 127);
      disableFlashingLEDs();
    } else if (clickcount === 4) {
      console.log("Click 4");
      midi.send(CHANNEL, CONTROLLER + 3, 127);
      if (!flashLEDs) {
        flashLEDs = setInterval(() => {
          flashLEDState = !flashLEDState;
          setLEDS(flashLEDState, !flashLEDState, false);
        }, 100);
      } else {
        disableFlashingLEDs();
      }
    }
    clickcount = 0;
  }, CLICK_GAP);
}, BTN, {
  edge: "rising",
  debounce: 10,
  repeat: true
});

setWatch((e) => {
  setLEDS(false, false, false);
  setTimeout(() => {
    clickevent = null;
  }, 400);
}, BTN, {
  edge: "falling",
  debounce: 10,
  repeat: true
});

NRF.nfcURL(urls[0]);
```

{/* /include */}

## The same button, not as MIDI

`firmware/espruino-zoom-muter/` is the same Puck as a Bluetooth keyboard that taps Cmd+Shift+A, Zoom's
mute shortcut, on press and release. A second script tries the HID telephony mute usage. A third sends
CC 80 instead. Three protocols, one `setWatch` on `BTN`. MIDI is the one a sketch can read with no
mapping software in between, which is why the clicker is MIDI and not keystrokes.

Source: [github.com/georgemandis/espruino-zoom-muter](https://github.com/georgemandis/espruino-zoom-muter).
