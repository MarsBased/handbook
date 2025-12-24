# Git & Commit Guidelines

This is a guide covering how we expect to work with Git at MarsBased. Most of this guide is GitHub oriented but might be adapted to other Git tools like GitLab or Bitbucket.

- **1.** [Commit Message Guidelines](#commitmessageguidelines)
- **1.1** [Message Format](#messageformat)
- **1.1.1** [Message Header Type](#headertype)
- **1.1.2** [Message Header Scope](#headerscope)
- **1.1.3** [Message Samples](#commitmessagesamples)
- **2.** [Git Branches Naming](#gitbranchesnaming)
- **3.** [Git Workflow](#gitworkflow)
- **4.** [Dangerous behaviours](#dangerousbehaviours)
- **5.** [Credits](#credits)

At MarsBased we work with a large variety of clients. Some clients may follow their own guidelines. You can always suggest improvements over their guidelines but there will be cases where it will not be possible to use ours.

## <a name="commitmessageguidelines"></a>Commit Message Guidelines

We have very precise rules on how git commit messages should be formatted. This leads to more readable messages that are easy to follow when reviewing the project history.

We use **Linear** as our tracking tool. Whenever possible, commit messages should reference the related Linear issue.

### <a name="messageformat"></a>Commit Message Format

Each commit message consists of a header and an optional description.

For squashed commits after merging a Pull Request, the commit message **must** follow this format:

```
[issue-code] <type>(<scope>): <subject>

<description>
```

Where:

- `issue-code` is the Linear issue identifier, for example `MARS-456`
- `type` is mandatory
- `scope` is optional
- `subject` is mandatory

If the commit is not related to a Linear issue, the `issue-code` could be ignored but only if the commit is not a feature commit (`feat`).

The maximum length of the header must be 72 characters. Any other line of the commit message must not exceed 100 characters. This improves readability in GitHub and other git tools.

The language used in commit messages is English. If the client needs access to the commit history for documentation purposes and does not understand English, other languages may be used instead.

### <a name="headertype"></a>Type

Choose the type that best fits the task:

- **fix**: Represents a bug fix.
- **feat**: Adds a new feature.
- **deploy**: Changes related to the deployment process.
- **chore**: Dependency upgrades, refactors or maintenance tasks.
- **docs**: Documentation-only changes.
- **test**: Adding or fixing tests.

### <a name="headerscope"></a>Scope

The scope describes the specific module or part of the application affected by the change. It is optional.

Examples:

- **admin**: Admin panel.
- **users**: User management.
- **payment**: Payment gateway.

### <a name="commitmessagesamples"></a>Commit Message Samples

With a Linear issue:

```
[MARS-456] fix: review the commits documentation in handbook
```

```
[MARS-789] feat(admin): add users CRUD

We can now manage users through the admin panel.
We have added a new search module with an integrated calendar to be able to
filter entities by creation date.
```

Without a Linear issue (`feat` is not allowed):

```
fix: update Docker base image to v2.6
```

## <a name="gitbranchesnaming"></a>Git Branches Naming

Any branch created for a project must follow these rules.

### Branches related to a Linear issue

Use the branch name provided by Linear or the client project tracking tool:

Examples:

- `mars-456`

This ensures that during the code review process, reviewers can simply copy the branch name from Linear and check out the code locally.

### Branches not related to a Linear issue

Use one of the following formats:

- `feat-short-description`
- `fix-short-description`

Examples:

- `feat-add-users-crud`
- `fix-logout-for-oauth-users`

For client projects, adapt the naming to their requirements if needed.

## <a name="gitworkflow"></a>Git Workflow

We use a simplified version of Gitflow.

For large projects already deployed to production, there are usually two long-lived branches:

- `main` (or `master` in older projects), which contains deployed code
- `development`, which contains the latest stable changes

For small or not-yet-deployed projects, it is acceptable to work directly on `main`.

Recommended workflow:

1. Create a new branch from the appropriate base branch.
2. Make as many commits as needed to complete the task. Commit message naming is not enforced at this stage.
3. Optionally open a draft Pull Request to get early feedback.
4. Rebase and clean up commits before requesting review. Leaving a single commit is acceptable.
5. Rebase your branch on top of the latest target branch.
6. Open a Pull Request for review.
7. Squash and merge. The resulting squashed commit message must follow the Commit Message Format.

If the project uses a `development` branch, merging to `main` should be done as follows:

1. Open a Pull Request from `development` to `main`.
2. Once all checks and reviews pass, merge using a merge commit strategy.
3. Create a new GitHub release and tag pointing to `main`.

For small projects or small teams, we usually keep things simpler by working with a single long-lived branch, typically `main`, and skip a separate development branch. This reduces overhead and makes day-to-day work and releases easier to manage.

Even in this simplified setup, we still work with short-lived branches per feature or fix, open Pull Requests, and perform code reviews before merging into `main`.

## <a name="dangerousbehaviours"></a>Dangerous behaviours

- Avoid using `git push -f` when working on a shared branch. Use `git push --force-with-lease` instead.

## <a name="credits"></a>Credits

This guide is heavily influenced by:

- [Angular Commit Message guidelines](https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#-commit-message-guidelines)
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0-beta.2/)

Some parts are adapted from those sources. All credit goes to the original authors 🙌
