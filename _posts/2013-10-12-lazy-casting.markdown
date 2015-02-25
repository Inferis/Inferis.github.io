---
layout: post
title: "Lazy casting"
date: 2013-10-12 14:33
comments: true
categories: 
- objc
- dev
---

Just a quick tip, this one.

In Objective-C, like in every strongly typed language, sometimes you need to cast something to another type:

``` objc
	ModalViewController* modalController = (ModalViewController*)self.parentViewController;
```

Well, you don't have to, but you get a pesky warning if you don't. The code will work fine, but warnings are ugly:

{% img  http://cl.ly/image/1P0B0G3Y0K2K/Image%202013.10.12%2014%3A37%3A17.png 700 %}

Also, this is conveying the same information twice: first you have the variable type, and then you repeat it in the cast. Just to satisy the compiler.
And since we're talking about Objective-C here, a language which is dynamic enough that the actual type of the object at runtime could be something not even remotely the same as the type intended by the developer writing this code. So the cast is just "syntactic sugar" to make your code more safe and more obvious. 

But also, this being Objective-C code, type names can be quite long. `ModalViewController` is not too long in this case, but if you're working with a `SelectedPriceListItemViewController` for example, or a `EnhancedCollectionViewFlowLayout` things can get a bit nasty, rendering your code as unreadable with the cast as it would be without the cast (but with the warning).

``` objc 
	SelectedPriceListItemViewController* controller = (SelectedPriceListItemViewController*)[self.pricelistViewController 
			viewControllerForItem:item ofState:kStateSelected];
```

This is long enough as it is, and the cast is not helping.

So what do you do? Use `id`. Just cast to `id` (`id` means "a reference to an Objective-C object of unknown class"). So you can happily cast to `id`, and the compiler will no longer complain for the assignment because you can assign an object of type `id` to a variable of any other object type. So our lengthy cast becomes much shorter, and much more readable. 

So we get:

``` objc
	ModalViewController* modalController = (id)self.parentViewController;
```
and it compiles without warning:

{% img http://cl.ly/image/0r2U3u0w0G0B/Image%202013.10.12%2015%3A05%3A45.png 700 %}

_(look ma, no warning!)_

Or for the example with the longer type names, this becomes:

``` objc 
SelectedPriceListItemViewController* controller = (id)[self.pricelistViewController 
		viewControllerForItem:item ofState:kStateSelected];
```
Which is still long, but quite a bit more readable (since the type information is there in the beginning of the line anyway).

While you can misuse it in other places - where the type of the object you are assigning to is much less obvious - I still think that the advantage you get from the cleaner code is more beneficial for readablity than the "missing" type information. If you're writing your code so that you *need* to see the type information anyway, you've got other problems than that, IMHO. 