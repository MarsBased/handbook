# The MarsBased GEO Guidelines

GEO (Generative Engine Optimization) is the practice of making a site easy for LLM-based systems (ChatGPT, Claude, Perplexity, Google AI Overviews) to read, quote, and cite correctly. It's SEO's younger sibling: same goal (be found and trusted), different reader (a model summarizing your page instead of a crawler ranking it).

These guidelines are distilled from the AI-discoverability work we shipped on marsbased.com itself. The site's own codebase (internally worked on as `mbweb`, and named `Perseverance` on GitHub) is where we built and hardened every pattern below (mainly Linear tickets WEB-513, WEB-574, WEB-577, WEB-579 and WEB-588). We treat our own site as the reference implementation: everything below is running in production, not theory.

---

## Principles

1. **Give LLMs a clean, dedicated version of your content.** Don't make a model scrape and guess at your HTML. Offer plain Markdown as a first-class citizen.
2. **Only expose what's worth citing.** Not every URL deserves a Markdown twin: ephemeral, list-only, or messily-sourced pages should be excluded rather than degrade the average.
3. **An unauthenticated content-rendering endpoint is an attack surface.** Treat it with the same care as any other public endpoint: bound its cost, cache it, and don't let it become a DoS or content-sniffing vector.
4. **Don't block AI crawlers by default.** Being cited by an answer engine is closer to earned media than to a scraper stealing your content; allow it unless a client has an explicit reason not to.
5. **Structure content the way a model would want to quote it.** Clear headings, direct answers, FAQ-style Q&A, and schema.org markup all make extraction easier and more accurate (see our [schema.org guidelines](/guides/schema.md)).

---

## `llms.txt` and `llms-full.txt`

[llms.txt](https://llmstxt.org) is the emerging convention for a machine-readable "map" of your site, similar in spirit to `sitemap.xml` but written in prose for a model instead of markup for a crawler. We serve it at the root and mirror it per locale.

- **`llms.txt`**: short, a one-paragraph summary of who you are, followed by a curated, categorized list of your most important pages with one-line descriptions. Written in the company's real voice, not boilerplate.
- **`llms-full.txt`**: the long-form companion, a fuller written profile (methodology, differentiators, how you work) for a model that wants more context than the link list gives it.
- **Mirror both per locale** (e.g. `/es/llms.txt`, `/es/llms-full.txt`) if the site is multilingual.
- **Point every page entry at its Markdown version**, not the HTML page, using a documented, predictable convention (see below).
- Keep both files curated by hand. This is editorial surface, not a generated dump; treat it like you'd treat the homepage copy.
- **Write explicit negative framing where it prevents mischaracterization**: a short "what we don't do" list (e.g. we don't train models, don't build gambling platforms, don't do body-shopping) helps a model avoid confidently getting your positioning wrong.
- **Put a recurring review on the calendar.** Content drifts: services get renamed, case studies get added, methodology evolves. We keep a quarterly Linear ticket ("Quarterly review of llms.txt") specifically to re-read both files against the current site and correct anything stale.

Reference implementation: [`public/llms.txt`](https://marsbased.com/llms.txt) and [`public/llms-full.txt`](https://marsbased.com/llms-full.txt) on marsbased.com.

---

## Per-page Markdown (`.md` convention)

Alongside `llms.txt`, expose a clean Markdown version of every citation-worthy page by appending `.md` to its URL, e.g. `/services/ruby-on-rails` → `/services/ruby-on-rails.md`. Document this convention explicitly in `llms.txt` so a model (or a person) can derive it for any URL without guessing.

### Scope it to high-value pages

Not everything should get a Markdown twin. Exclude:
- **Ephemeral or low-value pages**: newsletters (their HTML is often messy, e.g. pasted-in Mailchimp markup), job listings that expire.
- **List-only pages**: blog tag/author index pages that are just links, not content.
- Point their `llms.txt` entries at the HTML page instead of a `.md` that isn't worth serving.

Keep the exclusion list as an explicit allow/deny function in code (path prefixes and exact matches), not scattered conditionals; it should be trivial to see, at a glance, what is and isn't exposed.

### Prefer build-time generation over render-on-demand

For anything prerendered (static pages), generate the `.md` file at build time as a sibling of the `.html` file, and let it get served straight off disk. Reserve on-demand rendering for genuinely dynamic (SSR) pages only. This one decision closes most of the "render amplification" attack surface described below: a bogus `.md` path for a static page is a cheap 404, not a render.

### Conversion quality

Server-render the page, extract the main content region, strip non-content nodes (`script`, `style`, `noscript`, `svg`, `iframe`, `form`, `button`, visually-hidden/decorative elements), and convert to Markdown (we use [Turndown](https://github.com/mixmark-io/turndown)). A few conversion details matter more than they look:

- **Emit one clean H1 from the page `<title>`** (brand suffix stripped, e.g. "Ruby on Rails - MarsBased" → "Ruby on Rails"), rather than keeping whatever in-page `<h1>` exists; this avoids duplicate or awkwardly-styled headings.
- **Prepend the meta description as a blockquote**, and always include a `Source:` line with the canonical URL, so a model that later quotes the page can attribute it correctly.
- **FAQ accordions** (`<details>`/`<summary>`) should convert to real headings (e.g. `## Question text`), not a flattened paragraph; this is what preserves the Q&A structure that both models and `FAQPage` schema rely on.
- **Card titles wrapped in links** (`<a><h3>Title</h3></a>`) need a custom rule too, or Turndown's default nesting produces broken output like `[\n\n### Title\n\n](url)` instead of `### [Title](url)`.
- **Image-only content with no visible text** (e.g. a logo grid using `role="img"` + `aria-label` with a background-image) needs its `aria-label` promoted into a real text node before conversion, or the model gets an empty link.
- **Absolutize root-relative links** (`](/foo` → `](https://yoursite.com/foo`) so the Markdown is self-contained wherever it's fetched from.

### Security and performance hardening

An unauthenticated "render any path as Markdown" endpoint is a DoS and content-sniffing surface if you don't bound it:

- **`X-Content-Type-Options: nosniff`** on every `.md` response (and its 404): Markdown can contain passed-through HTML fragments; don't let a sniffing client reinterpret it as HTML.
- **A single, timeout-bounded self-fetch per request** (we use 5s) when rendering on demand: don't retry across multiple origins, since that just multiplies the cost an attacker can trigger per request.
- **A loop guard header** (e.g. `x-llms-md: 1`) on the internal self-fetch so a Markdown render can never trigger another Markdown render.
- **`redirect: 'manual'` on the self-fetch**, so a redirect alias (e.g. `/community` → `/company/community`) 404s instead of silently serving Markdown with a misleading `Source:`. The `.md` endpoint should only ever serve canonical URLs.
- **`X-Robots-Tag: noindex`** on `.md` responses: you want models fetching this content, not search engines indexing it as a duplicate page.
- **Cache aggressively at the edge**, including 404s, so repeated bogus `.md` requests are absorbed by the CDN rather than hitting your origin every time. Canonicalize the cache key (strip query strings) so `?x=1`, `?x=2`, … can't bust the cache.
- **Log self-fetch failures and 5xx upstreams as warnings**, distinct from a genuine 404; otherwise an infrastructure failure just looks like a missing page and is undebuggable.
- If the endpoint remains unauthenticated and render-on-demand for any path, note **edge rate-limiting on `*.md`** as a follow-up with infra: it's the cheapest additional mitigation once the above is in place.

### Test it like any other public endpoint

Cover at minimum: the URL-matching logic (what counts as a `.md` request), the exclusion/eligibility rules, title cleaning, the happy path (headers, content extraction, canonical source line), the loop guard, redirect-alias handling, and the error path (self-fetch throws, so it should produce a clean 404, not a crash).

---

## Robots.txt: don't block AI crawlers

Unless a client has a specific reason to opt out, allow AI crawlers the same way you allow search engines:

```plaintext
User-agent: *
Allow: /

Sitemap: https://www.example.com/sitemap-index.xml
```

A blanket `Allow: /` for `User-agent: *` already covers `GPTBot`, `ClaudeBot`, `PerplexityBot`, `Google-Extended`, and friends by omission; there's no strictly-necessary reason to enumerate them individually unless you want to grant or deny a specific one differently from the rest. Being cited by an AI answer is exposure, not theft; default to open.

That said, an *implicit* allow is a decision nobody actually made: it's worth making the choice explicit rather than relying on a blanket rule to cover crawlers it was never written with in mind. If a project cares about this, list the AI crawlers you've deliberately decided to allow (or, for a client with real reason to opt out, block) as their own `User-agent` blocks, rather than assuming the wildcard rule already reflects an intentional decision.

---

## A dedicated FAQ page, written to be quoted

Beyond FAQ accordions embedded in service pages, ship a standalone FAQ page answering the real questions your ICP (ideal customer profile) asks before hiring you: availability, team composition, how scoping/kickoff works, pricing approach, IP/NDA handling, how AI fits into your process, references, how you control scope creep, compliance status (e.g. GDPR, ISO 27001), and flexibility to scale up or down.

- **Each answer should stand alone as a quotable snippet**: a sentence or two that reads correctly even lifted out of context by an AI Overview, with no "as mentioned above" or other reference to surrounding content.
- **Answer the question directly first**, then add nuance; don't bury the actual answer under a paragraph of preamble.
- Mark the page up with `FAQPage` JSON-LD matching the visible `Question`/`acceptedAnswer` pairs exactly, in addition to whatever `WebPage` node the page already carries.

## Structured data and Knowledge Graph signals

GEO and schema.org markup reinforce each other: a model extracting your page benefits from the same clear entity/answer structure that search engines do. See our [schema.org implementation guidelines](/guides/schema.md) for the full approach, but a few patterns are specifically about being correctly resolved as an *entity* by AI systems, not just ranked as a page:

- **Enrich the sitewide `Organization` node** beyond the bare minimum: `legalName`, `description`, `foundingDate`, `foundingLocation`, `address`, `contactPoint`, `numberOfEmployees`, `knowsAbout` (your real areas of expertise), and a `founder` array of `Person` nodes (each with its own `@id` and `sameAs` linking to their real LinkedIn/GitHub). This is what strengthens Knowledge Graph eligibility and helps a model disambiguate who you are.
- **Never invent a field to fill out the schema.** If there's no on-site search, skip `SearchAction`. If you don't have a larger logo asset, don't fake the dimensions. Trust signals cut both ways: invented structured data is a liability the moment a model (or a person) cross-checks it against the visible page.
- **`FAQPage`** on any page with real Q&A content: mark it up as `Question`/`acceptedAnswer` pairs matching the visible accordion content exactly.
- **Conversational, direct-answer content structure** in general: a clear question as a heading, followed immediately by a direct answer, is both good `FAQPage` markup and good Markdown once converted.

---

## Meta descriptions and titles written for lifting

AI Overviews and answer engines frequently lift your meta description verbatim as the summary shown alongside a citation. Treat these fields as GEO copy, not an SEO afterthought:

- **Titles**: aim for 50–60 characters, specific rather than generic (avoid boilerplate like "Home | Company Name" repeated across pages).
- **Descriptions**: aim for 150–160 characters, a direct, complete sentence describing the page, not a keyword list or a generic company tagline reused everywhere.
- Rewrite anything that reads like it was auto-generated or copy-pasted across page types; it reads just as poorly lifted into an AI answer as it does in a search result.

---

## QA checklist

Before shipping GEO work on a project:

1. `llms.txt` and `llms-full.txt` exist, are mirrored per locale if applicable, are curated (not templated boilerplate), and have a recurring review scheduled.
2. Every important page category (services, work/case studies, company, blog) has a working `.md` twin; low-value pages (newsletters, expiring listings, tag/author indexes) are explicitly excluded, not accidentally broken.
3. Static pages generate their `.md` at build time; only genuinely dynamic pages render on demand.
4. The `.md` endpoint has: `nosniff`, a bounded single self-fetch with a timeout, a loop guard, manual redirect handling, `noindex`, and edge caching (including on 404s).
5. Converted Markdown reads cleanly: one H1, correct brand-stripped title, a `Source:` line, no mangled links or empty image labels, no leftover script/style/decorative noise.
6. `robots.txt`'s stance on AI crawlers is a deliberate decision, not an accident of the wildcard rule.
7. A dedicated FAQ page exists with short, self-contained, directly-quotable answers to real ICP questions, marked up with `FAQPage` schema.
8. The sitewide `Organization` node is enriched with real, verifiable facts (founders, expertise, contact, address); nothing invented to fill a field.
9. Meta titles (50–60 chars) and descriptions (150–160 chars) are specific and non-generic per page, not boilerplate reused across page types.
10. Unit tests exist for the URL-matching, eligibility, and rendering logic; this is production code serving the public internet, not a one-off script.
