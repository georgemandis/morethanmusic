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



    [199,  100, 100]

