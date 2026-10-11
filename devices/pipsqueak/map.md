## What it sends

| Control | Message | Default | Notes |
|---|---|---|---|
| Left and right | CC | CC 17 | 0 left, 126 right. Rest is around 60, not 64: the centre is off-centre on purpose and the helper calibrates for it. |
| Up and down | CC | CC 20 | 0 down, 126 up. Rest around 68. |
| Button | CC | CC 25 | Above 64 while held, 0 when released. |
| USB name | | contains "PipSqueak" | Some units enumerate as "PipSqueaker". The Explorer prints the exact name. |

Defaults measured from a real unit on September 12, 2026. A custom unit may use other numbers. Check
[the Explorer](@explorer) and pass a config.
