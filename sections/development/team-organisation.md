# Team organisation

We organise the people working on a project in three different roles:

- Project Manager
- Tech lead
- Engineer

In some projects, the same team member can do multiple roles. A common situation is the tech lead doing the project management role or an engineer also managing the communcation with the client.

## Project Manager

Person in charge of the top-level tasks required by the client, communicating between their team and the MarsBased team effectively.

__Duties:__

- __Planning__
  - Set the overall project schedule and the sprints for each project phase.
  - Define all the different areas of the project including the scope, objectives, schedule and tasks.
  - Identify blocking issues compromising the smooth development of the project and provide solutions.
  - Ensure the project completion on time and within budget.
- __Product ownership__
  - Understand client needs and product roadmap.
  - Work with the development team to come up with an efficient solution to client needs.
  - Define specifications for the product features so they are clear for the development team.
- __Organisation__
  - Project kick-off and setup of all the tools required to organise and manage it.
  - Organise project documentation and credentials to ensure all the parties involved have access to it.
  - Upon project completion, deliver the final product to the client as agreed and clean up the tools.
- __Communication and reporting__
  - Agree with clients on channels and frequency of meetings and reports to inform about the progress of the projects.
  - Coordinate meetings with team and clients to ensure the successful execution of each sprint of the project.
  - Communicate proactively with the team and clients providing transparent information on the state of the project and thus avoiding snowball effects.
  - Act as the liaison between clients and engineers.

## Tech Lead

A senior engineer able to take ownership of the code developed by the team and help the client to improve their code. Oftentimes, a sort of interim CTO for the projects, too, able to define architecture and take high-level decisions on critical aspects.

__Duties:__

- Decide the best way to implement the specifications decided by the client's Product Manager.
  - Take into account the project needs and tech debt in order to make the best decision possible, communicating with the Product Manager and the client the possible implications.
- Communicate correctly all the decisions to the engineers.
- [Review the code](/guides/development/code-reviews-guidelines.md) produced by the engineers, ensuring:
  - All the code follows our quality standards at code and architecture levels.
  - The changes introduced meet the requirements needed, no more and no less.
  - The changes don't introduce obvious bugs.
- Write technical specifications for tasks.
- Estimate the effort required to complete each task.
- Perform research tasks to solve complex problems / requirements.
- Decide 3rd party services to use (DevOps, log management, error tracking, etc.)

## Engineer

Engineers are in charge of building and maintaining the software following the previous analysis made by the Project Manager and the Tech Lead.

__Duties:__

- Create the best possible code for each feature, following the guidelines provided by the Tech Lead.
- Test extensively every issue to make sure it doesn't introduce new bugs, either in the feature itself or by producing regressions in the codebase.
  - Not only the happy path!
- Review continuously their own code before passing it to reviewers. The sooner a problem is detected, the faster and easier will be to fix it.
- Release the code effectively, caring not to produce undesired side-effects (like downtime) in production stages.
- Communicate blocking problems, delays and other issues to the Tech Lead in due time.
- Update our task board on a daily basis.

## Engineer - Reviewer contract

Collaboration between tech leads and engineers in a team is governed by the [Engineer - Reviewer contract](/guides/development/developer-reviewer-contract.md). If you are going to work as either an engineer or tech lead, read it carefully because you will need to make sure you comply with it all the time.
