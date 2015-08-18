---
title: "Sound debugging"
created_at: 2015-08-18 17:52:27 +0200
kind: article
---

I'd like to mention a trick I use often while debugging, a trick I learned from my good friend [Markos Charatzas](https://twitter.com/qnoid): triggering a sound when a breakpoint is hit. It's a pretty simple but useful trick, especially if you're debugging repeatable actions and you want to know when they happen.

I'm talking about this:

<!-- more -->

<center><iframe src="https://player.vimeo.com/video/96070920?color=aaafb3" width="600" height="338" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe><br><sub><a href="https://vimeo.com/96070920">Sound Debugging - Markos Charatzas</a> from <a href="https://vimeo.com/n
sconf">NSConference</a> on <a href="https://vimeo.com">Vimeo</a>.</sub></center>

If you don't have 11 minutes to watch the video (but please do, it's interesting!), here's short recap.

When setting a breakpoint in Xcode, you can set a number of options on the breakpoint:

{% img center http://c.inferis.org/image/2E3f2n2k2q0k/Screen%20Shot%202015-08-18%20at%2015.49.17.png 520 %}

1. **the condition**: an expression which is evaluated each time the breakpoint is hit; when the expression yields a truthy value, the breakpoint is actually hit. If it returns falsy, it's like nothing has happened.

2. **Ignore((: the number of times the breakpoint should be ignored. This is useful when I know the code in a loop goes ok for let's say the first 100 times, but fails the 101st or 102nd time. You can set a breakpoint before the offending line of code, have it ignored 100 times and then trigger the 101st time. Saves you a lot of "continue"s. 

3. Action: you can add one or more actions to the breakpoint. You've got the following options: 

	1. run an apple script {% img right http://c.inferis.org/image/3K3k2v0b0Y3n/Screen%20Shot%202015-08-18%20at%2015.55.54.png 183 %}
	2. capture a GPU frame
	3. run an LLDB command
	4. Log a message to the console
	5. run a shell command
	6. play a sound

4. finally, you can specify if the breakpoint **automatically continues** after it has evaluated all the actions. If you don't have any actions, this is a rather silly option since nothing will happen, but it's very useful when you do specify actions.

## Sound

The ones I used most are `run an LLDB command`, `log a message` and `play a sound`. The first two are pretty handy for adding ad-hoc logging to you app. No need to add manual `NSLog()` or `print()` statements: you can just log from a breakpoint you can set on the fly. 

Finally: there's `play a sound`. There's a number of sounds you can choose from:

{% img center http://c.inferis.org/image/2w1o213J020c/Screen%20Shot%202015-08-18%20at%2016.05.11.png 509 %}

When setting a *sound* action, it does exactly what you'd expect: it plays the sound you selected. Some of the sounds are long, some are short. There's one little caveat: it blocks your program while it plays the sound! So depending on where you place the sound, this action can have a serious "performance" impact on your app. That's why I usually go for short sounds (Morse, Tink, Bottle, Frog, Pop) for breakpoints which tend to get hit pretty frequently, and longer ones for "once in a while" breakpoints.

The cool thing about this technique is that you can actually hear what your code is doing (much to annoyance of your coworkers, so put headphones one when using this). If some concurrent code is not doing what you are expecting it to do, place some sound breakpoints in strategically placed locations in your code and you can just hear what is happening. If you don't get the sound pattern you expected, something is not going how you planned it and you can investigate further from there (with more information, because you *do* know now how the order of execution is). You can also log this to the console (remember, you can have more than 1 action per breakpoint) for later introspection, but I've found that the listening and analysing the *music* you code plays is a very valuable debugging technique.

I usually have one or more sound breakpoints in my concurrent "backend" code (when a network requests returns, for example, or after a long calculation), and then another one (or more) in UI facing code, so that you know that background piece of code has it's effect on the UI.

Or you can set it in any view related code, for example in the `-updateConstraints` or `-viewDidLayoutSubviews` to know when what happens. 

Like I said, it's a very useful technique since it allows you to use another sensory trigger to gather information, which is always a good thing. 

Let's just hope Apple doesn't add a *smell* action to that list. 😳



