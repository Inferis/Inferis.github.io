---
title: "Scripts in your app bundle"
created_at: 2015-04-22 15:02:23 +0200
kind: article
proofreaders: siegel@, iCyberPaul@, bazscott@
categories:
- deployment
- xcode
---

It appears Apple changed something in the iOS bundle upload : it now requires that all executables in your app bundle are signed (this might be applicable for Mac uploads too, but I haven't tried). I hear you think: isn't this the case anyway, but there might be more executables in your bundle than you expect.

Of course, there's the binary for your app, which obviously is executable. But there could be more too: if you include shell scripts, for example, which are marked executable (`chmod u+x script.sh`) then iTunes Connect now considers them as actual executables and now requires them to be codesigned.

<!-- more -->

This is evidenced by an error like this one:

{% img http://i.stack.imgur.com/KzOct.png 750 %}

*(Taken from a [Stack Overflow post on the error](http://stackoverflow.com/questions/29788601/error-itms-90035-xcode))*

## Problem solving

So there's two options:

1. [codesign](https://developer.apple.com/library/mac/documentation/Security/Conceptual/CodeSigningGuide/Introduction/Introduction.html) your included scripts
2. remove your scripts from the bundle

Option 2 will most likely always be the thing you'll want to do, unless you actually want to run the script in your app (to be honest: I'm not even sure that's even possible on iOS given the security issues).

Getting rid of the scripts is easy: find the script in Xcode and make sure it's not included in any of your targets. If it's not there, you're probably safe. If you still get errors, it might end up in your bundle through another way than Xcode. This can be an external script including the file in your bundle, for example. Which brings me to the harder part of the problem... Namely, when you're using CocoaPods that include executable scripts as a resource (for god knows what reason). An example of this is the [Crittercism pod](https://github.com/willowtreeapps/Crittercism-iOS): they include a `dsym_upload.sh` as a resource, probably as an easy way to distribute the file. If you look at the project file, you won't see the file marked as included in any target:

{% img center https://s3.amazonaws.com/f.cl.ly/items/3f1v3s251p1M2W1M3O3S/Image%202015-04-22%20at%203.32.19%20pm.png %}

But it **does** get copied into your bundle by the `Copy Pods Resources` build phase, which has no reference at all to the culprit in question (because it generically copies all pod resources into the app bundle):

{% img center https://s3.amazonaws.com/f.cl.ly/items/0k3Y131w0q0h3E2A2H04/Image%202015-04-22%20at%203.34.01%20pm.png 750 %}

So that's kind of non-obvious.

The tricky part here is that the inclusion of this file is a bit out of your reach. The author of the Podspec decided to include it for some reason and all you asked for was `pod 'CrittercismSDK'`. There is no way of manually excluding the file, not even by unticking a box even if that meant you had to do this after every `pod install`. So you're stuck waiting until the authors update their Podspec file, or you could do it yourself (for now).

## Fixing the podspec, temporarily

How? By duplicating the offending podspec locally and fix it. In the case of the Crittercism spec this means omitting the .sh file from resources:

```ruby
Pod::Spec.new do |s|
  ...
  s.resources = 'CrittercismSDK-crashonly/Resources/*'

  # add this line below
  s.exclude_files = "**/*.sh"
end
```

According to the [Podspec syntax reference](http://guides.cocoapods.org/syntax/podspec.html#exclude_files) `exclude_files` defines "A list of file patterns that should be excluded from the other file patterns.". Which is exactly what we need. There might already be a line like this in the podspec, so you might need to append to it instead of adding it, so take a good look first.

Now that you fixed your local copy of the podspec, use that one in your podfile. Which is as easy as adding a `podspec` reference for the pod:

```ruby
pod 'CrittercismSDK', :podspec => 'CrittercismSDK.podspec'
```

Of course, you'll only want to do this if this blocks your release. You'll need to keep monitoring the offending podspec(s) for actual fixes so that you can continue using the version you want. By capturing the podspec and storing it locally, you effectively use the version of a pod at the moment of capture, also in the future.

But it's a good compromise to make to get that app out of the door, which is what counts at the end of the day. Just ship it. 😎
