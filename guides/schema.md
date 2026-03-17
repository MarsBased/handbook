# MarsBased schema.org guidelines (JSON-LD)

Schema.org structured data helps search engines and other systems understand what a page is about. Done well, it improves clarity, supports eligibility for rich results where supported, and reduces ambiguity for entity-based retrieval. As such, we think it's critical to any public-facing project we develop to correctly implement this.

This is a practical, developer-focused guide for how we implement and maintain schema.org at MarsBased.

## Principles

1. **Mark up what the user can see:** Structured data must reflect the visible, user-facing content of the page. If the markup claims things the page does not show, it is a liability (validation issues, manual actions, or simply ignored markup). There are a few exceptions, which we will cover later.

2. **Prefer JSON-LD:** We use JSON-LD because it is easier to generate, test, and maintain than Microdata embedded across templates. We stopped putting schema in Microdata the moment we had to debug it across templates because it's very easy to skim through HTML and not see some fields and schema.org annotations you wanted to modify or get rid of.

3. **Think in entities and relationships, not fields:** A page is not "a blob of properties". It is typically a small graph: Organization -> WebSite -> WebPage -> mainEntity (Article, Service, Product, JobPosting, etc).

4. **Use stable IDs to connect nodes:** Use "@id" to link nodes across the graph. This prevents duplicate entities and keeps the markup coherent as the site grows.

5. **Keep it minimal, correct, and testable:** More markup is not automatically better. Aim for the smallest graph that is accurate, consistent, and validated.

## What we implement by default

Most sites we build should implement these baseline nodes, at least.

### 1) Organisation (site-wide)
Used to define the publisher and the entity behind the website. In the case of our website, MarsBased is our organisation.

Recommended:
- "@type": "Organization" (or "LocalBusiness" if truly local-first)
- "name"
- "url"
- "logo" (as an ImageObject if possible)
- "sameAs" (only real profiles - like social media)
- "contactPoint" (optional but useful)

### 2) WebSite (site-wide)
Defines the website as an entity.

Recommended:
- "@type": "WebSite"
- "@id"
- "url"
- "name"

Optional:
- "potentialAction" with "SearchAction" if the site has a real on-site search.

### 3) WebPage (per page)
Represents the page URL and ties it to the primary thing described.

Recommended:
- "@type": "WebPage"
- "@id"
- "url"
- "name"
- "isPartOf": WebSite "@id"
- "about" or "mainEntity": the primary entity of the page (see below)

### 4) BreadcrumbList (per page, if breadcrumbs exist)
Only add it if breadcrumbs exist in the UI. CMSs (Content Management Systems) often make use of breadcrumbs in their UIs.

## Page-type guidelines (pick the primary entity)

Each page should have a clear primary entity in structured data.

### Article / BlogPosting (content pages)
Use for posts, guides, case studies, and editorial content.

Recommended:
- "@type": "BlogPosting" or "Article"
- "headline"
- "description" (should match the page summary)
- "image" (URL or ImageObject)
- "author" (Person or Organization)
- "publisher" (Organization "@id")
- "datePublished"
- "dateModified"
- "mainEntityOfPage": WebPage "@id"

Notes:
- Always update "dateModified" when content changes materially. For instance, if you edit a blog post, your CMS should automatically do it.
- Keep author data consistent site-wide (same name, same "@id").

### Service (service landing pages)
Use for agency service pages describing what we provide. In our case, every page under https://marsbased.com/services

Recommended:
- "@type": "Service"
- "name"
- "description"
- "provider": Organization "@id"
- "areaServed" (only where true)
- "serviceType" (optional)
- "offers" (optional, only if pricing is actually shown)

Notes:
- Avoid inventing prices in schema if the page does not show them.

### Product / SoftwareApplication (product pages)
Use if a page describes a sellable product or software. Critical for e-commerce sites.

Recommended for Product:
- "@type": "Product"
- "name"
- "description"
- "image"
- "brand" (if applicable)
- "offers" (only if price/availability is shown)

Recommended for SoftwareApplication:
- "@type": "SoftwareApplication"
- "name"
- "applicationCategory"
- "operatingSystem" (if relevant)
- "offers" (only if price is shown)

Notes:
- If you cannot support key commerce fields with real page content, do not force Product markup.

### JobPosting (careers)
Use for job pages.

Recommended:
- "@type": "JobPosting"
- "title"
- "description" (can be the main job body)
- "hiringOrganization": Organization "@id"
- "datePosted"
- "validThrough" (important for stale listings)
- "employmentType"
- "jobLocationType" for remote roles
- "applicantLocationRequirements" for remote eligibility (country/region)
- "directApply" (only if it truly applies)

Notes:
- Keep job structured data aligned with the current job status. Expired roles should be removed or closed via the page content and schema.
- The location requirements content type have changed a few times over the years. Use a validator to ensure you're using the correct format/entity.

### Other entities

"FAQPage" and "HowTo" entities are becoming more and more popular, in line with the conversational kind of content preferred by LLMs and crawlers of companies like Perplexity, ChatGPT, Claude and the like.

"Person", although is only mentioned in passing for author @id, it deserves a good mention since companies like MarsBased publish a lot of authored content (blog, case studies, podcasts, news). Having a profile for each person in the company helps to build their profile and rank better in authority.
Related to that, paginated content (blog index pages, etc.) they get "WebPage" with a "CollectionPage" type. Same for Authors and the typical Author page like: https://marsbased.com/blog/Anna-Vidal

Last, but not least, "Event". if you're building community stuff or clients have events, this comes up. Don't have events on our website but when we will incorporate this, sometime in the future, it'll be important.

## Implementation patterns we prefer

### One JSON-LD block per page, using @graph

The script approach is the one we go for as we can't see a reason to implement the other approaches. Placing it in the <head> is conventional, but render-blocking concerns on JS-heavy sites sometimes push it to end of <body>. We personally prefer the latter.

We generate a single script tag with an "@graph" that includes:
- Organization
- WebSite
- WebPage
- BreadcrumbList (if applicable)
- Primary entity (Article/Service/etc)

Example (applicantLocationRequirements cut for legibility purposes):
````
<script type="application/ld+json">
  { "@context":"https://schema.org/",
      "@graph": [
        {
        "@type":"JobPosting",
          "title":"Full Stack Software Engineer  (100% Remote)",
          "description":"We are looking for a Full Stack Software Engineer to join our Martian team.",
          "identifier":{"@type":"PropertyValue","name":"MarsBased","value":""},
          "datePosted":"2026-02-06",
          "applicantLocationRequirements":[{"@type":"Country","name":"Austria"},{"@type":"Country","name":"Belgium"},[...]],
          "jobLocationType":"TELECOMMUTE",
          "employmentType":"FULL_TIME",
          "hiringOrganization":{"@id":"https://marsbased.com/#organization"},
          "baseSalary":{"@type":"MonetaryAmount","currency":"EUR","value": {"@type":"QuantitativeValue","minValue":40000,"maxValue":60000,"unitText":"YEAR"}}}
              ]
    }
</script>
````

This makes QA and diffing simpler and avoids scattering markup across components. We don't want littered HTML with bits of schema here and there.

### Stable "@id" scheme
Pick a consistent convention:
- Organization: "https://example.com/#organization"
- WebSite: "https://example.com/#website"
- WebPage: page URL plus "#webpage" or similar
- People: "https://example.com/#person-jane-doe" (or author page URL)

If an entity has its own canonical URL (author page, product page), prefer that as its "@id".

### Centralize data sources
Avoid hardcoding schema objects in multiple templates. Instead:
- Maintain a single source of truth for Organization and WebSite data.
- Derive WebPage and page entity markup from page metadata (CMS, frontmatter, DB).

### Multilingual sites
Multilingual sites introduce a specific problem: the same content exists at multiple URLs, and structured data must not treat those URLs as separate entities. The goal is one coherent entity graph, with language variants correctly signalled; not three disconnected graphs that happen to describe the same thing.

**The core rule:** **canonical @id, language-specific @id only where justified**.
The "Organization" and "WebSite" nodes are language-agnostic. They represent the entity itself, not a page about the entity. Use the canonical (language-neutral) URL as the @id and do not duplicate or translate these nodes per language variant.

```json
{
  "@type": "Organization",
  "@id": "https://example.com/#organization",
  "name": "Example Company",
  "url": "https://example.com"
}
```

This node is identical across all language variants. It goes in every @graph, unchanged.
The "WebPage" node is where language variants diverge. Each URL gets its own "WebPage" node with its own @id because each URL genuinely is a different page, but all of them point back to the same "Organization" and "WebSite" via "isPartOf" and "publisher".

```json
{
  "@type": "WebPage",
  "@id": "https://example.com/ca/about/#webpage",
  "url": "https://example.com/ca/about/",
  "name": "Sobre nosaltres",
  "inLanguage": "ca",
  "isPartOf": { "@id": "https://example.com/#website" }
}
```

**Use inLanguage on content nodes**

Add "inLanguage" to "WebPage", "BlogPosting", "Article", and any content entity that has a language-specific expression. Use BCP 47 codes: "ca" for Catalan, "es" for Spanish, "en" for English, just to name a few.

Do not add "inLanguage" to "Organization" or "WebSite". Those entities have no language.

**Connect variants with sameAs or translationOfWork**

If the page has a clear canonical equivalent, you can signal the relationship between translated pages using "translationOfWork" on the translated version pointing to the canonical:

```json
{
  "@type": "BlogPosting",
  "@id": "https://example.com/ca/blog/some-post/#blogposting",
  "inLanguage": "ca",
  "translationOfWork": {
    "@id": "https://example.com/blog/some-post/#blogposting"
  }
}
```

This is optional but useful for content-heavy sites. Do not use "sameAs" here. "sameAs" is for external identity claims (social profiles, Wikidata entries), not for relating internal URL variants.

**hreflang is not schema — but it matters just as much**

Language variant signalling for crawlers happens primarily through hreflang, not structured data. Make sure hreflang annotations are in place (via <link> tags in <head> or HTTP headers) before worrying about language in schema. Schema inLanguage is additive context; hreflang is what tells Google which URL to serve to which user.
If hreflang is wrong or missing, schema "inLanguage" will not compensate for it.

**Common mistakes on multilingual sites**

Duplicating the "Organization" node in each language with a translated name. The legal entity name does not change, as "name" should be the registered name, not a translated label.

Using the canonical URL as the @id for translated "WebPage" nodes. Each page URL must be its own @id. The canonical URL belongs in a "url" or "mainEntityOfPage" reference, not as the @id of a different page's node.

Omitting "inLanguage" entirely. Crawlers can infer it from hreflang, but being explicit in schema removes ambiguity, especially as LLM-based retrieval systems grow more prevalent.

Generating identical JSON-LD across all language variants. If the only thing changing between the Catalan and Spanish page schemas is the @id URL but not "inLanguage" or content properties like headline, the markup is incomplete.

## Validation and QA checklist

We do not ship structured data without a basic QA pass. We test using the Schema Markup Validator (schema.org/validator) which catches type/property errors the Google tool misses.

1) Syntax and shape validation
- Validate the JSON-LD is valid JSON.
- Validate schema types and property names.

2) Eligibility testing (Google-focused)
- If the page targets a rich result type, test with the Rich Results Test.
- Monitor Search Console enhancement reports after deploy.

3) Content parity
- Confirm every important claim in markup is visible on the page.
- Confirm dates, prices, availability, and locations match.

4) Regression control
- Add snapshot tests for JSON-LD generation where feasible.
- Include a structured data smoke test in release QA for critical templates.

## Common mistakes to avoid

- Marking up content that is not on the page (or only behind UI interactions).
  - **Exception:** When a certain entity requires a field that you don't want to show in the UI, just add it as a meta tag.
- Copy-pasting generic schemas that do not match the page.
- Missing "@id" links so entities become disconnected.
- Using Product/Offer fields without showing pricing/availability in the UI.
- Leaving JobPosting live after the role is closed.
- Duplicating Organization definitions with different names/URLs across pages.

## Minimal example structure (conceptual)

- Organization "@id": "https://marsbased.com/#organization"
- WebSite "@id": "https://marsbased.com/#website"
- WebPage "@id": "https://marsbased.com/blog/some-post/#webpage"
- BlogPosting "@id": "https://marsbased.com/blog/some-post/#blogposting"
- BlogPosting "publisher": Organization "@id"
- WebPage "mainEntity": BlogPosting "@id"

Keep it boring and correct. That is what scales.
