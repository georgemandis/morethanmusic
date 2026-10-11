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

A transcript is at the bottom of the page.

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

## Transcript

YouTube's automatic captions, deduplicated and broken into paragraphs by `talks/vtt2md.py`. Not
corrected, so names and the technical words come out wrong now and then.

<details>
<summary>Read the transcript</summary>

All right this thing is on uh thank you everyone for being here today I know the conference is winding down and it's just after lunch my hope is that my talk can be maybe a little bit more lively than some of the other ones and maybe it'll wake you up after you've eaten your meals and whatnot um my name my name is George mandis I'm here to talk about tiny computers JavaScript and midi as you may have guessed um there have been a lot of really wonderful talks here there have been a lot of.

Uh very sort of cuttingedge practical things you can probably use in your projects and your work at home this will have none of that I promise you I actually I would be impressed I if anyone uses this and their their projects or work uh coming away from this I would really want to hear about it cuz it would probably be kind of interesting um this is this is more about fun and experimenting with pardon me and experimenting with um some Curious cutting edge browser features.

And an old protocol it's been around since 1983 and it's interesting how this protocol invented in 1983 plays really nicely with the JavaScript we know and love today and the way we like to use it so we're going to explore that um a quick show of hands who who thinks they know what midi is okay okay good we're going to dive into that a little bit because I realiz growing up as a musician I I've had a very clear idea my whole life and talking to people.

I realized that's not always the case so it's interesting to to see there's sometimes an overlap with the the the techie people I think in this technology so it's interesting so I'm going to talk a little bit about myself before I jump into it um because I because I know you came here to hear about me obviously uh so my name is George mandis I'm I'm from the US I'm a freelance web developer I've done that for about 11 years which feels like about a 100 years.

When I look at what changed in that time I I feel a lot older than I am it's very strange um uh you can find me at all these places online I never realized until I made this slide but if you if you were curious how to spell my name this would also be very useful slag is it's up there about five times I think um uh yeah feel free to get in touch uh contact me if you have questions and things that'll make more sense at.

The end I suppose um fun facts because everyone needs fun facts about the speaker they're about to listen to I threw this up here originally because I thought people might be trickling in slowly from lunch I actually what I wanted to start with was an experiment that's going to involve some of you and hopefully your computers if anyone is willing to bring out their the laptop that's actually kind of a subtle hint if if there's anyone willing to participate in an interactive component in the next few minutes feel free to get out your laptop.

And maybe fire up Chrome or some some browser um but until that point uh a couple random fun facts about me to maybe help make this talk more memorable or maybe humanize me a little bit because sometimes we don't humanize developers enough um so this is my first time in Russia I arrived a few days ago and I'm leaving tomorrow uh this hotel is very lovely I look forward to coming back sometime and having a chance to explore more of St Petersburg um most seriously.

I do want to come back it seems like a beautiful city from everything I've heard um I lived as a digital Nomad for a year and I lived in 18 different countries living and working that's uh kind of an interesting story and could probably be a talk in and of itself frankly um I was born in Saudi Arabia which is really strange when you're not Saudi that's a really long story I don't have time for that but it's interesting Maybe maybe these should be interesting facts I'm not sure.

And I once unintentionally cheated running a marathon in North Korea which you know I don't really Advocate cheating on any marathon but there are certain marathons where you should be a little more wary than others I think anyway those are my those are my four fun facts oh no I have a fifth one that's actually a little more relevant to what we're talking about now ever so barely so so a lot of people who are speaking at this event and attending uh you know work for really impressive companies.

And big impressive projects I was looking over my 11-year history and the project that the only possible project I've done that I could be known for is a little thing called Konami JS I'm I'm doubting any hands are going to go up but has anyone heard of it no okay it's okay it has almost 600 stars on GitHub so Konami JS was I made that back in 2009 and it was a silly Easter egg plugin that allowed you to enter the Konami codee on any website.

And the timing was just right uh I made it so it would work with gestures on your iPhone and all that stuff which is you know at the time a big deal um and for whatever reason that project got really popular and picked up in lots of other projects um and thus began my history with creating frivolous things like this midi presentation and Easter egg JavaScript libraries it seems that the things I I get the most attention for and the things that are kind of frivolous.

And not practical but I'm okay with that um funny story about the Konami JS project uh the big claim to fame of that one is it got used in production on two very big websites one was marvel.com which I was very excited about at the time I remember the uh the developer on Twitter poked at me and said hey you should go enter the Konami Code on marvel.com and I checked it out and I was like oh my God that's so cool and I remember at.

The time uh I was hosting it on Google code back in 2009 and he was linking directly to the raw files and I was so excited by him using it I said oh I'm going to clean it up and fix things and do all this stuff and I I did that and I went back to marvel.com just to see it work and their whole site was really up and I was like oh I did something and so I had to RT it really quick so about for about 10 seconds.

I broke marvel.com that was kind of funny uh and then the other one was Newsweek which was really funny someone had put the the Konami Code in there is a sort of a debugging tool to replace all of the articles with articles about zombies and that one was really funny and someone on forbes.com did some very like half-ass research and put my name in The Articles and somehow I got picked up on that it was really odd anyway so that those are the only things.

I feel like I could possibly be known for at this conference and I just wanted to share those up front so let's oh that's right right I I had this uh I I was going to gravel for more more likes on my GitHub project but I'll skip that slide so this is the one I really wanted to start with um I'd really like to start with an interactive experiment and if anyone I'm not seeing any laptops which might make it kind of oh no I am.

Okay okay because I only need a few people maybe to do this um so before I even explain too much what's going on if you could pull up that site you see at the bottom uh I'd like to hopefully do this interactive project with you guys I also thought if I got done with this up front then if this was a total disaster and it didn't work then I could get that out of the way real early so while you are getting that website up I'm going to get a slightly different website up here on.

The screen oh one of You's in okay two three o this is exciting can I hear four can I hear four all right four is enough um so let's see if this works oh also you should have your volume UPS volume up on your laptops I didn't explain that I guess I thought that might be clear so if you could uh crank your volume a little bit um it shouldn't be too loud and let's see what happens here I hear something where's that coming from.

Okay you got no you you won't all get everything at once you'll see let's see who's that so you again okay so you okay cuz the light there should be a little little circle on the middle of your screen that lights up when it's your turn okay now let's see if there are oh there's eight or nine of you oh I'm going to have to start playing faster because it Cycles through all the people that are present you're not okay I'll just start playing more.

So that one's loud I'm not sure who that was so I don't think this is going to translate on the video at all but I thought this would be kind of a cool experiment I'm actually really pretty pleased with this right now it's fun up here I can hear the sounds coming from different computers and with uh with nine people in there that's quite a good bit of um uh polopony I can uh there we go start making chords maybe make like kind of a.

So good all right there's I should also maybe propes this this talk is going to be it's going to be talk about midi it's going to be talking about JavaScript it's going to be talking about the tools I'm using to build these things it's also just going to be a lot of really kind of wacky demos um because you although I'm starting with the musical examples the the the Crux of this talk is midi at the end of the day is just a bunch of numbers it's just a bunch of numbers one machine throwing at another machine after.

You hit some buttons and we can do more interesting things than just make sounds I think with that and so I want to explore some of that um okay that one went really well I was I was way too pleased with that honestly okay so um and if you don't mind I have one more I have one more I promise you we won't it won't all be like this I just want to get them done up front so let me my pull up my conductor's chair up here.

And sort of a similar setup you you won't have to click on anything this one's a little more um I'll be less surprised if this one crashes and burns but we'll see okay okay two people I'm going to wait until I get about five or so I think once we get more than five some of you won't get any sound but I can explain why that is in a second here so so while I'm waiting for a second um we got a of songs here does anyone have any.

Uh any requests from the the very random selection I've made of of uh midi Tunes up here what's which one Star Wars Star Wars I knew I knew this crowd do you want to do do we want to do well I don't know I I gu just do his uh Star Wars like raise a hand no yeah okay jeez fine all right let's do this honestly this is the one I've tested the least 25 holy crap what happened um that strikes me as a as a bug on my end.

But I'm not going to think about it um okay so this is going to take a moment what it's doing right now is it's it's taking apart the midi file which has about well I think most of the other ones have six or seven Parts the Star Wars one might have more it's it's taking all the different parts of the mini file and it's it's parsing all those and it's going to send those to each of you individually so what should happen if this all works correctly is.

We should hear the Star Wars medle but you're each going to be playing different parts like you're all the orchestra now um it takes a moment though it takes a few moments and I've never done it with 25 people okay so in 12 seconds I know it's kind of an absurd countdown but there's actually a reason I chose such a high one CU you know if this is let's see just wait three 2 one let's see crack that volume a sounds like it might have just stopped H well.

The first one was really good oh oh this one builds kind of slowly I forgot about this maybe that's hm is anyone else getting parts I hear your part over there the problem with the diving it up into so many parts is some of the tracks have like three notes in them I found out so you'll get like one blip and then nothing for a minute I can hear you yeah you might have gotten the main part yeah well I tell you what I I'm going to go through.

The rest of the talk and if there's time at the end maybe we can try one more song I'll try one of the ones I know Works a little bit better so um you can just refresh the window if you want to stop the Star Wars sound anyway thank you for indulging me on that that was that was you know half a success I'm okay with that so what we're talking about today we are talking about JavaScript obviously um oh oops sorry I didn't close my window you're not seeing.

The slide what we're talking about today JavaScript obviously as this is a JavaScript conference uh I'm going to talk about tiny computers and I've basically been like making it my own term because I don't really know what else to call them because that is what they are I'm talking about arduinos uh raspberry pies esperos um and other things I know I'm forgetting at the moment basically uh little guy like this are people generally familiar with with those that I've listed on the screen can I get a little show hands I'm curious.

And how many people own one I'm curious you're okay and how many well I want to ask that actually okay uh JavaScript tiny computers and midi obviously musical instrument device interface so why JavaScript uh JavaScript is everywhere I don't really need to tell you guys but um you know it's it's really impressive to me it's I was talking the other day to someone and it's you know it's literally an interpreter that everybody I mean almost everybody in the world uses whether they're really using it or not it's got to be.

The most accessible language on the planet For Better or Worse um and we're finding it you know in more and more places it's become like sort of the universal language of of just doing anything on the web again for better or worse um so obviously that's you know one reason we would use JavaScript um it's async Rous nature uh is a natural fit with the way midi wants to behave midi uh even though was came out in 1983 and was trying to fulfill a very different role.

That we'll talk about um it it fits very naturally with the way we write asynchronous code in JavaScript and it's kind of fun because of that you know it's just a series of events and you're waiting things and it doesn't really matter when they happen um yeah it fits so naturally and nicely it's kind of it's kind of neat um and it's where the people are you know they're like I said in the last eight years or so uh you know node in particular sort or.

You know the V8 engine really but like um JavaScript is found in more and more places you know it used to just be on the client side for a long time and now we have serers side JavaScript and now we have like embedded JavaScript in these tiny computer is like the one I'm holding in my hand this is a an asiro and you can write like Hardware level JavaScript instructions on these things and you know there's probably going to be more places in the coming years.

You can use your JavaScript code and it just you know it makes even if it's not a good idea today I think it's worth tinkering around with in JavaScript or show things to work um so why why tiny computers to be perfectly honest I feel like I probably could have pitched this talk without it but I just really love them I think they're just so much fun um so to clarify what I mean by tiny computers here's all the ones I have at home well most of.

The ones I have home I have a few more than that we have our raspberry pies or arduinos um I'm really partial the chip has anyone heard of the chip computers yeah yeah I think those are really I really fell in love with those not just cuz they're $9 but um they're just very uh easy to use a real low barrier entry on those guys um so just a brief uh Spiel on these guys uh so uina was sort of the first one I remember being aware of.

And it's still sort of the go-to tiny computer you would use for like if you want to break out the breadboard and start soldering LEDs together and switches and making a more sort of interactive Hardware Centric thing um and uh that's actually going to come into play a little bit later when we talk about building your own midi controllers uh the Raspberry Pi is the one I sort of remember coming after that um and what was interesting about that is that was like an actual computer.

You could actually put an operating system on that and run all your software and it was literally just a tiny computer you could hide on your bookshelf somewhere and have do interesting things um and then like I mentioned a minute ago I really fell in love with the chip computer because although the raspberry pies are fun you know it's fun for the kind of people that like to spend half their day like setting up their Linux distributions and debugging things and finding drivers for things.

That you didn't realize you needed drivers for and you know like those kind of people chip like everything worked out of the box which I think you know everyone can appreciate but also I think it makes it more accessible for people who want to learn on these devices which is actually a big um component of my whole talk actually I think this this whole platform is a really interesting way to teach people how to do uh Curious interactive things in a way that has sort of a low barrier entry.

Um and then esperino is the one I actually only discovered these existed like a few months ago I was really excited when I did and being able to write JavaScript like on the hardware like on an embedded Hardware level is really interesting and something I'm exploring and I think we'll probably hear more about over the years okay yeah they're fast they're affordable they're easy to use the other thing that's fun is they're great for Standalone projects you know I can buy a $9 computer I can set it up to do one specific task.

And I can leave it on my bookshelf and I don't ever have to think about it you know when computers get that cheap you can start putting computers in things you didn't really think you would ever need to put a computer in and I think that's um I don't know I think it's fascinating uh they're fun that's a helpful side the other thing that I think about when I think of chiny computers it's sort of the they're kind of like the hardware side of the open source movement in some ways like there's something very empowering.

I think about being able to buy the hardware take it apart put it together the way you like install what you want on it and run precisely what you want you know that's becoming more and more rare we have these you know more and more capable services and tools and platforms but we're we're sort of acquiring them at the cost of a lot of freedom I think honestly and I I'm you know in all the ways I get sort of jaded and sad about that I'm excited.

When I look at this because this is something that when I was a kid I would have been blown away by so why midi uh maybe a better question what is midi exactly let's talk about it for a second when so uh it stands for musical instrument device interface which is first you kind of Nod think oh that makes sense and you kind of think about it you're like wait are those words in the right order I'm not exactly sure but sure uh it's a protocol.

Uh for musical instruments electronic musical instruments to speak with one another um it's also a standard there's actually a standards body from midi that is very similar to the way standards are decided in our industry they're still active today they've been around since 1985 basically all the electronics music um companies banded together and agreed how midi should work and they they maintain it and and similar to other standards there's like dozens of derivatives with weird little sort of idiosyncrasies and things um it's also a file format.

So this is why when I ask do you know what midi is I think there's occasionally confusion because we sort of use the term midi interchangeably for all these things things you know are we talking about the protocol are we talking about like a midi file are we talking about a midi capable piece of Hardware I mean I guess we could be talking about all those things but it's I think it's good to clear up that it is all those things um and was created in 1983 which is kind of kind of old for something.

That we're going to be using in our browsers on JavaScript I can't think of anything else that would be that old I should think about that um and then like I said yeah it's maintained by the media Association it's a standard it is not it is not this precisely I mean this is a midi file the reason I had this example is I remember growing up in the 9s before we had MP3s for whatever reason we listened a lot of MIDI files um I'm sorry there's only.

So much of that I can take when I'm talking uh I remember listing these mini files and at least when I was a kid in the '90s the word midi just came became synonymous with basically these chintzy sounding instruments and these silly songs and things like this so it's it's not this which is a a song that came shipped with Windows 95 back in the day it's not this which is another one I kind of like this one actually got to wait for it there.

We go and it's not this now this one's funny so Brian or was an intern in Microsoft and they asked him to write this song to promote Windows 95 and he never got credit for it there's an interesting blog post about it if you want to look it up I also think it was actually really kind of fun looking at the credits for these obscure MIDI files to see who wrote them uh for example like passport designs they're still around they're like they design really kind of strange looking music software was kind of funny anyway.

So when we're talking about midi we're not talking about chiny sounding audio files which I think a lot of people assume when you just say the word midi we're talking about the protocols we're talking about the standard we're talking about you know a little bit deeper um so General midi is actually a different thing those are the chiny sounds so it's actually a derivative of midi it's it's different it was it came out in 1992 and basically all the electronic music uh instrument manufacturers agreed hey.

If something is going to have General midi support it should be able to create this set of 127 sounds and we're all going to agree on what those 127 different sounds should be and so the first one is like piano and the second is guitar and it goes down the list um and it gets weirder and weirder and everything that has General midi support has to have support for these same 127 different sounds and some of my favorites are guitar fret noise breath noise Seashore bird tweet telephone ring helicopter Applause.

And gunshot so if you buy a general midi capable piece of Hardware you're going to you're going to have gunshots and seash Shores on that thing stander's bodies are great um so midi the protocol uh it like I said it allows electronic musical instruments to communicate with one another it can describe common performance parameters like you know this note is on this note is off it can describe maybe more obscure things you hadn't thought about like I'm going to bend in this note I'm going to modulate.

This note which is some a signal that could be up to interpretation by the thing that's receiving that modulation command um it can also communicate other other more General things that are not specific to the the like the the notes being created on the instrument it can say like oh hey we're at this point in the song right now let's all get on the same page uh so midi the standard like I said before it was created by a bunch of musical instrument companies and in.

The early 80s uh it was those guys up there Roland y corg Kawai obri and sequential circuits uh I was going to put the logos up there but I could not find a logo for sequential circuit so I just did that um so these are the companies that agreed upon it but uh utaro Kakashi was kind of the leading force behind it and if you do a little bit of reading about this guy he's really he's really interesting he was sort of a Pioneer in.

All maners of electronic music he was a he was the founder of Roland and boss and aone he was one of the mins behind the tr808 and the 909 and he invented midi so he's he's a cool guy he's interesting he was worth having a picture of one of my slides there midi the file format like we said it describes midi events so those those uh the midi protocol we were talking about earlier when I'm describing you know hey this note is on or this note is off a midi file is just another format.

That contains that buried within it basically um it also describes most importantly it describes the timing surrounding those events uh My Demo earlier didn't demonstrate that very well but if we try it again later it might um it kind of reminds me of an old player piano do people know what I'm talking about when I say player piano show of hands okay interesting um so the way those worked since there weren't very many hands uh they they would have a roll of paper inside the piano.

And there were holes inside that piece of paper and as the roll moved along um there was a mechanism inside the piano would play the notes as it passed over those holes and the where the notes fall on the paper and how long they are would dictate uh you know when the note is played and for how long the notes are played this is actually a YouTube video um oops let me do this it's worth playing for a second just to demonstrate if you've never seen it before it's kind of interesting.

Uh it's actually not an inaccurate way of thinking about how a midi file works it also reminds me of Dance Dance Revolution the more I watch this anyway you get the idea I mean the real payoff is when they zoom out and you see the piano actually playing itself I wish it came a little earlier in the video but and then we zoom in on the paper for some reason okay whatever and there's even more to be disc you could go down a rabbit hole of midi standards.

And protocols and things there is a whole subset of midi designed to control light shows and theater Productions which is really interesting because that sort of delves into the area I want to talk about with doing things with midi that are not music precisely um there's General midi too which to be honest I don't really know much about I just know it exists and it probably is better than midi but whatever black midi is interesting it's like um it's it's not a standard it's like a music genre where people write MIDI files.

That are impossible to play in real life with literally millions of notes it's just just look it up it's pretty funny um and then MIDI midi like control and show control are related but technically different things anyway there's it never ends okay so back to the question I just explained what midi is midi is a lot of different things obviously so why midi is the more important question midi is asynchronous as I discussed before uh it talks to Hardware granted mostly musical Hardware but you like.

I said we can repurpose that Hardware to do other things and in a weird way it's sort of of a good way of dipping your toe into like The Internet of Things mode of thinking and dabbling you know we we can go out and purchase devices made in 1985 and hook them up to our computers get them talking to our browser and have a a new interface a new type of interface where you push a button and things happen and you know that's a simple interaction.

That I just described but that's that's interesting that's cool and I think it's really cool that we're taking like an old piece of technology and you know able to create new things from that oops that's doing the YouTube video uh it's really easy to repurpose um as we'll see in a minute the signal is pretty easy it's not very complicated um I have to show you this I wish I built this this is so cool this guy took a he he built a midi stepper.

And he's feeding a midi file into this thing that just creates voltage controls and he's hooked up physical um uh like switches and things I'm just going to play it you'll understand but basically a midi file is controlling this thing I'll just let it play for a couple seconds I'm realizing I'm talking kind of slowly so I'll hurry it up in a moment so he's using midi note messages to control the motors and things that you see in this video in a second I just got to notice.

That I can finally buy one of these I'm going I think that's so cool yeah okay oh I'll just do that okay Escape is not making it go away that's oh there we go I apologize okay and lastly Chrome speaks midi which is actually really strange but really awesome for my presentation so as of chrome 43 uh it has built-in native midi support which I don't really know why they did that my only thought is that it makes more sense for like Chrome OS if they wanted it to be like a full featured OS.

That can do a lot of different things um but yeah so you can your your Chrome browser will natively support midi and it's really interesting and there are a lot of other existing javascrip that support midi so you know there's just a lot of good stuff out there for it so let's talk about different types of midi controllers like I said you can you can go and buy uh like all these Medi controllers I have up here with USB support or you can go find.

All the hardware you know in your attic or at a pawn shop and with a u mid USB cable you could hook that up to your browser in theory and start doing things that way uh or you can build your own you can use an naruino and there existing midi libraries you can download to turn your into a full functioned uh like a legitimate midi device that would be recognized not only on your computer but on older pieces of like midi Hardware that that support.

That and and that's pretty interesting too um so just some examples some keyboards they lpd8 which I got up here the logy foot controller which I got down here um and then there's a lot of other weird ones there's like breath control there's accelerometer based controllers I you know I'm going to post my my slides later and you can click on those links but there are a lot of um very strange midi controllers out there bananas is my favorite Mickey Mickey you should look at Mickey Mickey.

If you're not familiar with it you can basically put little alligator clips on bananas and turn them into oops a piano if you want to uh let's see or you can build your own with an uino like I said I actually I had one I was going to bring it a week ago I dropped it and it broke I was really sad and the only evidence I had of it was this um it's really shitty video so I'm just G to play it for a second there it is that's me at home just.

I don't even know why I recorded this I was just trying to make this work and then I was going to do something much cooler all those lights were RGB LEDs and I had this great idea of making a big colorful thing and I don't know maybe next conference okay uh anatomy of a mini message okay every message I'm going to race through this okay every message is byes and there are only two types of messages there's a status message and a data message a status bite will always begin with a one.

And data bytes only always begin with zero that will leave seven bits left per bite for expressing the message which ends up being 128 different possibilities uh for a status message three of those bits describe the type of the status that could be like note on Note Off Pitch Bend modulation and like a 100 other things um and the remaining four describe what channel so there's only 16 channels that that message that status message could be applied to uh so for example this these if.

We break that down three bytes we have uh the status code is 128 which is the midi standard for turning a note on and it's telling it we want to turn the note on in channel one the second data bite is telling us we want to have a data value of 127 and the third bite tells us we want to have um a value of zero it's C you're not picking up any of this because to be honest you don't really need to know this to do cool stuff with it.

Um so I sort of translated it there to explain right you know there's the status it's a note on uh Channel One what I just said and then but when we deal with it in JavaScript there are libraries that just give us a nice little array like that and and a message accompanying it letting us know what kind of status it is so we don't really need to know all that other stuff um and then here's all the just a very short sampling of all.

The different types of commands that can be sent so there's note on and off uh poly pressure a bunch of different control changes there's there's lots of things some that I have no idea what they are to be honest uh anatomy of a mini file it's very similar in that it's um it has three chunks not three bytes just three chunks of information um one of them describes the the type the other describes the length and the other is the data um yeah I'm going to skip ahead a little bit because.

I have a whole bunch of cool demos I just want to show you to be honest and you can read that other stuff later so before we get too far into the more than music aspect of the stock I want to show you the some of the more musical aspects so here is a very simple polyphonic synthesizer that I built in Chrome kind of cool um what else under the hood it uses these different uh projects that are out there um if you interested in knowing more about them come talk to me.

Um uh the gist of it is that web midi uh although the the browser has native midi support web midi sort of packages that up in a way that's a little bit nicer to use particularly remaking musical applications midi utils does some nice features where it'll take a midi note and translate that into a frequency that you can then feed to a um a web audio component they can interpret that into a sine wave and actually make noise and picado is just a nice uh library for interfacing with web audio in doing.

That and basically I have this this for all my slides like what's under the hood that's pretty much the three I use for most of them as you'll see uh we have fun with control changes so it doesn't just have to be like sine waves and chintzy noises we can we can mess around with like samples basically which is kind of fun we can change the pitch we can even make them go backwards let's see how do I do that anyway you all kinds of fun trippy things with.

That um under the hood same thing interactive piano recital that was the first one we did that went really well uh oh actually that was using web RTC which I tried to use that I tried to build that using websockets at first and that was not very good the latency with web RTC was significantly better and didn't seem to work um pretty okay latency is a big issue actually if you're trying to make you know if you're trying to use this for like a live musical performance context it's pretty tricky.

But um and then let's see oh this is the one that did not work so well but I promise you I have had it work well before uh was a little more complicated I actually did use websockets for that just because it was a little bit easier and I could get it to work on tablets and phones and other devices and it was pretty cool when I had that working I actually had people like in the Park using it it was It was kind of cool.

I I brought I uh I brought one of these tiny computers and I can create a wireless network on that and then I can talk strangers into connecting to my wireless network and run this little pus of software and have weird sounds come out of them that's what I do for fun um okay so let's talk about the more than music with mini this is the more interesting stuff okay so I thought you know we have we have these really interesting uh interfac on a lot of these mini controllers.

And I thought a ways to repurpose that and so one of the things I built was a just a simple color mixer and I have this little output here that you know gives me my hex values my hsl values make a little program change and I can start mixing in uh some of the other colors like blue let's see maybe I want to add some red to this guy anyway I thought that was sort of an interesting application uh manipulating bleeding edge CSS features same idea basically.

Um only instead of just manipulating the color we're using some of those really fun CSS filters oh wait I have to turn on this program and do that okay now it'll work CP is not there we go yeah so we can like play with Hue rotate a little bit we can play with blur which is always kind of fun play with cpia any I thought this would be sort of a fun interface to you know you could build like your own little uh you know way to sort of fine-tune like tweaking your CSS.

And stuff it was kind of a fun experiment let's see oops forgot that it does the same thing on that oopsy D all right oh no no no no no there we go uh drawing simple images on the Launchpad so I've got I think I haven't even used up here yet um thank you uh so let's see I'm just going to draw a little picture here yeah that worked out okay um does this one do something else no this one doesn't do anything else I couldn't remember.

Um so this one actually I just Ed the native web midia implementation because we can if we use some like bit shifting we can actually get the XY coordinates in a way that makes more sense than we're treating like musical notes but that's not really worth going into in depth here um this is another color uh mixer but with a more interesting um mini controller that I found this one has a built-in accelerometer and so I can now like move my hand and kind of change.

The color which is fun maybe if I find something I like I can just click on it and save the value maybe I got to figure out how I'm going to get a red I think I have to raise my hand like that which is kind of strange that was kind of fun and I was playing around with that for a while and I thought well you know what that was that was actually kind of uh that was actually kind of fun I wonder if.

I could turn that like into a strange game and the game was not as much fun but now I so I made this thing where oh that was a bad one let me reload it it's still kind of a bad one well the objective is to try to match that color it looks a little gray so maybe I broke something at some point here anyway this is a good way to get carpel tunnel really quickly just trying to Contour your hand to get these different colors.

What else do we um what else do we have um oh this one yeah and this then after I made that game I thought what other games could I make with mini controllers this would be kind of funny and I was thought well I remember I remember I love wack-a-mole as a little kid and I thought you know there's eight little pads in this thing I could probably make a whack-a-mole game that would be pretty easy and oh oh wait I got to do the.

Right program there we go wait I missed darn it and what's kind of fun about this I told you you're not going to learn anything you can use here um one of the sort of interesting things I noticed in doing this is the the MIDI controller can sense velocity and so that confidence meter is uh it's trying to measure how hard I'm hitting it I I don't know how I got over 100% I didn't realize I could do that but um oops Yeah so you can.

You can add like more subtle layers to it that are kind of interesting um oh there's my little clicker turning and this one was kind of interesting so I was I was looking at this and I was like could I maybe I could make checkers or chest or something like that and and then I decided maybe I can make go it's a little bit small it's only 8 by8 and I'm I'm terrible at go so I don't really care but um I I thought it would be fun to turn.

The the Launchpad into go and so I did that um now you can't see it up here so I'm going to turn on a little thing here that hopefully you can see that works with and so now I'm going to play go with myself wait there we go yeah and so this was actually really satisfying when I got this working cuz this actually goes back to the tiny computers thing finally I realized so I found I'm not going to take I didn't build the Go game.

I found an existing JavaScript go um implementation which is really fantastic here let me make this go away for a moment uh called Tanuki JS and what's beautiful about that is like it can work on the client side or it can work on the server side and I haven't implemented it fully yet but I the plan is to get a serers side Tanuki Go game going on one of his little computers uh just like attach it to the back of a Launchpad now you have a really strange.

You know portable version of go that you can play on your Innovation Launchpad so that was kind of an interesting application of midi using midi to play go um what else here Alpha go AI not included oops and oh yeah the other thing that I did is this whole slide deck like I'm controlling it with this little guy which is actually sending midi signals to my my my slide deck and making things go forward or backwards or triggering videos and audio sometimes I've also got a foot controller down here.

That I've not used nearly as much but it's the same kind of idea I can just go back through my slides like this it's kind of fun actually I meant to use that more because that one's fun um you know and I so I used the reveal JS framework I'm sure a lot of you are familiar with that and have used that for things um it was pretty they great API so it was really easy to get the web Medi API to talk to that.

And how it do things um I'm using a special kind of uh esperino called the puck JS and uh it's a midi Bluetooth or it's a Bluetooth controller that you can convert into a midi Bluetooth controller um so I'm using that as my little clicker up here um I have a lot of slides that talked about my goals and how I approached it but I'm I'm sort of running out of time here so I'm going to kind of go through it pretty quickly um you know one of.

The challeng is I have like six midi devices plugged into here and like I had to figure out a way to differentiate between them and so I explain how the that method is not good because it looks like this and you have to do it like this and that doesn't tell me which controller that is so instead we're going to do that because I know that's the lpd8 now and I can do it this way and I'm just going to race through these I apologize controller that's.

So that first bullet point although I'm talking specifically about how I set up my slide deck uh that is like the thing that is true no matter what you're trying to do with M you have to learn the controller and its idiosyncrasies and how it chooses to map the different signals because I mean it's going to be very different you know I have another thing that looks a lot like the Novation um Launchpad up here uh but it behaves very differently and I spent a couple hours like figuring out like how it Maps notes.

And if I hit this button and this button all these bits shift this way so I have to account for that and and figure out things um right yeah I made a lot of slides about how I built this slide deck I thought I would get to this part sooner I apologize yeah so there's a you can't really see it from where you're sitting but that's what the foot controller looks like that's the other part I'm using that's a zoomed up version of the uh.

The puck that I'm using here's my Clicker and there's a pseudo code breakdown of how I the um the different floor buttons are breaking down to MIDI notes and then those are triggering parts of the reveal API oh there's also an expression pedal that's kind of an interesting thing I I have this set just so I can like refresh the page when I do that because you know it screws up every once in a while and I thought well I'll probably have to refresh it.

So I don't want to like type and actually forgot that was there because I was doing it over here oh well um yeah just breaking how it looks down the actual code uh the puck was much more interesting actually once we get to the ACT this is like the actual code I had to put on the esparo to get it to differentiate between a single click a double click and a triple click to trigger media and things like that um we have to also advertise to.

The computer that we are a midi Bluetooth capable thing and I just found this on the internet and copied it that's evidently how you do that I didn't know anything about that I won't pretend to um but that was an interesting that was interesting I thought this would be like the easy part of the project but that turned out to be the one I spent the most time on um oh yeah how I approached the trigger media thing okay so now I'm getting close to.

The end oh good I'm getting close to the end of my slides and I'm already close to the end of my talk here so this is a photo of an installation outside of the experience music project in Seattle Washington which is pretty close to where I'm from and it's an interactive musical kind of thing and I I love stuff like that but one of the things I really like about this is they've repurposed a bunch of um things that are not musical items to create music.

Um and I I'm just a sucker for stuff like that in general but it I wanted to end with that slide because I I love stuff like that because it always makes me think of how can we repurpose something um for things other than what they intended and that was the whole focus of my talk here was to be talking about how can we repurpose you know midi and this musical language that was invented 30 some years ago for things that are not necessarily music.

And and creative and interesting ways and there's a little video of this actually working there were a bunch of kids there that day and we got them to play like Twinkle Twinkle Little Star and it was kind of fun so anyway repurposing things for music why not repurpose music for other things uh spaceo there are any questions i' be happy to try to answer them thank you for your speech my question is how about uh OC media uh are there JavaScript libraries implementing this protocol yes there are.

I I flew over them really quickly and I can um you know actually so that website I I need to update a couple things on it but I'm going to have a list of all the things I used if you go to that website yeah sure thanks for the talk it was excellent but my question is why midi why did you choose it is it like a simplest way to interact with Hardware I mean there might be simpler ways it you don't have to you know.

I already had some I I'm a musician so I already had some midi stuff around and what's funny is I was I was playing around with my midi hardware and I was trying to do something musical with it and I was playing with this program and I found out I could write a JavaScript program to make it do an needed and then I realized oh well if I can I didn't know I could do that in JavaScript well I can make that button do anything.

Now and that kind of is what set me down that whole path of thinking um it seems like a very low barrier to entry uh way to interact with Hardware that's already out there you don't have to solder things on a breadboard you don't have to the protocol is not complicated it's just three numbers like if you ignore all the stuff I said about channels and bytes it's like it sends you three numbers and you decide what those numbers mean you know they don't have to be notes.

And uh do you know any alternatives for for Hardware interaction with browser I say one more time I'm sorry uh do you know any alternative ways to interact uh to make to make an interaction between the browser and the hardware like buttons triggers buttons and triggers um what do you mean by alternative exactly how do other people do that how do other people do uh with I mean other people without web midi without midi yes um what technologies do they use oh uh I oh.

Um I understand now um Mouse do you say mouse mouse and the keyboard and the no this is uh I mean like if we go back to the beginning of the talk when I talking about Arduino programming like that is sort of I think maybe more in the spirit of what you're talking about and um I mean there's just other languages you can use and things like that I see okay thank you yeah I hope I answer that okay oh hello thanks to for for your talk sure thanks for having me.

And um what is the simplest way to connect some device like uh midi fighter to browser did you say midi file or just midi device I mean the simplest way is like USB right no no uh fighter uh that uh can send to computer media nodes oh i s um there are there are a couple existing libraries that I found that do a good job wait uh um actually it it can be it it can be uh any device that can send media nodes to computer.

What the simplest way to connect it with a browser um can you give me an example Medi keyboard Medi keyboard okay I see um I mean the simplest way like I I found this online for like really cheap and you just it's just a USB cable you just plug it in and it it works I'm misunderstanding I'm sorry uh the simplest library or API to connect oh I I would say it's like the web mini uh API that's built into Chrome you don't have to download or install anything it's like your your Chrome browser.

Right now on your computer can do this without anything yes and M I mean I would say that's the easiest way.

</details>
