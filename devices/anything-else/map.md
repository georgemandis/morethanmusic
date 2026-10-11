## On the table

| Device | What it is | What it sends |
|---|---|---|
| [Slide Trinkey](./slide-trinkey.md) | Adafruit USB stick with a slider, a touch pad and two pixels. Shows up as "Slide Trinkey M0". | Slider is CC 1, 0 at the left to 127 at the right. Touch pad is note 60. Send it a note on and the pixels take that note's colour for a second. Firmware in [firmware/trinkey-midi/](pathname:///firmware/trinkey-midi/README.md). |
| [Rotary Trinkey](./rotary-trinkey.md) | A click knob with a push switch, a touch pad and one pixel. Shows up as "Rotary Trinkey M0". | Knob is CC 2 as an absolute 0..127 position and CC 3 as relative clicks (1 clockwise, 127 counter-clockwise). Pressing the knob is note 61, the touch pad note 62. Same colour trick on incoming notes. |
| NeoTrellis M4 | Adafruit's 4×8 grid of RGB-lit buttons with an accelerometer | Probably notes for the buttons and CCs for tilt. Check the Explorer. It is a grid, so the Midi Fighter ideas transfer. |
| Yours | Anything | Same drill. Explorer first. |
