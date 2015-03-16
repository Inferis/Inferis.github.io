---
layout: post
title: "Cocoapod All The Things"
created_at: 2014-09-14 13:19:57 +0200
comments: true
categories:
- development
- cocoapods
kind: article
---

So, am I the only one who manages to get sidetracked a lot when working on (personal) projects?

For example, I have a few generic components written for various projects. In the past I would just add a `vendor` folder to my project, put the component there and be done with it.

But I've become to like CocoaPods to much that I cannot get myself to use this simple approach anymore. The CocoaPods approach makes using external libs so clean that it feels dirty not to (unless there's no other option).

<!-- more -->

But then the problem is that when I have a "new" generic component for a new project, I need to turn it into a CocoaPod first. This means splitting of the code, making a podspec, testing the podspec and then integration it into your project. Sure, not a lot of work, but it adds to the 'total drag'. Now I know I only inflict this on myself, but still. :)

It also doesn't help me thinking: "wait, somebody else might find this handy" and I go off by making another repo on github, pushing the code there, adding a README and LICENSE file, add/update the CocoaPods specs repo with the new/updated podspec and issue a pull request for the update to be merge into the main repository. I could be using a simple development or local pod, but the first keeps the code local to the repo, and the second one, well, I don't have a local CocoaPods repo set up.

So, nothing big, but these things feel like a hassle sometimes even though I'm happy to share my code with other. Sometimes I just wish I could force myself back to the vendor approach, but I guess I'm tainted forever.  
