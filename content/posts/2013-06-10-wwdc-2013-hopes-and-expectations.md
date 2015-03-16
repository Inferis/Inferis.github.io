---
layout: post
title: "WWDC 2013 Hopes and Expectations"
created_at: 2013-06-10 14:20
comments: true
categories:
- wwdc
- apple
- mac
- ios
- xcode
kind: article
---

No real predictions post. You never know with Apple what they're going to produce at a developer event, so I won't go there.
What I will do is list what I'd like to see. Mostly iOS stuff, because that's what I do.

<!-- more -->

## XPC

I think there's a real need to have some interapp communication. In its present state, all iOS apps live on their own island and there is virtually no way to talk from one app to another. Sure, there are [UTIs](http://developer.apple.com/library/ios/#documentation/Miscellaneous/Reference/UTIRef/Introduction/Introduction.html) but that's only a half baked way of communication. You can open something you created in another app (eg send an image to instagram) but once you're out of your app there's no real way for the user to go back and continue from where she left off except for manually switching to the app.
There's also [x-callback-url](http://x-callback-url.com/). This works for relative simple data and requires a lot of work for the developer: you have to manually support each other app that supports _x-callback-url_. Less than ideal in my opinion and there's not a lot of apps doing it.

So, a way to do proper cross process communication. iOS supports this for a number of native things. You can send an email from within your app, which uses the builtin Mail app. There's also the tweet and Facebook popups you can use from within an app. It would be great if there was a way to have a way to open up an Instagram screen within your app, have it handle the posting to Instagram and than closing again so that the user was right were she left off. While basic, this would open up a whole new set of interactions between apps.

## App store

First of all: they need to make the App store app an actual native app instead of a glorified webview which acts up even on my iPhone5 or iPad3.

That said: I'd love if they would introduce trial versions for apps. The other platforms (Google Play, Windows Phone) have some system or another to do this, but iOS hasn't. Same for the Mac app store, by the way. I think it would have a positive effect on App store pricing. You see a lot of apps now that are free but with in-app purchasing so that you have to pay to unlock more functionality. I have to admin I've been toying with this myself, but I don't like it. It's a sneaky way to ask for money. Having a sort of trial mechanism would surely reduce the number of actual sales but I'm sure it'll work out better in the long run. Besides: it will free up my "purchased" folder from all the apps I've tried for a few minutes but are there forever. Don't like a trial? Just remove the app and it's like you never bought it.

Also: promo codes for in-app purchases, please.

## More Mac/iOS convergenance, developer wise

I'm guessing they would want to bring some of the UIKit goodness back to the Mac. Of course a lot of iOS concepts don't translate directly or even at all back to the Mac, but I think that AppKit could use a revival. I'd love to make "suites" of applications that work on all Apple platforms (iPhone, iPad and Mac), but right now it's a bit of a pain in the butt. Sure, the language is the same so you get all the ObjC goodness, but the frameworks and APIs are too different even for stuff you'd expect it to be the same (the coordinate space flipping on Mac vs iOS is on example). Changing everything at once is maybe a bit too much too ask (on the other hand, they did produce the iOS SDK out of thin air) but it would be very interesting to be able to port my iOS skills and knowledge to Mac. Not to mention that it would be a lot easier

## A Better Xcode

Xcode is pretty good, but it could be a lot better. Comparing to other IDEs I've used the debugger support is pretty basic (it works, but that's about it). Also, I think the iOS Simulator could use some love: if you have one of these neat multitouch trackpad, why aren't you able to use it to simulate multitouch gestures, for example? Or even over the air deployment: this was present in older versions of Xcode 4 but has dissappeared more recently. If you're developing an app and want to tests on multiple devices, this would really shine. Also, when doing AR development, the length of the USB cable is really limiting, so it would have in several scenarios, I think.
I think it's about time for Xcode 5, too.

## iCloud+CoreData

I hope they fix iCloud+CoreData, I expect them not to. Hard stuff.

## New developer machines

I think there will be an update to the developer machines. Updated retina Macbook Pros. Unlikely, but perhaps a retina Macbook Air. And a new "Mac Pro" (but they're not going to call it Mac Pro, I think).

## Something new

I'm guessing they've got something new. Not entirely sure what it is, perhaps it's the iWatch or something wearable? Could be an iTV? Maybe they have an actual non-gross version of Google Glass. But I think it's about time do it now. The iPhone is 6 years old, the iPad 3. You could argue there's a bit of a pattern there, I guess. Also: there's not a single credible rumour around for new devices or stuff. My gut feeling says there's something completely new.

Which sucks, because it means another possible switch to make as a developer. Oh well.
