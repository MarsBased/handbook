# Cycles and project management

We use Linear to manage all our projects, except the ones where we integrate with the client's team. In these cases, we adapt to the client’s tools.

Linear is an incredible task management tool for development teams, but we use it in many other areas like Hiring, Management, or organising our Martian Tapas sessions.

In this section of the Handbook, we describe a few Linear concepts that every Martian ought to know.

1. [Triage](#triage)
2. [Backlog](#backlog)
3. [Cycles](#cycles)
4. [Projects](#projects)
5. [Statuses](#statuses)
6. [Fields](#fields)
7. [Other tips](#tips)

## 1. <a name='triage'></a>Triage

New tasks are typically created in the Triage section. It's like a list of things that we still haven't decided that we want to develop. Some tasks will be approved and moved to the backlog while others won't.

You can create new tasks in the Triage section. The project manager and/or the tech lead of the project will review the Triage list periodically and approve or reject each task. When a task is approved, it can go to the backlog, if it's not urgent, or directly to a development cycle (keep reading to know more about cycles!).

Creating new tasks is everyone's responsibility. If you find an error or detect something that could be improved, or if a client tells you of a new feature, please create a task in the Triage section. Before submitting the new issue, remember filling all the relevant details:

- Short title
- Description
- Labels
- Estimate
- Priority (optional)
- Related issues

If it's a bug, make sure to include the following information:

- Steps to reproduce the bug, if known.
- Screenshots or a video showing the problem, if it's meaningful.
- URLs (staging / production / Sentry / other monitoring platforms), if present.

## 2. <a name='backlog'></a>Backlog

The Backlog is our list of pending work, sorted by priority (urgent, high, medium, low). Tasks approved in the Triage section go here.

## 3. <a name='cycles'></a>Cycles

Cycles are like development sprints but with a different name. We work in three-week sprints (or cycles 😅). The active cycle is where the development takes place. We typically plan the next development cycle right before finishing the previous one. Project managers and tech leads decide what's included according to the client's needs and the project priorities (we always try to mix technical improvements and maintenance tasks with new features).

When it comes to cycle planning, we always leave room for new urgent tasks or unforeseen situations by leaving 15-20% of our capacity unplanned.

## 4. <a name='projects'></a>Projects

We use Linear projects in a slightly different way than it might seem.

When we are working on new projects that start from scratch, with phases and deliveries, we use Linear projects to split the development into small phases. Authentication, checkout, user settings, admin panel, are just a few examples. This approach lets us plan better, identify delays, and gives the team a sense of accomplishment when a phase is completed.

In a few projects that are already in production, we use Linear projects to group tasks that will release together: release v1.0, release v1.1, release v.1.2, etc. Tagging each task with a release name helps the team know when it is planned to release, and it allows us to test releases as a whole.

In other ones, where we can effectively apply a continuous delivery approach, we don't use Linear projects at all. So, as you can see, it depends a lot on each project 🤷🏻‍♂️

## 5. <a name='statuses'></a>Statuses (columns of the board)

- **To Do:** Tasks assigned to the active cycle go here. We sort them by priority.
- **Blocked:** If something is blocked, it goes into this column.
- **In Progress:** Tasks we are developing currently.
- **Needs Fixing:** Finished tasks that require fixes or polishing.
- **In Review:** Finished issues go through a code review (typically from the tech lead of the project or another engineer).
- **To be deployed:** A task has passed the code review and has been merged, but it is still not deployed anywhere.
- **Staging:** Tasks deployed to the staging environment. The project manager (or the client, sometimes) does another review of the task in the staging environment.
- **Done:** When a task gets the final OK, it is moved to Done.
- **Canceled:** Tasks that have been canceled because they are duplicated or no longer needed.

## 6. <a name='fields'></a>Fields

Here's a short description of the fields that we use when we create a new issue:

- **Short title:** Write a short title to help identify the task.
- **Description:** Write as many details as possible about the task. It's important to write a proper description. The project manager / tech lead needs to understand what the task is about, its scope, difficulty and importance (or severity in case of a bug) to be able to plan when to develop it and decide who should work on it.
- **Estimate:** How long do you think it can take to complete a task. The estimate is not mandatory. It’s just a guess to help the project manager and the client organise the development cycles. Don’t spend more than a couple of minutes thinking about it. We use an exponential list of values: 1, 2, 4, 8, 16, 32, 64. We count each story point as an hour of work. 
- **Labels:** Labels categorise the details of an issue, describing it. There are labels for the technologies affected in the ticket, the specific task at hand (documentation, testing), or if the issue was not included in the client offer, among others. Add as many labels as needed.
- **Priority:** The priority of a task is decided by the client or the project manager. The project manager is the final person responsible for the prioritization, but that doesn't mean that other people can't add the initial priority or discuss it. If you are the person creating a task on Linear, please indicate its priority according to your own common sense. Is it a very important technical change? Is it a refactor that can wait a few more weeks? Setting up a priority will help the client and the project manager take better calls when planning the new development cycle. If you want, you can add a comment explaining why do you think a task is more or less urgent to do.
- **Related issues:** Linear lets you link issues with each other and even indicate whether an issue is blocked or is blocking another one.
- **Child issues:** You can create child issues inside other issues. Use it when a task is too big or has multiple steps.
- **Comments:** Use comments as much as you like to update the rest of the team about a task, ask questions or answer your teammates. Linear is our source of truth so keeping it up to date with comments is very important.

## 7. <a name='tips'></a>Other tips and best practices

- We prefer working asynchronously. Please use the task comments to communicate if it's not urgent.
- Keeping Linear organised is everyone's job, not just the tech lead's or the project manager's.
- If a task can't be completed in less than 32 hours of work, split it in two or create multiple child issues.
- Don’t wait until the end of the day (or even worse, the end of the week) to update Linear: keep Linear updated as things happen in the project.
- Be proactive: create tasks, move them, and update them.
- If a task will take more than one day, keep your teammates informed by adding a comment and explaining your progress.
- Mention only the relevant person in each comment. We all receive too many notifications.
- Include the issue ID in your branch name, to properly link them with each other.
- Review your Linear inbox daily.
