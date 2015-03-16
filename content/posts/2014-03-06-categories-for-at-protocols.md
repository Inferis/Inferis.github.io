---
layout: post
title: "Categories for @protocols"
created_at: 2014-03-06 21:54
comments: true
categories:
- objc
- development
kind: article
---

Yup. Categories for protocols. You heard that right.
It started with me asking about it on twitter:

{% tweet https://twitter.com/inferis/status/441603940250288128 align=center %}

This question caused much confusion. "How is that even possible?" "Categories are used to
extend existing classes, surely how can you extend a protocol?"

<!-- more -->

I also got the suggestion that protocols can extend other protocols:

{% tweet https://twitter.com/bluecrowbar/status/441661650098466816 align=center %}

I knew about that, and it was not what I was looking for. I genuinly want categories for protocols.

Let me explain.

## Categories and protocols

Suppose I have these two protocols:

```objc
@protocol EffectsView <NSObject>

@property (nonatomic, strong) NSArray* effects;
// more ...

@end

@protocol LayeredEffectsView <EffectsView>

@property (nonatomic, strong, readonly) UIView<EffectsView>* mainEffectsView;
@property (nonatomic, strong, readonly) UIView<EffectsView>* overlaidEffectsViw;
// more ...

@end
```

Basically, the first one describes a view/object that has effects, the second one
describes a view/object has 2 layered effect views (the actual code is different
but equivalent - I changed the original code to protect the innocent).

My UI uses these two view types interchangely. I do not want to use classes since
I want to be free to embed any type of view, as long as it implements effect. Sometimes
I want to have a layered effect view, sometimes I want to have a single effect view.

Now I also have a container view that handles these effects. But it takes a
layered view (for reasons not disclosed here):

```objc
@interface EffectsContainerView

- (id)initWithEffectsView:(UIView<LayeredEffectsView>*)effectView;

@end
```

So when I want to use a simple effect view in this container view I need to wrap it into
a layered view.


```objc
StandardEffectsView* standard = [StandardEffectsView new];
LayeredEffectsView* layers = [[LayeredEffectsView alloc] initWithMainEffectsView:standard];
EffectsContainerView* container = [EffectsContainerView alloc] initWithEffectsView:layers];
```

While this works, it's a bit verbose (but hey, it's Cocoa, what did you expect).
Still, while I was writing code I was thinking how useful it would be to be able to write:

```objc
EffectsContainerView* container = [EffectsContainerView alloc] initWithEffectsView:[[StandardEffectsView new] layeredAsMain]];
```

Now I hear you say: you can do that!

Of course I can. Just write a category on `StandardEffectsView` that handles that:

```objc
@interface StandardEffectsView (Layered)

- (UIView<LayeredEffectsView>*)layeredAsMain;

@end
```

Sure. But what if I have a `SliderEffectsView` and a `ButtonEffectsView` and
a `TableEffectsView`? I now have to write the same code for each class.

* I can't make a common superclass to define the category on,
because I want the effects on a `UISlider`, `UIButton` and `UITableView`, for example.
This is also tedious and error prone since every new class I add that implements
this protocol would need to add this method.
* I could make a category on UIView, but then all `UIView`s would gain this method
which is not what I want since the views on the `LayeredEffectsView` protocol
are expected to implement `EffectsView`. So that wouldn't work, really.
* I could extend the `EffectsView` protocol to include the layeredAsMain method,
but that would still require me to implement the same code on each class.

So I thought: wouldn't it be cool if you can create category on a protocol?
Something like:

```objc
@interface UIView<EffectsView> (Layered)

- (UIView<LayeredEffectsView>*)layeredAsMain;

@end
```

This would have all UIView subclasses conforming to the `EffectsView` protocol
gain the `layeredAsMain` method. But how would you implement it? A protocol is
just that: a definition of how a class should act and you don't have any specific
instance to work with.

But do we need one? Adding a category on a protocol would allow you to extend
all classes confirming to the protocol, and you only have the protocol information
to work with. But that's just fine. The implementation of our category method
above would become:

```objc
@implementation UIView<EffectsView> (Layered)

- (UIView<LayeredEffectsView>*)layeredAsMain
{
  // we could also use self.effects here, for example
  return [[LayeredEffectsView alloc] initWithMainEffectsView:self];
}

@end
```

Which works fine. We can use `self` because the protocol has to be implemented on
an actual class, so at runtime an instance will be there. And that instance will
conform to the protocol, so we can use it to it's full potential.
And I only have to implement it once, and all `UIView` classes with `<EffectsView>`
would be convertible to a layered view with once short, simple method.

To elaborate a bit: in this case, `self` would be at least a `UIView` instance so
we could use properties and methods from that class to, in addition to the
protocol's stuff. In this case, we have an actual underlying class, but I guess
it would work for "pure" protocols too:

```objc
@protocol EffectsView (Layered)

- (UIView<LayeredEffectsView>*)layeredAsMain;

@end
```

Everything conforming to this protocol would gain this (irregardless of class).
The confusing part becomes the implementation because that would mean a .m file
for the protocol category but that's not too problematic. Just something we're not used to.
There would be no class methods/properties to use, just protocol methods/properties.

I might hear you make a last complaint: "how would an object know what method to
run, if more that one category supplies the same method?"
The same problem arises with plain class categories, so this is as problematic as
it is now. So really no larger problem than before.

## In closing
So yeah, categories for protocols. A generic way to extend a range of classes without
having to resort to class hierarchies. Unconventional, I admit.

For the moment, this isn't possible. The syntax described above doesn't work.
Sure, I can work around it. Sure, it's a bit more verbose. Nothing much.

But it would be cool to be able to do this, I think. :)
