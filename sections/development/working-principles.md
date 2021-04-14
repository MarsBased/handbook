## Working principles

- 1. [Speak like a Martian](#SpeaklikeaMartian)
- 2. [No Martian left behind](#NoMartianleftbehind)
- 3. [Let your code history speak for itself](#Letyourcodehistoryspeakforitself)
- 4. [Measure twice, cut once!](#Measuretwicecutonce)
- 5. [Who watches the watchmen?](#Whowatchesthewatchmen)
- 6. [Async is the way](#Asyncistheway)

Those are our principles, and if you don't like them... well, we are afraid Groucho Marx is not here.

## 1. <a name='SpeaklikeaMartian'></a>Speak like a Martian

Be communicative with your team. We're far from each other, so any information you can provide about you and your work is welcome.

Let everybody know your daily schedule so the team can know when it's best to reach you. Add this information in your Slack profile. Use the #status Slack channel and / or Slack built-in status messages to inform when you are not available.

Update the status of the task you are working on frequently. Use comments in the the project management tool to keep everybody in the loop. Use Slack instead if you need a more direct status report.

## 2. <a name='NoMartianleftbehind'></a>No Martian left behind

Software development is hard and no matter how expert you are, you may have doubts. Your team supports you. As soon as you are blocked on something, and after spend some time time on it (around 40 minutes), don't hesitate to ask for help to a colleague (it can be any martian, often just by explaining the problem to someone you figure it out yourself). It's better to sort things early on, before is too late to affect estimations or deadlines.

MarsBased encourages async communication and we all understand that someone might not be able to reply immediately; but by raising the flag it will be easier for everybody to organize the work for helping you (sync or async).

## 3. <a name='Letyourcodehistoryspeakforitself'></a>Let your code history speak for itself

Git is a great tool to document the coding process. Take care of it.

- Check out our [Git guidelines](https://github.com/MarsBased/handbook/blob/master/guides/git-guidelines.md)
- We value a clean git history.
- Write meaningful PRs:
  - Link the ticket you are working on
  - Explain any surprising characteristics of the implementation.
  - Explain how to test if it requires some setup.
  - If you made additional changes like a refactor or some other change needed, please explain it.

## 4. <a name='Measuretwicecutonce'></a>Measure twice, cut once!

Take some time to read all the documentation available (ticket description and comments) before start working. Make sure you understand everything and share the same vision as the Tech Lead. If there are any disagreement, being doubts, suggestions o misunderstandings, reach out the Tech Lead to discuss them. Tech leads or Project Managers cannot describe every single detail.

While you are working on the ticket, re-read its description to make sure no detail is being forgotten.

Also, take a final look at the description when you are done with the implementation to double check that the code is delivering exactly what is expected.

## 5. <a name='Whowatchesthewatchmen'></a>Who watches the watchmen?

Any change can lead to new bugs. Do not think a change won't break everything. Test extensively all use cases. Try to break the code. If you don't do it, an anonymous user will do it for you.

[Review your own code](/guides/development/code-reviews-guidelines.md). Do not trust your past self. You are older and wiser now.

After finishing a feature, try to look at the big picture. At this point is easier to detect possible improvements.

As a tip, when you are about to open a PR, use the Github web interface (or a local tool like [Gitx](https://rowanj.github.io/gitx/)) to make a review of your own code, as it if were from a different person. Even if you are confident that you know exactly what you have pushed, you'll surely will find unexpected stuff (like incorrectly pushed changes, a common example in Rails is unintended changes to schema.rb).

It's a good idea to wait some hours or even a day before making this self review. When you finish working on a task you have tunnel vision about it. Revisiting it later or the next day will help you see mistakes or possible improvements. Give your brain a break.

Applying an improvement left by a reviewer to an open PR needs to be done with extra caution. It's very easy to introduce a bug because the second time we tend to omit exhaustive testing. Remember, any change can led to new bug.

## 6. <a name='Asyncistheway'></a>Async is the way

MarsBased operates mainly asynchronously. Having +400 unread messages will cause you problems.

Make sure that:

- Your email inbox & notifications are clean. Some important notifications are received by email or Basecamp. For example, new issues being posted. A review being done. A task priority change.
- Cleanup the sources that send you notifications. Keep only the most meaningful ones to minimise the risk of missing important information.
  - Disable all Basecamp/Jira notifications you are not interested in.
  - Disable notifications on shared Slack channels (e.g: #random, #status, #marsbased). Or disable notifications on all channels if you are in many. If someone needs to let you notice something they will use mentions.
  - Review and clean your email at least once a day. Don't use the email as to do list. It's easy to mark as read an important email and forget about it. Use To Do lists instead, for example.
  - Look for your personal workflows to remember future actions. Each Martian has its own workflow. Ask for tips if you don't know how to do it.

It's ok to spend time on this, it's part of your work as a developer.
