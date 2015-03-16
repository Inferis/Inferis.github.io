---
layout: post
title: "categories-for-@protocols (2)"
created_at: 2014-03-07 00:23:26 +0100
comments: true
categories:
- objc
- development
kind: article
---

And a follow-up post for [this one](../../06/categories-for-at-protocols). Already!

I forgot about it, but [@pjaspers](http://twitter.com/pjaspers) reminded me that
we actually did something similar to this using "regular" language constructs.

What you could do:

1. extend the protocol with the method you need (as has been suggested before)
2. implement the protocol extension method a seperate .m file (similarly named to
  the .h file the protocol is defined in, I guess). Forgo the @implementation/@end
  dance, just put the method code "naked" into the file.
3. for each class conforming to the protocol do a `#include "Protocol+Implementation.m"` in
the class' implementation file. You read that right: thats an **include** and not an **import**.

<!-- more -->

In effect, this includes the code of the .m file into each class implementation file.
Which means that you only have to write it once, which was my main gripe with extending the protocol.

So, we have:

```objc
// Awesome.h
@protocol Awesome <NSObject>

- (void)two_fingers;
- (id<Spam>)spammize;

@end

// Awesome+Implementation.m
- (id<Spam>)spammize
{
  return [[Spam alloc] initSpam:self].spam.spam;
}

@end
```

Which we'll use like this:

```objc
// DogeCat.h

#import "Awesome.h"
@interface DogeCat <Awesome>
@end

// DogeCat.m
#import "DogeCat.h"

@implementation

- (void)two_fingers {
  // ...
}

#include "Awesome+Implemenation.m"

@end
```

You can do the same for any other file implementing the protocol. So that's nice.
You still have to think of putting the #include statement into the file, so it's
not ideal yet but it's good enough to be actually useable.

On the other hand: this feels hacky enough not to use it unless there's no good other
way around it. Right?
