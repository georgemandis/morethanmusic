---
title: "Web Weekend Kathmandu"
description: "The talk's last conference outing under its own name, retitled More Than Music with WebMIDI and JavaScript, with the deck rebuilt two days before and the video posted four years later."
slug: /talks/2019-web-weekend-kathmandu/
sidebar_label: "Web Weekend Kathmandu 2019"
sidebar_position: 20190921
---

{/* generated from talks/2019-web-weekend-kathmandu/talk.md by `node website/refresh.mjs talks`; edit the source, not this */}

# Web Weekend Kathmandu

The talk's last conference outing under its own name, retitled More Than Music with WebMIDI and JavaScript, with the deck rebuilt two days before and the video posted four years later.

| | |
|---|---|
| When | September 21 to 22, 2019 |
| Where | Web Weekend Kathmandu (wwktm), Kathmandu, Nepal |
| What | talk |
| Video | [youtube.com/watch?v=aYwuHTVZrqY](https://www.youtube.com/watch?v=aYwuHTVZrqY) |
| Event page | [2019.wwktm.co](https://2019.wwktm.co/) |

No slides for this one are published. A transcript is at the bottom of the page.

<iframe src="https://www.youtube-nocookie.com/embed/aYwuHTVZrqY" title="Web Weekend Kathmandu, Web Weekend Kathmandu (wwktm)" style={{width: '100%', aspectRatio: '16 / 9', border: 0}} allow="encrypted-media; picture-in-picture" allowFullScreen />

## What happened

A year and a bit after SPA the deck woke up again: "wwktm updates" and "adding all media" on
2019-09-21, "changes for wwktm presentation" on 2019-09-23. The title slide from that version, still
visible in the deck's git diff, read "Web Weekend Kathmandu 2019" with "@wwktm • #wwktm2019" under
it. By now the "tiny computers" had slipped out of the title. The video is called "More Than Music
with WebMIDI & JavaScript" and its description is the short abstract from the notes folder: "Did you
know there's a widely-supported browser API that allows you to interface with a wide variety of
hardware, including some you can build yourself?"

Web Weekend posted the recording on 2023-03-28, three and a half years after the conference. It
runs 31 minutes.

This was a busy fortnight. The talks page has HalfStack Vienna on the 19th and 20th, Kathmandu on
the 21st and 22nd, Heapcon in Belgrade on the 26th and 27th, ChangeCon in Zagreb on the 28th. The
Belgrade and Zagreb recordings are JavaScript for Artists, not this talk.

## Sources

- https://george.mand.is/talks/ : Web Weekend Kathmandu, September 21 to 22, 2019, Kathmandu
- Talk folder: `slidedeck/` git log 2019-09-21, 2019-09-23; `git diff slidedeck/index.html` (the title slide before the Recurse Center edit); `notes/Tiny Computers JavaScript and MIDI - George Mandis.md` ("Succinct version")
- YouTube aYwuHTVZrqY, uploaded 2023-03-28 by Web Weekend, 1877 seconds

## Transcript

YouTube's automatic captions, deduplicated and broken into paragraphs by `talks/vtt2md.py`. Not
corrected, so names and the technical words come out wrong now and then.

<details>
<summary>Read the transcript</summary>

I think we should have another round of uh Round of Applause for the organizers of what we can cat men do because they I know they've worked incredibly hard to make this happen and they've done a wonderful job and they've been really lovely and I'm I'm super flattered and happy to be here um uh I'm excited to be presenting last just a little bit of pressure I realize uh the very last slide in Archer's uh presentation I think it says something like have fun coding or coding should be fun or something like.

That I feel like that was a very good introduction for what I'm going to talk about today actually all of the talks today were very good and very brilliant and lots of things that you can probably take back to your profession or work or help develop your skills and in some professional context I promise you none of that with my talk come talk to me because I want to know where you work um my talk today is going to largely be about having a lot of fun coding.

And learning a little bit about uh web music protocols and building interesting things with them it'll make more sense as I go along I think so without further Ado um let's get started so first I would like to I'd like to introduce myself uh that is my that is actually me that's been a point of discussion among the organizers and the other speakers um it's a good argument for getting your headshot updated once more more than once every three years or so uh anyway my name is George.

Um I always like to share a couple random facts about myself I find when I go see other uh people present at conferences it helps me remember something about their talk later if they personalize themselves up front of the humanize themselves a little bit so I'm going to show you just some random things that maybe they'll stick with you maybe they won't I don't know so I've been freelancing I've been independent developer for over 13 years I think in JavaScript years that makes me about 72 or something like.

That which means I can retire which is great um I oh you can't really read that because of the way the screen is doing things I once spent a year living as a digital Nomad all around the world continuously in 18 different countries I love talking about that because it was so much fun that was a anyway that's a random fact that it's fun to throw out it's always interesting um and based out of Portland Oregon I don't know that's actually a fun or interesting fact.

But I'm from the US I'm from Portland Oregon that's almost as far as you could probably fly in the U.S to get to Nepal I'm pretty sure um one of my funny personal claims to fame that I should put on LinkedIn is I accidentally broke marvel.com for about 30 seconds uh due to an errant git push they that was me uh it was um they were linking directly to the raw code in my what's probably my only and best known open source project something called Konami JS has anyone heard of.

That I'm curious every couple hints okay yeah so sometimes I get them more and it always surprises the heck out of me um just for some clarification what that project does is it allows it enables the Konami Code to work on your website so you can then have it reveal Easter eggs and do silly things like that um anyway Marvel was using it I got really excited when I found this out I tried to make a quick Improvement I broke their site I I reverted it really quickly.

I don't think anyone ever noticed um it's also sort of on-brand for me I realize my famous my most well-known open source project is frivolous and kind of pointless but just fun um and then the last thing well Chris already introduced this and sort of shared this with you but I once cheated while I was running a marathon um in North Korea I uh in my defense it was an accident I wasn't trying to cheat um for a little bit of context on the the way.

The course was set up is you do four loops around the city and I did the first two I did okay I was doing all right and then I can't afford myself and I had to stop and I just ended up walking the third one and I was okay with that long story short I I thought I assumed they would know that I hadn't finished the race then two days later they they gave me uh there's proof by the way there's me in North Korea.

You don't have to look far to find a flag um there's my certificate of completion so for what that's worth um I promise there's code eventually in this talk oh and then the last thing I want to share before diving into the subject properly uh getting back to my photo looks nothing like me the organizers made these lovely gifts for us where we had these coffee mugs with our faces drawn on them but they only had the photos we'd given them to base the drawings on.

And so mine in particular does not bear I love it I'm going to keep it forever anyhow um but more relevantly I as you may have picked up by now I like to make things I really enjoyed creative coding I like making arts I like to um use my tools my programming tools and sort of unexpected many unintended ways um in this talk I'm going to show you how I've made things using midi a music protocol I'll dive into a little bit JavaScript and Tiny computers are not.

So tiny computers it's a component of the stock that we'll touch on but um yeah I'm just going to show you some fun things I've made with this and why I think this is actually a valuable exercise at the end so what we're talking about today we're talking about midi uh it's a protocol it's an acronym it stands for musical instrument device interface uh tiny computers when I do bring that up later I'm going to be talking about things like arduinos esperinos Raspberry Pi's hey raise your hand I'm curious who's sort of.

The esperino anyone look who's sort of Arduino yeah okay that one's like globally just popular um I'm hoping I'm hoping I can turn something on to the Esperanto it's the difference with Esperanto is you can there's a JavaScript interpreter on board on the device I'm actually holding one here in my hand I've actually reprogrammed this to be my clicker in a fancy way which I'll elaborate on here in a little bit and then the third thing we're talking about obviously is Javascript sort of the lingua Franca of.

The web for better or worse it seems here to stay and it you can find it literally and everything from Hardware to the browser to the server Etc oops okay so what actually makes this combination of things interesting um this combination of Technologies is I found actually a very low barrier to entry uh way to start dabbling with basic iot concepts and Hardware programming if you've ever had an interest in that I saw a lot of hands go up when I asked if you heard.

The Arduino one of the things that can be a little daunting about that is to get it to do anything cool you got to start wiring it up and and creating elaborate circuits and then you have to know about electronics and that's fascinating and very cool but that's a lot of you know extra stuff you have to learn which can be a little intimidating sometimes with with this technology stack there's a little bit less of that um with so with midi we can talk to Real World Musical Hardware as I'll be demonstrating.

And with JavaScript and the web and the browser we can build virtual interfaces when we combine the two we can build an interface that kind of straddles Both Worlds we can have something in the physical real world that we're interacting with or or speaking through in some capacity and we'll have responses in the virtual world and that gives a lot of um there's a lot of creative potential in in that combination I find um and it's yeah it's just a good tool set for for.

That that kind of creative Explorer exploration that kind of coding so so why JavaScript I feel like I should just keep posting that in bigger and bigger letters why JavaScript um honestly for basically javascript's everywhere like I said it's in the browser it's on the server it's on it's embedded Hardware now it's probably in places I'm not even thinking of um it's you know like for better for worse it's everywhere so that's a good language to learn and explore and teach these kind of it may not be.

The most efficient language depending what you're trying to do I'm doing a different talk right now about machine learning and creative uses for that and you can do it and it's very interesting but it's not necessarily the most efficient um uh Community traction there are so many meetups and conferences and things out there open source projects if a new if a new startup has an API that they want you know the rest of the world to start using they're probably going to have a JavaScript SDK to go with.

That or some sort of interface you can you can talk to now is like a very good time to be a JavaScript developer um it's a seeing crowness nature is actually a very natural fit with the way the midi protocol wants to behave midi doesn't really care when things happen it's just it's very event driven and through some sort of happy accident even though midi was invented in the early mid 80s before JavaScript was a twinkle and Brendan whatever his name is I um uh it just feels very natural.

And at home when you start writing uh JavaScript software that talks to MIDI and then why tidy computers to be perfectly honest it's just because I really love them but I think there's also a good argument for it um so we're talking about like I said arduinos esparinos even raspberry pies just small compact computers which are really ideal for making Standalone creative projects um here's some of these I have at home that white circle there in the middle is actually the uh the one that I'm holding up here in my hand.

The esperuno it's actually called the puck and then the one to the left is a different esperino and anyway just sort of showing you what I'm talking about when I talk about tiny computers and then I have the logos on these slides for reasons I don't honestly entirely remember but just out of fridge is a great place to look if you want to see um they have lots of really great like example projects for those kind of things too and then esperino um so the fun part about.

This particular spirit I said I programmed it and turned it into a clicker I didn't just turn into a clicker I turned this into a midi instrument it's a midi Bluetooth instrument my computer right now thinks this is some kind of musical instrument and it doesn't really know what or what it can do it doesn't really care but every time I click this it sends a musical note it sends a c the C note to my computer my slideshow is a JavaScript program that is using.

The web midi API to listen for Midi signals from an instrument it's hearing that particular note from this instrument and then it's progressing the slides like this so I can click it once and the C will take me forward if I click it twice I get a d it takes me back this is also a good way to wear out the button and if I hit it three times if I'm feeling kind of nervous um did that work there we go I always bring my own Applause Just in case just in case.

But now I got a little off track um oh I'm not sure why oops another fun thing I did today because this was acting up is I reprogrammed my little musical keyboard to also progress my slides forward so I'm going to go back a few slides now here so bear with me that's where we left off I think right okay we can go forward now okay tiny computers they're affordable and generally easy to use there I didn't realize how funny that was going to be they're powerful enough to perform a variety of tasks.

Uh and like I said they're great for Standalone projects and creative tinkering of all kinds I think I'm gonna have to alternate between those because that's gonna get too funny um some of them can run JavaScript natively there's a great project called um Johnny five I think it's called yeah Johnny Five Js which uh um I don't actually have a slide for that but if you if you want to know more about JavaScript on Hardware I really suggest looking into that project and you can also interface with midi devices in a variety of ways.

So why midi um so let's talk about what midi is so like I said it's an acronym it stands for musical instrument device interface um but there's a lot of confusion surrounding this I was actually having a discussion with someone here about this and there's a lot of common confusion about what midi is exactly because that acronym is used to describe a whole lot of things that technically use midi but by themselves they are not midi if that makes any sense um so it's what we're mostly talking about.

What it is that its core is a protocol it is a way for musical instruments like this keyboard up here um keyboard up here to um communicate with computers and other midi uh capable Hardware basically it's a protocol so they can communicate made all kinds of sense in 1983 or so when it was invented but it's also sometimes used to describe the standards so the protocol is actually just the transmission of these numbers and messages the standard is what dictates when I push this button.

And it sends the number 60 or whatever that is going to be a c does that make sense a little bit it's also sometimes interchangeably used to describe the midi file format which I find is more common when I say oh do I talk about midi people are like oh I love uh you know the chintzy Windows 95 music or whatever that came with my computer um so I just want to clarify it's not this foreign file and there's midi involved but that that if.

I can't exactly point to that and call that MIDI it's not this I think all of these came with Windows 95 I'm dating myself or even this what's funny about this one is I found Brian Orr was a he was an intern at Microsoft and his job was to write this song for Windows 95 and it got shipped on your computer as a midi file which you could play and then change all the instruments computers are weird so midi the protocol uh like I said allows electronic musical instruments to communicate with other midi capable Hardware.

This is done by sending and receiving three byte midi messages the midi standard like I said it gives our midi messages meaning um it lets us know not just like which node is being played but is that note being uh turned on is it being turned off and a whole host of others a music specific parameters that can be specified a good parallel I think of is HTTP goes like who knows who's familiar with HTTP goes like the ones I have up here like 404.

But it's not found everybody's seen that one 301 move permanently my favorite uh 418 I'm a teapot that's real look it up it's real uh I think that's actually good parallels like those numbers by themselves don't mean anything but because of the standard we know what the 404 means the page is missing because of the midi standard we know that these midi numbers these messages mean certain things in the musical context that's all that means um and I also I have this bullet point up here.

Uh just to point out there's a lot of strange parallels between the midi world and like software in general there's like an or an association that maintains the standard and they ratify things and there's been amendments and like Forks of the original midi protocol and all kinds of interesting things uh and so the file format when we're talking about midi describes a sequence of midi events basically um it describes the not just the notes themselves and whether they're on or off but the timing surrounding those.

This is incredibly Antiquated uh reference but I always think of a player piano in those sheets of paper it's kind of like that the the punches the holes and the sheets of paper sort of dictate the notes and how long they're playing the timing surrounding them I feel like this is a more modern GIF I could throw in there it sort of feels like Guitar Hero to me too I don't know that guy's rocking um okay so when we look at these midi messages through.

The computer though they look kind of like this we get um a three byte message here's what they look like in binary uh every message like I said consists of three bytes and the standard dictates there are only two different types of bytes there's a status byte which tells us what is going on and then two different data bytes which we can use to describe parameters related to what's going on um a status message always Begins the one data bytes always will be under the zero which means.

We only have seven digits left to start expressing things um and then for status message you actually even have fewer because the first three bytes um describe the status of the message and then we just have the remaining four but let me show you that's hard to follow I realize I'm getting through it really quickly and here's a table that sort of dictates that so if you want to um yeah that just sort of explains like what all the different bytes would be for these different commands.

So if that's my binary example basically by the time I get into my browser and by the time I'm playing with midi messages in JavaScript using the web midi API I'm basically getting an array of three numbers and that's kind of all you need to know if I press a button on this device I'm going to three numbers they mean things but if you're not necessarily making music you don't necessarily need to know what those numbers mean you can kind of just figure it out for yourself.

I have I've bought strange midi devices in Alibaba not with the game with no instructions and I basically sat there and just pushed buttons trying to figure out how they work looking at the numbers that we'll go through and then in a cleaner sort of Json formatted thing that might look like this okay so back to the question it's uh just summarize it's an asynchronous protocol the less Musical electronic musical instruments communicate with computers and other midi capable devices uh it lets us have a two-way conversation with Hardware in.

The real world you know I can press the notes on this keyboard um and obviously you know when I hit those notes it's sending information back to the browser and it's interpreting that it's playing sound it's moving my slideshow forward um I think it's playing Applause if I do this one remembers of this one um it lets us have a two-way conversation this one is only sending but some of the other devices I have up here can receive midi messages and that's where it gets kind of fun.

And interesting so I I've sort of buried the lead on this so the coolest part about this is we can use JavaScript to talk to MIDI capable devices because our browsers support midi for reasons I don't fully understand but it's cool uh any chromium-based browser is going to support web midi uh so chromium uh Chrome electron the latest Microsoft Edge um uh not quite Firefox yet but it's been coming soon for a long time there's actually something like 79 no 73 Global coverage not the.

I don't think this would ever matter it's such a niche application I don't know why you would ever entirely care about global coverage for this particular feature but just so you know 73 percent and some midi controllers basically instruments come in a lot of different uh flavors there's a lot of variety in MIDI hardware and some of the fun is like you know a traditional piano keyboard uh just has a bunch of buttons but some of them have more interesting interfaces that might be fun to play with as developers.

And then last but not least you can even build your own getting back to small computers you can program your Arduino to be recognized as a midi device and then just go to town and build your own custom buttons and controllers and just go absolutely nuts I've seen some really cool things that people have made and so there's some here's the keyboard I have up here on my page who's a old synthesizer that technically if I had a an old school midi to USB adapter.

I could plug this into my computer and it would still work with my demos I could I could make my slideshow work with that thing believe it or not um I have one of these up here too it's more of a DJ pad thing and that's kind of a cool interface because now we have knobs and now we have buttons and like they're pressure sensitive so we actually have some of the messages being returned let me know how hard I'm actually hitting the buttons so it's an extra layer of.

Um interactivity we can start playing with and then this is sort of a heavy duty foot switch I didn't bring it with me because it's hard to get through the airport but it's something you can put on the ground and like step on which is kind of a fun interface and that's a much bigger version of that um you can get something like this which is sort of like you know putting the gas pedal in your car or something like that um it's basically a volume control.

That you can play with your foot but that's another interesting uh physical interface this one is actually breath controlled I've never used one but I've seen people play them um yeah I would love to play with one of those those are very interesting uh this one is actually motion controlled it has a gyroscope and the X Y and Z parameters mapped to many messages and actually brought that with me and I'm going to show you that in a little bit uh or you can build your own like.

This guys anyone recognize him I'm curious all right he's a musician but I'm like kind of dating myself in a really weird way with that guy so I I'll leave that and here's another homemade one that someone made this is actually a really cool little instrument from an Arduino I think and that's one I made I actually think I brought that with me I forgot about that that's I can explain that one another time and uh let's see oh yeah there's might be my banana piano.

That I made one time there it is so I I took a a different kind of microcontroller I turned it into a midi instrument then I wrote a web page that I connected it to the capacitive sensors and then I had a little banana piano and what actually ended up building was um my idea was to make like flash cards for learning a language and so I plugged like different kinds of fruits into them and then I used the speech API in Chrome to have it tell me.

What I was touching in different languages which is kind of a fun demo I kind of wanted to do that one today but I I could only bring so much with me uh so what does what does it actually look like when we use this so who's ever used like the geolocation API or the notification API in the browser or something like that it's basically like that it is if you click in the little um if you're using Chrome and you click on the little.

I next to the website you'll get the list of all the things that that page is permission to access you will see midi access is one of those down there um so it looks like this it's very similar you basically request access to the midi device you get back an object letting us know whether or not the user has allowed it if they have then now you can start listening for events on that device and that they haven't then well you can't I guess very straightforward.

Um once you have access to the midi objects the the mini access object then you can iterate through all of the instruments that are plugged in just to sort of demonstrate that here I have this thing that I made this is called the I call it my controller Explorer so it goes through all the midi instruments that are connected to my device right now I've got those four and it lets me know what the different numbers are what the different messages are as I play them.

If I do over this one I'm spinning a knob right now so you can see the numbers change very quickly on this device over here um yeah and then so we have to set up an event listener to handle when a message comes in through that midi device and when we do we get a data array that has those three bytes I mentioned earlier and that's basically it and then we can just start playing with it so let me run through some demos of things I've made.

That are not precisely music things using midi um that I think that I'll sort of touch on the why I think this is a fun combination of Technologies why it's a cool way to explore building creative and interesting things and let me plug this in let me turn this on I'm gonna start with the motion controlled one just because that's interesting and kind of fun so oh here it is okay so if I hold my hand perfectly still so right now I can't remember which coordinate I'm after which thing.

But it's changing the RGB values for the background down there and if I tilt my hand in different directions I have sort of a weird very inefficient way of selecting colors for my web pages if I see something I like I think I set it up so I can go like this yep and it'll record uh what the RGB value is if I put my hand down on my side that's kind of a weird pink salmon color if I put it straight out I guess.

I get I haven't seen a good green yet oh there we go maybe I got to go like this I find that uh actually doing a little with hsl is a little more interesting because when I hold it perfectly flat it's white which is kind of cool and I start to raise it and then we get sort of a red color I guess all right and then if I go straight down you should also get the same red color and then if I twist my hand slightly.

And do it like this anyway you get the idea it's kind of fun I had a lot of fun making that and my next idea oops that was not the one I meant um I thought well what could I what could I do with that sort of a creative interesting way so I tried to make a game where I would randomly pick a color and then I would have to contort myself to try to match that color as well as I oh got it there.

We go got one see if I can get that blue oh we're getting close it gets bigger when I get closer there we go and then I found actually the really easy way to cheat with this game it's just gonna go like this and eventually oh there we go oh normally I get a one when that happens anyway just kind of go like this eventually it'll get them it's kind of fun yeah um Let me let me show you a couple other demos here how am.

I in time I think I'm probably running over can I do I have another five ten I'm good okay good thank you um let me show you oh here's a very good this is I've not shown you this tool yet so I've got this thing up here um this is a it's called a launch pad it's sort of a DJ equipment um and I was playing with it and figuring out to send messages and I made a very just simple drawing application here you can see in a minute let's see not a real High Fidelity dropping drawing application it's like an 8x8 pixel art sort of a thing.

So it's kind of fun and then I was playing with that and I thought what could I what could I do to make that more interesting and so then I made this interactive maze which is kind of hard to explain but I so I have a little little guy that starts in the corner there a little person a little blue pixel um and with the keyboard on my computer here I can move it around the screen like this that's pretty straightforward and then I thought it'd be kind of fun to create sort of a two-person interactive experience where one person's on.

The computer or whatever you know moving around like I'm doing here but then the other person could maybe physically draw like a maze let's see here and now when I try to move I can't move through the walls and so I actually have like an interactive maze that I have to Traverse with this thing which is kind of a fun game and I think the next step with this would be to like build a custom board there's way more things that could actually be more fun.

And see if I can do one or I'll do two more real quick um just because I haven't used that instrument yet so this was also I this this particular device has um knobs on it or sort of like dial controls oh maybe I deleted the webcam oh well you can sort of see it's not that big of a room uh it has dials and things like control and so I set this up to control all the different uh CSS filter parameters uh just because.

I thought it was a fun and more natural kind of intuitive way to like fine-tune a particular blend of things that I was trying to explore and so let's see I have to put it on program four I think there we go and so now with this style I can play with the sepia property this one I can play with the opacity which you know isn't quite as interesting just the brightness you know in case you're tired of like actually typing in these numbers and want to find a very elaborate way to set your different.

Uh CSS properties here rotate is always my favorite because it's kind of trippy and then the very last one I will show you we're going to go back to the uh the launch pad for now and this one I think is probably my favorites let's see there it is whose heart of the game go it's it's a pretty old game uh I thought I was trying to figure out games I could play on here I'm still working on chess and checkers but I found a version of JavaScript go.

That I was able to tweak and hook midi into to send and receive signals from here so I can now play Go On we'll do it like this yeah it can be like that so I can use my mouse and actually play go here on the screen I'm a terrible go player by the way and that's kind of fun do this to make sure it works boom there we go playing go but I can actually physically play it here on the board I don't need to look at.

The screen at all and as I hit the different Keys here and there we go so we have go on go on the go I guess and I have many more demos if you're interested in talking about this kind of stuff because there's always one or two people who have a lot of questions I'm more than happy to talk to you after about that um yeah and uh thank you very much for having me um I guess the last thing I wanted to say that.

I think this kind of creative exploration and playing with our code and our tools really makes us better developers in the long run so I encourage you to go out and just do something fun and explore and use your tools in ways that maybe they were not meant to so thank you.

</details>
