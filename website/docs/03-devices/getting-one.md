---
title: Getting a device
description: Where the devices on this site come from, what else is cheap and still made, where to look second-hand, and what to check in a listing.
sidebar_position: 8
---

# Getting a device

You do not need any particular device. Anything that shows up as a MIDI device works with every
sketch on this site, and [the Explorer](/the-explorer/) tells you what it sends. This page is for
when you have nothing yet.

## The ones on this site

| Device | Where | Price band |
|---|---|---|
| PipSqueak | [useMidi](https://usemidi.com/product/pipsqueak-black), a one-person maker | low |
| Slide Trinkey, Rotary Trinkey | [Adafruit](https://www.adafruit.com/product/5021), the [Rotary](https://www.adafruit.com/product/4964) too | low |
| Circuit Playground Express | [Adafruit](https://www.adafruit.com/product/3333); needs the [multi-tool firmware](/make-your-own/circuit-playground/) first | low |
| Launchpad Mini MK3 | [Novation](https://novationmusic.com/products/launchpad-mini-mk3) | mid |
| Midi Fighter | not made any more, second-hand only | varies |

The Trinkeys and the Circuit Playground arrive as boards, not controllers. [Make your own](/make-your-own/)
has the flash steps; it takes a few minutes.

## Cheap, still made, no driver

Two that have been on George's table since the 2017 talks and are still sold:

- Korg [nanoKEY2](https://www.korg.com/us/products/computergear/nanokey2/): a two-octave keyboard
  the size of a paperback. Keys are notes.
- Akai LPD8: eight pads and eight knobs. Pads are notes, knobs are CCs. Akai's site moves it around;
  search for the name.

Anything sold as a "USB MIDI controller" from the last fifteen years is almost certainly class
compliant, which means it needs no driver and the browser and Processing both see it.

## Second-hand

MIDI gear lasts. Old controllers go for little because the software they came bundled with is long
gone, and none of that matters here.

- eBay and [Reverb](https://reverb.com), the music-gear marketplace, for anything with a name.
- Craigslist and the local equivalent. Music shops often have a bin.
- [Tindie](https://www.tindie.com) for small-run controllers from makers, the way the PipSqueak started.

## What to check in a listing

- A USB socket on the device. Older gear has only the round five-pin MIDI sockets; that still works
  through a USB MIDI interface, a cable with a USB plug on one end and two five-pin plugs on the other.
  Any class-compliant one will do.
- Bluetooth MIDI works too. On macOS, Audio MIDI Setup pairs it (Window, Show MIDI Studio, the
  Bluetooth button); after that the browser and Processing see it like a USB device.
- "Class compliant" or "no driver needed" in the description is the phrase you want. A device that
  needs the maker's software to talk to the computer is a worse bet.

Plugged in and nothing shows? [Troubleshooting](/troubleshooting/).

## Not a controller yet

A board with native USB and a sensor is a controller in an afternoon. [Make your own](/make-your-own/)
starts from a Circuit Playground, a Trinkey, a Puck.js or any Arduino with native USB.
