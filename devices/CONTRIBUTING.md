# Adding a device

One folder per device. The site page is generated from it, so edit here, never in
`website/docs/03-devices/`.

```
devices/
  _template/        copy this
  pipsqueak/
    device.md       front matter + the page body
    map.md          the message map
  links.json        the site pages a body may link to
  test/             a broken sample and the test that proves the generator refuses it
```

1. Copy `_template/` to `devices/<slug>/`. The slug is the URL: lowercase, hyphens.
2. Plug the device in, open the Explorer, press everything once. Write the numbers into `map.md`.
3. Fill the front matter in `device.md`. Every required field must be there. Write `none` when one
   does not apply (no shop, no photo, stock firmware).
4. Put a photo in `website/static/img/devices/<slug>.jpg` and point `photo` at `/img/devices/<slug>.jpg`.
   Your own photo, or one you have the rights to.
5. Render and check:

```
node website/refresh.mjs devices           # writes website/docs/03-devices/<slug>.md
node --test devices/test/                  # the generator still refuses a broken folder
cd website && npm run build                # the page compiles
```

6. Open a pull request with the folder and the generated page.

## device.md

Front matter is one `key: value` per line. A nested map is a key with no value and lines indented by
two spaces. No lists, no multi-line strings. Values are Markdown, so a link works. Quotes around a
value are stripped; to show quotes on the page, write `'"Midi Fighter Classic"'`.

Required: `name`, `maker`, `usb_name`, `ports`, `sends`, `receives`, `buy`, `photo`, `firmware`. The
generator stops with the file name and the field name when one is missing. These values land in a
table cell, so `|`, `<` and `{` must sit inside backticks; the generator stops on a bare one.

Optional:

| Key | What it does |
|---|---|
| `title` | The page heading when it differs from `name` (sidebar says Launchpad, page says Launchpad Mini MK3). |
| `description` | One line for search and the sidebar hover. |
| `order` | Sidebar position. Lower is higher. |
| `helper` | The heading of the device's section in `midi-helpers/README.md`. Needed by the `helper` slot, and names the live starter. |
| `starters` | `p5` (a folder with `index.html` and `sketch.js`), `python` and `java` (the sketch file). Needed by the `starters` slot. |
| `starter_notes` | A sentence per language, shown next to the starter. |
| `raw` | `java`, `python` (the sketch file) and `p5` (the folder). Needed by the `raw` slot. |

The body is Markdown that ends up in MDX, so no HTML comments except the slots, and `<` and `{` need
escaping outside code. Slots:

| Slot | Renders |
|---|---|
| `<!-- facts -->` | The photo and a table of maker, USB name, ports, sends, receives, buy, firmware. Rows that say `none` are left out. Lands before the first `##` if you leave it out. |
| `<!-- map -->` | `map.md`, verbatim. |
| `<!-- starters -->` | The three-language tab block with the live p5 sketch and the code pulled in. |
| `<!-- helper -->` | "From the helpers' README" with that section pulled in. |
| `<!-- raw -->` | The three links to the no-helper sketches. |

Site links: write `[the Explorer](@explorer)` and the generator looks `explorer` up in `links.json`.
Add a name there before using it. When the site moves pages, edit `links.json` once.

Code is pulled in with the same `{/* include: path */}` blocks the rest of the site uses, so a body
may include a port or a README section directly. `node website/refresh.mjs devices` fills them.

## map.md

Markdown, usually a `## What it sends` table and a `## What it receives` table. Keep the numbers exact
and say where they came from: a date, a firmware version, the Explorer. Channels are 1 to 16, notes
and controllers 0 to 127.

## Voice

Short sentences. Say what it is and what to do. See the Voice section in `PLAN.md`.

## Assumptions

Decisions made while building the catalog, 2026-10-04, without asking:

- Starters stay in `starters/` and `starters/raw/` and the device folder links to them, because the
  Processing starters carry copies of the helper tabs and the sync script knows that layout. The spec
  put them inside the device folder; the plan said links, and the plan won.
- The body is the whole page, with slots, rather than a fixed skeleton. The existing pages differ too
  much (the Circuit Playground page has ten modes and six projects, the Launchpad page a colour
  section) for a skeleton to carry them without losing anything.
- `none` is a value, not an absence. A missing key is an error so that a contributor cannot forget
  a field; `none` says they thought about it.
- Front matter is parsed by a tiny reader in `refresh.mjs` rather than a YAML library, so the test
  runs with no `npm install`. Hence no lists and no multi-line values.
- The Trinkey pages use the AnyMidi starters with a note, because there are no Trinkey starters yet.
  Those starter folders carry no Trinkeys tab, so the note says to copy it from `midi-helpers/`.
  The helper tables come from the Trinkeys section of the helpers README.
- Photos: none exist in the repo (the old site referenced `img/pipsqueak.jpg` and friends but they
  were never committed), so every `photo` is `none` for now.
- Buy links were checked on 2026-10-04: useMidi's pipSqueak Black page, Adafruit products 3333
  (Circuit Playground Express), 5021 (Slide Trinkey) and 4964 (Rotary Trinkey), Novation's Launchpad
  Mini page. DJ TechTools no longer lists the Midi Fighter Classic, so its row says second-hand
  instead of linking. The Rotary Trinkey's encoder not being pre-soldered and the Trinkeys plugging
  straight into USB-A come from the Adafruit product page, same date.
- Generated pages live at `website/docs/03-devices/<slug>.md` with `sidebar_position` from `order`.
  The section's `index.md` and any `_category_.json` belong to the site restructure, not to this
  folder.
- `links.json` holds the site URLs the pages link to (`/the-explorer/`, `/examples/hello-world/` and
  so on). When a page moves, change it there and re-run the generator (mtm-site did this on
  2026-10-04 and removed the old `website/docs/5-your-device/` pages; `/your-device/*` redirects).
