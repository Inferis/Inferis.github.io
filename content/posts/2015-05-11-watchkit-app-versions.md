---
title: "Watchkit app versions"
created_at: 2015-05-11 18:15:28 +0200
kind: article
---

I came across [this article](http://ikennd.ac/blog/2015/05/build-time-cfbundleversion-values-in-watchkit-apps/) by Daniel Kellett this morning. I had seen him tweet about it too, but checking my feeds (yeah, I still do that, albeit not daily) I noticed he also made a post about it.

Having toyed a lot with build configurations and their associated settings configuration, I was curious how he solved the issue.

I'd have to concur with Daniel: the solution is horrible. 8 Steps to get this working, with aggregate targets and disabling of parallelization of the project: Not Good™.

But my interest was piqued, and so I tried to recreate his problem (not hard) and find a better solution. I assumed it would still be hacky, but less hacky than Daniel's "Horrible" solution.

<!-- more -->

## Step 0

Create iPhone app, add Watchkit extension. In this case, just an empty app that displays the version of the app in a label (both on the watch and the phone). Or use existing iPhone + Watch apps.

## Step 1

In the root of your project, add a shell script that we'll use to define the version settings:

{% img center http://c.inferis.org/image/2J2p3L1Q2o30/Image%202015-05-11%20at%207.05.55%20pm.png 750 %}

The contents of the scripts are similar to the script Daniel creates:

```sh
#!/bin/sh

S=$(date "+%S")
M=$(date "+%M")
D=$(date)

GENERATED_BUNDLE_VERSION=${S}
GENERATED_BUNDLE_SHORTVERSION=${M}.${S}

SRCROOT=${SRCROOT:-.}

echo "// Generated: ${D}" > "${SRCROOT}/Version.xcconfig"
echo "GENERATED_BUNDLE_VERSION = ${GENERATED_BUNDLE_VERSION}" >> "${SRCROOT}/Version.xcconfig"
echo "GENERATED_BUNDLE_SHORTVERSION = ${GENERATED_BUNDLE_SHORTVERSION}" >> "${SRCROOT}/Version.xcconfig"

echo "Generated: ${GENERATED_BUNDLE_VERSION} & ${GENERATED_BUNDLE_SHORTVERSION}"
```

This script generates a file `Version.xcconfig` in the root of the project, containing two build settings: `GENERATED_BUNDLE_VERSION` and `GENERATED_BUNDLE_SHORTVERSION`.

This is slightly different since we use the date of the system here to generate the version numbers, and Daniel's approach is more *real life* than mine using the git commit hash, but I wanted something that would change regularly for testing purposes. You'll obviously want to change the source for `GENERATED_BUNDLE_VERSION` and `GENERATED_BUNDLE_SHORTVERSION` to something more sensible.

## Step 2

Integrate the script to your project, not as a *Build Phase*, but as a *Build Pre-Action*. You can find these under the schemes of your project:

{% img center http://c.inferis.org/image/161A0v25191W/Image%202015-05-11%20at%207.14.59%20pm.png 750 %}

You can define pre-actions and post-actions for every "Product Action" of the project. This is defined in the scheme, so you'll have to do this for all schemes defined in the project where you want this to happen. In our case, this is twice since Xcode creates a default scheme for the app and a scheme for the watchkit app (basically because it's a lot easier to run them that way).

This is also why we made a script; you could also paste the code right into the action window textarea like Daniel did. That works as good, but then you'd have to change the code for every scheme when you want a change (which is at least twice in our case), so I prefer to put scripts in their own file. It's also easier to edit them this way.

Don't forget to specify to "take the buildsettings" from the appropriate target, otherwise the `$SRCROOT` variable we use in the script (and to invoke it) is not set.

## Step 3

Build the project. This should generate a `Version.xcconfig` along side the `Version.sh` file. Add this xcconfig file to the project:

{% img center http://c.inferis.org/image/1g1L1B0k0w0e/Image%202015-05-11%20at%207.23.24%20pm.png 750 %}

Don't add it to a target (uncheck all the boxes); we don't want it included in a build product, but it needs to be in the project... because we want to use it as base setting for our project's configurations:

{% img center http://c.inferis.org/image/07153B0F1Y25/Image%202015-05-11%20at%207.28.28%20pm.png 750 %}

This makes sure that the settings defined in the config file are usable in our project. Since we add them at project level, they will be present for *every target* which is **exactly** what we want. You can verify this by looking at user defined settings in *Build Settings* (all the way to the bottom):

{% img center http://c.inferis.org/image/3r0a3s1h1Z3g/Image%202015-05-11%20at%207.49.08%20pm.png 675 %}

## Step 4

Now we need to incorporate the generated settings into the Info.plist files. By default, the *Expand Build Settings in Info.plist File* is set to `YES`, so we don't have to take precautions for this like Daniel did, because his version settings were in a header file. I had no clue that you could do this, by the way, and it allows for interesting approaches for other problems. 😍

So for every `Info.plist` file, change the hardcoded `CFBundleVersion` and `CFBundleShortVersionString` values to the values we get from the settings, like this:

```xml
<plist version="1.0">
<dict>
   ...
   <key>CFBundleShortVersionString</key>
   <string>$(GENERATED_BUNDLE_SHORTVERSION)</string>
   <key>CFBundleVersion</key>
   <string>$(GENERATED_BUNDLE_VERSION)</string>
   ...
</dict>
```

This will look like this in when you inspect the project:

{% img center http://c.inferis.org/image/2R383y10101i/Image%202015-05-11%20at%207.57.25%20pm.png 400 %}

## Step 5

There is no step 5. Well, except for: build your app (I have no Watch yet so I can't show you a fancy hairy wrist with the demo app running), and continue developing.

## Caveat

Now once in a while you might get the original error because thanks to (what I presume to be) Xcode caching things: it seems the changes to the Version.xcconfig file aren't picked up right away or Xcode doesn't notice it was changed.

{% img center http://c.inferis.org/image/2s270O1i462K/Image%202015-05-11%20at%208.06.53%20pm.png 750 %}

It seems that this also has to do with the parallelized builds: it looks like Xcode is running the pre-action scripts for each run it can parallellize, causing slight changes in the resulting values.

Now, this is more an obvious problem for this demo project since the values change so often but in a real world case this won't happen as much (see Daniel's script, for example). And when this occurs, you can clean the project and rebuild in which case all plist files will be updated. But still, this does not make me happy and for larger project can cause quite a bit of delay.

Additionally, the updated values sometimes aren't picked up directly due to the same caching playing its role. So most of the time you don't see the updated version inside the app unless you clean or reopen the project. This is usually not a problem since the use case for these versions are only applicable for release builds, but it's not pretty.

## Step 1 (🙈)

But both problems can be remedied pretty simple by augmenting our script with 2 lines:

```sh
# finishing touch
find "$SRCROOT" -name Info.plist -exec touch "{}" \;

# haste makes waste
sleep 0.5
```

The first line looks for all Info.plist files under the source root and *touches* them. Xcode will pick them up as changed and incorporate the updated version settings into the build.

The second line waits a bit before continuing. This adds an extra half second to your build but this fixes the problem with the parallellized builds: by waiting a bit before continuing, we make sure the last change is picked up nicely for all build runs.

Now, these two lines are the icing on the case and shouldn't be really necessary for a real world scenario where the versions don't change often. But in case these issue do bite you, here's a solution.

## Conclusion

There's still no "out of the box" solution for this version numbering issue. I don't know why you need to set the version of each extension manually while Xcode could be doing this itself since it's mandatory anyway. The steps above make it a bit simpler to have a general system of version numbers for your app and your (WatchKit) extensions, using tools we have to our disposal anyway.

Having access to the build steps like Daniel asks would be nice but I don't think it's necessary for this problem, because we can fix it with plain old configuration. The only downside is that you need to add the script for each scheme you have in your project, but that's (IMHO) a small price to pay.

Thanks again to Daniel for the original post which I thought was very interesting, and by which I learned that you can use preprocessing for `Info.plist` files too: something I hadn't discovered before. It's always nice to learn something new. 🌟
