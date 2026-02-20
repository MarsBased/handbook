## AI at MarsBased

### Why we use AI

We use AI to remove busywork, accelerate learning, and improve consistency, without lowering our quality bar. In practice, that means using AI for drafting, summarizing, exploring options, and speeding up repetitive tasks, while keeping humans accountable for decisions and deliverables.

We also build AI-first products for clients, including LLM apps, automations, and MCP servers under our GPTApps initiative.

### Principles

1) Humans own the output.
If AI helped, a Martian still owns the final result: correctness, security, tone, and fit for the audience.

2) Protect client and company data.
Treat third-party AI tools like any other external vendor. Do not paste sensitive data unless we have an explicit, vetted setup for it.

3) Prefer high-impact, narrow AI.
Our best results typically come from small, well-defined AI capabilities embedded into real workflows (not "AI everywhere"). 

4) Assume hype, verify reality.
Many AI tools look good in demos and fail under real constraints. Validate with tests, edge cases, and measurable outcomes.

### Toolstack and what we use it for

This list is descriptive (what we actually use) and not a blanket approval to put sensitive data into any tool.

- Google Gemini (meeting notes / recordings)
  We record weekly internal meetings and client/relevant meetings, and store recordings and notes in the project's "Meeting notes" folder in Google Drive.

- Google Drive (company and project documents)
  All company documents live in the shared drive called "MarsBased". Be cautious with external sharing; it is easy to share and hard to audit later.

- 1Password (credentials and access)
  We store logins and confidential access information in 1Password vaults (company-wide and per-project). Keep vault entries tidy and up to date.

- Prompting practices (for ChatGPT, Gemini, and similar)
  We expect people to write prompts with context, role, examples, and constraints, and to iterate instead of expecting magic.

- Content tooling (marketing/podcasting)
  We have used AI features in tools like Buzzsprout, Auphonic, and Capcut to speed up marketing and media production workflows.

### Hard rules

1) No agentic browsers on work devices with access to passwords, company tools, or client data.
This is strictly prohibited until the security model is enterprise-ready.

2) Do not paste secrets into prompts.
No passwords, tokens, private keys, session cookies, or internal-only credentials. Use 1Password for secrets.

3) Do not paste client confidential data into public AI tools.
If you need AI help with client material, prefer anonymized/redacted snippets and only the minimum required context.

4) AI output is never "done" without review.
If it ships (code, copy, client-facing docs), it gets the same review standards we apply everywhere else.

### What AI is good for at MarsBased

Use AI aggressively for these, with normal review:

- Drafting and rewriting
  Internal docs, proposals, meeting agendas, release notes, blog drafts (then edited by a human).

- Summaries and extraction
  Turning long notes into action items, extracting decisions, converting meeting transcripts into structured follow-ups (this is a key reason we record and store meeting notes consistently).

- Ideation and tradeoffs
  Getting 2-3 implementation options with pros/cons before picking a direction (especially useful early in discovery).

- Code assistance (paired with tests and review)
  Debugging hypotheses, scaffolding, refactors, generating PR summaries, or producing small helpers. Our prompt guide includes practical dev and non-dev use cases.

- Micro-features that unlock leverage
  We have repeatedly seen value in AI as a focused module inside a broader product (e.g., matching, summarization, translation, classification), where success can be measured.

### What AI is not good for (or needs extra caution)

- "Vibe coding" for production systems
  Rapid generation can be useful for side projects and prototypes, but it often breaks down for correctness, maintainability, and security unless a real engineer takes over. The ecosystem also attracts non-technical builders who may iterate endlessly without getting to robust outcomes.

- Style consistency by default in generative visuals
  For brand visuals, naive approaches (like assuming a custom GPT "learns" a visual style from uploaded images) do not work reliably. If we use AI images, we follow a controlled workflow that emphasizes reference context and post-production checks.

- Unverified facts
  AI will confidently invent details. For anything factual, financial, legal, security-related, or client-committing, verify via primary sources.

- Security-sensitive workflows
  Any workflow that touches secrets, access, or client-restricted systems should avoid autonomous tools and prefer audited, least-privilege approaches (aligned with our general security posture).  [oai_citation:15‡handbook.marsbased.com](https://handbook.marsbased.com/our-development-guides/security)

### How we use AI on client projects

We build AI features when they are tied to a concrete user outcome, measurable impact, and a clear operating model (cost, latency, privacy, failure modes).

Common project shapes we deliver:
- LLM apps and connectors, including interactive components inside assistants.  [oai_citation:16‡GPTApps Blog](https://blog.gptapps.dev/introducing-gptapps/)
- MCP server development to expose enterprise or platform data safely to AI assistants.  [oai_citation:17‡GPTApps Blog](https://blog.gptapps.dev/introducing-gptapps/)
- AI automation to replace repetitive internal processes.  [oai_citation:18‡GPTApps Blog](https://blog.gptapps.dev/introducing-gptapps/)
- Strategy and implementation guidance focused on ROI and realistic adoption.  [oai_citation:19‡GPTApps Blog](https://blog.gptapps.dev/introducing-gptapps/)

### Practical guidance: prompting standards

If you ask AI for help, do not write "Explain X". Provide:
- Role/persona (who the assistant should be)
- Task (what you want)
- Context (code snippet, constraints, audience, stack)
- Constraints (format, length, tone, definitions)
- Examples (when output style matters)

This is documented in our "Prompt engineering basics" guide and should be the default for internal use.  [oai_citation:20‡handbook.marsbased.com](https://handbook.marsbased.com/our-guides/prompts)

### Reporting issues and improving the policy

If you find a workflow where AI creates risk (security, client trust, data leakage) or repeatedly produces low-quality results, raise it in the team and propose an update to this section. This policy should evolve with real usage, not trends.
