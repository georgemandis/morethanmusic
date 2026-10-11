## What it sends

| Control | Message | Numbers | Notes |
|---|---|---|---|
| Slider | CC | CC 1, 0 to 127 | 0 at the left, 127 at the right. Sent when it moves, and once at startup. |
| Touch pad | Note on, note off | Note 60, velocity 127 | On when touched, off on release. |
| USB name | | "Slide Trinkey M0" | The drive, when it mounts, is `SLIDEPY`. |

## What it receives

| Message | Effect |
|---|---|
| Any note on | Both pixels take a colour from the note number for one second. `m.noteOn(1, 60, 127)` from a sketch. |
