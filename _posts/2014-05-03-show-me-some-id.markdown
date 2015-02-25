---
layout: post
title: "Show me some id"
date: 2014-05-03 22:21:14 +0200
comments: true
categories:
- objc
- development
---

Brent Simmons touches on the use of [abbreviations](http://inessential.com/2014/05/03/abbreviations) in Cocoa. I've noticed this behaviour too, and other uncocoalike things too. This is especially apparant in code of devs coming from other programming language/platforms.

## How about that id
Another thing is the use of `id`. I find that a lot of Cocoadevs don't fully understand the way Objective-C deals with objects and types. They mostly assume it's like `Object` in Java or C# (for example).

And so you get code like this:

```objc
[datapoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
  DataPoint *datapoint = (DataPoint*)obj;

  [datapoint doSomethingWithThisDatapoint];
}];
```

This hurts my eyes.

First of all, there's no need to cast. You can just do this:

```objc
[datapoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
  [obj doSomethingWithThisDatapoint];
}];
```

Let me explain: even though you might assume that all those objects are actually going to be DataPoint objects, there's no actual guarantee that they will actual be DataPoint objects at runtime. Casting them only satisfies your hunger for type safety, but nothing else really. And you can just invoke your selector on the `id` value, since it will accept any **known** selector. The emphasis is on *known* here, since you do need to include the _DataPoint.h_ file for the compiler to recognize the `doSomethingWithThisDataPoint` selector. You can thank ARC for that because the only reason is that the ARC analyser needs to know how to deal with incoming and outgoing objects (which it knows about thanks to the message signature in the .h file). But that's the only reason.

In fact, if you turn off ARC (for that file) you can send whatever selector you want to the object and the compiler won't complain. You won't get autocompletion either, though, but you do know the frameworks by heart, don't you?

Finally, there's a way to meet in the middle. Even though the signature of the `enumerateObjectsUsingBlock:` takes a `(void (^)(id obj, NSUInteger idx, BOOL *stop))` parameter indicating a block with a first parameter of 'type' `id`, you can specify whatever type you want when actually implementing the block:

```objc
[datapoints enumerateObjectsUsingBlock:^(DataPoint *datapoint, NSUInteger idx, BOOL *stop) {
  [datapoint doSomethingWithThisDatapoint];
}];
```

This gives you autocompletion, and you might feel a little more typesafe but it's only a little bit of extra convenience gained and nothing more.

This works because `id obj` in the block argument list specifies that it "will be an object", and that means that the `DataPoint*` we specified also satisfies that constraint. If the block argument list would have said `Thingy *obj`, the compiler would complain about the signature mismatch.

I find myself opting for the last option most of the time. It conveys what you want to do nicely, integrates with Xcode's autocompletion and it's less typing than writing a cast. But as mentioned before: there's no guarantee whatsoever that those `datapoints` are going to actual `DataPoint` objects at runtime.

By the way: this doesn't apply to blocks only, you know. It works for any selector:

```objc
- (IBAction)logout:(UIButton *)sender
{
  sender.userInteractionEnabled = NO;
}
```

See. :)
