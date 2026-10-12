---
title: "HolyJS, St. Petersburg"
description: "The first time out. Make More Than Music with Tiny Computers, JavaScript and MIDI, an hour long, on the last day of the conference, with six controllers on the table and a Puck.js in my hand."
slug: /talks/2017-holyjs-st-petersburg/
sidebar_label: "HolyJS 2017"
sidebar_position: 20170602
---

{/* generated from talks/2017-holyjs-st-petersburg/talk.md by `node website/refresh.mjs talks`; edit the source, not this */}

# HolyJS, St. Petersburg

The first time out. Make More Than Music with Tiny Computers, JavaScript and MIDI, an hour long, on the last day of the conference, with six controllers on the table and a Puck.js in my hand.

| | |
|---|---|
| When | June 2 to 3, 2017 |
| Where | HolyJS, St. Petersburg, Russia |
| What | talk |
| Slides | [speakerdeck.com/georgemandis/make-more-than-music-with-tiny-computers-javascript-and-midi-at-holy-js-2017-st-petersburg](https://speakerdeck.com/georgemandis/make-more-than-music-with-tiny-computers-javascript-and-midi-at-holy-js-2017-st-petersburg) |
| Video | [youtube.com/watch?v=-Ml7J3ocqUo](https://www.youtube.com/watch?v=-Ml7J3ocqUo) |
| Event page | [holyjs-piter.ru/en](https://holyjs-piter.ru/en/) |

<iframe src="https://www.youtube-nocookie.com/embed/-Ml7J3ocqUo" title="HolyJS, St. Petersburg, HolyJS" style={{width: '100%', aspectRatio: '16 / 9', border: 0}} allow="encrypted-media; picture-in-picture" allowFullScreen />

## What happened

This is where the whole thing starts. I flew close to 30 hours to get to St. Petersburg, forgot my
voltage adapters at home, and spent the first day buying new ones so the gadgets would charge. That
is from the post I wrote the night I landed, 2017-05-31.

The talk was an hour. The only other time I had spoken to a room was a five-minute Ignite talk in
Portland, so an hour terrified me. It turned out to be the easier format. I could pause, drink water,
look at my notes. I also had too much to say about the history and the byte layout of MIDI and
promised myself to cut it next time. That is from the reflections post, 2017-06-10, which also says
the talk was on the last day, second to last in English before the closing keynote, and that Lea
Verou and Douglas Crockford were on the same bill.

The speaking notes for this one survive as a text file in the talk folder, "MMTM Talk Notes from
Russia 2017.txt". They open with the Websocket Symphony: everyone in the room joins a wifi network
called Sputnik, opens sputnik.local, and I play their phones from a keyboard. The notes admit "I've
never tested this with more than... 10." They also have the Big Lebowski bit about three-byte
messages ("We have three... numbers, man. They can mean what you want"), the Goonies organ, the
Puck.js that turned middle C on over Bluetooth, and the line I still think is the whole talk: "I'm
basically building fun, goofy things on the shoulders of giants."

The recording was posted by the HolyJS channel on 2017-11-22 and runs 56 minutes.

## The setup

Six MIDI controllers, three Node servers tunneled through ngrok, a WebRTC demo, a WebSockets demo,
audio and video, all off a 2015 MacBook with one USB-C port. There is a photo of it in the ngrok post
from 2017-07-06, captioned "The whole thing looks absurd." The deck's `NOTES.md` still has the
hostname for the day: `ngrok http -hostname=holyjs.mand.is 9000`.

## Sources

- https://george.mand.is/2017/05/speaking-on-javascript-midi-and-more-at-holy-js-2017/ (2017-05-31)
- https://george.mand.is/2017/06/reflecting-on-my-time-speaking-at-holyjs-in-st-petersburg/ (2017-06-10)
- https://george.mand.is/2017/07/how-ngrok-saved-my-talk-at-odessajs/ (2017-07-06, the setup photo)
- https://george.mand.is/talks/ : HolyJS, June 2 to 3, 2017, St. Petersburg
- Talk folder: `MMTM Talk Notes from Russia 2017.txt`, `slidedeck/NOTES.md`
- YouTube -Ml7J3ocqUo, uploaded 2017-11-22 by the HolyJS channel, 3395 seconds
