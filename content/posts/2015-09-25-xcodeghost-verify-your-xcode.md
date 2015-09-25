---
title: "XcodeGhost: verify your Xcode"
created_at: 2015-09-25 15:23:09 +0200
kind: article
---

Recently a malware issue for the iOS app store (which is a rarity in itself) called [XcodeGhost](http://www.macrumors.com/2015/09/20/xcodeghost-chinese-malware-faq/) made its appearance. I'm not going to go into the [gory](http://researchcenter.paloaltonetworks.com/2015/09/novel-malware-xcodeghost-modifies-xcode-infects-apple-ios-apps-and-hits-app-store/) [details](http://researchcenter.paloaltonetworks.com/2015/09/more-details-on-the-xcodeghost-malware-and-affected-ios-apps/), but it boils down to a malware injection through a patched version of Xcode. When building iOS apps with such an Xcode, the app binary is modified transparantly, injecting malware into your app at runtime. Nothing is downloaded from the internet, the malware just gets compiled into your app.

There's not a lot you can do about this, except to make sure that you're using a legit Xcode. You can do this by **never-ever** downloading a version of Xcode from a location other than Apple's, which is either from the Mac App Store, or from [http://developer.apple.com](http://developer.apple.com)) (I know this is easier said than done, saying this from my chair in the middle of super-connected Europe).

<!-- more -->

But, once you have an Xcode installed, it doesn't hurt to verify its authenticity once in a while, especially if you use a build server to deliver your products.

In the [communication](https://developer.apple.com/news/?id=09222015a) Apple released about XcodeGhost, they mention a simple tool to verify your Xcode. Fire up the command line and enter:

```
spctl --assess --verbose /Applications/Xcode.app
```

`spctl` is a command that manages the security assessment policy subsystem of OSX, which is used to define the system software policy (what you can install -- think *GateKeeper*) and code signing requirements.

If you get back a response which includes `accepted` (e.g. `/Applications/Xcode.app: accepted source=Mac App Store` or `/Applications/Xcode.app: accepted source=Apple`) you're in the safe zone and Xcode is not compromised. If you get back something else, chances are that your Xcode is compromised. It doesn't necessarily means that: if you accidentally edited a header file in the .app bundle, the assessment tool will also notice this and will report an error. 
However, if you see a mention of `CoreServices` passing by in the output of `spctl`, you're probably going to have a problem. By the way, the command can take a while so don't worry if it doesn't pony up an answer right away.

In any case, if you get an error it's a good idea to download a fresh copy to be safe. Verify the downloaded app again, to make sure you updated it correctly.

## Jenkins

Now, you don't want to be doing this manually on a regular basis, especially on a build server. At [iCapps](http://icapps.com), we have more than one Xcode version on the server in order to support older projects (or until they are upgraded to newer versions of Xcode). So what we did was create a small shell script which fires off the `spctl` command. That script takes a path to any Xcode.app as an argument. So we have that script run each morning to verify all of our Xcode versions. The script terminates with a faulty exit code if the `spctl` output doesn't contain `accepted`, causing that job to fail. The failed job sends of an email to the development team so we get notified pretty quick in case something would go wrong.

{% img center http://c.inferis.org/image/1x2M1L2u2O3J/Untitled-1.png %}

The script itself is pretty simple, like I said:

```sh
#!/bin/bash

echo "Validating '$1'. This can take a while."
OUTPUT=`spctl --assess --verbose $1 2>&1`

echo $OUTPUT

if [[ $OUTPUT =~ accepted ]]; then
	echo "'$1' validates just fine."
	exit 0
fi;

echo "'$1' does not validate."
exit 1
```

This should be pretty obvious. There's one thing to point out: the `spctl` command outputs it's assessment on *stderr* so we need to pipe that output to *stdout* for the backtick invocation to be able to grab it. You do this by adding `2>&1` to your command invocation (standard error = file number 2, standard output = file number 1). If you don't do this, the script fails even though the command finds no problem.

We added this script to a git repo, set up a jenkins job with that repo and had it run periodically, in our case each morning at 7am:

{% img center http://c.inferis.org/image/2P3E1K2W030w/Image%202015-09-25%20at%204.00.51%20PM.png %}

But you could schedule this however you wanted, of course.

*Why use a repo and not install the script on the server directly*, you ask? First of all it's a lot easier to keep track of any changes, and in case it needs changing you can do the changes locally, try them out and push to the repo. The server is updated automatically at the next validation job run.

And that job, all it does is invoke the script:

{% img center http://c.inferis.org/image/0P2k3Z2S3c1Y/Image%202015-09-25%20at%203.58.29%20PM.png %}

The parameter obviously changes for each Xcode install: just change the path to the Xcode.app you want to verify.

Finally, set up a post build email notification so that you actually get a warning when something goes south:

{% img center http://c.inferis.org/image/2b2l1W432O07/Image%202015-09-25%20at%204.02.57%20PM.png %}

And that's it. You're now a little bit safer in this cruel, cruel world. Not entirely safe though: if somebody gains access to your server and messes with your Xcodes they'll probably find and disable these jobs too (if only that: if they are resourceful enough, they might hack into spctl too). But this is better than nothing at all. 

The best part: if you 🌟*Do Things Right*🌟 (which includes *Not Ever Turning GateKeeper Off*), this should never bother you. 😉

## Fastlane

And oh, the fabulous [Fastlane](http://fastlane.tools) toolchain by [Felix Krause](http://twitter.com/krausefx) also provides a `verify` action that you can use in your Fastfiles, making sure that you verify the Xcode you're going to use for that build is valid. The build will take longer of course, but it's the price to pay for ensured security. So if you're using Fastlane and want to make sure your builds are "safe of malware" add this action to your Fastfile.



