# Git & Commit Guidelines

This is a guide that covers how we expect to work with Git at MarsBased. Most of this guide is GitHub oriented but might be adapted to
other Git tools like Gitlab or Bitbucket.

Please, notice that at MarsBased we work with a large variety of clients. There could be clients that
follow their own guidelines. You can always suggest improvements over their guidelines but there
will be cases where it won't be possible to use ours.

## Commit Message Guidelines

We have very precise rules over how our git commit messages can be formatted.
This leads to more readable messages that are easy to follow when looking through the project history.

### Commit Message Format

Each commit message consists of a header, a body and a footer. The header has a special format that includes a type, a scope and a subject:

```
<type>(<scope>): <subject>
<BLANK LINE>
<description>
<BLANK LINE>
<footer>
```

The header is mandatory and the scope of the header is **optional**.

The maximum length of the header must be 72 characters and any other line of the commit message cannot be longer 100 characters. This allows the message to be easier to read on GitHub as well as in various git tools.
The language used in the commit messages is English. If the client wants to have access to the commit history for documentation purposes and they don't understand English, other languages can be used instead.

The `<footer>` should contain a [closing reference to a github issue](https://help.github.com/en/github/managing-your-work-on-github/closing-issues-using-keywords),
a Trello card link, a JIRA issue ID or link. If there is no project management tool that can be referenced or the issue was not created for this specific commit.

#### Type

Choose the one that best fits the task:

- fix: Represents a bug fix for your application.
- feat: Adds a new feature to your application or library.
- refactor: A code change that neither fixes a bug nor adds a feature.
- deploy: Changes to modify or related to the deployment process.
- chore: Upgrades libraries and/or performs maintenance tasks.
- docs: Documentation only changes.
- test: Adding missing tests or correcting existing tests.

#### Scope

The scope is meant to describe a specific module / part of the application and it's highly dependant on the application you are building.

Some examples to serve as inspiration:

- admin: refers to the admin panel
- users: refers to the user management module
- payment: changes on the payment gateway

#### Samples

```
chore(deploy): Update Docker base image to v2.6

Closes #345
```

```
feat(admin): Add users CRUD

We can now manage users through the admin panel.
We have added a new search module with an integrated calendar to be able to
filter entities by creation date.

https://trello.com/c/random-id/20-mycooltask
```

```
fix: Users can't logout when authenticated via oauth2

JIRA Issue: 23456
```

## Git branches naming

Any branch created for the project will have the following structure:

`<type>/<short-name-of-task>`

Samples:

- feat/users-crud
- fix/logout-for-oauth-users


## Git workflow

We are using a modified and simplified version of Gitflow.

For big projects already deployed to production there will always be 2 branches: `master` and `develop`.
The master branch will contain the code that has been deployed while the develop branch will contain the most recent stable version of it.

For small projects or projects that are have not been deployed we allow simplifying this by working only with a `master` branch.

These are the required steps to add new code to a main branch (develop or master, depending on the nature of the project).

- Create a new branch using the branch naming convention from the main branch.
- Do as many commits as are required to complete the feature.
- You may open a _draft_ Pull Request (PR) if you want some colleague to review your work in progress.
- Once the work is finished, rebase your commits to leave only the meaningful ones for the reviewer to better understand your changes. Leaving only one commit is also fine.
- Rebase with the main branch to have the latest changes.
- Open a Pull Request to be reviewed by your colleagues.
- Once reviewed, squash & merge on the target branch. The commit resulting from the squash & merge must be compliant with the Commit Message Format.

If the project is using a develop branch, this is the recommended way of merging against the master branch:

- Create a Pull Request from develop to master
- Once all automated tests and manual reviews have finished, merge the develop branch to the master branch by creating a merge commit strategy.
- Create a new Github release pointing to the master branch and create a new tag to identify the release.

You might want to add additional steps depending on your project.

## Credits

This guide is heavily influenced by:

- [Angular Commit Message guidelines](https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#-commit-message-guidelines)
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0-beta.2/)

Some part of this guide are a copy & paste of theirs. All the credit and respect 🙌 goes to the original authors.
