# AI Augmented Development

At MarsBased, all developers use [Claude Code](https://claude.ai/download) as our primary AI coding tool. Rather than treating AI as a glorified autocomplete, we follow a structured methodology that keeps humans in control of decisions while letting AI handle the heavy lifting.

This guide covers how we work with AI coding agents, the methodology we follow, and how we set up our environment for consistent results.

## The Research / Plan / Implement (RPI) methodology

Unstructured "vibe coding" with AI agents produces unreliable results. We follow the **Research / Plan / Implement** framework to keep quality high and mistakes contained.

Each phase runs in a fresh context window so that irrelevant information from previous steps does not degrade output quality.

### Research

Map the problem space without writing any code. The goal is to understand the codebase, dependencies, data flows, and constraints relevant to the task. Document findings so they can be carried into the next phase.

- Explore files, dependencies, and architecture related to the task.
- Summarize what you found: what exists, what's missing, what's tricky.
- Do not write implementation code during this phase.

### Plan

Create a detailed, step-by-step execution plan based on your research. We use Claude Code's **plan mode** (`/plan`) for this phase. Plan mode forces Claude to think through the approach and produce a structured plan before writing any code.

The plan should be specific enough that implementation becomes almost mechanical. A bad step in a plan produces hundreds of wrong lines of code, so catching mistakes here is far cheaper than catching them later.

- Break the work into numbered, sequential steps.
- Each step should reference specific files and describe the change.
- Instruct Claude to ask you whenever it faces a decision with multiple possible choices, rather than picking one silently. This keeps you in the loop on trade-offs and prevents wrong turns.
- Review the plan before moving on. Does it solve the right problem? Is the approach sound?

### Implement

Execute the plan. For larger tasks, break implementation into chunks, each in a separate context window, to keep context utilization manageable.

- Follow the plan step by step.
- Flag deviations: if you need to diverge from the plan, note why.
- Review the output against both the requirements and the plan.

### Three review points

Human judgment applies at three moments, not just at the end:

1. **After Research** — Are we solving the right problem?
2. **After Plan** — Is the approach sound?
3. **After Implementation** — Does the output match requirements and plan?

## CLAUDE.md and rules

Claude Code starts every session with a fresh context window. `CLAUDE.md` files give it persistent instructions so you don't re-explain the same things every time.

We maintain a project-level `CLAUDE.md` in every repository with:

- Build and test commands.
- Project conventions and architecture decisions.
- Common workflows and gotchas.

For more granular control, we use `.claude/rules/` files scoped to specific file types or directories (e.g., testing conventions that only load when working on test files).

Keep instructions concise, specific, and verifiable. "Use 2-space indentation" works better than "format code nicely."

## Context management

The context window is finite. How you manage it directly affects output quality. Key practices:

- **Start fresh for new tasks** — Use `/clear` when switching to an unrelated task.
- **Rewind over correction** — If Claude goes down a wrong path, use `/rewind` to go back instead of asking it to fix its own mistakes. Then re-prompt with what you learned.
- **Compact when needed** — Use `/compact` when a session feels bloated with stale debugging context.
- **Delegate noisy work to subagents** — When a task generates lots of intermediate output you won't need again (large searches, verification), let a subagent handle it so your main context stays clean.

## Skills and subagents

**Skills** are reusable, project-specific workflows packaged as prompts. They load on demand when you invoke them (e.g., `/review`, `/commit`) rather than occupying context at all times. We use skills for repetitive workflows like code reviews, commit message generation, and PR creation.

**Subagents** are independent Claude Code instances that run in isolation with their own context window. A useful mental model: treat a subagent the way you would treat someone you're delegating work to. When you identify a task you would hand off to a colleague — self-contained, well-defined, with a clear deliverable — that's a good candidate for a subagent. You scope the work, hand it over, and get back a result without being involved in the intermediate steps.

A concrete example is the `pr-code-reviewer` agent. When a PR is ready for review, open a terminal, start Claude, and share the GitHub PR URL. The agent fetches the diff, evaluates it against a defined checklist — security, naming, test coverage, SOLID principles, commit conventions — and returns a structured review draft. Code review becomes something you delegate rather than something you do yourself.

We don't default to subagents. We only reach for them when there is a clear reason:

1. **Parallelization** — When multiple independent tasks can run simultaneously (e.g., researching two unrelated parts of the codebase at once).
2. **Specific isolated tasks** — When a well-defined task would generate large amounts of intermediate output that would pollute the main session (e.g., broad codebase searches, running verification suites).

Only the final result of a subagent returns to your main context, keeping it clean. If the task doesn't clearly benefit from parallelization or isolation, work directly in your main session.

## Hooks

Hooks are shell scripts that Claude Code runs automatically at specific points during a session — before reading a file, after writing one, when a tool is called, and so on. They run outside of Claude's context and cannot be overridden by prompts, which makes them the right place to enforce hard rules.

We use hooks for two main purposes:

- **Security** — to prevent Claude from reading files that contain secrets or credentials, regardless of what the task is or what it is asked to do.
- **Static analysis and formatting** — to run tools like Prettier, ESLint, or RuboCop automatically after Claude modifies a file, so the codebase stays consistent without Claude having to remember to do it. For example, we run Prettier on every TypeScript file Claude edits.

### Pre-read hook

Our `pre-read` hook runs before Claude reads any file. It blocks access to:

- **Credential files** — any file whose name starts with `.env` (`.env`, `.env.local`, `.env.production`, etc.) and `.netrc`.
- **Sensitive directories** — `.ssh`, `.aws`, `.gnupg`, `.kube`, and `.docker`.

If Claude tries to read a blocked path, the hook exits with a non-zero code and returns a `BLOCKED:` message. Claude Code surfaces this as an error and does not proceed with the read.

The hook lives at `.claude/hooks/pre-read.sh` in the project repository and is wired up in `.claude/settings.json` under the `hooks` key.

## Resources

- [How I work with AI coding agents (Daz)](https://daz.is/blog/how-i-work-with-ai-coding-agents/) — Deep dive into the RPI framework: how to structure research, write effective plans, and implement in chunks while keeping context quality high.
- [Research, Plan, Implement (Tyler Burleigh)](https://tylerburleigh.com/blog/2026/02/22/) — Practical walkthrough of RPI with concrete examples of `RESEARCH.md` and `PLAN.md` artifacts, phased implementation, and git-based rollback strategies.
- [Session management and the 1M context window](https://claude.com/blog/using-claude-code-session-management-and-1m-context) — Anthropic's guide to managing Claude Code sessions: when to clear, rewind, compact, or delegate to subagents.
- [How Claude remembers your project](https://code.claude.com/docs/en/memory) — Official documentation on CLAUDE.md files, `.claude/rules/`, auto memory, and how to write effective persistent instructions.
- [Claude Code in Action](https://anthropic.skilljar.com/claude-code-in-action) — Anthropic's hands-on training course covering Claude Code architecture, tool usage, context management, MCP servers, and GitHub integration through video lessons and projects.
