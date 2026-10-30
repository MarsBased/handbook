# Coding guidelines

AI agents write most of our code, but we remain responsible for every line that we ship. These guidelines set the baseline for all our code, whether you or an AI agent wrote it. Use them to guide your agent and to review its output. See our [AI Augmented Development guide](/guides/development/ai-augmented-development.md) for how we work with AI agents.

Focus on code readability. Code should tell a story. Code should be easy for anyone to understand and reason about.

- [1. Do's and Don'ts](#id-1.-dos-and-donts)
  - [1.1 Do's](#id-1.1-dos)
    - [1.1.1 Keep code simple](#id-1.1.1-keep-code-simple)
    - [1.1.2 Naming is key](#id-1.1.2-naming-is-key)
    - [1.1.3 Remove unused code](#id-1.1.3-remove-unused-code)
    - [1.1.4 Write meaningful code comments](#id-1.1.4-write-meaningful-code-comments)
    - [1.1.5 Keep it small](#id-1.1.5-keep-it-small)
  - [1.2 Don'ts](#id-1.2-donts)
    - [1.2.1 Don't refactor ahead of time](#id-1.2.1-dont-refactor-ahead-of-time)
    - [1.2.2 Premature optimization](#id-1.2.2-premature-optimization)
    - [1.2.3 Unnecessary dependencies](#id-1.2.3-unnecessary-dependencies)
    - [1.2.4 Don't comment code to remove it, just delete it](#id-1.2.4-dont-comment-code-to-remove-it-just-delete-it)
    - [1.2.5 Refactor and add features](#id-1.2.5-refactor-and-add-features)
    - [1.2.6 Don't make typos](#id-1.2.6-dont-make-typos)
    - [1.2.7 Avoid comments with TODOs](#id-1.2.7-avoid-comments-with-todos)

## 1. Do's and Don'ts

### 1.1 Do's

#### 1.1.1 Keep code simple
Code should be simple and easy to understand. Use good names for variables and methods. Keep methods short and classes small. Code should be properly organized for this purpose. Sometimes we can think of some design patterns that could be applied or some (complex) abstractions, but these can lead to over-engineering. Your code has a purpose, focus on that. Let the patterns, the abstractions and the complexity come to you instead of driving you.

[Keep it simple, stupid](https://en.wikipedia.org/wiki/KISS_principle).

#### 1.1.2 Naming is key
Spend some time looking for good class, method and variable names. Use long and descriptive names for both functions/methods and variables. Avoid single-letter names, except in conventional idioms such as loop indexes (`i`) or exception variables (`e`). Remember you are writing code for others and for yourself, so make it the best. Push to give the readers a good time.

Naming is key!

#### 1.1.3 Remove unused code
When we stop using a feature or part of it, we should remove that code and any code that becomes unused as a consequence, in the same pull request. Remember, we don't want "dead" code around. It will give you a hard time later when you need to understand it again.

If you find unrelated dead code or legacy code, don't remove it in the same pull request. Create a Linear issue and do the cleanup in a separate pull request.

#### 1.1.4 Write meaningful code comments
Don't comment on the WHAT of a piece of code, only on the WHY, and only if necessary. Comments should exist if you believe that the solution you've chosen might need extra context to be understood. Always focus on the WHY instead of the WHAT, as the WHAT is already there: it is our code.

AI agents often add comments that only repeat the WHAT. Look for them and remove them. See our [AI guidelines](/guides/ai-guidelines.md#remove-ai-generated-code-comments-that-add-no-value).

#### 1.1.5 Keep it small
The less code, the better. The fewer code changes, the better. As we like to build one thing at a time, we should also build it as simple and focused as possible. Less code is easier to understand, and fewer code changes make it much more accessible for you and for our colleagues as reviewers.

### 1.2 Don'ts

#### 1.2.1 Don't refactor ahead of time
Wait until something is painful to change or understand. Remember that we should keep it small and simple. Refactoring without a purpose can lead to complexity, unnecessary abstractions and miscommunication about what you are trying to achieve.

#### 1.2.2 Premature optimization
In general, don't do premature optimization, but always keep in mind that there are some basic techniques that can have a big impact. Avoid N+1 queries (take advantage of the logs during development for this). Filter using SQL as much as possible (but keep a balance to avoid over-complicating the code). There are problems that can be avoided at first, but don't go too deep blindly if there isn't any reason to.

#### 1.2.3 Unnecessary dependencies
Before adding a 3rd party library or a dependency, think carefully about whether it's really necessary and about the compromises you are making. We don't want to reinvent the wheel, but sometimes it could be better to build what we need instead of depending on a library that does that and much more.

When adding a new library to an application, make sure:
* It's well maintained (check when the last commit was made and the number of open issues).
* It's not unnecessarily big and does not introduce a lot of extra dependencies under the hood.
* The license fits within the policy used in the application. Some projects only allow libraries with the MIT license, for example. Before adding a library with a more restrictive license, check with the team.

#### 1.2.4 Don't comment code to remove it, just delete it
We have Git for god's sake. We can always check a previous commit to find the deleted code.

#### 1.2.5 Refactor and add features
Don't build new features and refactor at the same time unless that feature demands it. Focus on your current code and use code refactoring as a tool to achieve our goal. Refactoring an unrelated part of the code that has nothing to do with that feature will not bring any value to you, to the reviewer or to your codebase.

#### 1.2.6 Don't make typos
Be careful with your typing. Class, method and variable names, code comments, literal strings, page copy and documentation should be free of typos.

Let your editor help you by installing a spell checker. Check [this plugin](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker) if you are using Visual Studio Code. Remember, checking typos is part of code reviews.

#### 1.2.7 Avoid comments with TODOs
If you think that something should be done, create an issue for it. Maybe it will be done right after, or maybe some weeks after. Let that decision be where it belongs: in your project management tool. Your code is not the place to leave task descriptions or memos.
