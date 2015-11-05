---
title: "Wanted: new maintainer for ViewDeck"
created_at: 2015-09-14 17:07:24 +0200
kind: article
categories:
- open source
- development
---

I'm pretty sure that if you found this blog, you also know about a little piece of software I wrote a few years ago: [ViewDeck](https://github.com/ViewDeck/ViewDeck). The [initial commit](https://github.com/ViewDeck/ViewDeck/commit/463324184a67a7fa24c9207352298e69da0d66b7) was on December 3rd, 2011. I'd been doing nearly a year of iOS development at that moment, and both the Facebook and Path apps came with this nifty new feature we now call "a hamburger menu". 

{% img right http://cl.ly/063X412a1i2U2e3f3D02/Image%202012.01.26%2023:26:55.png 240 %} I remember finding it an interesting piece of user interaction and wondered how it was implemented, and so set out one night to try to recreate something like it myself. At that point, not an awful lot of libraries existed that recreated that UX, so I had no way to base my code on somebody elses creations. By the end of the night I had a mostly working prototype, and decided to continue working on it, and to share it with the world. After all it might come in handy for someone else and it was a fun way of showing of what I did (**YEAH BABY**).

<!-- more -->

ViewDeck grew, more features were added, people started creating pull requests with some pretty cool stuff. It got to a point the library started to become a bit bloated with all the features it had gained (AFAIK, [MMDrawerController](https://github.com/mutualmobile/MMDrawerController) was created as a sort of reaction against that, but I might be wrong). It required quite a bit of support to be honest, support for which I didn't always have the time.

And then, a refactoring to fix a number of problems introduced more problems that it fixed, it seemed. Version 2.3 was "the bridge too far". Fixing this would prove to be a very timeconsuming problem due to the myriad of UI configurations possible. So I kind of abandoned development, not even bothering to retract 2.3 from CocoaPods but just left a notice that 2.2.11 should be used. A bit shameful, I admit. The fact that iOS7 had just arrived and introduced a number of additional complexities (A transparent status bar, for example, or translucent navigation bars) didn't help at all. That was the last update. I tried restarting work on it a few times, but I never retained the traction I had up till version 2.2. It's been a few years now since I touched the code.

I never understood why it was and still is so popular. At the time of writing it has 4.416 stars on Github, 901 forks and gets cloned between 10 to 30 times per day. This means people still use it. Not by an immense number, but it's not a small forgotten library either. I fondly remember finding out that the Foursquare app used it, and have gotten several emails of people telling me that they used it in their app. It's great fun to have people use your "framework".

But the time has come to let it go more formally. My future job at Apple interferes with maintaining open source (UIKit related) software (which I can understand), and even apart from that I have no intention to continue development or maintance for ViewDeck. 

So... I'm looking for one or more people to take over the library. It's going to be all yours, and I will not interfere with its future development. The one thing I ask is to be recognized and mentioned as its original author, but that's it. If you want to turn it into something completely else: fine by me. I have moved the repo from its original location under my Github account to a newly created ViewDeck organisation in order to "set it free". If nobody takes over: again, fine by me, the code won't go away. But if somebody wants to take the current code and do magic with it: I'd love that. I know I'm not leaving a perfectly maintained library behind, but setting the code free is the least I can do. 

Interested? Shoot me a message on [Twitter](https://twitter.com/inferis) and we'll talk. And oh: I'm fine with adding more than one maintainer. :)