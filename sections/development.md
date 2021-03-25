# Development

Resposinble: Pablo

## Team organization

* Tech lead:
  * explain role, responsibilites. How code reviews are done
* Developer:
  * explain role, responsibilites
  * don't introduce bugs either in new code or existing code. Also, strong emphasis on reviewing your own code to make sure you don't pass on untested code to the reviewer.
  * Code reviews: we expect you to test the code in depth (not only the happy path) and to auto-review the code. A good piece of advice is to not open the PR on the same day, wait for the next day and then do an auto code-review (you will always find things!) and then open the PR.
* Project manager:
  * explain role, responsibilites

## Project organization

* Weekly report: weekly check-in you have to answer on Basecamp before Monday.
  * Developer needs to answer weekly check-in on Basecamp before Monday.
  * Project manager sends weekly report to the client from the developers check-ins.
* Weekly meeting with client and internal.
* Sprints, etc. depends on the project, usually 2 weeks.
  * Tech lead defines tasks for the Sprint and adds some technical definition (depending on the project, task, etc.), and estimates the tasks.

## Working principles

TODO: think of a name for each principles (David has ideas about this). And maybe find ane emoji for each too.

### Principle 1

Be very communicative. As soon as you are blocked on something don't waste too much time, ask for help.
  * blocked is like 30 or 40 minutes.

Don’t spend too much time blocked on a task. If you are blocked and need help, dedicate some time to yourself but then ask for help to a college. Don't wait to open a chat with a teammate. If they are occupied they will tell you. It's better to sort things early on. Slack is meant to have async communication and we all understand that someone might not be able to reply immediately.

### Principle 2

When working on a long task, keep the team updated on the progress by commenting on the JIRA ticket.
  * For example, if you are in the middle of a task and you finish for the day, add a short comment to update the status so the tech lead can be up to date.
  * Depending on the project could make sense also to leave this update on slack for a more direct status report.

### Principle 3

TODO: Decide if this fits here or not. Let's decide how to make this fit with the Git guideliens (maybe cross link?).

* Be formal and have care of PR descriptions and commit messages. We value a clean git history (no "apply fix" commits).
  * Commit messages guide: https://github.com/MarsBased/handbook/blob/master/guides/git-guidelines.md
  * Write meaningful PR messages:
     * Explain any surprising characteristics of the implementation.
     * Explain how to test if it requires some setup.
     * If you made additional changes like a refactor or some other change needed, list it in the PR description too.

### Principle 4

Read issues / tasks descriptions (including comments) carefully. Read it all before starting and ask any questions or comment any disagreements with the tech lead. While working on the task you should be re-reading the part you are working on to make sure you didn't left anything out. Finally, before opening the PR read it in full again and check that everything is done.
  * Having doubts or suggestions is good. Tech Leads or PMs cannot describe everything to the detail.
  * Before considering a task finished, it's important to reread again the task (and its comments) to ensure that you'll deliver what was expected.

### Principle 5

* When making changes to the code, always test all the changes.
* Review your own code.
* It's a good opportunity to find bugs or improvements because you are seeing the code as a whole.

When you are about to open a PR, use the Github web interface (or a local tool like Gitx) to make a review of your own code. Even if you are confident that you know exactly what you have pushed, you'll surely will find unexpected stuff (like incorrectly pushed changes, a common example in Rails is unintended changes to schema.rb).

Applying an improvement left by a reviewer to an open PR needs to be done with extra caution. It's very easy to introduce a bug because the second time we tend to omit exhaustive testing.
  * Make sure to test again with every change you make.

Link to one bug rule description (wherever that is)

### Principle 6

Have your email inbox & notifications clean
* Some important notifications are received by email or Basecamp. For example, new issues being posted. A review being done. Or a task priority change.
* Having +400 unread messages can make you miss some of these async communications.
* Write tips for doing this like disable all basecamp notifications you are not interested in, JIRA notifications you are not interested in. Review and clean your email at least once a day. Recommendation to create tasks in a To Do list for e-mails that require an action, so you can safely mark the e-mail as read.


TODO: Place links to guidelines here.

-----

To decide where to place:
* One bug rule (port from Xavi’s presentation): https://3.basecamp.com/3091551/buckets/208435/uploads/3519843107
