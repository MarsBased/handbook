# Coding guidelines

Responisble: José Malaca

Reference structure https://github.com/MarsBased/marsgular/blob/master/docs/ANGULAR_STYLE_GUIDE.md (open to modification, but David might get mad at you)

Do's
* Keep code simple
  * Don't try to impress us with design patterns, complex abstractions or over-engineering.
  * We will be impressed if the code is simple, easy to understand, variables and methods have good naming, methods are short, classes are small, code is properly organized.
* Naming is key: spend some time looking for good classes / variables / method names. Use long and descriptive names for both variables and functions/methods. Never use 1 char variables.
* Remove unused code. When we stop using a feature or part of the code remove it and any other unused code as a consequence.
* Create new issues instead of writing TODO comments in the code.
* Less code the better, less code changes the better.

Dont's
* Don't refactor ahead of time. Wait until something is painful to change/understand to refactor it.
* In general we don't do premature optimization, but keep in mind some basic elements that have a big impact. Avoid N+1 queries (always be looking at the application logs during development), filter using SQL as long as possible (but keep a balance to avoid over-complicating the code).
* Don't add unnecessary dependencies. Before adding a 3rd party library or a dependency, think carefully if it's really necessary and the compromises you are making.
* Don't comment code to remove it, just delete it. We just git for something for godsake.
* Don't comment the WHAT of a piece of code only the why, if necessary.
  * Comment code only if you believe that the solution you've chosen might need extra context to be understood. Focus on the WHY instead of the WHAT.
* Do not refactor and add features at the same time.
  * Unless required for the functionality we are writing.
  * So to clarify: it's ok to refactor code to fit with a new feature we are writing, it's not ok to refactor an unreleated part of the code that has nothing to do with that feature.
