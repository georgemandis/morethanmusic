# firmware

Code that turns a board into a MIDI device, one folder per board, each laid out as a repo of its own:
a README that states exactly what it sends and receives, flash steps you can paste, a licence, the
source. The site's Make your own section is written from these folders.

| Folder | Board | Language | Status |
|---|---|---|---|
| `circuit-playground-midi-multi-tool/` | Adafruit Circuit Playground Classic and Express | Arduino, MIDIUSB | public repo since 2019; this folder is a README patch for it |
| `trinkey-midi/` | Adafruit Slide Trinkey M0 and Rotary Trinkey M0 | CircuitPython | moved here from `trinkeys/`; flashed and used at PCD 2026 |
| `puck-js-midi-clicker/` | Puck.js (Espruino, Bluetooth MIDI) | JavaScript | public repo since 2017; this folder is the 2026 refresh |
| `espruino-zoom-muter/` | Puck.js (Espruino, Bluetooth keyboard and MIDI) | JavaScript | public repo since 2024; refreshed, plus an untested MIDI variant |
| `arduino-midiusb-starter/` | anything with native USB: Leonardo, Micro, Circuit Playground, Trinkey | Arduino, MIDIUSB | new, compiles, not yet run on a board |

`<!-- repo: pending -->` at the top of a README marks where a GitHub URL goes once the repo exists. The
site pages carry the same marker inside an MDX comment, `{/* repo: pending */}`, because Docusaurus 3
rejects HTML comments.

## Making one a repo

```sh
cd firmware/trinkey-midi
git init && git add . && git commit -m "trinkey-midi: CircuitPython MIDI firmware for the Slide and Rotary Trinkey"
gh repo create georgemandis/trinkey-midi --public --source . --push
```

Then replace the marker in its README and on its site page with the URL. For the three that already
have repos, push the refreshed files over the existing checkout instead:

```sh
cp -R firmware/puck-js-midi-clicker/. ~/Projects/puck-js-midi-clicker/     # then review the diff and commit
cp -R firmware/espruino-zoom-muter/.  ~/Projects/espruino-zoom-muter/
cd ~/Projects/circuit-playground-midi-multi-tool && git apply ~/Projects/speaking/workshops/morethanmusic/firmware/circuit-playground-midi-multi-tool/README.patch
```

## Assumptions

- Licence is MIT for every folder, per the spec's proposal. The clicker was already MIT (2017). New
  `LICENSE` files carry George's name and the year range of the code in them.
- `trinkeys/` was moved with `git mv` so history follows. A two-line pointer README stays in `trinkeys/`
  because `midi-helpers/README.md`, `README.public.md` and `publish.sh` still say `trinkeys/`; those
  files belong to other sessions and were not edited.
- The Circuit Playground multi-tool is linked, not copied. The site's device page and helper already
  treat the repo's `.ino` as the source of truth. The patch targets commit `3ba8b2a` of that repo.
- The two Puck.js repos are already public, so their folders say "Repo:" with the URL rather than
  `repo: pending`. The refreshed files are meant to be pushed to those repos, not to new ones.
- Behaviour of existing firmware is unchanged. The clicker script was tidied (helpers hoisted, a
  shadowed variable removed, the 350 ms gap named) and sends the same bytes. The Trinkey code is
  untouched.
- The channel in Espruino's `ble_midi` module is zero-based and added straight into the status byte, so
  the clicker's `CHANNEL = 10` is channel 11 to the Explorer. The old README said channel 10. Both
  READMEs now give the status byte.
- `zoom-mute-button-midi.js` is new and has not run on hardware. It is marked untested in its README.
- The Arduino starter compiles for `arduino:avr:leonardo`, `arduino:avr:circuitplay32u4cat` and
  `adafruit:samd:adafruit_circuitplayground_m0` with arduino-cli 1.5.1 (2026-10-04). It has not been
  uploaded to a board. The colour mixer example compiles for both Circuit Playgrounds and is the 2018
  sketch unchanged.
- Flash steps give arduino-cli commands with a macOS port name as the example. The Arduino IDE steps
  are listed too.
- `website/refresh.mjs` has no fence language for `.ino`, so Arduino code pulled onto the site pages
  renders without highlighting until `'.ino': 'cpp'` is added to its `LANG` table. That file belongs to
  the site session.
