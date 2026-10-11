## What it sends

| Event | Message | Notes |
|---|---|---|
| Press | Note on, channel 3 | Status `0x92`. Velocity is fixed per unit, 127 or 125 on ours. |
| Release | Note off, channel 3 | Status `0x82`. |
| USB name | | "Midi Fighter Classic" |

In the factory Default mode the notes are 36 to 51. Bottom-left is the lowest note and top-left is 48:

```
48 49 50 51
44 45 46 47
40 41 42 43
36 37 38 39
```

The helper numbers cells 0 to 15 in reading order, top-left first, and reports a bank if the unit is in
Four Banks mode, where the top row switches banks and sends notes 0 to 3. All units should be in
Default. If the top row does something odd, the unit is in Four Banks mode and the helper reports the
bank.
