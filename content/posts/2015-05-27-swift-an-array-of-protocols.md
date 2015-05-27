---
title: "Swift: an array of protocols"
created_at: 2015-05-27 07:03:27 +0200
kind: article
categories:
- swift
- opensource
- development
preview: true
proofreaders: joericoach@, damon__jones@, istx25@
---

I was working on a side project yesterday, a side project which I decided to develop using Swift. My day job mostly consists of Objective-C (which I still love) but all the hip kids are doing Swift and it doesn't hurt to keep along with the latest trend, right? And learning is fun.

So I was coding away, and I had this component which needed to notify several other components of certain events that happened. In practice this meant that I needed a sort of *multicast delegate*. Now, I could have solved this the old Cocoa way by using notifications, but I try to stay away from them unless it really makes sense. The contract they offer is pretty loose (which can be handy too), but I wanted to try something more set-in-stone right now.

<!-- more -->

## The setup

So I created this class and protocol.

```swift
protocol ThingyNotifier  {
    func didDoOneThingy(thingyName: String)
    func didDoOtherThingy(thingyId: Int)
}

class ThingyManager {
    func doOneThingy() {
        for thingyName in ["one-thing", "other-thing"] {
          notifyAll { notifier in
            notifier.didDoOneThingy(thingyName)
          }
        }
    }

    func doOtherThingy() {
      for thingyId in [1, 2] {
        notifyAll { notifier in
          notifier.didDoOtherThingy(thingyId)
        }
      }
    }

    func addNotifier(notifier: ThingyNotifier) {
        // to be implemented
    }

    func removeNotifier(notifier: ThingyNotifier) {
        // to be implemented
    }

    private func notifyAll(notify: ThingyNotifier -> ()) {
        // to be implemented
    }
}
```

*(Note: The actual code was obviously different but similar.)*

This is pretty simple: I have a `ThingyManager` which manages thingies (not very good in this case, but I disgress), and whenever something changes I'd like to notify one or more instances of said changes. This is where `ThingyNotifier` comes in; and as you can see, there's more than one thing to be notified of. This is like the delegate pattern, but as a `1->n` connection instead of a `1->1` connection.

You'll also notice that there are 3 methods still left to be implemented: `addNotifier`, `removeNotifier` and `notifyAll`. We'll cover these later.

Additionally, I'd like to sprinkle some operator magic on top so that using these notifiers becomes more intuitive:

```swift
func +=(left: ThingyManager, right: ThingyNotifier) -> ThingyManager {
    left.addNotifier(right)
    return left
}

func -=(left: ThingyManager, right: ThingyNotifier) -> ThingyManager {
    left.removeNotifier(right)
    return left
}
```

This just wraps our `addNotifier` and `removeNotifier` in `+=` and `-=` calls, and so I can use this class like this:

```swift
class ThatController : ThingyNotifier {
  let thingyManager: thingyManager

  init(thingyManager: ThingyManager) {
    self.thingyManager = thingyManager
    thingyManager += self
  }

  deinit() {
    self.thingyManager -= self
  }
}
```

Which is nice (IMHO) and invokes some fond memories of using multicast delegates in my C# days.

## // to be implemented

But now those three methods remain. Let's implement them.

First of all, we need a place to store our `ThingyNotifier` instances:

```swift
private var notifiers: [ThingyNotifier] = []
```

We'll just use an array of `ThingyNotifier`. Easy.

Now onto `notifyAll`, which is just an iteration over said array to invoke the block on each notifier:

```swift
private func notifyAll(notify: ThingyNotifier -> ()) {
    for notifier in notifiers {
        notify(notifier)
    }
}
```

Again, easy.

Next up: `addNotifier`. This is even easier, just add the notifier to our array:

```swift
func addNotifier(notifier: ThingyNotifier) {
    notifiers.append(notifier)
}
```

And finally `removeNotifier`. Here's where things get tricky (you felt this coming, right?).
A naive implementation could be:

```swift
func removeNotifier(notifier: ThingyNotifier) {
    if let index = find(notifiers, notifier) {
        notifiers.removeAtIndex(index)
    }
}
```

But alas, the compiler disagrees:

{% img center http://c.inferis.org/image/1b3f0W103t37/Image%202015-05-27%20at%207.48.13%20am.png 750 %}

Now the error is a bit sparse on information, but looking at the (current) definition of `find` gives us more information:

```swift
func find<C : CollectionType where C.Generator.Element : Equatable>(domain: C, value: C.Generator.Element) -> C.Index?
```

It turns out that the element of the collection type we're trying to find something in must conform to `Equatable`. That makes sense since how else would `find` know if it has found the element it is looking for? There must be some kind of test for equality.

So, the solution is easy, right? Just make `ThingyNotifier` conform to `Equatable`:

```swift
protocol ThingyNotifier : Equatable {
    func didDoOneThingy(thingyName: String)
    func didDoOtherThingy(thingyId: Int)
}
```

Nope. This introduces a slew of new errors (of the same type):

{% img center http://c.inferis.org/image/1Z0b2L3M0v08/Image%202015-05-27%20at%207.58.20%20am.png 750 %}

Looking at the definition of `Equatable`:

```swift
protocol Equatable {
    func ==(lhs: Self, rhs: Self) -> Bool
}
```

Notice the `Self` type. This denotes that the method will use the actual type that's implementing the protocol. In this case, it makes sure we're comparing two objects of the same type with each other. This actually makes sense from a semantic standpoint: it's a pretty good assumption that objects need to be of the same type to be considered equal.

But this doesn't help us: we can't use `Equatable`, and thus we can't use `find`. We'll have to find another way.

## Our own ==

So let's declare the `==` operator/func to be part of the `ThingyNotifier` protocol itself:

```swift
protocol ThingyNotifier {
    func didDoOneThingy(thingyName: String)
    func didDoOtherThingy(thingyId: Int)

    func ==(lhs: ThingyNotifier, rhs: ThingyNotifier) -> Bool
}
```

And then we'll change our searching a bit to do a manual loop over the array instead of using `find`.

```swift
func removeNotifier(notifier: ThingyNotifier) {
    for (var i=0; i<notifiers.count; ++i) {
        if notifiers[i] == notifier {
            notifiers.removeAtIndex(i)
            break;
        }
    }
}
```

Well, that doesn't work either: we get back to the same problem as before, kind of:

{% img center http://c.inferis.org/image/3K0a2i2y0k1k/Image%202015-05-27%20at%208.35.57%20am.png 750 %}

And while you can make that error go away by providing an implementation of that `==` operator, like this...

```swift
func ==(lhs: ThingyNotifier, rhs: ThingyNotifier) -> Bool
{
    return true // UWOTM8
}
```

... it's kind of useless since you still need to do comparing of ThingyNotifier instances and always returning `true` or `false` isn't going to do that. Since we have nothing else to work with, we're stuck.

### A solution

Since we can't do this in pure-pure Swift, let's include *Foundation* into the party. How about we declare `ThingyNotifier` to have to conform to `NSObjectProtocol`? In my use case, this wasn't a problem since the notifier instances would be `UIViewController` instances anyway, but I guess this puts a bit of a limitation on what target objects you can use in the more general case.

```swift
protocol ThingyNotifier : NSObjectProtocol {
    func didDoOneThingy(thingyName: String)
    func didDoOtherThingy(thingyId: Int)
}
```

But it does introduce `isEqual()` into the equation. So now our `removeNotifier` implementation will become:

```swift
func removeNotifier(notifier: ThingyNotifier) {
    for (var i=0; i<notifiers.count; ++i) {
        if notifiers[i].isEqual(notifier) {
            notifiers.removeAtIndex(i)
            break;
        }
    }
}
```

And that works as expected. Like I said before, this introduces an extra requirement to conform to the `NSObject` protocol, which might be problematic depending on how you want to use this. But in practice, it's likely that the objects you're using as `ThingyNotifiers` are a subclass of `NSObject` anyway.

I can hear you think: "*but what if I just add an equality method myself?*". Let's just copy the `isEqual` method signature from `NSObjectProtocol` and we're good, right?

```swift
protocol ThingyNotifier {
    func didDoOneThingy(thingyName: String)
    func didDoOtherThingy(thingyId: Int)

    func isEqual(object: AnyObject!) -> Bool
}
```

Result:

{% img center http://c.inferis.org/image/39081y3E1C1T/nope.gif %}

Why? Objects conforming to `ThingyNotifier` now have to implement this method too and on top of it you cannot freeload on the `NSObjectProtocol` implementation anyway:

{% img center http://c.inferis.org/image/3w0P3p0a2I41/Image%202015-05-27%20at%209.16.19%20am.png 750 %}

And! Our equality check doesn't work anymore:

{% img center http://c.inferis.org/image/2Y082Z3v3S2q/Image%202015-05-27%20at%209.16.05%20am.png 750 %}

So, all in all, this `NSObjectProtocol` approach isn't too bad.

### A Real Pure™ Swift solution.

Confession time, I lied before: there is a kind of pure Swift solution. [Joe Groff](https://twitter.com/jckarter) of the Swift team at Apple provided [one](https://gist.github.com/jckarter/49e10f5b58eb5ad81646), but in my opinion and for this case it's such a contraption (if you'll pardon my French) that it becomes counterproductive to use. It makes the API I want to provide needlessly complex, but it **is** a pure Swift solution so I guess it has that going for it. 😉

Also, I love how the Swift team reaches out to us for problems like this. They cannot solve them all but they are very helpful and even getting these problems noticed by them makes me feel like there's a good chance they'll be actually solved in the future. Who knows, right?

Anyway, thanks to Joe (and the team) for the help. Much appreciated! 👍

### Example code

You can find a playground with the code of this post on [Github](https://github.com/Inferis/ThingyNotifier), if you care to play with it some more.

And oh, if there's another approach, I'd love to hear it!
