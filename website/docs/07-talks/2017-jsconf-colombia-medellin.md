---
title: "JSConf Colombia, Medellín"
description: "The last stop of 2017. Twenty-seven minutes, the tightest cut of the talk, and a Morse code demo that was two days old."
slug: /talks/2017-jsconf-colombia-medellin/
sidebar_label: "JSConf Colombia 2017"
sidebar_position: 20171103
---

{/* generated from talks/2017-jsconf-colombia-medellin/talk.md by `node website/refresh.mjs talks`; edit the source, not this */}

# JSConf Colombia, Medellín

The last stop of 2017. Twenty-seven minutes, the tightest cut of the talk, and a Morse code demo that was two days old.

| | |
|---|---|
| When | November 3 to 4, 2017 |
| Where | JSConf Colombia, Medellín, Colombia |
| What | talk |
| Video | [youtube.com/watch?v=iKKUNUXoxOA](https://www.youtube.com/watch?v=iKKUNUXoxOA) |
| Event page | [jsconf.co](https://jsconf.co/) |

No slides for this one are published. A transcript is at the bottom of the page.

<iframe src="https://www.youtube-nocookie.com/embed/iKKUNUXoxOA" title="JSConf Colombia, Medellín, JSConf Colombia" style={{width: '100%', aspectRatio: '16 / 9', border: 0}} allow="encrypted-media; picture-in-picture" allowFullScreen />

## What happened

Two demos were born for this trip. The Launchpad MK2 version of Go and the Morse code demo both
have their first commits on 2017-11-01, and the Morse one was "updating for foot controller" on
2017-11-03, the first day of the conference. The deck has "workingon jsconfco" on 2017-11-04 and
"Amendments for JSConfCO" on 2017-11-07.

JSConf Colombia posted the recording the following August, 2018-08-09. At 27 minutes it is the
shortest conference version. The media folder in the deck still has a `colombia.jpg` and a
`colombia.png` from the title slide.

## Sources

- https://george.mand.is/talks/ : JSConf Colombia, November 3 to 4, 2017, Medellín
- Talk folder: `demos/midi-launchpad-mk2-go/` (first commit 2017-11-01), `demos/midi-morse-code/` (2017-11-01, 2017-11-03); `slidedeck/` git log 2017-11-04, 2017-11-07; `slidedeck/media/colombia.jpg`
- YouTube iKKUNUXoxOA, uploaded 2018-08-09 by JSConf Colombia, 1624 seconds

## Transcript

YouTube's automatic captions, deduplicated and broken into paragraphs by `talks/vtt2md.py`. Not
corrected, so names and the technical words come out wrong now and then.

<details>
<summary>Read the transcript</summary>

Microphone oh can you hear me I can hear me that's good let me do this and that's okay hello I'm happy to be here presenting in the afternoon at Jay s Kampf Colombia my name is Jorge Mendes and I'm here to talk today about JavaScript's MIDI and tiny computers thanks for coming back and and you know bearing with me after the technical difficulties this morning I feel like I kind of set things on a bad path but hopefully there I think they're straighten now I think.

We got to figure it out there's been a lot of fun talks today about you know technical things and also sort of cultural things and fun things a surprising amount of music has shown up in this conference today which is pleasing to me normally my talk is the only one that touches on that and my experience so it's been really fun to see that so in that vein my presentation is going to be kind of fun and talking about interesting creative things that we can do with some of these technologies first a little bit.

Okay a little bit about me you can find me at all these places if you want to email me or ping me or say something funny about me on Twitter while I'm talking up here I'm a freelance web developer from Portland Oregon somehow I'm not the only presenter from Portland Oregon today Emily will be speaking later today it's kind of interesting I've been developing for over ten years close to eleven years now I think that's like 45 years in JavaScript years I'm not sure a lot of things have changed in.

That time I you know when you do it for over a decade you have to wear a lot of different hats I kind of do a 50/50 percent blend of front-end and back-end these days just in case you're curious about any of that so I think it's good to humanize developers at these conferences I can get up here and just give it a technical press datian about MIDI and JavaScript and what we're doing but it might be easier when you go home later to remember something I've said.

If you remember some random fun fact about me you know maybe it helps I find it helps me so the other reason I like to present fun facts at the beginning is back in Portland I I teach a code camp sometimes I do some mentoring and one of the things I did with the newbies for the new students is I brought in developers to speak about their story like their life experience and how they became developers and what's really interesting as no two stories are.

The same you know there's sort of a perception that there's it's just all computer science majors who did this and that and followed you know from point A to point B and when you start talking to people you realize people come from all walks of life you know and in that vein I just wanted to share some random facts about me and humanized myself a little bit this is my first time in Colombia because Isis if I knew applause is gonna be that easy I would have dropped.

That more in life I once lived as a digital nomad in 18 different countries kind of an interesting story ask me about it later if you're curious I was born in Saudi Arabia that's a random fact you might remember and they'll help you remember the rest of this so that's a longer story my most known projects are not very wonderful but I mean they're not very how do I say this they're not very useful projects I'm curious a quick show of hands does anyone heard of Kaname Jas or Jekyll RSS feeds.

I heard one one two okay nothing everyone Sarah I'm surprised and I get a few if you're not familiar which is most of you Kaname Jas was a simple easter egg code javascript thing that I wrote almost a decade ago where you entered the Konami code on a website and then stupid things happen marvel.com used my script Newsweek used it it showed up in a couple of US government sites like it was really for whatever reason I made it at the right time and it got really popular.

And a lot of people use it and I still see it today it's pretty funny to me it's funny to me because that's like my most well-known thing if I start going through the list I once I once unintentionally cheated while running a marathon in North Korea I i I don't advocate cheating in general but if you're going to cheat just be very mindful of where your happen to be doing it that's all I can say and normally that's my last fun fact but after.

The introduction this morning I felt like I had to add that I forgot that I described myself as a guitar banshee on the Internet when she introduced me this morning and that made me kind of laugh so I had to throw that in there be careful what you say about yourself on the Internet okay but more relevantly I like to break things I like to I like to stretch my tools to the extent that they're intended to be used and a little bit further just to see.

What we can make with them somebody gonna become a little more relevant later today when we talk about MIDI and what MIDI was designed for and how I'm trying to use MIDI to do interesting things I think this process I think it's just good for my brain you know it keeps me interested it's it's like playing with our tools it's a creative process and I think through playing an exploration of our tools it at least for me I think it makes me a better developer.

I think it's good to have time to sort of play and do something creative and interesting not just always learning the latest framework that came out this week or you know something that I necessarily have to apply to my work all the time and I hope that this talk encourages you to maybe go home and do something kind of interesting and fun also so now that we got everything up and working let's break it again by doing an interactive experiment so I have a little website here.

And if any of you have a computer open or perhaps even a phone I think versions of Android with Chrome should work feel free to pull up that website and I want to try a little interactive demo that uses some of the stuff I'm going to talk about and I'm not gonna tell you what it's gonna do we're just gonna see what happens here so I'm gonna wait a moment and hopefully it works okay looks like I'm seeing numbers go up we have one person in.

The orchestra I'll wait until we get a few more it's a little more interesting when we have more than one two okay if I can get about four that's usually like the sweet spot though once I opened it up and there's a hundred fifty-seven in one conference and that might have been too many giving you one more person in there okay three so for those of you who have connected make sure your volume is up as loud as it can go I hope and let's just see.

If this works or if I break the connection again and because it's kind of a big room if you hear something on your machine please raise your hand so I can try this let's see is there good was that one back there no no hmm oh wait thought I hear something oh did it fail well alright well what was supposed to happen I won't push my luck on this one what was supposed to happen is as I played the notes up here on the keyboard I'm sending MIDI signals back of my computer which is then sending.

The information about those notes to your computer to the people who were connected over a puree is connection over WebRTC and we were going to in an ideal situation we get different sounds coming out the audience as I play up here on the piano it's kind of fun things the middle if he connection wise today so it sounds like it might have crashed I'll just move on and if you're really curious maybe we can demo in the hall if you want to track me down.

Okay so I'll skip over that demo here so what I'm talking about today I'm talking about JavaScript um Pocoyo this is a JavaScript conference we're talking about tiny computers and what I mean by tiny computers are single board controllers and single board and microcontrollers things like arduino z-- s Perino's raspberry PI's and more raise your hand real quick if you've dabbled with these or heard of any of these guys okay so don't see like how much hardware everyone maybe third third people or hardware dabblers.

Okay that's good and then lastly the thing we're talking about is MIDI so quick show ants who thinks they know what MIDI is or is deviled with MIDI before okay okay also not a huge number of people but that's good so I get to explain to you what it is so I'm going to dive into all three of those in a moment and describe them but first I want to talk about what makes all these things in combination kind of exciting to me these things in combination are a really wonderful platform or making interactive hardware things with JavaScript it's a really.

You can make it as easy or as complicated as you want it to be as I'll show you it's a really low barrier to entry towards starting to dabble with basic hardware programming and the Internet of Things however you want to look at that it's it's a really great way to dip your toes in that water and start to make really creative fun and kind of interesting outside the box things MIDI is a very simple protocol for this as I'll show you and oh yeah these as.

I was saying that and yeah so that's what makes this kind of an exciting platform for me you can make a lot of fun creative interactive things using a very simple stack of affordable and easily available easy to work with things okay so why javascript javascript is everywhere I don't need to tell you that there's conferences and all kinds of you know there's thousands of conferences it seems like but it's everywhere you know like 10 years ago and I started JavaScript was a it was on.

The front end only it was in your browser and now it's on the server and now we're building chat BOTS and we're building you know hardware based things and we have we have you know apps and we have AI and I mean we have you name it it's being done or at least attempted to be done in JavaScript for better or worse so that's you know the primary reason I chose JavaScript to try to do some of the things I'm talking about here you know what's interesting is.

That Stanford University that when their introduction to a computer science course they used to use Java and over this past year they switch to JavaScript so javascript really is becoming like a lot of people's first introduction to programming for better or worse in some ways so it's a good it's a good place to be it's where the people are I mean I kind of just said that but not only is it everywhere as far as the tech stack is concerned it's it's where a lot of people are doing.

The work you know one of the things I've also learned in 10 years of working a freelancing is that things can change quickly and you kind of have to go where to where all the attention is being paid you know and right now that's JavaScript and that's node and so long as it's there I you know that's a good place to be you're not gonna run out of work you're not gonna run out of new things to learn for a while I think if you focus on JavaScript JavaScript a scene nature is a very natural fit with.

The way MIDI wants to do things MIDI doesn't care when things happen if they happen at all it just sits there and waits patiently to listen for events and then sometimes spit events back out it's a totally asynchronous protocol invented in 1983 before javascript was even born you know and so when we write things interact with MIDI in JavaScript it's a very natural fit it's already you're already writing in a style that you know plays nicely with the way media wants to do things okay.

So why tiny computers first of all what is a tiny computer or what am I talking about like I said I'm talking about single board computers and single-board microcontroller z' like some of those brands I mentioned earlier I'm talking about things like these we're talking about raspberry PI's or dree nose chip computers s Perino's as purina's are kind of fun actually and this little clicker I have in my hand is actually an esper ino I programmed it to be a Bluetooth MIDI instrument that talks to a webpage.

That is my presentation and it uses that to sort of control my slideshow as I go so I can click I can go forward I can go back if I'm feeling kind of nervous I can give myself applause all of these are great they're they're fun because they're I mean affordable and generally pretty easy to use they're powerful enough to do a lot of fun creative things I mean they're very they don't compare to like the computer I'm presenting on obviously up here but they're still like 100 like 10 times faster than.

The computer I grew up learning on it's really kind of fascinating what you can do they're great for standalone projects and art projects they're you know I'll talk about it a little bit later but they are if you want to make like a kiosk style interactive exhibit that you might put in a museum or something like that you know tiny computers and this this tech stack is really a great platform for that kind of thing most of them are capable of running JavaScript natively in some capacity or another.

The s Peru you know actually you write on the hardware level in JavaScript it's kind of interesting others you know are just like tiny Linux computers you can run node and do other interactive things there there's a great library called Johnny Five I thought I was familiar with that I'm curious anybody yeah so Johnny Five Daioh is a really great website to go to to sort of see how to get node up and running on a variety of hardware don't worry about remembering that I have a website at.

The end has links to most of the stuff I'm talking about so don't don't worry about that I talk kind of fast sometimes they're also fine and so why MIDI and what is MIDI exactly so MIDI is an acronym stands for the musical instrument device interface okay that maybe tells me something maybe it doesn't I find for those that do know MIDI or for those that are familiar with MIDI to some extent there is a little bit of confusion sometimes as to what that actually means because it's used interchangeably for three different things sort of it's used to talk about.

The MIDI protocol which is how the machines talk to each other like how a musical instrument talks to another musical instrument or how a musical instrument might talk to a computer it's also used to describe the MIDI standard which is sort of this in-between thing where a we're all explained the next slide actually and third of all MIDI is often used to talk about MIDI files which I find is what most people are familiar with talking about maybe you know the sort of like chintzy music.

This sounds or something like this that is a MIDI file and there's MIDI to say that this is mating doesn't really capture the whole thing that's my adventure so MIDI the protocol that's kind of the thing that we're focusing on today that's the thing that makes it interesting so it's it's a way for electronic musical instruments to speak to hardware and other MIDI capable devices like my laptop or like some of these devices I have up here on the table it's it's kind of like some of.

The IOT hardware protocols before any of that existed in a weird way yeah it's a super simple protocol it just basically you send three numbers back and forth and you get to decide what those three numbers I mean to some extent now the MIDI standard is actually the thing that gives those numbers meaning right so if I push to this button here on my keyboard that's going to send three numbers to my computer and because of the MIDI standard which was decided upon by electronic music instrument manufacturers they they live agreed.

That you know that particular combination of numbers that gets sent when I hit that button that's gonna be a note that's gonna be that's gonna be a see a middle C and and this other numbers when to tell it okay this person is pressing the button and it's on and when I lift my finger that sends another set of three numbers telling my computer hey they've lifted their finger up now that number is off and there's kind of variations on that I like to say think about HTTP codes.

Right everyone's familiar with that I imagine or most people so you've all got a 404 error on a web page right so in HTTP code is just a number and the reason those numbers have meaning is because standards bodies have decided to give those things meeting and we all agree on that MIDI is kind of the same way the MIDI signals the messages themselves are just series of numbers and what they actually correspond to on the instruments is just sort of agreed upon by a standard.

And where this gets fun is that we can ignore the standard if we want to start making things have nothing to do with music we just need to know what numbers are getting spit out back and forth and lastly a MIDI file is just contains a sequence of MIDI events it describes when they happen and that's how you can basically recreate a song using a MIDI file it makes me kind of think of a player piano or this kind of a visual visualization sort of a guitar hero kind of a thing.

So to get back to the question why MIDI MIDI is asynchronous and plays nicely with JavaScript it talks to hardware which you know is sort of where my interest lies and there's a fun way to dabble in the IOT and MIDI is really easy to use for non musical applications because it's a simple protocol it's just three numbers and here's the other really cool thing chrome talks to MIDI all of you out there of Chrome on your computer right now I could plug in any of these devices.

And we could write a little webpage in JavaScript this starts talking to that device and started making something interactive right now you don't need to install anything special we don't need special drivers you don't need anything chrome does it natively and by extension so does chromium and electron and Chrome OS and that kind of opens up the door for possibilities now you can make a standalone MIDI capable application using electron and if you're using you know custom MIDI hardware suddenly you have a very custom hardware interaction experience.

That you're creating just using JavaScript and that's kind of fun to me and you can also do it on the server side with node which I realize I sort of skipped over for those who are curious can I use comm lets us know that 59% are we 59% global coverage on the web MIDI API which is pretty useless but I just want to throw that up there and when I talk about MIDI controllers like maybe musical instruments I want to show some of you what these are since not.

All of your probably musicians and it might be helpful to see this so we're talking about things like keyboards like this that's actually the first MIDI capable synthesizer ever created back in 1983 little things like that DJ equipment buttons more buttons foot controllers this one you can actually breathe into like a flute this one is like an accelerometer that I'm actually wearing on my finger but I mean I get to because I'm gonna kind of rush through some demos here in a moment or you can build your own which is also where it gets interesting.

So when I say they can be as easier as complicated as you want it to be this is kind of what I'm talking about that is a a small computer I purchased from out of komm it's the circuit playground and I was playing around in a hotel at a different conference trying to build a little bee Ana banana piano and there was really easy so I may I turned it into a MIDI controller and when I tap the little bananas it sends MIDI signals and then two minutes later.

I make a little JavaScript page that listens for those MIDI signals and now you can make you know it doesn't have to be music I can make a website that just says hey you touchin a banana great you know I told you this wasn't gonna be useful talking necessarily I might breeze through this because I'd like to show you some demos but a MIDI message is just three numbers if you want to know more about that go to the website I'm gonna show you at.

The end so ya this page so that when I read the signal from the hardware I get it like this when I want to interpret it per the MIDI standard I have to look at it through this lens but at the end of the day all I have to know is that when I hit this button on my keyboard I get an array of three numbers like that that's really all I need to know and we'll try it on a different page here so what is using javascript.

And MIDI look like it's actually it's the same as using like the web camera or the location API of the notification API you ask for permission it returns a promise if they allow for maybe the user allows permission for that then you can start interacting with any MIDI device that's plugged in to that page I mean I'm sorry plugged into that computer while they're on that page it's really very straightforward and there are some existing libraries out there that make it easier to work with in certain capacities particularly making musical things.

But like I said I want to show you some of the non musical demos that we can do here and when we're doing MIDI on the server there are some it's pretty much the same there a couple extra things we can do interesting system level things latency can actually be more of an issue on these sort of server side depending on what you're trying to make and working with MIDI files is easier as you might imagine but for the most part it's pretty much the same here's an example of a node script.

That interacts with MIDI listens from any message that's all there is to it as far as talking to MIDI and getting to work so let me show you a couple things that use the stack and like I said if you're interested you can track me down in the hallway I'm happy to show you more of this and talk a little bit more about how you can get started with this at home so I will show you I have a lot of demos here let me find a good one.

Okay so this is one of the first demos I ever made I'm a musician sort of back at home I'm actually a very analog musician and I played somewhere once with my friend and we wanted to have a visualization behind us we wanted to sort of artsy visualization they had like poems and words and moving video and stuff and I'd been just learning a little bit about MIDI and how to script it and I realized I could write a little program that just generates random art behind us while.

We play and so I made this little thing and it generates a random poems when I hit this button down here which I normally have by my foot and then I hit this other button and it creates sort of random arts so these are the kind of things I like to make my spare time just random generated okay oops no no not again there we go here's another quick demo this is a launch pad which is a a common DJ instrument you can see this up here on my screen.

And I just created a simple page that allows me to draw images and sort of interact with it on the page it's kind of fun not bad I made another one I won't do that one I apologize through this one this is another one uses the launch pad one of my first programs I ever wrote was something that just bounces the ball on the screen when I was like 10 years old that's become like my version of hello world when I want to learn a new language or a platform or something like.

That and so I made something that just sort of does that on the screen and if I add a couple more they start to interact with each other when they collide like I said it's like creative exploration creating art creative interactive Hardware real-world things using javascript this is just an ordinary web page there's really nothing else special going on there I will skip that one also here this one sort of an interactive maze I can control where this little guy shows up using the keyboards are using.

The arrow keys on my keyboard I actually have this set up to use WebSockets and stuff - I'm not going to do that now and where the physical interactive component comes in is I can like start to draw walls on the screen and I can't actually pass the wall until I make the little hole there anyway fun goofy interactive things obviously the bigger screen that'd be kind of more interesting I will just you I'll show you the very last one which is who plays who's familiar with.

The game go any go players here okay so what I have here is a fully functional the slightly small version of the go that we can play either by taking turns on the board like this let's see I'm not very good at go I apologize see or I can actually click over here on the screen interact with it that way and what's fun is I can actually I have a server-side version of this running on a tiny computer that's entirely self-contained and I powered it with a battery once.

And I had the world's most inconvenient tiny go board running on a tiny computer I'm going to that's the last demo I'm going to show up here because I'm kind of running out of time there are many more demos I have that I could show you again track me down if you'd like to see them or talk about any of them some of them are less visual this is the last thing I wanna leave you with is this is an installation in Seattle Washington near where I'm from in Portland.

And they've used billiard balls and pipes and interesting things to creating interactive musical and I'd like to end this because I think it's cool always they can totally non-musical things to create this big interactive musical thing and that's in some ways kind of the inspiration for taking this musical further call and trying to make interactive non-musical things gracias.

</details>
