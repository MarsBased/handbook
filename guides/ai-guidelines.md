# MarsBased AI guidelines

AI should help us produce better work, learn faster, and reduce repetitive tasks. We remain responsible for understanding, validating, and communicating everything we produce with it.

## Table of Contents

- [Communication and reporting](#communication-and-reporting)
- [Personal growth and productivity](#personal-growth-and-productivity)
- [Code and technical work](#code-and-technical-work)
- [AI use and security](#ai-use-and-security)

## Communication and reporting

### Only share AI output you have understood, processed, and validated

Forwarding raw output from Claude or another large language model (LLM) creates noise. The person carrying out the task can ask AI themselves. Your contribution should be informed judgment and useful context.

### Read, digest, and summarize AI-generated content before publishing it

This applies to Linear, Slack, Google Drive, blog posts, and newsletters.

AI makes it easy to produce longer texts, but the reader still needs time to process them. Without proper editing, we encourage skim-reading, increase the risk of important information being missed, and waste people's time. Keep the message concise and make the essential points easy to find.

### Client-facing content must reflect your own understanding and voice

Review and edit AI-assisted content so that it reads naturally and meets the same standards as anything you would write yourself.

If a message feels like unedited AI output, clients may question whether we understand the subject or have simply forwarded an answer from Claude. Be prepared to explain and stand behind everything you send.

### Share the problem with a colleague, rather than forwarding AI questions you cannot answer

When AI asks a question you cannot answer, give your colleague the underlying problem and the relevant task context. Explain what you have established so far and what you are confident is correct.

If you cannot answer the AI's question, you may also be unable to judge whether it is relevant to the problem.

## Personal growth and productivity

### Before starting any task, consider whether Claude could help

Keeping up with AI requires regular, deliberate use. Build the habit of considering how it could help with your work (even with small, quick tasks), while always following MarsBased's security policies.

### Automate recurring work

Look for tasks you repeat and use Claude's recurring tasks where appropriate to automate them. This helps you save time and develop practical experience with AI.

### You can use AI to do something you do not yet understand, but you must be able to explain it afterward

Treat unfamiliar AI-generated solutions as an opportunity to learn. Do not settle for a partial explanation. Keep asking questions until you understand the solution well enough to explain it, assess its trade-offs, and justify its use.

### When using AI to improve your writing, compare the original with the revised version

Use AI feedback to learn how to write better and internalize grammar and vocabulary corrections. AI often explains its changes; read those explanations and ask for clarification when needed.

What you learn can also improve your spoken communication.

### Ask for concise answers and iterate instead of writing long prompts and skimming the response

Recent models tend to be verbose by default. It is better to ask for a shorter answer and read it in full than to skim a longer one and miss important information. Ask follow-up questions to explore anything that needs more detail.

If you repeatedly have to ask Claude to be more concise, update your user-level instructions. Revisit those instructions whenever a new model is released.

## Code and technical work

### Use Fable for well-defined tasks and Opus for tasks that require RPI

RPI refers to our [Research / Plan / Implement methodology](/guides/development/ai-augmented-development.md#the-research--plan--implement-rpi-methodology).

Learn what tasks are most suitable for each model by using them. New versions change their capabilities and limitations, so revisit your choices regularly rather than assuming the same model will always be the best fit for a given task.

### Focus code reviews on functionality, architecture, best practices, and duplication

Do not review AI-generated code line by line. Focus on whether the solution works as intended, fits the wider system, follows best practices, and avoids unnecessary duplication.

Pay particular attention to mistakes caused by AI lacking a complete view of the work. Inspect specific implementation details when needed to investigate a concern.

### Understand the scope of the problem and ask AI for a proportionate solution

When asked to design a solution's architecture, AI can overengineer it. Give it enough context about the client's needs and constraints to propose an appropriate approach.

A client may be better served by a pragmatic, well-implemented solution that meets their needs than by a textbook architecture that adds unnecessary complexity.

### Read the automated tests AI generates

AI often generates tests alongside an implementation, and it may produce more than necessary. Review them to ensure they verify meaningful behavior and add value.

Unnecessary tests increase execution time and can create a false sense of security.

### Remove AI-generated code comments that add no value

Unnecessary comments make source code harder to read and maintain. They can also confuse AI tools working on the code later. Keep comments that explain useful context, intent, or non-obvious decisions.

### Turn corrections into repository rules

Whenever you correct the AI, capture the applicable lesson as a rule in the repository. This helps prevent repeated mistakes and supports continuous improvement.

### Keep AI-assisted code reviews focused on actionable issues

Exclude nice-to-have suggestions. AI will often find something to comment on when asked to review code, but many observations are irrelevant. Review feedback should identify meaningful problems that warrant a change.

## AI use and security

Internet access and MCP connections are key areas of security risk.

### Use only connectors approved by MarsBased

If you need another connector, request approval and explain the business need.

### Do not use custom MCPs without MarsBased's approval

Custom MCPs can introduce significant security risks and must be approved before use.

### Never connect an AI agent to production infrastructure

Agents can take destructive actions, including deleting production databases. Use safer alternatives, such as running the agent locally against an anonymized copy of a staging database.

### Disable internet access for Claude Code and Claude Cowork by default

For Claude Code, use sandbox controls to restrict network access as described in the [Sandboxing section of our AI Augmented Development guide](/guides/development/ai-augmented-development.md#sandboxing).

### Pay close attention to internet access in Claude Desktop and Claude Web

Even without access to your local files, these tools may have access to MCP connections and, through them, MarsBased data available to your account. Consider that access when enabling internet capabilities.

### Do not import cookies or existing sessions into Claude's embedded browser

Importing cookies or sessions may give the agent access to your email or other services you did not intend it to access.
