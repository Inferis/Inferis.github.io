---
layout: post
title: "The Builder Pattern in Objective-C"
created_at: 2014-04-12 18:42:02 +0200
comments: true
categories:
- ios
- objc
- development
kind: article
---

A [blogpost](http://www.annema.me/blog/post/2014/4/4/the-builder-pattern-in-objective-c) by [Klaas Pieter Annema](http://twitter.com/klaaspieter) is doing the rounds on twitter lately. It appears the builder pattern is quite new to iOS devs since everybody is raving about it. In my own humble opinion I do think it is a bit convoluted for what it's worth.

The [followup post](http://joris.kluivers.nl/blog/2014/04/08/the-builder-pattern-in-objective-c-foundation/) by [Joris Kluivers](http://twitter.com/kluivers) makes better use of existing classes: `NSURLComponents` becomes the builder for an `NSURL`, and given that these classes are already present and used in other use-cases, the builder pattern makes a lot of sense this way.

But I still feel that rolling just a builder class to construct an object is a bit overkill. But it turns out you don't need two classes: you just need to leverage another feature of Objective-C: protocols.

<!-- more -->

Let's go back to Klaas Pieters last iteration:

```objc
Pizza *pizza = [Pizza pizzaWithBlock:^(PizzaBuilder *builder) {
    builder.size = 12;
    builder.pepperoni = YES;
    builder.mushrooms = YES;
}];
```

This needs a builder object class (`PizzaBuilder`) and the object class (`Pizza`) itself. These are most likely very alike, although this doesn't have to be the case as Joris' Foundation example points out so succinctly.

But you can also do it like this:

```objc
Pizza *pizza = [Pizza build:^(id<PizzaBuilder> builder) {
    builder.size = 12;
    builder.pepperoni = YES;
    builder.mushrooms = YES;
}];
```

So we replaced the `PizzaBuilder` **class** with a `<PizzaBuilder>` **protocol**. The rest of the code stays exactly the same.

How is this protocol defined?

```objc
@protocol PizzaBuilder <NSObject>

@required
- (void)setSize:(NSUInteger)size;
- (void)setMushrooms:(BOOL)mushrooms;
- (void)setPepperoni:(BOOL)pepperoni;

@end
```

It just defines a number of setter methods to set the pizza values. You could also define regular properties if you need to read your builder values, but in this case this is not necessary.

The `pizzaWithBlock:` defined by Klaas Pieter becomes a `build:` method (I like methods that actually describe what they do, and in this case `build:` makes perfect sense, although you could contend that `pizzaWithBlock:` adheres more closely to what Apple does I guess):

```objc
+ (instancetype)build:(void(^)(id<PizzaBuilder>builder))buildBlock {
    Pizza* pizza = [Pizza new];
    if (buildBlock) buildBlock(pizza);
    return pizza;
}
```

Now we just need to have `Pizza` implement `<PizzaBuilder>` but we can do that in the `Pizza.m` file in an extension category:

```objc
// in Pizza.h

@interface Pizza : NSObject

@property (nonatomic, assign, readonly) NSUInteger size;
@property (nonatomic, assign, readonly) BOOL mushrooms;
@property (nonatomic, assign, readonly) BOOL pepperoni;

@end

// in Pizza.m
@interface Pizza () <PizzaBuilder>

@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, assign) BOOL mushrooms;
@property (nonatomic, assign) BOOL pepperoni;

@end

@implementation

// ...

@end
```

And now the builder can directly set the properties on the pizza itself. But this happens *in private*, and it's the sole responsiblilty of `Pizza` itself and not the outside world. Also notice that I made `Pizza` immutable, so its properties are not writable for that same outside world, and the class itself is responsible for its state (as it should be).

But even better, `Pizza` is now free to provide whatever builder implementation it chooses so, so instead of becoming a `<PizzaBuilder>` itself for direct manipulation, it can actually construct an `ItalianPizzaBuilder` class (for example) that implements the `<PizzaBuilder>` protocol. To the user building a pizza this makes absolutely no difference so our current code won't break. Which is harder to do when using an actual class. So that's a lot cleaner. And if I want a New York style pizza I can have `Pizza` use a `NewYorkStylePizzaBuilder`.

So, yeah, I'm a big fan of protocols. I try to use them where they make sense. They offer flexibility and are more futureproof than actual classes (which you still need for an actual implementation, of course). Also remember that protocols can inherit too, so you can have more complex `<PizzaBuilder>` protocols for more complex `Pizza` classes too.

And oh: (I think that) if you actually need another object to build one object you need a *Factory*, not a *Builder*.

### Update

[Simon Wolf](http://twitter.com/sgaw) points out that Xcode/clang doesn't recognizer the setters as "writeonly" properties:

{% tweet https://twitter.com/sgaw/status/455052594126544896 align=center %}

Which I should have known because I looked up if there was a writeonly flag on a property (and there isn't, but there is a readonly flag).
So, you need to either write:

```objc
Pizza *pizza = [Pizza build:^(id<PizzaBuilder> builder) {
    [builder setSize:12];
    [builder setPepperoni:YES];
    [builder mushrooms:YES];
}];
```

or have the setters as regular properties (as mentioned before):

```objc
@protocol PizzaBuilder <NSObject>

@required
@property (nonatomic, assign) NSUInteger size;
@property (nonatomic, assign) BOOL mushrooms;
@property (nonatomic, assign) BOOL pepperoni;

@end
```

But in that case you also need to make sure your builder implementation properly returns the values, which might be more work in the end.
