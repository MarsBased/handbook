#  Team organization

- 1. [Project Manager](#ProjectManager)
- 2. [Tech Lead](#TechLead)
- 3. [Developer](#Developer)
- 4. [Developer - Reviewer contract](#Contract)

We organize the people working on a project in three different roles:

- Project Manager
- Tech lead
- Developer

In some projects, the same team member can do multiple roles. A common situation is the tech lead doing the project management role.

## 1. <a name='ProjectManager'></a>Project Manager

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

## 2. <a name='TechLead'></a>Tech Lead

Senior developer able to take ownership on the code developed by the team and help the client improve their code.

Responsibilities:

- Decide the best way to implement the specifications decided by the Product Manager.
  - Take into account the project needs and tech debt in order to make the best decision possible, communicating with the Product Manager and the client the possible implications.
- Communicate correctly all the decisions to the developers.
- [Review the code](/guides/development/code-reviews-guidelines.md) produced by the developers, ensuring:
  - All the code follow our quality standards at code and architecture levels.
  - The changes introduced met the requirements needed, no more and no less.
  - The changes don't introduce obvious bugs.
- Write technical specifications for tasks.
- Perform research tasks to solve complex problems / requirements.
- Decide 3rd party services to use (DevOps, log management, error tracking, etc.)

### 3. <a name='Developer'></a>Developer

Developers are in charge of building and maintaining the software following the previous analysis made by the Project Manager and the Tech Lead.

Responsibilities:

- Create the best possible code for each feature, following the baselines provided by the Tech Lead.
- Test extensively every issue to make sure it doesn't introduce new bugs, neither in the feature itself nor by producing regressions in the codebase.
  - Not only the happy path!
- Continuously reviews its own code before passing it to reviewers. The soon any problem is detected, the fastest and easiest will be to fix it.
- Release the code effectively, caring to not produce undesired side-effects (like downtime) on production.
- Communicate blocking problems, delays and other issues to the Tech Lead.

### 4. <a name='Contract'></a>Developer - Reviewer contract

Collaboration between tech leads and developers in a team is governed by the [Developer - Reviewer contract](/guides/development/developer-reviewer-contract.md). If you are going to work as either a developer or tech lead, read it carefully because you will need to make sure you comply with it all the team.
