---
layout: post
title: "Explicitly implemented protocols"
date: 2014-09-21 07:07:27 +0200
comments: true
published: false
categories:
- swift
- development
- csharp
- patterns
---

While traveling home from NSSpain yesterday, I got an idea for a new app. Nothing groundbreaking, and more on that later, but it required the use of health kit. I also decided to write this one in Swift, for fun and profit but mostly for fun (and perhaps also because practice makes perfect).

## The problem

I soon stumbled on the "you need to authorize HealthKit access" mess. It's even more an issue in HealthKit than with the other APIs since you have to ask permission to read and/or write *for each type* of object you want to access.

So I decided to write a sort of proxy class that would handle the requesting, shielding off that hassle (since I would be needing access in several parts of the code). A pattern I've used for this kind of APIs before is that you have the class with the public API, which have an "access" call (for example). That call takes a block with one parameter: the "priviledged" part of the API. When the block is called, you can be sure to have the proper permissions making your code simpler and more obvious. Something like this:

```
protocol HealthKitAccessorReader {
    func someReadOperation(someValue: AnyObject) -> AnyObject
}


var accessor = HealthKitAccessor(neededObjectType)

accessor.read { (reader: HealthKitAccessorReader) -> Void in
    reader.someReadOperation(someValue)
}

```

Now I've made APIs like these before in C#, because I think it's an interesting and useful pattern. You're able to restrict access to certain parts of the API depending on the context the user of your API needs. In the example above, the `read` method only provides access to read operations. We could have a `write` method that only provides access to write operations (or even a `readwrite` which does both).

And the way I'd do this in C# is using private interface implementations. This is a technique which allows you to  specify that an implementation of an interface method is only usable if you use the class which implements it *as an interface*. For example, given this declarations:

```
interface IHealthKitAccessorReader {
  Object someReadOperation(Object someValue);
}  

class HealthKitAccessor : IHealthKitAccessorReader {
  private HKHealthKitStore store = ...;

  public void read(Action<IHealthKitAccessor> reader) {
    makeSureYouHaveAccess();
    reader(this);
  }

  Object IHealthKitAccessorReader.someReadOperation(Object someValue) {
    store.somethingSomething()
  }
}
```

you can do:

```
var accessor = new HealthKitAccessor();
accessor.read(reader => { reader.someReadOperation(someValue); });
```

but you can't do:

```
var accessor = new HealthKitAccessor();
accessor.someReadOperation(someValue);
```

even though `HealthKitAccessor` implements `IHealthKitAccessorReader`. This is because we explictly implemented the interface method, and so it's only available if we approach accessor as an instance of `IHealthKitAccessorReader`. So technically, you can do this:

```
var accessor = new HealthKitAccessor();
var reader = accessor as IHealthKitAccessorReader;
reader.someReadOperation(someValue);
```

which will work, even though it's not the intention of the API.

I've found this technique pretty useful in the past to have a class implement an API but shield direct access to it without using the specialized calls. The interface calls do not show up in intellisense/autocompletion when using the class, so it's pretty obvious in use.

Now in Swift (ånd this ends the C# interlude), this isn't possible. Having the same structure like before but in Swift gives us this:

```
protocol HealthKitAccessorReader {
  func someReadOperation(someValue: AnyObject) -> AnyObject
}  

class HealthKitAccessor : HealthKitAccessorReader {
  private store: HKHealthKitStore = ...;

  func read((reader: HealthKitAccessorReader) -> Void) {
    makeSureYouHaveAccess()
    reader(self)
  }

  func someReadOperation(someValue: AnyObject) -> AnyObject {
    store.somethingSomething()
  }
}
```

But this allows us to call both `read` and `someReadOperation` on any instance of the class, which is not what we want:

```
let accessor = HealthKitAccessor()
accessor.read { (reader) -> Void in
    reader.someReadOperation(someValue)
}

// but this also works
reader.someReadOperation(someValue)
```

## The fix

This does not mean we cannot use this pattern in Swift. We just need an inner proxy struct that implements the methods of the protocol:

```
class HealthKitAccessor {
  private store: HKHealthKitStore = ...;

  func read((reader: HealthKitAccessorReader) -> Void) {
    makeSureYouHaveAccess()
    reader(Reader(self))
  }

  private struct Reader : HealthKitAccessorReader {
    let accessor : HealthKitAccessor

    init(accessor: HealthKitAccessor) {
      self.accessor = accessor
    }

    func someReadOperation(someValue: AnyObject) -> AnyObject {
      accessor.store.somethingSomething()
    }
  }
}
```

This is not bad, of course. The code is a bit less obvious because you need to have this inner class (which might implement more than one protocol, of course). And in the implementation of that inner class you always need to deference the original object first before using it. But that's just that. In effect you're moving the gist of your implementation to the inner class instead of in the class itself. When writing more complex APIs (like fluent APIs), this might become a bit cumbersome. But again, that's just than and mostly a minor inconvenience.

## Conclusion

I think that explictly implemented protocol methods would be a valuable addition to Swift. I think they'd be handy (the same for abstract classes, but that's another discussion). The benefit of being able to use all internals of the class directly without dereferencing the original object makes the implementation more clear and there's no need for an internal proxy class. While the pattern is possible to use in Swift is required a bit more code and thus maintenance when changing the API in the future. But I guess that's a reasonable price to pay (until they add explicitly implemented protocol methods).
