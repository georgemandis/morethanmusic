# Talks and workshops: the entry list

One folder per entry under `talks/<yyyy>-<slug>/`. Each has a `talk.md` (front matter plus the
page body), `assets/` for thumbnails, and `site/` where
an old workshop site is re-hosted. `node website/refresh.mjs talks` renders them into
`website/docs/07-talks/`.

The rule for every page: no date, venue or quote without a source. Sources are the talk folder at
`~/Projects/speaking/talks/more-than-music-with-tiny-computers-javascript-midi/` (called "the talk
folder" below), the three workshop folders under `~/Projects/speaking/workshops/`, George's site,
the CSS-Tricks article and YouTube. Where two sources disagree, the page says so.

## Entries

| Folder | Kind | Date | Venue | Recording |
|---|---|---|---|---|
| 2017-holyjs-st-petersburg | talk | 2017-06-02 to 03 | HolyJS, St. Petersburg | youtube -Ml7J3ocqUo |
| 2017-odessajs | talk | 2017-07-01 to 02 | OdessaJS, Odessa | youtube XR8ZmimWgd4 |
| 2017-fullstack-london | talk | 2017-07-12 to 14 | FullStack 2017, London | none found |
| 2017-nejs-conf-omaha | talk | 2017-07-20 to 22 | NEJS Conf, Omaha | youtube h-kNLD6nBeA |
| 2017-the-demos | demo | 2017-07 onward | the demos folder and its repos | four short videos |
| 2017-jsfoo-bangalore | talk | 2017-09-15 to 16 | JSFoo 2017, Bangalore | youtube R0-XLrr8icY |
| 2017-donutjs-portland | talk | 2017-09-26 | Donut.js, Portland | youtube UsqEFwfdBdU |
| 2017-cellular-automata | article | 2017-10-02 | george.mand.is | youtube tlUewcmKpAg |
| 2017-voxxed-days-belgrade | talk | 2017-10-19 to 20 | Voxxed Days Belgrade | youtube kJUFUBGPWG4 |
| 2017-jsconf-colombia-medellin | talk | 2017-11-03 to 04 | JSConf Colombia, Medellín | youtube iKKUNUXoxOA |
| 2018-brooklynjs | talk | 2018-01-18 | BrooklynJS, New York | none found |
| 2018-mixit-lyon | talk | 2018-04-19 to 20 | MiXiT, Lyon | vimeo 269818334 |
| 2018-teardown-portland | workshop | 2018-05-11 to 13 | Teardown, Portland | none; site re-hosted |
| 2018-spa-london | workshop | 2018-07-02 to 04 | SPA Software in Practice, London | none; site re-hosted |
| 2019-web-weekend-kathmandu | talk | 2019-09-21 to 22 | Web Weekend Kathmandu | youtube aYwuHTVZrqY |
| 2019-libertyjs-philadelphia | workshop | 2019-10-24 to 25 | LibertyJS, Philadelphia | none; site re-hosted |
| 2019-css-tricks-article | article | 2019-12-12 | CSS-Tricks | n/a |
| 2020-recurse-center | talk | 2020 (deck edited 2020-02-06) | Recurse Center | none found |
| 2023-zoom-muter | article | 2023-09-09 | george.mand.is | youtube KDszbcDRIL4 |
| 2026-pcd-nyc | workshop | 2026-10-03 | Processing Community Day, NYU ITP, Brooklyn | six preview videos |

## Sources, by where they live

The talk folder:

- `MMTM Talk Notes from Russia 2017.txt`: the HolyJS speaking notes, with the anecdotes.
- `notes/`: the abstracts and pitches, the 20-point outline, the JSFoo outline. Its git log has two
  commits, 2017-07-29 and 2017-10-08.
- `notes/pitch.md`: "I've given this talk at 5 different conferences this year".
- `notes/Making More Than Music - Tiny Computers, JS, MIDI.md`: "I've delivered this talk 6 times in
  various incarnations and venues: HolyJS, OdessaJS, Fullstack London, NEJS Conf, Donut.js, JSFoo
  and Voxxed Days Belgrade."
- `notes/Tiny Computers JavaScript and MIDI - George Mandis.md`: the abstract amended for
  Front-Trends 2018 and the 200 OK, WebCamp and Dublin submissions. Whether those were accepted is
  not in the sources.
- `slidedeck/`: the reveal.js deck. Its git log is the venue timeline: 2017-07-29 "Initial commit
  circa NEJS", 2017-09-15 "JSFoo updates", 2017-10-31 "belgrade", 2017-11-07 "Amendments for
  JSConfCO", 2018-01-24 "changes for brooklynjs", 2018-04-20 "ready for mixit", 2018-05-13 "for
  teardown 2018", 2018-07-02 "updated slides for SPA London 2018", 2019-09-23 "changes for wwktm
  presentation". The working copy is modified (2020-02-06) and its title slide reads "Recurse Center
  2020". `slidedeck/NOTES.md` lists the ngrok hostnames used on stage: holyjs, fullstack2017, nejs,
  jsfoo, voxxed.
- `slide-deck-breakdown.html` (2017-06-29): how the deck itself is driven by MIDI.
- `demos/`: the demo repos. Most have an initial commit of 2017-07-29; the cellular automata demo is
  2017-10-02; the Launchpad MK2 Go and Morse code demos are 2017-11-01.
- `Teardown 2018 Submission.md`, `StarConf Summary.md`: the workshop and talk abstracts.
- `midi-talk-notes-ideas.taskpaper`: the ideas list, including "Make a MIDI device exploration
  frontend tool. Select input. Drop down. Show numbers. That's it. Not rocket science." which is the
  Explorer, nine years early.

Sibling talk folders: `hardware-hacking-with-javascript` (Espruino pitch for Teardown, 2019-06-14),
`interactive-music`, `interactive-poetry-box`, `javascript-for-artists` (the 2018 to 2019 successor
talk, with WebMIDI as one colour on the palette).

Workshop folders: `teardown-webmidi-2018` (git: 2018-05-12 to 14), `spa2018-webmidi-2018`
(2018-07-02 to 04), `libertyjs-webmidi-2019` (2019-10-25 to 2019-11-14). All three are VuePress
sites. Their deploy scripts pushed to `georgemandis/teardown-midi-workshop` and
`georgemandis/spa2018-midi-workshop` on GitHub Pages; the LibertyJS deploy script pushes to the
SPA repo, so the 2019 site replaced the 2018 one at the same URL. Both URLs returned 404 on
2026-10-04 and the Wayback Machine has no snapshot of either.

George's site:

- https://george.mand.is/talks/ : the full list of engagements with dates and cities. Every date on
  the timeline comes from here unless the page says otherwise.
- https://george.mand.is/javascript-webmidi-tiny-computers : where midi.mand.is forwards. The
  editor's note says the page "previously lived at midi.mand.is" (December 2023).
- Posts: 2017-05-31 (HolyJS), 2017-06-10 (HolyJS reflections), 2017-06-13 (OdessaJS), 2017-07-06
  (ngrok at OdessaJS), 2017-07-09 (FullStack 2017), 2017-10-02 (cellular automata), 2018-07-03
  (Circuit Playground multi-tool v1.0.0), 2023-09-09 (Zoom muter), 2026-09-19 (PCD preview).

The article: https://css-tricks.com/dip-your-toes-into-hardware-with-webmidi/ , 2019-12-12.

YouTube, found with `yt-dlp "ytsearch10:George Mandis MIDI"` and the playlist
`PLsTcGz22ZXo4omxUbGHooU8iaqyhMLG77` that George links from his own notes. Captions are YouTube's
automatic English captions, pulled with `yt-dlp --write-auto-subs --sub-lang en --skip-download`,
deduplicated and broken into paragraphs by `talks/vtt2md.py`. They are not corrected: names and
technical words come out wrong ("Jorge mandus"). Four videos have no captions (the 2017 and 2026
demo clips). The MiXiT recording is on Vimeo and needs a login to fetch, so it is linked, not
transcribed.

## Not included, and why

- FullStack 2018, FrontMania 2018, GDG DevFest SF 2018, c't webdev 2019, Microsoft Build 2019,
  HalfStack Vienna 2019, Heapcon 2019, ChangeCon 2019, RuhrJS 2019, WebCamp Zagreb 2019: on the
  talks page, but the sources name a different talk (JavaScript for Artists, Self-Portraits in
  JavaScript) or no talk at all. They are listed on the timeline page as "also on the road" with
  what the sources say, nothing more.
- Front-Trends 2018, 200 OK, WebCamp, "the Dublin conference": submissions exist in the notes; no
  acceptance or date exists in the sources.
- The Hot Hand controller, the Goonies organ, the WebRTC symphony and the rest of the 2017 demos
  have no separate entries. They live on the demos page.

## Assumptions

- "The talk" means one talk, revised per venue. The deck's git log and the pitch text both treat it
  that way, so one entry per venue links to the same deck and the same demos.
- Dates for multi-day conferences are the conference dates from the talks page. Which day George
  spoke is only known where a source says (HolyJS: the reflections post says the last day).
- The talks page lists BrooklynJS as 2018-01-18 and the deck commit "changes for brooklynjs" is
  2018-01-24. The page keeps the talks-page date and notes the commit.
- Recurse Center 2020 is a real entry because the deck was edited for it, but no date, city or
  recording is in the sources. The page says so.
- The PCD 2026 entry is the compendium's record of the day: date, venue, preview videos, links. The
  day-of agenda lives on the site session's page at `/talks/pcd-2026-nyc/`, which this entry links to.
- Demo repos that return 404 on GitHub (most of the 2017 ones) are private or renamed. The demos
  page names the local folder and the remote it was cloned from, without linking.
- CodePen returns 403 to curl but the pens are linked from the workshop sites, so the links stay.

## How it is rendered

`node website/refresh.mjs talks` (or `--check`) reads every `talks/<yyyy>-<slug>/` and writes:

- `website/docs/07-talks/<slug>.md`: the entry, with an explicit `slug: /talks/<slug>/` because
  Docusaurus would otherwise read the year as a number prefix and drop it from the URL.
- `website/docs/07-talks/<slug>/`: the re-hosted site, one page per sidebar entry of its
  `vuepress-config.js`, each with a banner line, image paths pointed at
  `/img/talks/<slug>/`, page links pointed at the sibling pages, and the CodePen iframes made
  MDX-safe (self-closed, fallback text after them). `index.md` is the old home page.
- `website/static/img/talks/<slug>/`: the site's images and the entry's `assets/`.
- The table between the `talks:timeline` markers in `website/docs/07-talks/index.md`.

The re-hosted images were copied from the workshop folders; `midi-bananas.jpg` (4032 px, 1.8 MB)
was scaled to 1600 px and `roland-jupiter-6.jpg` re-encoded at quality 80, so three copies of each
do not cost 8 MB. Nothing else about the sites was changed.

The PCD 2026 entry links to `/talks/pcd-2026-nyc/`, the day-of page the site session is writing.
Until that page exists the build reports it as a broken link and continues (`onBrokenLinks: warn`).
