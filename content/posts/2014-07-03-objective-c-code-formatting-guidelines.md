---
layout: post
title: "Objective-C Code Formatting Guidelines"
created_at: 2014-07-03 09:29:22 +0200
published: false
comments: true
categories:
kind: article
---

I've been working on [an iPhone app](https://www.bolero.be/nl/platformen/mobile) (warning: link to a page in dutch) for the last 9 months (and we're continuing development on an iPad version of the same app with more functionality). I'm acting as a team lead and architect. It's a fun job with a lot of challenges, not in the least managing a team of 6 developers with varying levels of experience.

One of the problems we've been facing is the lack of code formatting guidelines. We haven't had them because I'm not a very big fan of them. Formatting guidelines are nothing new and in the past I've been on both the receiving as imposing side of that fence, with mostly mixed results.

<!-- more -->

The problem with formatting guidelines is that I feel it mostly hampers (good) developers in how they code. Let me explain: a good developer formats the code in a way he or she likes, but I've noticed that that code is very readable most of the time, even if the "standards" the developer used are so different from what you would use yourself. In a way it really doesn't matter how you format your code if you manage to write consise and clear code. The code should speak for itself, and they way it is formatted shouldn't really matter much.

But not everybody is a good developer, and there are also people who actually need a "support" to handle their code correctly. For small (one-man) projects this is less of an issue since they'll most likely be the only developer working on the application. And since apps in the mobile space were not long lived anyway this even posed less of an issue (I say: "not long lived" but that doesn't mean the app dissappears quickly: there's usually no budget to implement updates or new versions so that means it's dead developer-wise). But once you start working on longer term projects or with more than one developer on one project a certain set of rules can become beneficial.

The hard part is: what rules to make and how much of them. Because once you make a set of rules or guidelines, that means you need to enforce them which also takes time and hampers productivity. But if you omit them not everybody in the team will have problemns read everybody else's code which also hampers productivity (which is especially the case when you want to share functional experience across the team meaning that everybody should work on everybody's code in a way).

So what I'm going to try is to create a loose set of guidelines with mostly a few not-dones, and a few best practices. I don't want to  check every line of code somebody writes. Even if you manage to do that at first you'll probably fail after a few days/week at keeping the guard up. So the main goal is to get everybody to adhere to set of "common sense rules" so that developers who need a formatting support do at least get one, and developers not needing one won't feel too caged by having a set of rules imposed on them.

## Automated tools

It has been suggested to use an automated tool to handle code formatting for you. I'm not a very big fan of those. First of all do they have the potential to create a lot of noise in the version control system you'll be using (due to the formatting change only commits which will inevitable appear even which "format on save" options available). It also requires all developers to have the same exact code formatting rules set.  

But mostly: I don't think they actually solve the problem even if they make it go away. Having developers rely on automated tools will even deteriorate their formatting skills even more. Because why spend time on writing well formatted code when a tool does it for you? You can say that's a good thing but I disagree: like I said before, writing sloppy styled code most of the time results in sloppy written code. And that's something to avoid. :)

## Guidelines

If there's interest, I might do a post on what guidelines we're actually talking about. They're are work in progress and are subject to change but hopefully not too much (because why have guidelines in the first place at all, right?).
