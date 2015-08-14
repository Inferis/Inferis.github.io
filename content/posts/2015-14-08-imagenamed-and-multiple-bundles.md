---
title: "imageNamed: and multiple bundles"
created_at: 2015-08-14 16:10:27 +0200
kind: article
---

I've been working on a largeish project for a client for the last few months. We're have to modularized our code into several sections using CocoaPods (this is a post worth on itself, really). 

One of the problems you encounter with this approach is that for each pod, CocoaPods creates a bundle with resources for that pod (at least it does so when you tell it to do that). It's the only good way to package pod resources into the main app. This means that our resources do not all live in the main bundle but in seperate bundles (which themselves **do** live in the main bundle). This is no problem in itself, but it can cause loading problems of resources in those bundles. It doesn't pose that much of an issue when you specify images in a nib since iOS will search in the nib's bundle too, but it's a bit harder to get resources from within your code

<!-- more -->

Basically, you're going to be doing this:

```objc
NSBundle *bundle = [self loadTheNeededBundle]; // funk that
NSString *path = [bundle pathForResource:name ofType:nil];
UIImage *image = [UIImage imageWithContentsOfFile:path];
return image;
```

First of all, you need to know where the bundle is. I'm not going to add code for this, because you might already have a reference to this bundle. And otherwise you need to lookup the bundle within your main bundle. But we'll get to that later.

Then, you need to find out if there's a file named just like the image name you're after. This poses a second hurdle: for `imageNamed:` you can specify an image with or without the extension. That's not going to work here since we explicitly need the extension (either separately or in the resource name) otherwise the path cannot be found. And only then, when you have the actual physical path of the resource, you can load up the image.

While not a lot of code, reusing these same lines of code becomes tedious and repetitive. And we don't like repetitive code, do we? 

So on to a better solution.

## Resource bundles

First of all, we need to lookup all the bundles in our app. There's no built in way to do this, unfortunately. `NSBundle` does not have facilities to search for all app bundles. Let's cook up our own, because it's relatively easy.

Turns out that all "bundled" bundles are just living in your app's main bundle:

{% img http://c.inferis.org/image/1p3G2V0M0h1s/Image%202015-08-11%20at%209.46.46%20am.png %}

Let's find a way to enumerate them. Like I said: that's pretty easy:

```objc
+ (NSArray*)allAppBundles
{
    static NSArray *_bundles = nil;
    
    if (!_bundles) {
        NSArray *bundles = [[NSBundle mainBundle] pathsForResourcesOfType:@"bundle" 
                                                              inDirectory:@"."];
        bundles = [bundles map:^id(NSString *path) {
            return [NSBundle bundleWithPath:path];
        }];

        _bundles = [@[[NSBundle mainBundle]] arrayByAddingObjectsFromArray:bundles];
    }
    
    return _bundles;
}
```

`+allAppBundles` returns an array of `NSBundle` instances, all representing a resource bundle in your app (including the main app bundle). We get those bundles like this:

1. ask the main bundles for the paths of all resources of type "bundle". This gives us a bunch of strings with bundle paths.
2. we try to load an NSBundle for each of those paths
3. we tack the main bundle in front of our result

*(The `map` in that code sample does exactly what you expect it to do: it transforms an array into objects of a different type. This particular implementation automatically discards `nil` result instances)*

*We don't need to use `dispatch_once()` here since the data we're after is mostly static anyway. Even if you call this code simulanteously from 2 threads, it might execute twice but it won't ever introduce a race condition since we're just gathering data. You **can** use `dispatch_once()` of course, but it's not necessary.*

So `+allAppBundles` gives us an ordered array of `NSBundle`s to work with. This solves the first hurdle in our original problem. You can add this method as a category on `NSBundle` if you'd like.

## Finding an image

Now that we have "easy" access to all app bundles, we can tackle the next hurdle: find the correct instance of the image. This again is relatively easy: 

1. for each bundle in `allAppBundles`
2. try to load the image you want 
3. if found, return image, otherwise continue

That might look like:

```objc
+ (UIImage *)imageNamedGlobally:(NSString *)name
{
    UIImage *image = [UIImage imageNamed:name];
    if (image) return image;

    NSArray *bundles = [NSBundle allAppBundles];
    for (NSBundle* bundle in bundles) {
        NSString *path = [bundle pathForResource:name ofType:nil];
        image = [UIImage imageWithContentsOfFile:path];
        if (image) return image;
    }
    
    return nil;
}
```

As you can see, it first tries: `imageNamed`. This makes sure that the default behavior is still present, before falling back to our *let's search all app bundles* approach.

Good, this works, but it has a downside: you need to fully quantify the image name with the extension, otherwise it won't be found. We can solve this by explicitly adding extra checks for known extensions:

```objc
+ (UIImage *)imageNamedGlobally:(NSString *)name
{
    UIImage *image = [UIImage imageNamed:name];
    if (image) return image;

    NSArray *bundles = [NSBundle allAppBundles];
    for (NSBundle* bundle in bundles) {
        NSString *path = [bundle pathForResource:name ofType:nil];
        image = [UIImage imageWithContentsOfFile:path];
        if (image) return image;

        for (NSString *extension in @[@"jpg", @"png", @"tiff", @"gif", @"tif"]) {
		    NSString *path = [bundle pathForResource:name ofType:extension];
        	image = [UIImage imageWithContentsOfFile:path];
        	if (image) return image;
        }
    }
    
    return nil;
}
```

Surely, the added complexity comes at a cost, since if you now drop the extension from the name the code has to go searching for the correct file. If you do this, make sure the list of extensions is in the most appropriate order (if you have more jpgs, put `jpg` first). But better still, just use a fully quantified name `image.jpg` so you can leave the code out.

One downside of this approach is that if a image is present in more than one bundle, only the first one (in the order of the bundles as returned by `allAppBundles`) is returned. But this usually is not a problem unless you use multiple frameworks with similar embedded image names.

So that that's: just use `+imageNamedGlobally:` instead of `+imageNamed:` and you're set. 

## Swizzling

But suppose you want this behavior everywhere, or you always seem to forgot to use the *Globally* postfix (REALLY?)? In that case, you can swizzle `+imageNamed:`. 

> **Now, a big fair warning!** Since you are changing are core UIKit component, this will have effect in **all** places in your app where `+imageNamed:` is used. This includes not only your code, but all invocations of `+imageNamed:` in any framework or component that's loaded into your app!

With that out of the way, let's find a way have `imageNamed:` always do the *global* search. We'll have to *swizzle* the default implemenation with our own implementation. */cue dramatic music*<br>
I'm going to use [Peter Steinberger](http://twitter.com/steipete)'s [method swizzling](http://petersteinberger.com/blog/2014/a-story-about-swizzling-the-right-way-and-touch-forwarding/) code for that (not included here, you can get it from his post).

```objc
+ (void)makeImageNamedActGlobally
{
    __block IMP imageNamedImp = PSPDFReplaceMethodWithBlock(
    	objc_getMetaClass("UIImage"), 
        @selector(imageNamed:), 
        (UIImage*)^(Class self, NSString *name) {
	        UIImage*(^imageNamed)(NSString* name) = ^(NSString *name) {
	            return ((UIImage*(*)(id, SEL sel, NSString*))imageNamedImp)
	                (self, @selector(imageNamed:), name);
	        };
	        UIImage *image = imageNamed(name);
	        if (image) return image;
	        
	        NSArray *bundles = [NSBundle allAppBundles];
	        for (NSBundle* bundle in bundles) {
	            NSString *path = [bundle pathForResource:name ofType:nil];
	            image = [UIImage imageWithContentsOfFile:path];
	            if (image) return image;
	        }
	        
	        return (UIImage*)nil;
    	}
    );
}
```

The code essentially does the same as the code above, but with a slight twist. As you can see, `PSPDFReplaceMethodWithBlock` provides us with a block for the new implementation and it returns the original implementation. We need that implementation to call the "regular" `imageNamed:`, of course. Since that `IMP` is just a C function, we need to cast it to the correct signature **and** provide a correct `self` and *selector* for the call. I wrapped that part in a block of it's own to make it more readable. Also notice that we can reuse the return value from the call (the original `IMP`) in the block itself by prepending it with `__block` so that the compiler will keep the reference to it until the block executes. The rest of the code is the same as our original implementation since we did not rely on `self` or `imageNamed:` apart from that first call.

You could also have this code in a `+load` method, but I prefer to have it explicitly called in an AppDelegate so that it's clear you're doing magic. 

But again: this approach is probably not the most sound one, but it probably is the most lazy one. 

## One more thing: nibs

For completeness: you can use the same system for Nibs, by the way. Since there's no `nibNamed:` we can create one ourselves:

 ```objc
+ (UIImage *)nibNamed:(NSString *)name
{
    NSArray *bundles = [NSBundle allAppBundles];
    for (NSBundle* bundle in bundles) {
        UINib *nib = [UINib nibWithName:name bundle:bundle];
        if (nib) {
	        return nib;
        }
    }
    
    return nil;
}
```

So that's it. `imageNamedGlobally:` is an easy way out of doing manual bundle searching yourself. 

There's a few optimisations that can be made on this code, like remembering where you find an image so that you don't have to search again for every invocation. But I'll leave those as an exercise to the reader. 
