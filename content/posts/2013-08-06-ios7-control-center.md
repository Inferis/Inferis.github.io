---
layout: post
title: "iOS7 control center"
created_at: 2013-08-06 15:26
comments: true
categories:
- ios7
- camera
- gestures
kind: article
---

Last weekend, I went on a short trip to the south of France with my kids, on a visit. I was planning to take the D90 with me to snap some pictures of us having fun, but I managed to forget the bag with the camera at home. While that sucked, I had my iPhone with me, so the backup plan was to use the camera of the phone. That camera is pretty good, but it's no DSLR either. But that was not the point I was going trying to make.

No, it's the interaction between the camera button on the lock screen and the new notification center in iOS7. The camera button has been there since iOS5 I think, and I've used it quite a lot (I even lock the phone and access the camera through the lock screen instead of using the camera app icon in the app grid). It's a great way to quickly access the camera, and it works fine.

<!-- more -->

In iOS7, there's the new Control Center, which you access at the bottom by swiping up from the edge. This is great, as it allows you quick access to some settings, access which wasn't there before. I've used it extensively to use the also-new flashlight functionality. The fact that you can access it so quickly is really useful. The Control Center is also accessibly on the lock screen, which makes it so great to use. No need to unlock, go to an app and change something: no, just swipe up, toggle the wanted setting and you're done.

{% img center http://f.cl.ly/items/0X072Y0p0D0N3m1y4127/Screenshot%202013.08.06%2015.46.55.png 'Lock screen' %}

But it interferes with the get-me-the-camera gesture that's been there since a few releases. I found this out the hard way while in France this weekend, and using the phone as a glorified camera. Which meant that I had to corner-swipe the camera icon up quite a bit, and that didn't always pan out as expected: I think I got the Control Center 1 times out of each 2 times I tried to get the camera. Result: missed photo opportunities. While not a big deal, if you're touting your flagship smartphone as a great picture taking device this shouldn't be happening. I haven't had much problem with every day use, but I don't take a lot of photos in that case. When using the phone as a camera as I did this weekend, it bothered me a lot more than expected.

So while I don't know how Apple handles the gestures, I think it would be a good idea to shorten the Control Center gesture area a bit so that it does not overlap with the Camera gesture. Swiping up in the bottom right corner gives you the camera, swiping up everywhere else gives you the Control Center. Right now, you need to start swiping *on* the camera icon. Swiping from the edge gives the Control Center. But like I said, if you swipe up (even from the edge) in the neighbourhood of the lock screen camera icon, I think it's safe to assume the user wants the camera and not the Control Center.

{% img center http://f.cl.ly/items/223j3P1l0S2D2s2u1j2R/Image%202013.08.06%2015%3A57%3A43.png 'Gesture areas' %}

There's another problem with the camera gesture anyway: since it's powered by the new dynamics system, your swipe gesture sometimes isn't "strong" enough to "throw" the lockscreen up. And so you have to try again. I've had that a few times last weekend, but far less than the Control Center swipe issue.

No big issues, and easily fixable I think. I filed bugs for both. Let's see what they're going to do with it.
