# Coding guidelines

Writing code can be as personal as hand-writing but we like to keep everyone within the same baseline. From our experience, some good ideas, patterns and styles we built a cool baseline that we believe it makes us better engineers, not only better programmers.

Focus on code readability. Code should tell a story. Code should be easy to understand and reason about by anyone.

* **1.** [Do's and Don'ts](#DosandDonts)
	* **1.1** [Do's](#Dos)
		* **1.1.1** [Keep code simple](#KeepCodeSimple)
		* **1.1.2** [Naming is key](#Naming)
		* **1.1.3** [Remove unused code](#UnusedCode)
		* **1.1.4** [Write meaningful code comments](#CodeComments)
		* **1.1.5** [Keep it small](#KeepItSmall)
	* **1.2** [Don'ts](#Donts)
		* **1.2.1** [Refactor ahead of time](#RefactorAheadOfTime)
		* **1.2.2** [Premature optimization](#PrematureOptimization)
		* **1.2.3** [Unnecessary dependencies](#UnnecessaryDependencies)
		* **1.2.4** [Don't comment code to remove it, just delete it](#CommentCodeToRemove)
		* **1.2.5** [Refactor and add features](#RefactorAndAddFeatures)
		* **1.2.6** [Don't make typos](#DontMakeTypos)
		* **1.2.7** [Avoid comments with TODOs](#AvoidTODOs)

### 1. <a name="DosandDonts"></a>Do's and Don'ts

### 1.1 <a name='Dos'></a>Do's

#### 1.1.1 <a name='KeepCodeSimple'></a>Keep Code Simple
Code should be simple! Easy to understand. Variables and methods with good naming. Methods short, classes small. Code should be properly organized for this purpose. Sometimes we can think of some design patterns that could be applied or some (complex) abstractions but these can lead to over-engineering. Your code as a purpose, focus on that. Let the patterns, the abstractions, the complexity come to you instead of driving you.

[Keep it simple, stupid](https://en.wikipedia.org/wiki/KISS_principle).

#### 1.1.2 <a name='Naming'></a>Naming is key
Spend some time looking for good classes, methods and variables names. Make use of long and descriptive names for both functions/methods and variables. Never use 1 char variables! Remember you are writing code for others and for you, make it the best. Push to give the readers a good time.

Naming is key!

#### 1.1.3 <a name='UnusedCode'></a>Remove unused code
When we stop using a feature or part of it we should remove that code and any other unused code as a consequence. Remember, we don't want "dead" code around. It will give you a hard time later when you need to comprehend it again.

#### 1.1.4 <a name='CodeComments'></a>Write meaningful code comments
Don't comment the WHAT about a piece of code, only the WHY, and if necessary. Comments should exist if you believe that the solution you've chosen might need extra context to be understood. Always focus on the WHY instead of the WHAT as this last one is already there, is our code.

#### 1.1.5 <a name='KeepItSmall'></a>Keep it small
Less code the better, less code changes the better. As we like to build one thing at a time we should also built it as simple and focused as possible. Less code makes it better to understand, less code changes make it much more accessible for you and our colleagues as reviewers.

### 1.2 <a name='Donts'></a>Don'ts

#### 1.2.1 <a name='RefactorAheadOfTime'></a>Don't refactor ahead of time
Wait until something is painful to change or understand. Remember that we should keep it small and simple. Refactor without a purpose can lead to complexity, unnecessary abstractions and miscommunication about what you are trying to achieve.

#### 1.2.2 <a name='PrematureOptimization'></a>Premature optimization
In general don't do premature optimization, but always keep in mind that there are some basic techniques that can have big impact. Avoid N+1 queries (take advantage of the logs during development for this). Filter using SQL as long as possible (but keep a balance to avoid over-complicating the code). There are problems that can be avoided at first but don't go to deep blindly if there isn't any reason to.

#### 1.2.3 <a name='UnnecessaryDependencies'></a>Unnecessary dependencies
Before adding a 3rd party library or a dependency think carefully if it's really necessary and the compromises you are making. We don't want to re-invent the wheel but sometimes it could be better to build what we need instead of depend on some library that do that and much more.

When adding a new library to an application, make sure:
* It's well maintained (check when the last commit was made and the number of open issues).
* It's not unnecessarily big and does not introduce a lot of extra dependencies under the hood.
* The license fits within the policy used in the application. Some projects only allow to have libraries using the MIT license, for example. Before adding a library with a more restrictive license, check with the team.

#### 1.2.4 <a name='CommentCodeToRemove'></a>Don't comment code to remove it, just delete it
We have git for god's sake. We can always check a previous commit to find the deleted code.

#### 1.2.5 <a name='RefactorAndAddFeatures'></a>Refactor and add features
Don't build new features and refactor at the same time unless that feature demands it. Focus on your current code and use code refactoring as a tool to achieve our goal. Refactor an unrelated part of the code that has nothing to do with that feature will not bring any value to you, to the reviewer and your codebase.

#### 1.2.6 <a name='DontMakeTypos'></a>Don't Make Typos
Be careful with your typing. Writing classes/methods/variable names, code comments, literal string/page copies and documentation should be free of typos.

Let your editor help you by installing a spell checker. Check [this plugin](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker) if you are using Visual Studio Code. Remember, checking typos is part of code reviews.

#### 1.2.7 <a name='AvoidTODOs'></a>Avoid comments with TODOs
If there is something that you think it should be done create an issue for it. Maybe it will be done right after, or maybe some weeks after. Let that decision be where it belongs, in your project management tool. Your code is not the place to leave tasks descriptions or memos.
