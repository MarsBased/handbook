# Development

<!-- vscode-markdown-toc -->
- 1. [Team organization](#Teamorganization)
  - 1.1. [Project Manager](#ProjectManager)
  - 1.2. [Tech Lead](#TechLead)
  - 1.3. [Developer](#Developer)
- 2. [Project organization](#Projectorganization)
  - 2.1. [Weekly report](#Weeklyreport)
  - 2.2. [Weekly meeting with the client](#Weeklymeetingwiththeclient)
  - 2.3. [Weekly internal meeting](#Weeklyinternalmeeting)
  - 2.4. [Agile development rituals](#Agiledevelopmentrituals)
- 3. [Working principles](#Workingprinciples)
  - 3.1. [Speak like a Martian](#SpeaklikeaMartian)
  - 3.2. [No Martian left behind](#NoMartianleftbehind)
  - 3.3. [Let your code history speak for itself](#Letyourcodehistoryspeakforitself)
  - 3.4. [Measure twice, cut once!](#Measuretwicecutonce)
  - 3.5. [Who watches the watchmen?](#Whowatchesthewatchmen)
  - 3.6. [Async is the way](#Asyncistheway)
- 4. [Development guidelines](#Developmentguidelines)

<!-- vscode-markdown-toc-config
  numbering=true
  autoSave=true
  /vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

Although each project is different and we are able to adapt to the specific necessities of a team, we have a well established and preferred way to work.

##  1. <a name='Teamorganization'></a>Team organization

We organize the people working on a project in three different roles:

- Project Manager
- Tech lead
- Developer

In some projects, the same team member can do multiple roles. A common situation is the tech lead doing the project management role.

###  1.1. <a name='ProjectManager'></a>Project Manager

Person in charge of the top level tasks required by the client, communicating between the team and the MarsBased team effectively.

Responsibilities:

- Planification
  - Set the overall project schedule and the sprints for each project phase.
  - Define all the different areas of the project including the scope, objectives, schedule and tasks.
  - Identify blocking issues compromising the smooth development of the project and provide solutions.
  - Ensure the project completion on time and within budget.
- Product ownership
  - Understand client needs and product roadmap.
  - Work with the development team to come up with an efficient solution to client needs.
  - Define specifications for the product features so they are clear for the development team.
- Organization
  - Kick off the project and set up all the tools required to organize and manage it.
  - Organize project documentation and credentials to ensure all the parties involved have access to it.
  - Upon project completion, deliver the final product to the client as agreed and clean up the tools used.
- Communication and reporting
  - Agree with clients on channels and frequency of meetings and reports to inform about the progress of the projects.
  - Coordinate meetings with team and clients to ensure the successful execution of each sprint of the project.
  - Communicate proactively with the team and clients providing transparent information on the state of the project and thus avoiding snowball effects.
  - Act as the link between clients and developers.

###  1.2. <a name='TechLead'></a>Tech Lead

Senior developer able to take ownership on the code developed by the team and help the client improve their code.

Responsibilities:

- Decide the best way to implement the specifications decided by the Product Manager.
  - Take into account the project needs and tech debt in order to make the best decision possible, communicating with the Product Manager and the client the possible implications.
- Communicate correctly all the decisions to the developers.
- [Review the code](/guides/code-reviews-guidelines.md) produced by the developers, ensuring:
  - All the code follow our quality standards at code and architecture levels.
  - The changes introduced met the requirements needed, no more and no less.
  - The changes don't introduce obvious bugs.
- Write technical specifications for tasks.
- Perform research tasks to solve complex problems / requirements.
- Decide 3rd party services to use (DevOps, log management, error tracking, etc.)

###  1.3. <a name='Developer'></a>Developer

Developers are in charge of building and maintaining the software following the previous analysis made by the Project Manager and the Tech Lead.

Responsibilities:

- Create the best possible code for each feature, following the baselines provided by the Tech Lead.
- Test extensively every issue to make sure it doesn't introduce new bugs, neither in the feature itself nor by producing regressions in the codebase.
  - Not only the happy path!
- Continuously reviews its own code before passing it to reviewers. The soon any problem is detected, the fastest and easiest will be to fix it.
- Release the code effectively, caring to not produce undesired side-effects (like downtime) on production.
- Communicate blocking problems, delays and other issues to the Tech Lead.

##  2. <a name='Projectorganization'></a>Project organization

Communication is vital for us, so we encourage a continuous flow of information between our team and the client to be always in the same page.

Our rituals are:

- Weekly report
- Weekly meeting with the client
- Weekly internal meeting
- Agile development rituals

###  2.1. <a name='Weeklyreport'></a>Weekly report

Each week, before next Monday, the developers fill a check-in with the tasks they were working on through the week, explaining its current status, estimated time left to finish each issue, and possible blockers that may arise.

With all the information, the Project Manager curates a weekly report for the client.

###  2.2. <a name='Weeklymeetingwiththeclient'></a>Weekly meeting with the client

Once a week, the whole team gathers and runs a meeting with the client to discuss about previous and current week's work. That way everybody is in the loop, aware of what's the status of the project.

###  2.3. <a name='Weeklyinternalmeeting'></a>Weekly internal meeting

Once a week, the whole team gathers to discuss tasks for the week, blocking issues or other organizational matters concerning the whole team.

###  2.4. <a name='Agiledevelopmentrituals'></a>Agile development rituals

We usually use a SCRUM-based methodology with two week sprints, but it depends on the project needs.

Using SCRUM, the Tech Lead defines before starting a spring which tasks are included providing technical definition and estimation. Once the sprint is ready, it starts and developers tackle the tasks one by one.

##  3. <a name='Workingprinciples'></a>Working principles

Those are our principles, and if you don't like them... well, we are afraid Groucho Marx is not here.

###  3.1. <a name='SpeaklikeaMartian'></a>Speak like a Martian

Be communicative with your team. We're far from each other, so any information you can provide about you and your work is welcome.

Let everybody know your daily schedule so the team can know when it's best to reach to you. Update your project management tool frequently with your status to keep everybody in the loop. Use Slack instead if you need a more direct status report.

###  3.2. <a name='NoMartianleftbehind'></a>No Martian left behind

Software development is hard and no matter how expert you are, you may have doubts. Your team supports you. As soon as you are blocked on something, and after spend some time time on it (around 40 minutes), don't hesitate to ask for help to a colleague (it can be any martian, often just by explaining the problem to someone you figure it out yourself). It's better to sort things early on, before is too late to affect estimations or deadlines.

MarsBased encourages async communication and we all understand that someone might not be able to reply immediately; but by raising the flag it will be easier for everybody to organize the work for helping you (sync or async).

###  3.3. <a name='Letyourcodehistoryspeakforitself'></a>Let your code history speak for itself

Git is a great tool to document the coding process. Take care of it.

- Check out our [Git guidelines](https://github.com/MarsBased/handbook/blob/master/guides/git-guidelines.md)
- We value a clean git history.
- Write meaningful PRs:
  - Link the ticket you are working on
  - Explain any surprising characteristics of the implementation.
  - Explain how to test if it requires some setup.
  - If you made additional changes like a refactor or some other change needed, please explain it.

###  3.4. <a name='Measuretwicecutonce'></a>Measure twice, cut once!

Take some time to read all the documentation available (ticket description and comments) before start working. Make sure you understand everything and share the same vision as the Tech Lead. If there are any disagreement, being doubts, suggestions o misunderstandings, reach out the Tech Lead to discuss them. Tech leads or Project Managers cannot describe every single detail.

While you are working on the ticket, re-read its description to make sure no detail is being forgotten.

Also, take a final look at the description when you are done with the implementation to double check that the code is delivering exactly what is expected.

###  3.5. <a name='Whowatchesthewatchmen'></a>Who watches the watchmen?

Any change can lead to new bugs. Do not think a change won't break everything. Test extensively all use cases. Try to break the code. If you don't do it, an anonymous user will do it for you.

[Review your own code](/guides/code-reviews-guidelines.md). Do not trust your past self. You are older and wiser now.

After finishing a feature, try to look at the big picture. At this point is easier to detect possible improvements.

As a tip, when you are about to open a PR, use the Github web interface (or a local tool like [Gitx](https://rowanj.github.io/gitx/)) to make a review of your own code, as it if were from a different person. Even if you are confident that you know exactly what you have pushed, you'll surely will find unexpected stuff (like incorrectly pushed changes, a common example in Rails is unintended changes to schema.rb).

It's a good idea to wait some hours or even a day before making this self review. When you finish working on a task you have tunnel vision about it. Revisiting it later or the next day will help you see mistakes or possible improvements. Give your brain a break.

Applying an improvement left by a reviewer to an open PR needs to be done with extra caution. It's very easy to introduce a bug because the second time we tend to omit exhaustive testing. Remember, any change can led to new bug.

###  3.6. <a name='Asyncistheway'></a>Async is the way

MarsBased operates mainly asynchronously. Having +400 unread messages will cause you problems.

Make sure that:

- Your email inbox & notifications are clean. Some important notifications are received by email or Basecamp. For example, new issues being posted. A review being done. A task priority change.
- Cleanup the sources that send you notifications. Keep only the most meaningful ones to minimise the risk of missing important information.
  - Disable all Basecamp/Jira notifications you are not interested in.
  - Review and clean your email at least once a day. Don't use the email as to do list. It's easy to mark as read an important email and forget about it. Use To Do lists instead, for example.
  - Look for your personal workflows to remember future actions. Each Martian has its own workflow. Ask for tips if you don't know how to do it.

It's ok to spend time on this, it's part of your work as a developer.

##  4. <a name='Developmentguidelines'></a>Development guidelines

 Check out our more technical development guidelines (if you dare!).

- [Angular guidelines](/guides/angular-reference-guide.md)
- [Back-end guidelines](/guides/back-end-development-guidelines.md)
- [Coding guidelines](/guides/coding-guidelines.md)
- [Code reviews guidelines](/guides/code-reviews-guidelines.md)
- [Git guidelines](/guides/git-guidelines.md)
- [React guidelines](/guides/react-guidelines.md)
- [Ruby & Rails guidelines](/guides/ruby-guidelines.md)
- [Testing guidelines](/guides/testing-guidelines.md)
