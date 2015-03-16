---
layout: post
title: "OHAI WatchKit - part 1"
created_at: 2014-11-23 00:09:53 +0100
comments: true
published: false
categories:
kind: article
---

So this week Apple finally - FINALLY - dropped the WatchKit bomb on us. Not entirely unexpected but still sooner than I had thought they would. But I guess it made sense to do this before Thanksgiving break. Work hard, play hard.

I was still at work (doing some kind of mini-hackathon) when I saw the news break on Twitter. And so one of the first things I did was go to developer.apple.com and download Xcode 6.2. I expected the download to be slow, but it was pretty fast all-in-all. I guess I got in pretty early, because I saw a lot of mentions on *eternal* downloads for Xcode 6.2. So I only had to wait like 15m before I could tinker with the new goodies.

And oh, the new goodies are new. First of all: this looks nothing like anything you're used to from UIKit. Oh, you can see where everything came from (UIKit), and how everything is based on existing technologies (UIKit), but still: it's very different. And very bare bones.

Now, I think they did a great job. I've been on the fence about the Watch since it's inception: I haven't worn a watch in over 15 or maybe even 20 years. When they announced the Watch in September, I was a bit underwhelmed. Sure, we've been spoiled by the spoils coming out of Apple. I just couldn't see myself wearing a big watch like that. But then I saw one in the wild (don't ask) and it didn't look so massive after all. And then WatchKit came out, and I played with it, and I'm sold. Depending on the technicalities, I think this will sell like hotcakes.

But that's not what I wanted to talk about.

<!-- more -->

I wanted to try out how developing for the Watch was like. So I tried a little app, getting familiar with the APIs, seeing what you could do. I went for a little app employing a map, which proved daunting enough (given my unfamiliarity with the changes CoreLocation APIs in iOS8). But it was fun. But after that, it was time for a bigger challenge: see if I could get a prototype of Bolero on the Watch.

For those who don't know (quite a sizable chunk of you, I guess): Bolero is a trading platform in Belgium. They only had a Flex based website until a few weeks ago, and I spent the last year leading a team of up to 7 iOS devs to build an iPhone and iPad app to bring their platform into The Mobile Age.

So it was obvious what I wanted to do: bring Bolero to the Watch. Why obvious, you ask? Well, because of the architecture of this first generation of WatchKit apps. You see, the apps don't actually run on the Watch itself. Basically, they're just like the extensions introduced in iOS8 (don't you love it when a plan comes together?): WatchKit apps run on your iPhone. The only difference is that their UI is not on that iPhone, but that it's on the Watch. That in itself is quite the feat, I think. It requires a pretty reliable connection between your iPhone and the watch, because nearly all processing is done on the iPhone. It's also pretty smart because writing apps is not that much harder than writing iPhone apps (you can use all/most-of-the tools and frameworks you're familiar with), but also it takes the burden of running apps off the watch with its limited battery capacity. I know that the future will bring real native WatchKit apps, but I'm guessing these will be in a whole different ballpark developmentwise. Constrained hardware means constrained software.

So apps run on your phone, and the UI runs on the watch.

{% img center http://cl.ly/image/2M0c1R1w0V2B/app_communication_2x.png 520 %}

This design shows in the APIs. WatchKit in its current form is no more than a light carbon copy of UIKit. But one of the key differences is that most of the classes you'll be using for interaction are write-only. You read that right: write-only. That means, amongst things:

* you can set the text of a label
* but you cannot read it

But also:

* you cannot create interface elements programatically
* but have to build and link them through IBOutlets using storyboards

And more:

* you can define IBActions
* but they can't have a sender (and when you do specify one, it's nil at invocation)

Finally:

* you can define an IBOutletCollection
* but it stays nil (yes, I did not specify it as `weak`)

So it's mostly a one-way communication device. You set properties, but can't read them. There's a limited set of reactions you can hook into. And: it's slow. Even when running in the Simulator (which is all we have now), WatchKit apps are **not** snappy. I'm pretty sure they're simulating the lag between the simulated watch display and the accompagnying iOS app, because I don't see an obvious reason for it to exist technically. But it gives a good sense on how interaction will be on the actual devices, so I'm happy they included this. The Simulator is a quite different beast performance and behevior wise as-is, but taking stuff like this into consideration is good. Certainly when there's no actual hardware available yet.

So, in short, WatchKit:

* is *just* a subset of UIKit, geared to the minimal UI of the watch
* mostly about one way communication (phone -> watch), with the occasional callback
* apps run on your phone, not on your watch
* is not snappy. For starters.
* provides the full capacity of the iOS framework for your WatchKit app
* allows you to use existing code from your iOS apps in your WatchKit apps

This last part is pretty important for me. It's pretty powerful. It allows you to get up to speed pretty quickly. If you coded your app well, it's really not that hard to adapt (part of your app) into a WatchKit app.

I did just that for Bolero. I took the iPhone app, cherry picked the pieces I needed and turned it into a small WatchKit app (with a very limited subset of functionality given the time constraints). I did all that in less than 8 hours. The fact that I was able to do that in so little time is remarkable, and IMHO was a very smart move of Apple to start Watch development this way. Devs get up to speed fairly quickly using familiar technologies. This means an abundance of Watch apps at launch next year. After that, there's time enough to spend on real native apps (should your app warrant one, because not all apps need this, I'm thinking).

But how I did create that WatchKit app, is another story. Stay tuned.
