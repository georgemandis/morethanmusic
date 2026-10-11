---
title: "JSFoo 2017, Bangalore"
description: "The version I pointed people at for years. It was the one embedded on midi.mand.is, and it still is on the page that replaced it."
slug: /talks/2017-jsfoo-bangalore/
sidebar_label: "JSFoo 2017"
sidebar_position: 20170915
---

{/* generated from talks/2017-jsfoo-bangalore/talk.md by `node website/refresh.mjs talks`; edit the source, not this */}

# JSFoo 2017, Bangalore

The version I pointed people at for years. It was the one embedded on midi.mand.is, and it still is on the page that replaced it.

| | |
|---|---|
| When | September 15 to 16, 2017 |
| Where | JSFoo 2017, Bangalore, India |
| What | talk |
| Video | [youtube.com/watch?v=R0-XLrr8icY](https://www.youtube.com/watch?v=R0-XLrr8icY) |
| Event page | [jsfoo.in/2017](https://jsfoo.in/2017/) |

No slides for this one are published. A transcript is at the bottom of the page.

<iframe src="https://www.youtube-nocookie.com/embed/R0-XLrr8icY" title="JSFoo 2017, Bangalore, JSFoo 2017" style={{width: '100%', aspectRatio: '16 / 9', border: 0}} allow="encrypted-media; picture-in-picture" allowFullScreen />

## What happened

Hasgeek filmed this one and had it up the next day, 2017-09-16, under the title "Tiny Computers,
JavaScript and MIDI". When I made the midi.mand.is landing page I embedded it with the words "You can
watch this version of my talk from JSFoo 2017 to get a sense of the topic," and that line is still
on the page it forwards to.

The deck has a commit from the day before, 2017-09-15, "JSFoo updates". There is also a separate
outline in the notes folder, `jsfoo-conversation-notes-outline.md`, that shows how the talk was
restructured for this run: open with the Websocket Symphony, then Symphony II with a MIDI file
spread across the crowd's phones, then introduce myself, then MIDI, JavaScript, tiny computers, then
four or five demos. It has the sentence that became the whole second half of the talk: "The secret
to this stack: MIDI is just numbers."

The abstract in the video description is the one from the notes folder: "We're living the halcyon
days of tiny computers and JavaScript, but MIDI is a technology that's been around for much longer."

## Sources

- https://george.mand.is/javascript-webmidi-tiny-computers (embeds this video as "The Talk")
- https://george.mand.is/talks/ : JSFoo 2017, September 15 to 16, 2017, Bangalore
- Talk folder: `slidedeck/` git log 2017-09-15 "JSFoo updates"; `notes/jsfoo-conversation-notes-outline.md`; `slidedeck/NOTES.md` hostname `jsfoo.mand.is`
- YouTube R0-XLrr8icY, uploaded 2017-09-16 by Hasgeek TV, 2649 seconds; description links https://jsfoo.talkfunnel.com/2017/19-tiny-computers-javascript-and-midi (unreachable on 2026-10-04)

## Transcript

YouTube's automatic captions, deduplicated and broken into paragraphs by `talks/vtt2md.py`. Not
corrected, so names and the technical words come out wrong now and then.

<details>
<summary>Read the transcript</summary>

Okay can everyone hear me now that's a little bit better I think okay well I I want to thank everyone for coming and I really want to thank Jess who for having me there are a lot of really cutting edge progressive talks here we have talks about progressive web apps and web components and people from very you know impressive companies like Google this talk you know all those talks those have like cutting edge information you're probably gonna be able to take home and use in your work or using your personal projects my talk I'm not.

So sure so on that third column where you check off whether you're gonna use it in your work you can already just check a one right there I don't mind I won't be offended so anyway my name is George man just like they said I am from Portland Oregon out there I am from Portland Oregon in the US I'm a freelance web developer I've been doing it for over a decade now one of the earlier slides during the first talk this sort of showed the evolution of front-end development it it kind of made me cry on some level because.

I remember each one of those stages so well and it's just a lot of pain it feels like a very long time some days Oh before I do all that yeah so I'm here today to talk about three things sort of primarily JavaScript MIDI and tiny computers and I'll get into what all these things are a little bit later here so let's through these some fun facts I think I think it's nice to sort of humanize developers a little bit you may or may not remember some of.

The things I say but if I say a couple funny things up here you might remember that and then you might remember something else I said right after it and so I kind of use it as a way to help people learn things or maybe he'll take away something from my dogs this is my first time in India it's a fact I don't know how fun that actually is for you it's fun for me I lived as a digital nomad in 18 different countries for over a year it was kind of an interesting story.

I like to throw that up there I was born in Saudi Arabia which is a long story and kind of interesting they already i forgot i put that on the bio but I once unintentionally cheated while running a marathon in North Korea thank you okay I cannot advocate cheating in general but if you're going to do it I would suggest picking a more lenient country it was fine my most known project is a really frivolous one called Konami JIS I always ask has anyone heard of it I'm curious are there any hands.

Okay like I see like five hands it's like maybe what I expected and I'm guessing you found it cuz you google my name cuz you saw that I was talking you wondered who I was maybe but that's okay it's a really frivolous easter egg project I started over a year ago and I'm sorry for almost 10 years ago it my claim to fame with that project is for about five minutes I crashed marvel.com because they were using it and I I pushed some changes to github.

And they were linking directly to the file and Newsweek decided to use it to make all of the articles on their website turned into articles about zombie attacks and other weird things like I said it was a very frivolous piece of open-source software and I'm kind of proud that like my most known contribution is really pretty silly and so you know in keeping with that I'm going to talk about more silly things with MIDI today so I like to start with an experiment here okay.

So I'm gonna pull up a website and if there's anyone out there with a laptop maybe a few people feel free to pull up this website I'm gonna wait a moment I have I have a lot of demos I've learned over the course of giving this talk I probably have too many demos so I may skip a couple as we go down the line but if you are interested in this stuff if you think it's fun you want to see more and talk more about it come meet me downstairs later.

And I could show you some of the demos I'll probably end up skipping over okay so hopefully a couple people have at a moment to could I say okay I see four people have joined so far that's probably enough so make sure your audios up I want to do just a little a little interactive demo here to start just to see how things go and this has been occasionally hit and miss but let's see how it goes so let's see how it goes Oh who's.

That could you raise your hand oh there we go there we go yeah so what's happening now is I'm playing I'm playing on a little keyboard up here on my stage which just in case you want to see what my stage looks like right now it's kind of a mess of many things here and what happens is every time I play a new note it comes out on a different computer out here in the audience using WebRTC okay here we go oh and now that I've got 71 of.

You in here I think I could actually play some chords okay anyway I just like to start with something kind of fun well that one went pretty well you know I think it's just fun sometimes too before you delve into the code or even instead of delving into decoding these things it's just sort of fun to sell the fun outside of the box interesting things you can do with with these things that we're talking about okay so I one more interactive demo let's see how.

This goes you kind of know the drill by now there's the website so it's a little bit different and I'll try to rush through this here I hope you've had a chance to see the the domain and type it in okay so once you get that you see a little page just as join the symphony and go ahead and click on that button it'll look different than my screen this one I'm a little less optimistic about working at the moment just because I'm noticing my web font isn't loading.

So something well you know that's why you can come back to them oh oh and Brooke shutdown that'll do it okay well let's move on okay so like I said today we're talking about three things we're talking about JavaScript obviously it's a JavaScript conference talking about tiny computers and what I mean by tiny computers are things like Arduino and Raspberry Pi Zess Perino's basically single board computers and single-board microcontroller x' quick show of hands how many of you have played around with any of these like are doing those things like.

That okay so maybe close to half or third to 40% I can't say they've added judging crowd pants and lastly MIDI I'm curious how many people are familiar with MIDI and think they know what it is okay your answer how many of the same people have put up their hands or musicians you're pretty good overlap okay so we're talking about these three things and the reason I like these is in combination you can make some really fun kind of outside of the box things using javascript tiny computers.

And a really old protocol called mini so why JavaScript I don't really have to spend a lot of time on this but javascript is everywhere it's on the client side so the server side it's you can use it for everything you know DVS per we know like I talked about earlier is you can actually write JavaScript that runs on the hardware directly it's a really cool pretty thing yeah basically javascript is literally just about anywhere you can think of when it comes to computers and programming.

And yeah like I said it's basically everywhere it's also you know where the people are there are so many JavaScript conferences and so many projects and there was a joke earlier about you know you go to NPM you type in the words thinking you looking for the packers you think you know that you want to get like 64 suggestions and you have to figure out which one you want to use you know there's just so much traction in the JavaScript community it's just a really good place to be.

Right now the asynchronous nature of JavaScript is a really good fit with MIDI so I'm going to talk about what the MIDI protocol actually is but MIDI is also an asynchronous well it's an asynchronous protocol and it's asynchronous nature makes working with it in JavaScript really easy it's it's very familiar and it's like almost any other sort of web-based or in the browser API you might think of so why tiny computers to be perfectly honest I probably could have done this talk without that but.

I just think they're so cool I think they're a lot of fun they also kind of remind me of sort of the the hardware answer to the open-source movement in some ways or something just very freeing about being able to buy a computer into own the entire thing and be able to put things on it in this you know in this day of like serverless technologies and cloud computing it's like for all the wonderful beautiful things that those can bring you know they're kind of owned by three big companies.

So at the end of the day and it's kind of nice to do something that's a little bit removed from anyone else's jurisdiction I think and just for those who don't know we have a Raspberry Pi and Arduino chip computer is anyone familiar with chip I'm curious yeah they're not as popular but I think they're really fantastic I really recommend looking into them oh and by the way at the end I have a website there's links to a lot of the stuff so don't worry too much about tracking.

What I'm saying and the last thing at the bottom I have an esper we know so this little clicker that I'm using is actually an esper II know it's a it's a tiny computer that I programmed to operate as a MIDI controller and I'm using it to control my my slides right now I can go forward I can go back and if I don't feel like there's enough applause I can do this and I get pause I have to make myself laugh sometimes okay so more.

You know more outside of the box and interesting so far so why MIDI so what is MIDI many Bolton acronym stands for musical instrument device interface that's kind of opaque I mean sort of it's a protocol invented in 1983 that's the other thing I think is really interesting about playing with JavaScript in MIDI it's a very old protocol that works with like the latest technology that we're using and it's funny how nicely they talk together and it's funny how I would say there are more interesting things.

You can do with MIDI now and you necessarily could say 10 years ago or I should say it's easier to do this interesting piece now and it's just funny how you know technology has a way being a little bit cyclical we like to reinvent wheels old things become new and MIDI is just kind of a funny outlier that sort of struck struck a chord with me when I was thinking about that it's also a standard it's actually the as I'll get into in a minute there are certain companies.

And bodies that maintain what the MIDI standard should be and I just think it's an interesting parallel with our own industry with what like you know w3c standards in their open standards and how those are decided and dictated it's pretty similar it's also a file format and I feel like this is probably where most people are familiar with it I think if you were depending on your age if you're growing up in the 90s or early 2000s like if you were on the internet in.

The days before mp3s like made streaming audio very easy you might have downloaded really chintzy sounding MIDI files like this or this I will play all these I'll take you up but and I you know at least between it with a lot of people I know this sort of these chintzy fake instrument sort of became synonymous with oh yeah MIDI that's MIDI right mitties that sort of cheap sounding music and I mean it's not 100 percent wrong but it's funny how that you know that synonym because.

The file format would be standard and the protocol or all just called MIDI as a lot of confusion surrounding like what exactly that means and it's definitely not this either I think all of these came with like Windows 95 back in the day man I'm not sure all right this one definitely it is actually okay so talked a little bit about sort of what MIDI is it's a lot of different things MIDI the protocol this is it is what allows electronic musical instruments like keyboards to talk to other electronical musical instruments.

And computers they describe common things you might associate with a musical performance like is this note on is this note off you know is this is this know being bent in a particular way and a bunch of other sort of musical things yeah it's you know this was all back in the days before I mean the first MIDI instruments were communicating like sort of directly with one another and not necessarily with computers like we would today and so it's really interesting to see how they came up with.

This protocol that still works like very well there's MIDI the standard like I said it's maintained by a body similar to other open standards and there's MIDI the file format like I said no that really does is described a sequence of MIDI events like I said the notes that Iram and it's better off things like that I always think of a piano roll kind of like this when I think of a MIDI file and how that works I just threw that in there and the last conference.

I gave this talk at I onstage it dawned on me you know I feel like Guitar Hero it's probably a much more modern example for what I was trying to convey here anyway okay so again why am I talking about MIDI in this in this talk MIDI is asynchronous like JavaScript it talks to hardware which is interesting that opens up a world of interesting possibilities and and the ability to you know hack on and create interesting things and it's incredibly easy to use as we'll see oh.

The other thing it's really interesting so JavaScript conductor mode talked to MIDI via node there's a lot of NPM packages and things but the thing that really piqued my curiosity and all this was when chrome shipped a couple years ago with MIDI support you can plug a MIDI capable device into your computer and Chrome will see it and you can start interacting with JavaScript with that MIDI device without any crazy extensions or plugins or any other like you know witchcraft it just kind of works out of.

The box like I could take these MIDI controllers and plug them into all of your computers out there and we could start hacking on it and making interesting Hardware JavaScript collaborative things and so by extension like I said so does Chrome OS chromium and electron which is really interesting if you want to make a standalone piece of software that operates with a heart a piece of hardware that maybe speaks MIDI and I went to curious the other day and I looked at can I use to see.

What browsers support it and it's really only Chrome but I guess technically we have 59% global coverage which is a lot better than I would have guessed not that I expect to use that information for anything okay so when I'm talking about MIDI controllers we're talking about like the things I have up here on my on the podium like I showed you a moment ago so there's pre-existing us be ready controllers you can actually buy controllers and keyboards and things from the mid-80s and buy an adapter.

And plug them into your computer and start talking with hardware that was invented before probably some of you were born honestly and you can even build your own getting back to the tiny computers I have I don't have it up here but I can show you downstairs if you're curious okay built a little MIDI controller using a and out of fruit Arduino based sort of a thing and the possibilities for just creative things you can build really open up when you start dabbling with actually making your own hardware.

And getting it to talk to the web and your some photos or some of these things I was talking about I've actually got this one up on stage I've got this one down by my feet I don't bring that one coz it's heavy let's see oh and yes so you know so far I've mostly talked about things like keyboards like things that have buttons but what's also interesting is there's like you know other types of sort of outside of the box controllers out there like.

This one is a breath controller it kind of looks like a flute or some sort of wind instrument but it's able to detect how hard you buy down and how how like hard you blow into it this one I also have up here it's an accelerometer that translates the accelerometer signals into MIDI signals that the browser can interpret and then start doing things with so there's just a lot of different ways to like interact with the physical world once you start delving into the different kinds of hardware that's out there.

And then this guy this guy was like does anyone know a future man is I'm curious we have one bailiff like fan in the audience I see yeah anyway he built his own MIDI controller like in the 80s and was way out of his time and is kind of out there and I just I just want to throw that in there like I said you can build your own this is a video I shot at home of a MIDI controller that I didn't but I didn't build with someone else bill else built using Arduino.

And I was experimenting with it a little bit doing an interactive website and hardware demo here there's no extra plugins or anything I just plugged into Chrome I wrote a couple of really simple lines of code and I made this this kind of fun interactive thing sadly I dropped this one it broke so I haven't been able to take it around so let's talk about what a MIDI message entails it's at the end of the day you get three numbers you get three bytes and.

You have bait only two types of messages within those bytes you have one called a status byte which is supposed to tell the controller what kind of a message we're sending like is it a is it a note that is on isn't know if that is off is it something called a control change which is a sort of reserved word for a different type of interaction and the other to tell you what sort of data to associate with that type of message you know I have links to websites to explain.

This more in-depth you probably don't want to do this you probably want to see some of the demos and some of the code samples to get a little more inspired by like what we can do with this so I'll skip through a couple these really what all this boils down to is that we hit three numbers in an array kind of like this and although the MIDI standard sort of dictates what those messages are supposed to mean like this one for example is supposed to be it's supposed to tell me.

That a particular node is is pressed on on this keyboard like I think gee maybe you know that's standard at the end of the day it's just three numbers and it can mean anything you want and so if you want to start using MIDI hardware to create your own contraptions all you have to keep track of is hey you know when I hit this button it gives me these three numbers if I send these three numbers back at the controller it reacts this way and.

So on and so forth okay so what does it actually look like if you're using Chrome you may be familiar with this you can you know if you want to make a webpage the requests location or wants to use the webcam or send notifications you have to ask the user for permission MIDI is kind of similar it's kind of a funny one it probably never pops up because there are not many you know websites asking you for MIDI access when you arrive for the most part.

But if you you know pull up any website look at it right now you should see it at the bottom and asking for requests to the MIDI access object looks you're more or less the same as it would to ask ask access to the like geolocation API or something like that you know you ask for access if it gives you access you give it a function to run if it's successful you give it a function to run if it's a if it fails and then there are a few other sort of specialized aspects of.

The API to handle messages as they're sent back and forth between your device and the page that you have set up I have some examples here of iterating through a bunch of control keys up here on stage I have one two three four five six seven MIDI controllers I think plugged into my computer right now and so this is just a tiny example of how I have a little function or a little that iterates through all of the available controllers looks at them by name.

And maps them to particular places so that I'm not you know down the line looking at like what was MIDI controller 1 what was MIDI controller 2 I really don't remember is that this little clicky thing in my hand or is it the keyboard I can't remember and then you know handling a message like I said you you just get an array that has three numbers there's some other event data that comes with it but the the three numbers and the data are really the only thing.

That are important or is interacting with it and yeah so there are some existing libraries that make working with it a little bit more easily easy especially if you want to work with it in a purely musical context like I said there are links to this on the website I have at the end but web MIDI is does a very good job of you know helping you write code that more clearly describes hey we're listening for a note that is going to be played we want to send a note to.

This device whereas the the sort of the built-in web the built-in web MIDI API has more sort of opaque methods when it comes to interacting in that way so here we have some MIDI utils ojs is a good utility for taking these MIDI messages and Coerver and converting them to notes and frequencies if we want to again create a more musical interactive kind of experience with our MIDI controllers and that's not it for the presentation that's it for talking about MIDI and so quick quick.

We mostly talked in these demos about the client side I'll touch real briefly on the server side it's very similar the only difference is we don't really have to request permission latency can be more of an issue depending on how you're trying to use maybe I could talk more about that downstairs if you're curious working with MIDI files is much much easier some of the front-end libraries that I just went through web MIDI and MIDI utils digest will also work on the server side which is very nice.

And you can do more interesting system level things one of the interesting things I'm playing with right now is you can actually create virtual midi instruments on your machine using node and when you create a virtual midi instrument in one instance of node you can fire up another one and it'll see that midi instrument and you can start sending messages back and forth and you have to think of a good outside-of-the-box way to use this but I'm I'm open to suggestions we can talk about it more later yeah.

And there is just an example of these server-side JavaScript and using MIDI on the on the server side using a MPAA NPM package called appropriately enough MIDI we listen for input from the MIDI object when we get a message we log it to the screen I don't know if you can read that but I just put parenthetically or commented out an example of the array that it usually spits out okay so now it's demo time let me show you a bunch of the interesting things.

I made and why I think this is a really good platform for you know creative computing and creating sort of hardware JavaScript hybrids and thinking about user interfaces in a way even outside of the computer that might be fun so one of the things I'll skip that one Excel is not as much fun this one's more fun well no no I got to do it I feel I got to do it okay so this piece of so this little page that I threw together it is.

All it is doing is finding all of the MIDI controllers that I have plugged into my system right now and then just listening for messages and it is spitting out the numbers that it sees when when messages are sent from this controller so if I start playing notes on my keyboard it's telling me okay when I push this button down I get those three numbers from my Nano key to keyboard controller if I push this button over here I get those three numbers from my launch pad mk2 controller.

And when I release I notice I get another number that that third number sort of changes between 0 127 and the whole reason I'm demoing this is sometimes if you delve into the world of building your own controllers or you know buying controllers off of like Aliexpress like I like to do that come with node mutation you have to learn how those controllers are built and how they work and so this can be a good way to just sort of explore how the controller is set up.

And what messages get sent when you hit different buttons okay so here's a quick musical example again you know we basically just did this in a more fun interactive way but all I'm doing is playing this keyboard up here no pretty easy you can find a lot of different MIDI MIDI uh web sent to demos out there under the hood we're using the web mini GS library I talked about the MIDI utils Jas library and pizza kado to actually generate the sine waves there's more fun with Web Audio here I'm using a different controller here to trigger sounds.

And let's see there we go so only to disturb your sound obviously and now if I turn these knobs I can alter the paycheck nails at the time I'm playing with different aspects of Web Audio which is a fun thing unto itself and worthy of a talk you know and that's just one example of a sort of audio based demo here and there in accurate interactive piano recital that's the thing I started at the top of the talk with this one which I will show people downstairs.

If they are interested and so okay let's look at the things that are not musical I should have enough time to get through a fair number of these now and then take a few questions I hope so one of the interesting things I've tried to build is ways to interact with different like css3 properties and things like that here is something let's see this is just a basic color mixer let's see ah there we go okay and so using the knobs in the same controller show - here.

I can mix different components of red green and blue to use it kind of like a color mixer I don't know if it's the most practical sort of thing but it's kind of a fun you know interesting way to play with this so you like get a little bit of green in there there we go it's kind of fun again under the hood I'm using web MIDI jeaious again on this because I just felt like it for some reason and then a nice uh library called tiny color just to mix.

The colors and things this is a interesting one I made a long time ago I called it my interactive poetry box and so the easiest way is just a demo at all it's doing is it's taking it's creating random poems using existing texts from Gutenberg the Gutenberg Project and open source video from archive.org and also random audio snippets from audio org to sort of create a mash of these different things and this was actually the project I made this a few years ago for a band.

I was playing in we wanted some interactive visuals behind us while we played and so I just came up with this idea I realized oh hey I could use these MIDI signals I don't have to use them for music I could use them for something interactive and kind of interesting so I made this and all I'm doing you can't really see it I realize from down here but I have three little buttons on the stage I can step on and when I step on them it triggers just different aspects of.

This page I made so when I hit this button it gives me a different randomly generated poem which sometimes they seem kind of profound and sometimes they really don't and I made this middle one we should get a random video playing in the background there we go animate at this third button okay and so what you get is sort of this really interesting interactive kind of mark projects very different things on a webpage laughter together and this project was actually kind of the impetus for life though there's probably a lot more interesting stuff.

That we can do I'll close this and kind of sail through here if you want to know how I made the random poems and things we can talk more about it later it was kind of an interesting conversation okay I mean quiz show answers who's seen the movie The Goonies okay there's a few more than I expected I might actually skip this one just because of that I'll skip through the next one here for those are not familiar with the movie it's it's a really it's an old movie from.

The 80s a lot of people my age growing up in the US probably saw it and there's a scene in the movie where the kids who were trying to escape these bad guys come across an organ that is made out of bones and they have to play the music correctly in order to open a open a gate so they can keep going through this this place that they're trapped in and I was looking into you know microcontrollers and JavaScript and MIDI and I realized hey with a couple like servos.

And stepper motors we could actually build that thing and that would be sort of a fun project and I made sort of a fake version of it here and I'm gonna skip it though for now because it's not as interesting if you don't know the movie to be honest so let's move on okay this is what I was talking about so here is an example of a bunch of microcontrollers hooked up to servos and and motors and this guy it's a plane no it's not playing.

This guy is using a MIDI controller to trigger the servos and have them turn so what I want to build basically is a fake organ that could eventually open up a door or something else kind of interactive and strange she wants to apply CSS filters we we have showed you the one where were mixing colors earlier I also did one where we can play with different css3 filters which is kind of fun what sort of fun about this context is I can mix multiple filters at.

The same time just to sort of see how they all look in combination again it's not super practical but it's a way to sort of try something new and outside of the box and use your brain in a slightly different way someone pointed out to me that this could be a very cheap and sort of ineffective alternative to the the Microsoft dial and I you know I'm just I suppose it could be drawing a simple image so this is a pretty simple one I have something up here called a a launch pad let's see.

You can sort of see and so I can just click it right now to sort of light up these buttons like so I'm sure you don't watch the page anyway there we go and so now I can sort of use the launch pad as a way to draw simple pictures if I had a larger one I think it'd be a fun way to like draw like a favicon or something like that Oh a little more interesting so this one is actually using the accelerometer controller.

I talked about at the top let's see turn it on now that's more helpful there we go and so this little guy now if I move it I could be the x y&z axis C's are mapped to the red green and blue values of the colors and I thought this is just kind of an abstract way to maybe you know mix colors or make some sort of interesting demo you can also change it to HSL let's see yeah so now I'm in HSL mode and that's a little more interesting because.

If you keep it level it's perfectly white you can move it up we get sort of a red color down we get that same red or a different sort of written oh on that same idea where let's see I'm gonna go I'm gonna go two more minutes and then I can take some questions here actually let me skip well let's see yeah I'll skip forward here okay this one so my mind always turns to games when I'm trying to think of new ways to explore things.

And just make them interesting for myself and other people and so I made this recreation of a a whack-a-mole game like I remember playing as a kid using oops this guy right here so I've mapped these different pads to the different moles that pop up on the screen here and when they show up always have to remember which one this is there we go when they show up I can try to hit them anyway but because the the pads are also velocity sensitive you can factor in different components to.

The game it's kind of an interesting fun way to reuse these controllers okay one of the first programs I made as a kid was an interactive like ball that bounced on the screen I remember doing I was about ten years old and like quick basic or something like that and so it dawned on me that might be a good sort of first program to try to use for one of these MIDI controllers to create a new sort of interactive thing and so let's see so.

I hit this button here there we go it's sort of it's fun sort of become like my personal hello world to like learning a new language particularly one of the visual component I like to just make a ball bounce on the screen it's a good way to sort of learn how to do something already familiar with how to do but in a new sort of paradigm okay and skip that one for now I have to skip that one too I'm afraid and the last one I'm going to show.

You that sort of interesting is who's familiar with the game go are there any go players here okay good number if there's like a good sort of like developer go overlap I've noticed most of the time and so I was trying to think of a way to repurpose this 8x8 board that I have up here and you know although it's a little bit small I found I was able to recreate a game of go and in combination with one of these tiny computers one of.

The things I have at home is a a self-contained and very impractical go board with a tiny computer which I can connect to a battery and then connect to this controller up here and you can play a game of go so I'll play for a couple minutes up here or second here on the screen just to sort of demonstrate let it say I'm also terrible to go just so you know anyway so I just wanted to demonstrate this this is another sort of outside the box application of MIDI.

And JavaScript here oops there we go so I'm sort of this is a an installation up sort of near where I live in Seattle Washington it's outside a museum called the experience music project and what they've done is they've taken giant girders and billiard balls and steel cables and created this sort of beautiful like interactive musical thing that you can play and it's really you know it sounds beautiful and it looks beautiful and I just kind of thought to put this up here sound oh that's.

Right anyway I thought to put this up here because it sort of made me think you know what they've done there is they've repurposed non-musical things you read this beautiful musical installation and what I'm trying to show here is that we can take something that is originally just a tool for communicating about music and repurpose it to do all kinds of interesting things with javascript and hardware and create unusual interfaces in creative ways thank you that's the end of my talk I'm happy to take a few questions.

We have some time for questions have you heard ever heard of what I'm sorry yes and I've seen that one in yeah yeah more questions yeah at the back question there what are you sure it is really awesome and almost freaking but I have a question do you get any industry level projects with this API implemented do I get an a what for the second s sea level project or any industry level implemented implementation tree level projects that's what any industry level industrial level projects.

I do not personally but if if you'd like to work on when I'd be happy to talk to you thank you sure hey so meat is a really old protocol right right you can hold it closer so it's a really old protocol back from 1983 okay and like it used to work on old phones which had less space and like you know they media drink tones yes does it solve any practical purposes even today I'm like like does it solve any problems it's still very effective for communicating musical signals.

And I mean it's still very effective for like musical applications I mean are there any bands that just release on MIDI they just are there any what are they any bands that just released their albums in MIDI or something like that bands a little bit maybe I mean I honest any electronic music any any electronic musician working today is probably adopted MIDI I will say I just thought of an example to answer your question there is an old game from like the mid to late 80s an old computer game they used MIDI to be across.

The network to communicate with other it was like an old Atari game or something like that and it would use MIDI to communicate two-player games because they didn't have any other way to network and so that's I mean that's kind of an interesting thank you yeah any more questions Hey hi so how broad is the spectrum of MIDI like I'm trying to understand so there is of course the sounds that we can hear as human sure right does MIDI also go beyond things that we can't really hear MIDI does not actually bias off dictate.

The the frequency I mean the the MIDI standard suggests that or when these numbers are thrown out there that should be you know this note on a piano right so there is a MIDI signal for the highest note on a p.m. but there's nothing that would stop you from writing a program that for example took a keyboard and moved everything up into a spectrum that humans could not hear so you could make a like a symphony for dogs or something I'm wondering if if this is a good deed our Transfer Protocol which happens silently it's like.

And transfer data I can send it next to you on your phone with music that we can't hear but probably our microphone can smell cats I think there could be an interesting application there I mean what you what you're delving into at that point really if you want to stay in the web-based world you know we're delving into Web Audio and we just have to generate frequencies that are in that register and we have to set up a microphone to listen to it but you could use MIDI to.

You know describe a sequence of frequencies like describe a message like it could be a good protocol for that baby one last question we have a bunch of hardware for it and yeah if you if you go to my website I have a lot of links to that and if you want to talk to me downstairs I can make some more suggestions because I have a lot of things I need to fix up there cool oh cool sounds good thank you George thank you.

</details>
