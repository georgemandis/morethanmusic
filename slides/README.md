# Slides: the 10 minute intro

One markdown file, presented two ways.

| File | What it is |
| --- | --- |
| `Processing Day MIDI Workshop Slides.md` | The deck. 17 slides, 38 fragments. |
| `TALK-TRACK.md` | What to say on each slide, with click cues and times. Core Slides has no speaker notes. |
| `ProcessingDeck/` | The same markdown as a Processing sketch, steered by a PipSqueak. See its README. |

The Obsidian note `Notes/Processing Day MIDI Workshop Slides.md` is a symlink to the deck file here.
Edit either path, it's the same file. ProcessingDeck re-reads it on save (or press `r`).

## Present from Obsidian

1. Open the note in the Notes vault.
2. Command Palette, Slides: Start presentation.
3. Arrow keys or space. 54 clicks start to finish. `Esc` leaves.

Keep `TALK-TRACK.md` on the laptop screen. The projector only sees the slides.

## The CSS snippet

`slides.css` in `Notes/.obsidian/snippets/` drops reveal's base font from 42px to 30px, widens the
slide and uses a serif for headings. Copied unchanged from the Starlight vault.

- Enable it: Settings > Appearance > CSS snippets, toggle `slides`. The vault's `slideshow.css` is
  separate; turn on either or both.
- After a CSS change, Cmd-R reloads Obsidian so the slideshow window picks it up.
- If a slide wraps badly, change the `font-size` in the snippet. Don't add line breaks to the note.

## Deck rules

From the Starlight vault's ruleset for core Slides, and PLAN.md's Voice section.

- No front matter. `---` alone on a line between slides. No vertical slides.
- Title slide, a header slide per section, one item per slide.
- Short lines. Bold for the one thing to remember.
- Click-to-reveal lines are raw HTML: `<p class="fragment">`. Use `<strong>` and `<code>` inside,
  not markdown.
- Headings, the title slide, tables and `<!-- visual: name -->` comments stay as they are. The
  comments pin a ProcessingDeck visual to a slide.
- A copy pass keeps the slide and fragment counts. If they change, update the click counts in
  `TALK-TRACK.md`.

## Assumptions

- The URL on the last slide is the live one. Change it there and in the talk track if it moves.
- The three story slides carry a one-line italic image description in place of a photo.
- The hardware table follows PLAN.md with spoken counts (lots, about 10, a few). Trinkeys are
  summarized as slider, knob, touch.
- The Explorer slide lists what `explorer/` ships: device list, live decode, device pictures, send
  panel. Trim fragments if that changes, and fix the counts.
- The 2019 Circuit Playground slide says the boards run the same multi-tool firmware, per PLAN.md.
