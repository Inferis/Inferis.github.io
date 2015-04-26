---
title: "Using interfaceOrientation with iOS8 transitions"
created_at: 2015-04-27 9:20:30 +0200
kind: article
proofreaders: cmaddern@, cocoakevin@
---

Working on an app today, I needed a way to respond to rotation events in a view controller. Since iOS8, the rotation APIs in `UIViewController` are deprecated:

```objc
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration NS_DEPRECATED_IOS(2_0,8_0, "Implement viewWillTransitionToSize:withTransitionCoordinator: instead");
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation NS_DEPRECATED_IOS(2_0,8_0);

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration NS_DEPRECATED_IOS(3_0,8_0, "Implement viewWillTransitionToSize:withTransitionCoordinator: instead");
```

As you can see, they want you to use `viewWillTransitionToSize:withTransitionCoordinator:` instead.

So, no problem, we'll just implement that method. The only thing is: what if you need to know those "toInterfaceOrientation" or "fromInterfaceOrientation" value from the old APIs?

<!-- more -->

Because: what if you do want the old behavior? Not everybody has the luxury of going iOS8 only; sure, you can still use the old callbacks - for now. They won't get called once you implement `viewWillTransitionToSize:withTransitionCoordinator:`, but you might want fallback behavior in addition to the new behavior.

And anyhow, I thought I would be a good exercise to see how we could use this new callback to derive our new interface orientation. Adaptive UI and all, but sometimes is just darn handy to know how your device is held.

Turns out, it's not very hard, but it's not a trivial amount of code.

I looked up session 214 of WWDC 2014: *View Controller Advancements in iOS8* by Bruce Nilo (📹 [video](http://devstreaming.apple.com/videos/wwdc/2014/214xxq2mdbtmp23/214/214_hd_view_controller_advancements_in_ios_8.mov) & 📈 [slides](http://devstreaming.apple.com/videos/wwdc/2014/214xxq2mdbtmp23/214/214_view_controller_advancements_in_ios_8.pdf)). It's a very interesting talk since he goes into all of the changes they've made, including the changes in rotation behavior.

A particular slide peaked my interest:

{% img center https://s3.amazonaws.com/f.cl.ly/items/0r1R2E132l3n2P1O472S/rotation.jpg 750 %}

Notice the `[self orientationFromTransform:[t targetTransform]]`. He doesn't go into it (obviously), but I knew what to do.

With some experimentation, it looks like the transform you get via `targetTransform` is the rotation transform resulting from rotating your device. So if you turn from portrait to landscape it will be a 90º (or `π/2` or even `M_PI_2`) rotation, and if you go from landscape left to landscape right it will a 180º rotation. Depending on the direction of the rotation, the angle will be either positive or negative.

So we can use this `targetTransform` to go from the current interface orientation to the target interfaceorientation: we just need to "add" the rotation to the interface orientation value.

## Some work, some math

The approach we'll be taking will be somewhat generic. Generic because we'll calculate the number of 90º "segments" we'll have to go through, and switch to the "next" interfaceorientation for each segment. In the end, we'll have the correct orientation.

This sounds easier than it proved to be. The first problem is calculating how many segments we need from the transform. We can calculate this from the [affine transform](https://developer.apple.com/library/ios/documentation/GraphicsImaging/Reference/CGAffineTransform/index.html#//apple_ref/c/tdef/CGAffineTransform), which is - and you may or may not know this - a struct representing a matrix. In code, this looks like this:

```objc
typedef struct CGAffineTransform CGAffineTransform;
struct CGAffineTransform {
  CGFloat a, b, c, d;
  CGFloat tx, ty;
};
```

This is a representation of this matrix:

$$\\begin{bmatrix}
  a & b & 0 \\\\
  c & d & 0 \\\\
  tx & ty & 1
 \\end{bmatrix}$$

This transformation matrix is used to transform the coordinates of the source point `(x,y)` to a target point `(x',y')`:

$$\\begin{bmatrix}
  x' & y' & 1
 \\end{bmatrix} = \\begin{bmatrix}
   x & y & 1
  \\end{bmatrix} \times \\begin{bmatrix}
   a & b & 0 \\\\
   c & d & 0 \\\\
   tx & ty & 1
  \\end{bmatrix}$$

For those not well versed in matrix algebra: you traverse each item of the source 1x3 matrix and multiply it with the corresponding row, and then adding these results together. You do this for each column so that you end up with a new 1x3 matrix.

Which results in the following equations:

$$x' = ax + cy + tx$$
$$y' = bx + dy + ty$$
$$1 = 0x + 0y + 1$$

That last one is useless, so we can ignore it.

CGAffineTransform is merely a struct representing the useful values of this matrix, and the transforms you use in your code are just representations of this matrix which is used [by Quartz](https://developer.apple.com/library/mac/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_affine/dq_affine.html) to perform the calculations using the equations above. In effect: the matrix *links* two coordinate systems — it specifies how points in one coordinate system map to points in another.

So back to our rotation: how does the [matrix for a rotation](http://en.wikipedia.org/wiki/Rotation_matrix) look like? Like this (where `α` is the angle of the rotation) (for Quartz):

$$\\begin{bmatrix}
 cos \alpha & sin \alpha & 0 \\\\
 -sin \alpha & cos \alpha & 0 \\\\
 0 & 0 & 1
\\end{bmatrix}$$

So when we want the angle from this matrix, we'd need to reverse the the matrix calculations. This is as simple as taking any of the a/b/c/d matrix elements and reverse it:

$$\alpha = acos(a) = acos(d)$$
$$\alpha = asin(b) = -asin(c)$$

Now using `acos` or `asin` to get the angle has a tiny problem: each input can result in 2 solutions (this is due to how sine and cosine functions work, of course). The `atan2` function doesn't have this problem since it uses two inputs to calculate the result. It's also better in our case since an affine transform can also contain a scale transform, which has no impact on the result if we use `atan2`. So here we go:

```objc
angle = atan2f(b, a) // or atan2(d, -c)
```

*Watch out, the atan2 function takes the `y` parameter first -> RTFM!*

If you want to know more about the maths behind this, check out [Euler angles](http://en.wikipedia.org/wiki/Euler_angles) and [this paper](http://staff.city.ac.uk/~sbbh653/publications/euler.pdf).

Back to our calculations: we actually don't want the angle, but the number of 90º segments of our rotation:

```objc
CGFloat angle = atan2f(transform.b, transform.a);
NSInteger multiplier = (NSInteger)roundf(angle / M_PI_2);
```

We explicitly round the division by `π/2`; relying on the implicit *CGFloat* to *NSInteger* conversion isn't good enough since it just takes the integral part of the float (in effect `floorf(...)`) which is *not* what you want.

Note that the angle of rotation will be the inverse of how you rotate the device: if you rotate the device clockwise, the angle of the transform will be negative (and thus counter-clockwise): the transform "counters" the rotation to get back to where we were before the rotation (albeit with other dimensions).

## interfaceOrientation: from ➢ to

Now that we know the angle and multiplier, it's time to transform our interface orientation according to this angle. This isn't hard, but it is cumbersome due to how the `UIInterfaceOrientation` enum is defined:

```objc
// Note that UIInterfaceOrientationLandscapeLeft is equal to
// UIDeviceOrientationLandscapeRight (and vice versa). This is because rotating
// the device to the left requires rotating the content to the right.
typedef NS_ENUM(NSInteger, UIInterfaceOrientation) {
    UIInterfaceOrientationUnknown            = UIDeviceOrientationUnknown,
    UIInterfaceOrientationPortrait           = UIDeviceOrientationPortrait,
    UIInterfaceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
    UIInterfaceOrientationLandscapeLeft      = UIDeviceOrientationLandscapeRight,
    UIInterfaceOrientationLandscapeRight     = UIDeviceOrientationLandscapeLeft
};
```

As you can see, it's just a mapping of the corresponding `UIDeviceOrientation` values, which are defined like this:

```objc
typedef NS_ENUM(NSInteger, UIDeviceOrientation) {
    UIDeviceOrientationUnknown,
    UIDeviceOrientationPortrait,        // Device oriented vertically, home btn -> bottom
    UIDeviceOrientationPortraitUpsideDown, // Device oriented vertically, home btn -> top
    UIDeviceOrientationLandscapeLeft,   // Device oriented horizontally, home btn -> right
    UIDeviceOrientationLandscapeRight,  // Device oriented horizontally, home btn -> left
    UIDeviceOrientationFaceUp,          // Device oriented flat, face up
    UIDeviceOrientationFaceDown         // Device oriented flat, face down
};
```

*As an aside: You'll notice that there's no equivalent interface orientation for the `UIDeviceOrientationFaceUp` and `UIDeviceOrientationFaceDown`, because they make no sense for the interface orientation: it remains the same whether you have the device face up or face down.*

I show this because my first idea was to *cycle* through the orientation values by adding or substracting 1 from each value, wrapping around a the minimum and maximum values of the enum. But looking at these definitions: this is not possible. First of all, the interface orientation values are based on the device orientation values, which have 2 more values we don't care about. And secondly, even if we could use the natural order of the device orientation values, they are shuffled around in the `UIInterfaceOrientationLandscapeLeft` and `UIInterfaceOrientationLandscapeRight` switcharoo in the definition of `UIInterfaceOrientation`.

The net result is that we need to resort to an ugly switch statement:

```objc
if (multiplier < 0) {
    // clockwise rotation
    while (multiplier++ < 0) {
        switch (orientation) {
            case UIInterfaceOrientationPortrait:
                orientation = UIInterfaceOrientationLandscapeLeft;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                orientation = UIInterfaceOrientationPortraitUpsideDown;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                orientation = UIInterfaceOrientationLandscapeRight;
                break;
            case UIInterfaceOrientationLandscapeRight:
                orientation = UIInterfaceOrientationPortrait;
                break;
            default:
                break;
        }
    }
}
else if (multiplier > 0) {
    // counter-clockwise rotation
    while (multiplier-- > 0) {
        switch (orientation) {
            case UIInterfaceOrientationPortrait:
                orientation = UIInterfaceOrientationLandscapeRight;
                break;
            case UIInterfaceOrientationLandscapeRight:
                orientation = UIInterfaceOrientationPortraitUpsideDown;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                orientation = UIInterfaceOrientationLandscapeLeft;
                break;
            case UIInterfaceOrientationLandscapeLeft:
                orientation = UIInterfaceOrientationPortrait;
                break;
            default:
                break;
        }
    }
}
```

When I said ugly, I meant ugly. 😭 But there's no real other way to do this, I guess: if there is, please let me know.
I initially thought this would also be a bit more robust future wise (you never know when Apple adds another interface orientation), but this code is just as brittle as the *addition based* code I intentionally wanted to use.

## Finally

The final resulting function:

```objc
- (UIInterfaceOrientation)orientationByTransforming:(CGAffineTransform)transform fromOrientation:(UIInterfaceOrientation)c
{
    CGFloat angle = atan2f(transform.b, transform.a);
    NSInteger multiplier = (NSInteger)roundf(angle / M_PI_2);
    UIInterfaceOrientation orientation = self.interfaceOrientation;

    if (multiplier < 0) {
        // clockwise rotation
        while (multiplier++ < 0) {
            switch (orientation) {
                case UIInterfaceOrientationPortrait:
                    orientation = UIInterfaceOrientationLandscapeLeft;
                    break;
                case UIInterfaceOrientationLandscapeLeft:
                    orientation = UIInterfaceOrientationPortraitUpsideDown;
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    orientation = UIInterfaceOrientationLandscapeRight;
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    orientation = UIInterfaceOrientationPortrait;
                    break;
                default:
                    break;
            }
        }
    }
    else if (multiplier > 0) {
        // counter-clockwise rotation
        while (multiplier-- > 0) {
            switch (orientation) {
                case UIInterfaceOrientationPortrait:
                    orientation = UIInterfaceOrientationLandscapeRight;
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    orientation = UIInterfaceOrientationPortraitUpsideDown;
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    orientation = UIInterfaceOrientationLandscapeLeft;
                    break;
                case UIInterfaceOrientationLandscapeLeft:
                    orientation = UIInterfaceOrientationPortrait;
                    break;
                default:
                    break;
            }
        }
    }

    return (UIInterfaceOrientation)orientation;
}
```

It's also available as [a gist](https://gist.github.com/Inferis/26ded6e1e8e625b3cd67), by the way. And I'll leave the Swift version as an exercise to the reader. 😉

## Postscriptum

I later refactored the code not to rely on the interface orientation, which is probably better anyway; but having done the exercise I did want to share it with the world. I did not find an 'out-of-the-box' solution right away, which either shows that it's a hard problem to tackle or that it's not really a problem needed to be tackled. But here I am, having tackled it, so sharing it for anyone else to use wouldn't hurt anyone, right?

And finally, I'll admit this: I learned a lot of the math behind this in high school and university, but had to actively relearn it all when researching this code and blogpost. Not using these mathematics (apart from the obvious ones you'd use in daily life I guess), resulted in the knowledge either being gone or stuck somewhere in the outback of my brain. However, it was fun to get reacquainted with this knowledge anyway. And while I found an actual usable code solution before diving into the maths myself, I'd really like to understand what I'm actually doing instead of just relying on a copy-paste solution.

So yeah: learning for fun **and** profit. Who knew?
