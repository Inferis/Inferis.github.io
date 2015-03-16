---
layout: post
title: "Easy Revealing"
created_at: 2014-12-1 00:34:09 +0200
comments: true
categories:
- development
- debugging
- ios
kind: article
---

I have a confession to make: I like [Reveal](http://revealapp.com). It's such a great tool to discover why your UI doesn't appear as it should be. It's such a great way to get a decent look at the view hierarchy in your iOS app.

Initially, loading Reveal required you to add the reveal framework to your project before running. While not a hassle, it was rather suboptimal because you had to remove it again before shipping the app.

But when you run your project in the simulator, there's an easier way. Have it automatically start up the Reveal server, so that you don't have to connect manually, and don't have to pollute your project with a debugging lib. Why only in the Simulator? Well, the technique requires the dynamic loading of `libReveal.dylib`. This is possible on your Mac but not on your iOS device. And the Simulator runs on your Mac, so we can use this trick to load the Reveal lib at runtime without prerequiring it in the project (to be fair, you can dynamically load libs on the device, but you'd still need to add them to your project).

So let's do that. First on: some LLDB tricks.

<!-- more -->

## Making custom LLDB commands

You might not know this, but you can extend LLDB by loading Python scripts. In those scripts you can define functions which can be used directly when you're debugging. That's pretty handy! So we'll use this to create some shortcuts to load the

So create a folder somewhere that can contain your LLDB scripts. I created a `lldb` folder in my home folder, but you can place it anywhere you want.

Then, create a `reveal.py` in that folder, and give it the following contents:

```python
# require the lldb lib to interact with LLDB
import lldb

# this is called when the file is added to the script runtime
# we'll invoke a lldb command that links the python functions to actual LLDB commands
# in this case, we're adding reveal_start_sim and reveal_stop
# note: the other functions in this file are no accessible from LLDB.
def __lldb_init_module (debugger, dict):
  debugger.HandleCommand('command script add -f reveal.reveal_start_sim reveal_start_sim')
  debugger.HandleCommand('command script add -f reveal.reveal_stop reveal_stop')

# This is the main entry point. This will load the reveal lib and then send a notification so that it will start
def reveal_start_sim(debugger, command, result, internal_dict):
  print "Installing reveal in the simulator"
  reveal_load_sim(debugger)
  reveal_start(debugger)

# Loads the libReveal.dylib from the Reveal app.
def reveal_load_sim(debugger):
  debugger.HandleCommand('expr (void*)dlopen("/Applications/Reveal.app/Contents/SharedSupport/iOS-Libraries/libReveal.dylib", 0x2);')

# Sends a notification to the reveal server so that it actually starts
def reveal_start(debugger):
  debugger.HandleCommand('expr [(NSNotificationCenter*)[NSNotificationCenter defaultCenter] postNotificationName:@"IBARevealRequestStart" object:nil];')

  # Sends a notification to the reveal server so that it stops (if you'd want that)
  def reveal_stop(debugger):
  debugger.HandleCommand('expr [(NSNotificationCenter*)[NSNotificationCenter defaultCenter] postNotificationName:@"IBARevealRequestStop" object:nil];')
```

There's nothing more to it. We expose two new commands `reveal_start_sim` and `reveal_stop`. Commands we can actually use during debugging.

Let's try this. Fire up your favorite iOS project - be sure to select to run on the Simulator. Run the app. Now break the app by pressing `^⌘Y`. This will give you the `(lldb)` prompt. Now load your python script by invoking the following command:

```
command script import ~/lldb/reveal.py
```

This will tell LLDB that we'd like the `reveal.py` script loaded into LLDB. The module will be loaded and thanks to the init there, we've just added two commands to use. There won't be any feedback, but now you can try and load the reveal lib:

```
reveal_start_sim
```

This will give you something like this:

{% img center http://cl.ly/image/062A1a230h35/Image%202014-12-11%20at%2012.29.05%20am.png 600 %}

After that, hit `^⌘Y` to continue the app (or just type `continue`). Now you can try to fire up the Reveal Client app, and connect to your app:

{% img center http://cl.ly/image/2M2m0j1u0p1O/Image%202014-12-11%20at%2012.25.57%20am.png 600 %}

Success!

## Loading the script by default

Now always having to load the python script is a bit cumbersome. Luckily for us, LLDB has a mechanism to do this by default. So we can always load our reveal script so that we can have it readily available when we need it.

So how do you do this?

It's pretty simple: make an `.lldbinit` file in your home folder. This file is read by LLDB when it is started (thus: everytime you debug an app). As an aside: you can also make an `.lldbinit-Xcode` which will only be read when debugging in Xcode.

In this `.lldbinit`, you can place any regular LLDB commands. In this case, we'll use this to import the python script as we did above. So the file basically looks like this:

```
command script import ~/lldb/reveal.py
```

Save the file, and now restart the debugger for your app. Try entering `reveal_start_sim` again and you'll see that it works. No need to manually load the python file again.

## Starting reveal at startup

Now wouldn't it be even better if we could have the Reveal server start by default? No need to break the app, run the command and continue. Xcode can do this for us, with a breakpoint.

Go to your app delegate file (or any other class you'll know that runs early in your app lifecycle), and add a new breakpoint. Then edit the breakpoint:

{% img center http://cl.ly/image/0Q3m0Z1i0223/Image%202014-12-11%20at%2012.37.25%20am.png 600 %}

Basically:

* add an action of type 'debugger command'. In the textfield below, enter `reveal_start_sim` (which, thanks to the magic above, is present).
* tick on "automatically continue after evaluating actions"

This breakpoint will be hit when you start your app but won't halt. It will execute the command specified, starting the Reveal server and then just continue running along.

After you tried this, rerun your app. Switch back to Reveal and you'll see that it can connect to your app running in the Simulator. Great success!

## Finally

You can now use this technique in every project. Either using the breakpoint approach for regular Reveal debugging, or just break the app, run the `start_reveal_sim` command and continue for occasional debugging. Up to you.

You can also use the techniques described about to extend LLDB to your own needs. You can leverage `.lldbinit` by providing custom aliases or load external scripts. You can use those external scripts to do more complex debugging should you require to.

For example, [Facebook's Chisel](https://github.com/facebook/chisel) uses these techniques to extend LLDB with a load of commands (highly recommended).

On a related note, it might be worthwhile to read up on LLDB techniques by reading [this article](http://www.objc.io/issue-19/lldb-debugging.html) in objc.io's [19th installment](http://www.objc.io/issue-19/) (which is all about debugging). Some neat tricks in there.

And finally, thanks to Reveal for an awesome app. Xcode6's Debug View Hierarchy is interesting but more limited than Reveal (and it doesn't always yield the correct results). Reveal rocks.
