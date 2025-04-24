# Working principles

1. [Speak like a Martian](#SpeaklikeaMartian)
2. [No Martian left behind](#NoMartianleftbehind)
3. [Let your code history speak for itself](#Letyourcodehistoryspeakforitself)
4. [Measure twice, cut once!](#Measuretwicecutonce)
5. [Who watches the watchmen?](#Whowatchesthewatchmen)

Those are our principles, and if you don't like them... well, you know how that goes.

## 1. <a name='SpeaklikeaMartian'></a>Speak like a Martian

Be communicative with your team. We're far from each other, so any information you can provide about you and your work is welcome.

Let everybody know your daily schedule so the team can know when it's best to reach you. Add this information on your Slack profile.

Use the #status Slack channel and / or Slack built-in status messages to inform when you are not available.

Update the status of the task you are working on frequently on Linear. Use comments in the project management tool to keep everybody in the loop. Use Slack instead if you need a more direct status report.

## 2. <a name='NoMartianleftbehind'></a>No Martian left behind

Software development is hard and no matter how expert you are. You may have doubts. Your team is here to support you.

As soon as you are blocked with something, and after spending some time on it (around 40 minutes), don't hesitate to ask for help from a colleague.

More often than not, you will find that solely by explaining it to someone else, the solution will dawn on you.

As a general rule, it's better to sort things early on before is too late, so they don't affect estimates or deadlines.

MarsBased encourages async communication and we all understand that someone might not be able to reply immediately; but by raising the flag it will be easier for everybody to organise the work and help you (sync or async).

## 3. <a name='Letyourcodehistoryspeakforitself'></a>Let your code history speak for itself

Git is a great tool to document the coding process. Take care of it.

- Check out our [Git guidelines](https://github.com/MarsBased/handbook/blob/master/guides/development/git-guidelines.md)
- We value a clean git history.
- Write meaningful PRs:
  - Link the ticket you are working on.
  - Explain any surprising characteristics of the implementation.
  - Explain how to test if it requires some setup.
  - If you made additional changes, like a refactor or some other change needed, please explain it.

## 4. <a name='Measuretwicecutonce'></a>Measure twice, cut once!

Take some time to read all the documentation available (ticket description and comments) before starting any task.

Make sure you understand everything and share the same vision as the Tech Lead. If there is any disagreement, such as doubts, suggestions o misunderstandings, reach out to the Tech Lead to discuss them. Tech leads or Project Managers may not be able to describe every single detail _all of the time_.

While you are working on the ticket, re-read its description to make sure no detail is being forgotten or overlooked.

Also, take a final look at the description when you are done with the implementation to double-check that the code is doing exactly what is expected.

## 5. <a name='Whowatchesthewatchmen'></a>Who watches the watchmen?

Any change can lead to new bugs. Do not think a change won't break everything or anything.

Test extensively all use cases. Try to break the code. If you don't do it, an anonymous user will do it for you.

[Review your own code](/guides/development/code-reviews-guidelines.md). Do not trust your past self. You are older and wiser now.

After finishing a feature, try to look at the big picture. At this point, it's easier to detect possible improvements.

As a tip, when you are about to open a PR, use the Github web interface to make a review of your own code, as it if were from a different person. Even if you are confident that you know exactly what you have pushed, you surely will find unexpected stuff.

It's a good idea to wait some hours or even a day before making this self-review. When you finish working on a task you have tunnel vision about it.

Revisiting it later or the next day will help you to spot mistakes or possible improvements. Give your brain a break.

Applying an improvement left by a reviewer to an open PR needs to be done with extra caution. It's very easy to introduce a bug because the second time we tend to omit exhaustive testing. Remember, any change can lead to new bugs.
