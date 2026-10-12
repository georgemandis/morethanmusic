# Introduction to MIDI

The **Musical Instrument Digital Interface** (MIDI) is a protocol that allows electronic musical instruments, computers and other devices to communicate with one another. It was standardized in 1983 so that electronic musical instruments of the era could communicate with one another between manufacturers. It was a relatively simple protocol designed to communicate aspects of a typical musical performance — notation, pitch, velocity and more.


## MIDI Controllers

A device that's capable of sending MIDI data to another MIDI-capable device is called a **MIDI controller.** A simple example to consider would be a simple, piano-style keyboard like this:

![Korg nanoKey](/images/korg-nanokey.jpg)

But they can vary widely in appearance and modes of interaction. Buttons are certainly common, but you might also find some that incorporate dials:

![AKAI LPD8](/images/akai-lpd8.png)

Others use more abstract and interesting modes of interaction, including mapping motion or breath to MIDI signals. For example, this controller uses three accelerometers to map hand gestures to MIDI messages:

![Hothand MIDI Controller](/images/hothand.jpg)

It turns out they're not terribly difficult to build and you can find a lot of home-brewed MIDI controllers out in the wild They can get much more elaborate in a hurray:

![Futureman](/images/futureman.jpg)


Some can be downright *bananas*:

![Bananas](/images/midi-bananas.jpg)




## Anatomy of a MIDI message

When a MIDI controller "speaks" to another MIDI-capable device or computer they are sending and receiving MIDI *messages* with one another. The protocol underlying this communication is quite simple in practice but a little verbose when explained. Still, I'll try.



#### Every MIDI message consists of **3 bytes** consisting of 8-bits (0-255)

Represented in binary, a message might look like this:

```
10010000 | 00111100 | 01111111
```

#### There are only 2 types of MIDI messages: status and data.

Every message will const of 1 status byte and 2 data bytes. A status byte will always begin with the number `1` and data bytes with the number `0`.

```
1x0010000 | 0x0111100 | 0x1111111
^status     ^data1      ^data2
```

For data bytes that leaves 7-bits to express the data in that byte. That gives us an integer range of `0-127`

For status bytes, the next 3-bits after the first describe the type of status message while the remaining 4-bits describe the channel. To break down our binary representation:

```
1x001x0000
```

With the WebMIDI API however we seldom have to process these binary presentations directly. When we send and receive these messages in JavaScript we simply use arrays like this:
          

    [144, 60, 127]

If you're working with existing musical hardware it's helpful to have this deeper understanding of how and why the messages are structured the way they are. It's helpful to know that receiving a `144` in your first byte means a note is being turned on in the first channel and that a `128` would indicate that a note is being turned off.

However, if we're building non-musical experiences and creating our own hardware these numbers can be repurposed to represent whatever you want!