---
layout: post
title: "Modular iOS Projects"
created_at: 2014-09-05 19:24:20 +0200
comments: true
published: false
categories:
kind: article
---

## Once upon a time...

Some context first: the last year I've been working on a duo of apps for the Belgian tradingplatform [Bolero](http://bolero.be). I was brought in as the team lead for the iOS team last september, and it's been a wild rollercoaster since then. The iOS team (1 out of 5 teams for this project) started out with just me and another developer. There was a minimal code base of a proof of concept app when I started and we worked from there. The team grew from 2 people to 8 people (including me).

<!-- more -->

Not only the team grew, but our code base too. I don't know how many lines of code we had we I started, but I can tell you the stats of the project at this very moment, near completion of the second app (keeping in mind that both apps share a lot of code):

```
    5834 text files.
    3526 unique files.
     961 files ignored.

http://cloc.sourceforge.net v 1.58  T=22.0 s (137.8 files/s, 10100.7 lines/s)
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Objective C                   1655          35557          17234         132816
C/C++ Header                  1372           8236          15203          12715
C                                1             41            125            148
CSS                              1             25              0             90
HTML                             1              1              0             12
XML                              1              1              0             12
-------------------------------------------------------------------------------
SUM:                          3031          43861          32562         145793
-------------------------------------------------------------------------------
```

Now I know that lines-of-code is a bad measurement for developer performance, but I'm using it here to give an idea of the size of this project. It's the largest (set of) iOS projects I've worked on so for. At 145k LOC, this project is not small (and that is not counting the several [CocoaPods](http://cocoapods.org) we're using).

The problem with projects of this size is that they become unmaintable in the long run. If you put everything into one project, the seduction call of using whatever you need whereever you need it becomes so loud that you'll probably end up with a spagetti mess of interdependent files.

## A solution

So, how did we solve this?

Easy: break it up into pieces.

Now, that's easier said than done. We knew on beforehand that these projects were going to be large, so we accounted for it while developing code. This was not easy on the development team, because they only worked on normal sized projects where modularity can certainly be a benefit, but usually is not necessary on this scale. When I started out, everything was one project (with two targets: one for the iPhone app, one for the iPad app).

## Cocoapods

The first step was split the single project into three. One for the iPhone app, one for the iPad app (we were going to develop both a the same time but we would release iPhone first so focus was obviously on that project). A third project became our "Services" project which contained all the code that talked to the backend. This was in effect qua a large portion of the app (and at that time a little bit overengineered even for the (future) size of this project). We also took advantage of the split to refactor a part of this code so that it would become simpler to maintain and easier to develop with/for.

So basically, we added a "custom framework" to the mix. This was before native iOS custom frameworks that came with Xcode 6, so we had to find a solution to integrate our *Services* into the two app projects.

The most obvious solution was to add it as subproject to each app project. This works fine, but I saw a few problems:

1) since we had two app projects, it meant we could have only one open at a time. The Services project wouldn't load in the second project if the first project was open, and thus wouldn't compile. A bit of a hassle but a small one.
2) this would get cumbersome once we would start adding more subprojects. It was not the case at the moment but I was already thinking of creating a "shared library" for common code (macros, helpers, ...) for all 3 projects. Having the correct dependencies was going to be non-trivial.
3) I also had a feeling it was going to be a mess when you have access to all the files across 2 projects (App + Services), and that the benefit of putting it into two projects was going to be lost or at least greatly diminished. This is a highly subjective point to make, but I still feel was a valid one to make.

So no subprojects. What else?

CocoaPods.

We'd put our Services project in a pod, both as a separate project and a pod for the
CocoaPods allows you to have "Development Pods"
