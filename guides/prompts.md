# 🧠 Prompt Engineering 101

## 🎯 Goal

Learn how to write better prompts to get the most out of ChatGPT and similar tools — for _all_ kinds of tasks, not just coding.

---

## 🚀 Why This Matters

Most people write prompts like this:

> “Explain X”  
> “Write code for Y”  
> “What’s a good name for a feature?”

That’s the equivalent of Googling "stuff".

Let’s go pro.

---

## 📦 Core Concepts of Prompting

### 1. **Context is King**

LLMs love context. The more you give, the better the output.

> ❌ “Write a blog post about AI.”  
> ✅ “Write a 500-word blog post about how small dev agencies like MarsBased can use AI to automate documentation. Audience: CTOs. Tone: witty but professional.”

> ✅ “You're a senior backend dev at MarsBased. Given this GitHub issue, propose 3 implementation options with tradeoffs.”

---

### 2. **Role Assignment**

> “You're a senior full-stack dev.”  
> “Act like a sassy but accurate technical recruiter.”  
> “You're a product manager writing internal release notes.”

Roles change everything. Try it.

---

### 3. **Examples > Explanations**

Few-shot prompting is powerful.

> ❌ “Write me an error message.”  
> ✅ “Here are 2 examples of error messages from our system:\n\n1. 'We couldn’t connect to GitHub. Check your token.'\n2. 'Your session expired. Please log in again.'\n\nNow write a message for a failed API sync with Linear.”

---

### 4. **Constraints Help**

> “Explain this like I’m five.”  
> “Summarize this in 3 bullet points.”  
> “Reply in markdown, use emojis.”  
> “Write code with comments in Spanish.”

Constraints = better outputs.

---

### 5. **Iterate, Don’t Expect Magic**

You’re allowed to keep going:

> “That’s too long. Can you shorten it?”  
> “Add more sarcasm.”  
> “Use TypeScript instead.”  
> “Rewrite using a more optimistic tone.”

LLMs love feedback.

---

## 🔧 Dev Use Cases

- 🔍 Debugging:  
  Paste an error and ask for causes + fixes.
- 📄 PR Summaries:  
  “Summarize this PR in 3 sentences for a non-dev.”

- 🧠 Naming things:  
  “Suggest 10 function names. Context:…”

- 📜 Commit messages:  
  “Write a conventional commit for this diff.”

- 🤖 GitHub Copilot prompts:  
  Use natural language to write comments that guide code generation.

---

## 💼 Non-Dev Use Cases

- ✍️ Docs:  
  “Turn this bullet list into internal documentation.”  
  “Write a changelog based on these commits.”

- 📣 Marketing:  
  “Write a tweet thread from this blog post.”  
  “Summarize this podcast transcript for LinkedIn.”

- 📅 Planning:  
  “Create a rough roadmap based on these 4 Linear issues.”

- 🧑‍🏫 Hiring:  
  “Generate 5 technical interview questions for a senior Vue dev.”

---

## ⚙️ Bonus: API-Level Prompting (1 Minute)

If using OpenAI's API:

```json
{
  "model": "gpt-4o",
  "temperature": 0.7,
  "messages": [
    { "role": "system", "content": "You are a senior Rails engineer." },
    { "role": "user", "content": "Explain the pros and cons of Hotwire." }
  ]
}
```

- **system**: Sets the role/persona
- **user**: The actual prompt
- **temperature**: 0 = deterministic, 1 = creative/random

## 🎁 Cheat Code: Prompt Structure

- [Persona or role]
- [Clear task]
- [Context]
- [Constraints]
- [Optional: examples]
- [Optional: output formatting]

🔥
