---
title: "Demos"
description: The p5.js demos, all runnable from this site.
sidebar_position: 4
---

import LiveSketch from '@site/src/components/LiveSketch';

# Demos

The p5.js demos, served from this site. They need a
[browser with Web MIDI](/pick-your-tool/p5/#a-browser-that-speaks-midi), the device plugged in,
and one click on the page before the browser will ask for MIDI. Without a device, each one has
keyboard or mouse stand-ins.

## PipSqueak

- [PipSqueak Gray-Scott](pathname:///pipsqueak-grayscott/). Reaction-diffusion steered by the stick.
  Tune mode drifts the two parameters that decide spots, stripes, worms or nothing. Paint mode drips
  chemical where you point. Arrows steer, space switches mode, R resets, 1 to 9 pick presets.
- [PipSqueak Kaleidoscope](pathname:///pipsqueak/pipsqueak-sketch.html). Draw with the stick, mirrored.
- [PipSqueak Recorder](pathname:///pipsqueak/pipsqueak.html). Plots the raw values over time. For
  calibrating a custom unit.
- [PipSqueak Demo](pathname:///pipsqueak/pipsqueak-demo.html). The normalized state, drawn.

## PipSqueak projects, built

The ten PipSqueak ideas from the [ideas page](/examples/project-ideas/), each under about 60 lines, in
Java, Python Mode and p5.js. The p5 versions run here; the Processing versions are in the repo's
`projects/` folder. No stick? Arrows move, space is the button.

- [Cursor](pathname:///projects/p5/pipsqueak-cursor/), a dot with a fading trail. The button changes its colour.
- [Compass](pathname:///projects/p5/pipsqueak-compass/), an arrow coloured by angle. The stick sets its length.
- [Etch-a-sketch](pathname:///projects/p5/pipsqueak-etch-a-sketch/), the stick is the pen's velocity. Tap to switch between drawing and moving, hold to clear.
- [Knob](pathname:///projects/p5/pipsqueak-knob/), up and down nudge one number. The button latches it.
- [Timer](pathname:///projects/p5/pipsqueak-timer/), up and down set minutes, the button starts, pauses and resets.
- [Bouncy ball](pathname:///projects/p5/pipsqueak-bouncy-ball/), the stick is gravity. There is a target.
- [Snake](pathname:///projects/p5/pipsqueak-snake/), steer on cardinal pushes, hold the button to go faster.
- [Maze](pathname:///projects/p5/pipsqueak-maze/), one cell per push, with fog of war the button toggles.
- [Obstacle course](pathname:///projects/p5/pipsqueak-obstacle-course/), dodge up and down, the button jumps.
- [Flock](pathname:///projects/p5/pipsqueak-flock/), the stick drives the leader, the button scatters the boids.

### Snake

<LiveSketch src="/projects/p5/pipsqueak-snake/" title="PipSqueak Snake, p5.js" />

### Bouncy ball

<LiveSketch src="/projects/p5/pipsqueak-bouncy-ball/" title="PipSqueak Bouncy ball, p5.js" />

## Midi Fighter Classic

- [Midi Fighter Arcade](pathname:///midi-fighter/arcade.html). Five modes: a 12-step drum sequencer, a
  flipbook with one frame per bank, Lights Out, Simon, and Rooms, which remembers every visitor's
  pattern and can replay the day. Click once for sound.
- [Midi Fighter Fireworks](pathname:///midi-fighter/fireworks.html). Each bank is a shell type, each
  button a variant. Column is where it bursts, row how high, hold to charge. A PipSqueak adds wind and
  gravity. Keys 1 to 4 pick a bank.
- [Midi Fighter Viz](pathname:///midi-fighter/viz.html). Banks as visual modes: bursts, mirror tiles,
  pulse bands, constellation.

## Launchpad Mini MK3

These ask for SysEx as well as MIDI. They put the Launchpad in Programmer mode while open and back
when you leave.

- [Launchpad Quest](pathname:///launchpad-quest/). An overworld of 8×8 screens with coins, a key, lava,
  and puzzles only a second person at the board can solve. Arrow keys or a PipSqueak walk. R restarts.
- [Launchpad Automata](pathname:///launchpad-automata/). Game of Life, Wolfram rules, Langton's Ant and
  an L-system turtle. Press to seed. The right column is a speed fader.
- [Launchpad Chess](pathname:///launchpad-chess/). Chess on the pads, mirrored on screen, with a random
  bot. The [p5.js version](pathname:///launchpad-chess/p5/) reads like a Processing sketch.
- [Launchpad Marquee](pathname:///launchpad-marquee/). A marquee across the pads, the firmware's own
  text command or a custom 5×7 font with every attribute the 2002 tag had.

## Tools

- [Grid Controller Explorer](pathname:///grid-controllers/grid-explorer.html). A live picture of the
  Midi Fighter or Launchpad, plus Learn layout for a unit with a strange map.
- [LED Lab](pathname:///grid-controllers/led-lab.html). Click to light Midi Fighter LEDs.

## Ports you can take apart

Three of the demos were rewritten with the workshop helpers so you can open them in the IDE and change
them. The Processing versions are in [ports/](https://github.com/georgemandis/morethanmusic/tree/main/ports). Two of them also run right here
with the p5 helpers.

### Launchpad Automata, p5.js

<LiveSketch src="/ports/p5/launchpad-automata/" title="Launchpad Automata, p5.js port" />

### Midi Fighter sequencer, p5.js

<LiveSketch src="/ports/p5/midifighter-sequencer/" title="Midi Fighter sequencer, p5.js port" />

The big demos above stay as they are. They were built before the helpers existed.
