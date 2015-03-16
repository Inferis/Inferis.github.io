---
layout: post
title: "The setNeedsLayout pattern"
created_at: 2014-05-02 15:56:46 +0200
comments: true
categories:
- ios
- objc
- development
kind: article
---

For the project I'm working on we ran into a performance issue on iPhone4 where an interaction would lock up the phone for a few seconds. It ran fine on iPhone5 and in the Simulator, but there was a severe hangup in on the older device. Investigation in Instruments revealed to problem to be autolayout. A lot of time (>3 seconds) was spent recalculating layout.

So I first hunted for `[view layoutIfNeeded]` calls, replacing them by `[view setNeedsLayout]` where applicable (sometimes you actually want to layout immediately if you need to do more stuff based on the layout results, but this is rarely the case). To no real avail, the issue remained extremely slow.

Digging in further, I found that two different call trees were doing autolayout of a certain part of the screen at the same time. This was all happening on the main thread which explained the lockup (no surprises there though). But in the timespan of the 2 seconds Instruments reported where (the major part of the) lockup was, there were two blocks where setting a label caused at least 800ms of autolayout calculations. So that's 1.6s accounted for. Which seemed like a good starting point to optimize.

The code was just setting properties (in this case: a title label and a response handler block), but they both touched the same label twice. I pondered on coalescing the two properties in one method but it seemed like an unsatisfying solution. And so I decided to copy a pattern Apple uses too regarding UI: the 'setNeedsLayout' pattern.

<!-- more -->

### Approach

Basically, inside of directly updating the UI, you save the future state somewhere and then indicate you want to changes to occur as soon as possible. And when those changes can occur, you use the future values to actually update the UI. This way, even if you are updating a gazillion properties that all have effect on the UI this doesn't do a gazillion updates but just one when they're all done (presumably). Layout effects of those changes only occur once and so are less of a burden on the system. The downside is that changes aren't really immediate, but in this case I could live with that.

### Implementation

So, what I did was:

* change all property setters to store the value in a future ivar
* remove all direct UI touching code from the property setters
* added a `[self setNeedsUpdate]` to each setter

So, for example:

```objc
- (void)setTopBarTitle:(NSString *)title subtitle:(NSString *)subtitle
{
    _futureSubtitle = [subtitle copy];
    _futureTitle = [title copy];
    [self setNeedsUpdate];
}
```

But, what does this `setNeedsUpdate` do? It's actually pretty simple:

```objc
- (void)setNeedsUpdate
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(update)
                                               object:nil];
    [self performSelector:@selector(update)
               withObject:nil
               afterDelay:0];
}
```

It performs the `update` selector (which will actually do the UI updating) after a delay of `0`. This does not mean it will do this immediately when you invoke the `performSelector:withObject:afterDelay`, or so says Apple's documentation:

> **delay**
>
> The minimum time before which the message is sent. Specifying a delay of 0 does not necessarily cause the selector to be performed immediately. The selector is still queued on the thread's run loop and performed as soon as possible.

Which is exactly what we need. It will schedule the call on the default runloop which is perfect for UI updating.

We also cancel any previous calls to `update` so that subsequent calls to the `setNeedsUpdate` don't result in a lot of `update` calls (albeit delayed `update` calls). Canceling them effectively reduces the number of times `update` will be called, which is the main performance improvement exhibited by employing this pattern.

Finally, in our `update` method we actually can do updating:

```objc
- (void)update
{
    self.subtitleLabel.text = _futureSubtitle;
    [self.titleButton setTitle:_futureTitle
                      forState:UIControlStateNormal];
    [self.titleButton.superview setNeedsLayout];

    // ...

    _futureTitle = nil;
    _futureSubtitle = nil;
    _futureTopBarPressedHandler = nil;
}
```

Don't forget to nillify the future variables to regain precious memory.

### Final words

So that's it. Not a lot to it but it can seriously improve performance in a pretty easy way.

I've used this pattern before and it's not new, but I thought I might be a good way to share my approach. So here you go.
