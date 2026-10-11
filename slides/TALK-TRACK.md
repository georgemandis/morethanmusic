# Talk track: More than Music with MIDI

Script for `Processing Day MIDI Workshop Slides.md`. Core Slides has no speaker notes. Times are
where you should be when the slide comes up. "Click" is one fragment.

17 slides, 33 fragments, 49 clicks.

## 1. Title: More than Music with MIDI (0:00)

Hi, I'm George. Freelance developer, musician in a part-part-time kind of way. I've been plugging
weird things into computers over MIDI for about ten years. Hands: who's written a Processing or
p5 sketch? Who's touched MIDI? Fewer. This is for you.

Devices send signals, your sketch decides what they mean. In ten minutes you'll be plugging
something in.

## 2. Header: MIDI is older than you think (0:45)

Beat. It's old. For us that's good news.

## 3. 1983 (1:00)

Click: say "MIDI" and people hear canyon.mid, the Windows 95 tune, and those trumpets. Click:
that's General MIDI, a 1991 spec that says every sound card needs a trumpet, a helicopter and a
gunshot. Different thing. We're using the protocol underneath.

Click: 1983. Roland, Sequential Circuits, Yamaha and Korg had synths that couldn't talk to each
other, so they wrote down a tiny protocol and all shipped it. Click: 43 years old, so every OS
speaks it. Mac, Windows, Linux, your browser. No drivers. Click: Processing speaks it with Java's
built-in sound library. Nobody installs anything today except Processing.

## 4. Header: The whole protocol is three bytes (2:00)

Beat. It fits on one slide.

## 5. [144, 60, 127] (2:10)

Three numbers. Walk the table. First byte: what happened, and on which of 16 channels. Second:
which one. Which key, which knob, which pad. Third: how much. How hard, how far, how bright.

(Processing deck: the bytes sit top-right as live numbers with their binary. Two stick clicks for
INTERACTIVE: left/right sweeps the 60, up/down sweeps the 127. Click back to NAVIGATE before the
fragments.)

Click: data bytes are 0 to 127. Seven bits, because 1983. Click: a few other status numbers exist,
note off is 128, control change is 176, and that's about it. You'll see these numbers in the
Explorer in ten minutes.

## 6. What the standard says they mean (3:00)

Click: 144 is note on, channel 1. Click: 60 is middle C. Click: 127 is as hard as you can hit it.
A pianist hitting middle C hard sends 144, 60, 127.

Click: HTTP status codes. 404 is a number. It means Not Found because everyone agreed.

## 7. 418 (3:30)

Advance: 418, I'm a teapot. Beat for the laugh. The agreement is the whole thing.

(Processing deck: a teapot spins behind this slide. Two stick clicks for INTERACTIVE and flick it
if the room is warm. One more click back to NAVIGATE before moving on.)

## 8. The standard is a suggestion (3:40)

Click: a button sends note on when pressed, note off when released. Click: anything continuous,
a knob, a joystick axis, a light sensor, sends a control change from 0 to 127.

Click: your sketch decides what 60 means. Nothing on the wire cares. Click: 60 can draw a circle.
60 can open your garage door. Same three bytes.

## 9. Header: Things that have been MIDI (4:20)

Beat. Things I've done with this. Mostly in hotel rooms, for some reason.

## 10. Bananas (4:30)

The picture: three bananas on a hotel desk, alligator clips running to a Circuit Playground, which
has touch pads around its edge. Click: clip on each banana, touch one, note on. Three bananas,
three notes.

Click: a banana is mostly water, so the pad reads it like a finger. Click: Processing gets 144,
60, 127, same as a piano key. Click: nothing in the chain knows there's a banana. That's the part
I like.

## 11. 2019: a pile of Circuit Playgrounds (5:20)

The picture: the same coin-sized Adafruit board, glowing green, next to my laptop. Click: two
buttons, a slide switch, an accelerometer, light, microphone, thermometer, touch pads, ten RGB
pixels in a ring. Click: for a 2019 workshop I wrote a firmware with ten modes. Touch mode, light
mode, tilt mode. Plug it in and it's a MIDI device. Click: those boards are on this table, same
firmware. The site has a page with each sensor's message.

## 12. Demos! (6:00)

Alt-tab out of the deck to the browser. It keeps its place. Show one or two, not all:

- Launchpad Quest, the 8 by 8 grid as a dungeon.
- Launchpad Chess, two players on one grid.
- Midi Fighter arcade, sixteen arcade buttons doing arcade things.
- Gray-Scott, a PipSqueak steering reaction-diffusion.

Each one is a few lines of the same idea: a message comes in, the sketch decides what it means.
Alt-tab back to the deck.

## 13. Header: Today (7:00)

Beat. This table.

## 14. On the table (7:10)

Point as you go. PipSqueaks, a joystick with one button. We have lots, so most of you start there.
About ten Circuit Playground Express: sensors in, pixels out. Four Midi Fighters: sixteen arcade
buttons, an LED under each, and Processing can light them. Two Launchpad Minis: 8 by 8 RGB pads,
in and out. A few Trinkeys and a NeoTrellis. And whatever you brought.

Pick by what you want to make. Joystick for steering or drawing. Buttons for triggers and
sequencers. Pads for grids and games. Circuit Playground for sensors.

## 15. Step one: plug in and look (8:00)

Click: the Explorer is a Processing sketch, and it's the first thing we open. Click: it lists
every MIDI device and decodes every message as it arrives. Click: like this. PipSqueak, control
change 1, channel 1, value 97, raw bytes. Click: when it knows the device it draws it, so you see
the grid light up or the stick move. Click: the send panel fires a note at a Launchpad and a pad
lights up. Click: when your thing does something weird, and it will, open this first. It's also
what goes on the projector for show and tell.

## 16. Five minutes to pixels (8:50)

One rule: something on your screen within five minutes. Click: open Processing. Click: open the
starter for your device, Java or Python Mode, under forty lines. Click: run it and wiggle the
thing. Click: find the line that says "change this" and change it. Click: that's twenty minutes
in. Fifty minutes to build, I'll come around, then show and tell on the projector.

## 17. Everything is here (9:45)

Two links, two codes. The first is the docs site: install steps, the starters, the ideas list, these
slides. The second is the GitHub repo: clone it and every sketch is on your machine. Phones out, scan
either one. (Processing deck: both codes sit along the bottom. Two clicks for INTERACTIVE makes them
full contrast and push up to grow them.) Grab a device. Go.
