---
layout: post
title: "Quick Look for UIView"
date: 2014-03-14 21:21:33 +0100
comments: true
categories:
- ios
- objc
- development
---

Xcode 5.0 introduced an interesting new feature: [Quick Look for variables](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/CustomClassDisplay_in_QuickLook/Introduction/Introduction.html). Basically, it lets you inspect variables and their contents in a graphical way. This allows for interesting ways of viewing the state of your app.

I've been using the feature quite a bit: it's a great way to inspect images or colors you're using in your app, for example. Works great on attributed strings, too.

{% img center http://cl.ly/image/0f473u3W2f0L/Image%202014-03-14%20at%2010.00.01%20pm.png 500 %}

Xcode 5.1 improves the feature even further with the addition of `debugQuickLookObject`. This method allows you to provide quick look content for any of your own classes. A bit like `debugDescription` but more advanced. I haven't had the time to look further into it.

## iOS Dev Weekly to the rescue

But now it's friday, and reading the latest edition of [iOS Dev Weekly](http://iosdevweekly.com/issues/137), I saw a link titled  [Quick Look on UIViews](http://useyourloaf.com/blog/2014/03/12/xcode-debugger-quick-look.html) (the article itself is called *Xcode Debugger Quick Look*). My interest was immediately peaked: the quick look feature does not provide any specific support for UIViews, and it's been more than once where I had thought: "dammit it want to see what this view looks like". Because now you get this:

{% img center http://cl.ly/image/100g1D2L0s0v/Image%202014-03-14%20at%2010.24.22%20pm.png 500 %}

Not very useful. So my hopes were high for that article to provide a way to visualise views. And while it provided that, there was no *general* way to inspect any view. There were specific examples for labels etc, but nothing generic.

So I decided to implement this myself. Include "UIView+DebugQuickLook.m" into your project, and all your views automagically gain `debugQuickLookObject`. Like this:

{% img center http://cl.ly/image/0n12410C260c/Image%202014-03-14%20at%2010.29.49%20pm.png 300 %}

## Internals

So how does this work? It's actually pretty simple:

1. we define a category implementation on `UIView` (no interface needed since there's no public extensions for UIView).
2. implement the `+load` method in that category. This method is called when the class is loaded (the runtime will call load for the class and all its categories having the `load` method).
3. In that load method, we invoke another class method that installs the `debugQuickLookObject`.
4. We check that `debugQuickLookObject` isn't already present on `UIView`. This is in case Apple adds it themselves, or another library implements it for you: we don't want to break things in the future.
5. After that, we use `objc_addClassMethod` to add the `debugQuickLookObject` method to `UIView`. We use our `image_debugQuickLookObject` method as a template. This effectively adds a new method to all UIViews.

The whole `@implementation` block is wrapped in an `#if DEBUG ... #endif` block, since we only want to add this when debugging. There's no need to inject this code into your app when building for production use.

The `image_debugQuickLookObject` (or `debugQuickLookObject` once it's been added) method is pretty simple in itself:

1. It creates an image context with the size of the view.
2. It then tries render the view using `drawViewHierarchyInRect:afterScreenUpdates:`.
3. If that failed, it renders again using the view's layer.
4. It then retrieves the image from the context
5. and returns it. And that's it.

If you want to inspect the "full" code, check out the [Github repo](https://github.com/Inferis/UIView-DebugQuickLook/blob/master/UIView%2BDebugQuickLook.m).

## Get it on the internets

If you want to integrate this in your own projects, either can download the file from the [Github repo](https://github.com/Inferis/UIView-DebugQuickLook) (and add it manually to your project), or use CocoaPods. Just add:

```ruby
  pod 'UIView+DebugQuickLook', :git => 'https://github.com/Inferis/UIView-DebugQuickLook.git'
```

Enjoy!
