---
layout: post
title: "IIShortNotificationPresenter"
created_at: 2014-03-22 20:14:10 +0100
comments: true
published: false
categories:
- opensource
- ios
- objc
- development
kind: article
---

I'd like to present a small piece of new open source software I wrote: `IIShortNotificationPresenter`.

It's an iOS component that allows you to post a notification on top of the current view (or viewcontroller).
It's actually view based but currently viewcontroller oriented (by which I mean that you can post a notification on any view, but the convenience methods present operation on viewcontrollers).

The default implementation looks like this:

{% img center http://cl.ly/image/0x2i3n401m1g/Image%202014-03-23%20at%2012.11.07%20am.png 700 'confirmation - notification - error' %}

Yeah, those look pretty hideous. Which is kind of intentional, because the whole thing allows you to override the style.

<!-- more -->

## Features

* Presents 3 type of notifications: notification ('blue'), confirmation ('green') and error ('red')
* Notifications are presented by sliding down from the top. If there's a navigation controller present, it will slide under the navigationbar, otherwise just from the top of the view of the controller. It should account for the statusbar. It does not adjust the statusbar color.
* User can dismiss each notification with a tap or a swipe up.
* You can _stack_ notifications and they will be posted sequentially
* The user needs to dismiss the error notifications, the other two are dismissed automatically after a predefined (and configurable) interval.
* No sound effects.

## Presenting notifications

Using it is pretty simple. Include `IIShortNotificationPresenter.h` and just call one of the `present` methods (on a viewcontroller):

```objc
[self presentNotification:@"Hi there!"];
[self presentConfirmation:@"You did good. Go get cookie!"
                    title:@"Yay!"
                accessory:YES
               completion:^(IIShortNotificationDismissal dismissal) { ... }];
[self presentError:@"Seriously wrong stuff there man" title:@"boom!"];
```

There are a few options here.

**All-in**: The all-in version takes a message, a title, a flag if an _accessory_ chevron should be displayed and a completion callback.

```objc
- (void)presentConfirmation:(NSString *)confirmation
                      title:(NSString*)title
                  accessory:(BOOL)accessory
                 completion:(void(^)(IIShortNotificationDismissal dismissal))completion;
```

Using this style will give you something like this:

{% img center http://cl.ly/image/13241402111E/Image%202014-03-23%20at%201.01.21%20am.png 320 %}

The `accessory` part will instruct the notification to present a side chevron. If the user taps on the notification itself, the callback

1. The simple version just takes a message. This presents a notification without a title or an accessory. You get no completion block callback when the

## Interesting to know

* I use this in an (unreleased) project for a client, so this has been dogfooded. Works pretty well for us.
* This is mainly engineered towards iPhone, but it works on iPad too. I just isn't as appealing there. I'm working on a similar system more geared for the larger screen of the iPad.

The design of the original presentations was done for the client project, but it was adapted for this open source component. Not all interactions and elements are still present but credit goes to [Dennis Covent](http://twitter.com/denniscovent).

## Todo

* I might improve the default view color schemes. Suggestions welcome.
* Add prefixes to the category. `ii_presentNotification:` instead of `presentNotification:` mainly (and thus for each method on the category).
* add an informal protocol so that you get _delegate_ callbacks on the viewcontroller

No promises though. Not looking to bloat this with a lot of feature request like happened with [ViewDeck](https://github.com/Inferis/ViewDeck).

## Installing

So, you want to use this. Good!

Option 1: there's a CocoaPod:

```ruby
Pod 'IIShortNotificationPresenter'
```

Option 2: if you don't like CocoaPods -- you know who you are -- you can always fetch [the source](https://github.com/Inferis/IIShortNotificationPresenter) from Github and integrate it into your own project. Because that's a lot of fun, too.
