## What it sends

| Control | Message | Numbers | Notes |
|---|---|---|---|
| Knob, absolute | CC | CC 2, 0 to 127 | The position. Sent on every click, and once at startup. |
| Knob, relative | CC | CC 3 | 1 is one click clockwise, 127 one click counter-clockwise. Two's complement, so 2 is two clicks. |
| Knob press | Note on, note off | Note 61, velocity 127 | Down and up. |
| Touch pad | Note on, note off | Note 62, velocity 127 | On when touched, off on release. |
| USB name | | "Rotary Trinkey M0" | The drive, when it mounts, is `ROTARYPY`. |

## What it receives

| Message | Effect |
|---|---|
| Any note on | The pixel takes a colour from the note number for one second. `m.noteOn(1, 61, 127)` from a sketch. |
