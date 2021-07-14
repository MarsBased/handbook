# Git & Commit Guidelines

This is a guide covering how we expect to work with Git at MarsBased. Most of this guide is GitHub oriented but might be adapted to other Git tools like Gitlab or Bitbucket.

* **1.** [Commit Message Guidelines](#CommitMessageGuidelines)
* **1.1** [Message Format](#MessageFormat)
* **1.1.1** [Message Header Type](#HeaderType)
* **1.1.2** [Message Header Scope](#HeaderScope)
* **1.1.3** [Message Samples](#CommitMessageSamples)
* **2.** [Git Branches Naming](#GitBranchesNaming)
* **3.** [Git Workflow](#GitWorkflow)
* **4.** [Dangerous behaviours](#DangerousBehaviours)
* **5.** [Credits](#Credits)

Please, notice that at MarsBased we work with a large variety of clients. There could be clients that follow their own guidelines. You can always suggest improvements over their guidelines but there will be cases where it won't be possible to use ours.

## <a name='CommitMessageGuidelines'></a>Commit Message Guidelines

We have very precise rules over how our git commit messages can be formatted. This leads to more readable messages that are easy to follow when looking through the project history.

### <a name='MessageFormat'></a>Commit Message Format

Each commit message consists of a header, a body and a footer. The header has a special format that includes a type, a scope and a subject:

```
<type>(<scope>): <subject>
-BLANK LINE-
<description>
-BLANK LINE-
<footer>
```

The header is mandatory but the scope of the header is **optional**.

The maximum length of the header must be 72 characters and any other line of the commit message cannot be longer than 100 characters. This allows the message to be easier to read on GitHub as well as in various git tools.
The language used in the commit messages is English. If the client wants to have access to the commit history for documentation purposes and they don't understand English, other languages can be used instead.

The `<footer>` should contain a closing reference to a [github issue](https://help.github.com/en/github/managing-your-work-on-github/closing-issues-using-keywords), a Trello card link, a JIRA issue ID or link. If there is no GitHub issue or project management tool reference for this specific commit just leave it blank.

#### <a name='HeaderType'></a>Type

Choose the one that best fits the task:

- __fix__: Represents a bug fix for your application.
- __feature__ / __feat__: Adds a new feature to your application or library.
- __refactor__: A code change that neither fixes a bug nor adds a feature.
- __deploy__: Changes to modify or related to the deployment process.
- __chore__: Upgrades libraries and/or performs maintenance tasks.
- __docs__: Documentation only changes.
- __test__: Adding missing tests or correcting existing tests.

#### <a name='HeaderScope'></a>Scope

The scope is meant to describe a specific module/part of the application and it's highly dependant on the application you are building.

Some examples to serve as inspiration:

- __admin__: Refers to the admin panel.
- __users__: Refers to the user management module.
- __payment__: Changes on the payment gateway.

#### <a name='CommitMessageSamples'></a>Message Samples

```
chore(deploy): Update Docker base image to v2.6

Closes #345
```

```
feature(admin): Add users CRUD

We can now manage users through the admin panel.
We have added a new search module with an integrated calendar to be able to
filter entities by creation date.

https://trello.com/c/random-id/20-mycooltask
```

```
fix: Users can't log out when authenticated via oauth2

JIRA Issue: 23456
```

## <a name='GitBranchesNaming'></a>Git branches naming

Any branch created for the project will have the following structure:

`<type>/<short-name-of-task>`

Samples:

- feature/users-crud
- fix/logout-for-oauth-users

## <a name='GitWorkflow'></a>Git workflow

We are using a modified and simplified version of [Gitflow](https://guides.github.com/introduction/flow/).

For big projects already deployed to production, there will always be two branches: `main` (`master` in older projects) and `development`.
The **main** branch will contain the code that has been deployed while the **development** branch will contain the most recent stable version of it.

For small projects or projects that are have not been deployed we allow simplifying this by working only with a `main` branch.

These are the required steps to add new code to a branch (development or main, depending on the nature of the project).

1. Create a new branch using the branch naming convention from the branch you think relevant (main, development).
2. Do as many commits as are required to complete your task.
3. You may open a [_draft_ Pull Request (PR)](https://github.blog/2019-02-14-introducing-draft-pull-requests/) if you want some colleagues to review your work in progress.
4. Once the work is finished, rebase your commits to leave only the meaningful ones for the reviewer to better understand your changes. Leaving only one commit is also fine.
5. Rebase your branch with the one from where you open yours to have the latest changes.
6. Open a Pull Request to be reviewed by your colleagues.
7. Once reviewed, squash & merge on the target branch. The commit resulting from the squash & merge must be compliant with the Commit Message Format.

If the project is using a development branch, this is the recommended way of merging against the main branch:

1. Create a Pull Request from development to main
2. Once all automated tests and manual reviews have finished, merge the development branch to the main branch by creating a merge commit strategy.
3. Create a new Github release pointing to the main branch and create a new tag to identify the release.

You might want to add additional steps depending on your project.

## <a name='DangerousBehaviours'></a>Dangerous behaviours

* Avoid using `git push -f` while working on the same brach with other developers. Use `git push --force-with-lease` instead.

## <a name='Credits'></a>Credits

This guide is heavily influenced by:

- [Angular Commit Message guidelines](https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#-commit-message-guidelines)
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0-beta.2/)

Some parts of this guide are a copy & paste of theirs. All the credit and respect go to the original authors 🙌
