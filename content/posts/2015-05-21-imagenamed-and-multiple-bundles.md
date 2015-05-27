---
title: "imageNamed and multiple bundles"
created_at: 2015-05-21 16:56:27 +0200
kind: article
preview: true
---

I'm currently working on a largeish project for a client. We're trying to modularize our code into several sections using CocoaPods (this is a post worth on itself, which is forthcoming). One of the modules is a UI Library with common components.

One of the problems you encounter with this approach is that for each pod, CocoaPods creates a bundle with resources for that pod (at least when you tell it to do that). It's the only good way to package pod resources into the main app. This means that our resources do not all live in the main bundle but in seperate bundles (which themselves **do** live in the main bundle). This is no problem in itself, but it can cause loading problems of those
