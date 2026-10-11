## What it sends

In Programmer mode, which the helper switches on when it connects and off when your sketch closes:

| Control | Message | Numbers |
|---|---|---|
| Pad press and release | Note on, note off | Note is row × 10 + column counted from the bottom-left as 11, so top-right is 88. The helper turns that into x 0..7 left to right, y 0..7 top to bottom. |
| Top row buttons | CC | 91 to 98, left to right. The first four are printed as arrows. |
| Right column buttons | CC | 89 down to 19, in steps of 10 |
| Logo | CC | 99 |
| USB name | | "LPMiniMK3 MIDI". There is also a DAW port. The helper picks the MIDI one. |
