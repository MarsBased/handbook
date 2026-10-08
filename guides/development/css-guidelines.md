# CSS guidelines

How we organise styles: where tokens live, who owns a style, which mechanism handles variants, themes and breakpoints. [Tailwind CSS](https://tailwindcss.com/) is the default on our frontend projects. The Do's and Don'ts apply with or without it. This guide is for the web; React Native projects follow the styling section of the [React Native guidelines](/guides/development/react-native-guidelines.md#33-styling-and-theming).

## Table of Contents

- [Do's and Don'ts](#dos-and-donts)
- [Tailwind](#tailwind)
- [Without Tailwind](#without-tailwind)
- [Resources](#resources)

## Do's and Don'ts

### Organise tokens in three tiers

- **Primitives**: what the design tool exports. A colour ramp, a spacing scale, a type scale: `--color-blue-8`, `--space-4`.
- **Semantic**: a primitive with a role: `--primary`, `--muted-foreground`, `--border`. They point at primitives, never at raw values, so a palette change happens in one place.
- **Component**: a knob a parent can turn, such as `--card-padding`. Only when a component needs one.

Use the role names the client's design system already has. If it has none, or uses them inconsistently, use the names of the project's component library, so its components install without renaming a token. Without a library, use the shadcn/ui vocabulary: `background` and `foreground`; `primary`, `secondary`, `muted`, `accent` and `destructive`, each with a `-foreground` pair for the text on it; `border`, `input` and `ring`.

```css
:root {
  /* Primitives, as exported from the design tool */
  --color-blue-8: oklch(0.32 0.09 262);
  --color-sand-1: oklch(0.99 0.003 90);

  /* Semantic: a role, pointing at a primitive */
  --primary: var(--color-blue-8);
  --background: var(--color-sand-1);
}
```

### Use semantic tokens in components, never primitives

A component that says `bg-blue-8` has to be found and edited when the brand colour changes, and it tells the reader nothing about why it is blue. If the design names a primitive with no role, the missing piece is the role: add a semantic token and use that.

The framework's default palette (`neutral-200`, `gray-500`) is a primitive too and follows the same rule.

```tsx
// Don't
<p className="border-neutral-200 text-blue-8">{summary}</p>

// DO
<p className="border-border text-primary">{summary}</p>
```

### Keep the unit in the token

Sizes come from tokens, so the unit is chosen once, when the token is defined, and a component rarely writes one. When defining a token:

- `rem` for type, spacing, container widths and breakpoints. It follows the font size the user set in the browser.
- `px` for what must not scale with text: borders, outlines, shadows, and fixed sizes of images, video and embeds.
- `em` for what follows the text next to it: inline icons, `letter-spacing`.
- No unit on `line-height`.
- `svh` for viewport height, `dvh` only when the element must resize as the mobile browser bar hides, never `vh`: on phones, `100vh` overflows while the bar is visible.
- Never `vw` alone on a font size. Inside `clamp()`, the preferred value includes a `rem` term.

Figma works in pixels, and that is what its inspector and most exports show. The token is written in `rem` anyway: divide by 16 once, when you create it (`24px` is `1.5rem`), never in a component.

### Write colours in oklch and derive shades with color-mix()

Prefer `oklch()` for colour tokens: lightness means the same thing across hues, so a ramp reads evenly, and Tailwind v4's own palette uses it. A ramp the design gives in hex is either kept in hex or converted whole, with the original value in a comment so it can be checked against Figma. One format per ramp. A hover or active shade is derived from the token with `color-mix()`, which interpolates in oklch whatever the token's format:

```css
/* Don't: a second value nobody can trace back to the token */
@media (hover: hover) {
  .button:hover {
    background: #142f5d;
  }
}

/* DO */
@media (hover: hover) {
  .button:hover {
    background: color-mix(in oklch, var(--primary), black 12%);
  }
}
```

In Tailwind, the derived shade is a token (`--primary-hover: color-mix(in oklch, var(--primary), black 12%)`) exposed through `@theme inline`. The opacity modifier (`bg-primary/90`) is transparency, which depends on what sits behind, not a shade. Never use Sass `darken()` or `lighten()`: they run at compile time and cannot see a custom property.

### Define breakpoints once, mobile first

A breakpoint is the last resort. An intrinsic layout (`repeat(auto-fit, minmax())`, flex wrap) or a container query adapts without one. When you need a breakpoint, its value is defined once: in Tailwind's `--breakpoint-*`, in a Sass mixin, or in the breakpoint list of the repository rules for plain CSS. A query in a component uses that value, never a number of its own. If JavaScript needs the same breakpoints, one constants file exports them under the same names.

Write styles for the narrowest viewport first and add overrides upwards.

### Change responsive tokens in the token layer

When the design gives a token different values per breakpoint (a display size, a card padding, a section gap), redefine it under the breakpoint in the token file. One class then adapts everywhere and the component never knows there are steps.

```css
/* DO: tokens.css. Without Tailwind, the query is @media (width >= 60rem) */
:root {
  --font-size-display-l: 3.75rem;

  @variant lg {
    --font-size-display-l: 8.75rem;
  }
}
```

```tsx
// Don't: the breakpoint chain repeated in every component that uses the style
<h1 className="text-6xl lg:text-9xl">{title}</h1>

// DO
<h1 className="text-display-l">{title}</h1>
```

Use `clamp()` instead when the design defines a minimum and a maximum rather than steps.

### Theme with custom properties on :root and .dark

A value that changes with the theme is a custom property on `:root`, redefined in `.dark`. It is never a compile-time variable and never a conditional class in a component: with semantic tokens, a component has no chain of `dark:` classes. It reads `bg-background` and the theme does the rest.

`.dark` redefines only what changes. A script sets it on `<html>` before first paint, from the stored choice or `prefers-color-scheme`, so the page never flashes the wrong theme. A project without dark mode disables it explicitly. Installed components ship `dark:` classes and Tailwind's default `dark` variant follows the OS preference, so without that step a user with a dark OS gets a half-dark UI. In Tailwind, `@custom-variant dark (&:not(*));` makes every `dark:` class match nothing; without Tailwind, `color-scheme: light` on `:root` and no `.dark` block.

### Let the parent place the component; give it no outer margin

The parent decides where its children go and how far apart: `gap`, grid placement. A component's own styles set no outer margin, so it can be dropped anywhere. When a parent needs one, it adds it through the `className` slot.

A parent customises a child through the custom properties the child exposes, or through its `className` slot. It never selects the child's internals from outside.

```css
/* Don't: the listing reaches into the card */
.listing .card-title {
  font-size: var(--text-heading-m);
}

/* DO: the card reads a knob with a default, and the listing sets it */
.card-title {
  font-size: var(--card-title-size, var(--text-heading-l));
}

.listing {
  --card-title-size: var(--text-heading-m);
}
```

### Use one variant mechanism per project and put state in attributes

Variants (`primary`, `secondary`, `sm`, `lg`) go through one mechanism: `cva`, or `tailwind-variants` on Tailwind projects, when components are JavaScript; modifier classes in server-rendered templates. State (open, selected, invalid, current page) is an attribute the markup already has or should have: `aria-expanded`, `aria-current`, `data-state`, `:disabled`, `:user-invalid`. Style the attribute. A class like `.is-open` stores the state in a second place that drifts, and assistive technology cannot see it.

```tsx
// Don't
<ChevronIcon className={isOpen ? "rotate-180" : ""} />

// DO: the button already carries the state
<button aria-expanded={isOpen} className="group">
  <ChevronIcon className="group-aria-expanded:rotate-180" />
</button>
```

In Tailwind: `aria-expanded:`, `aria-[current=page]:`, `data-[state=open]:`, `has-[:checked]:`.

### Keep specificity flat

A selector is a class, optionally with an attribute or a pseudo-class. At most two compound selectors (`.a .b`). No IDs. No `!important`, not even through Tailwind's `!` modifier. An element selector styles every element of that type on the site, so it lives where a class always beats it: in the `base` layer, or wrapped in `:where()` when it targets HTML you do not control, such as rich text from a CMS (`.prose :where(h2)`).

The one case that seems to need `!important` is third-party CSS beating yours. It does so because an unlayered stylesheet wins over every layered one. Import it into a `vendor` layer, declared after `base` so the reset does not strip it and before `components` so your styles win.

```css
@layer theme, base, vendor, components, utilities;
@import "vendor/datepicker.css" layer(vendor);
```

### Put z-index on a scale

A few named layers as tokens, in stacking order, and nothing else: `--z-index-dropdown`, `--z-index-sticky`, `--z-index-overlay`, `--z-index-modal`, `--z-index-toast`. In Tailwind they go in `@theme` and give `z-dropdown`, `z-modal`; without it, `z-index: var(--z-index-modal)`. A `z-index: 9999` in a component means the scale is missing a layer, or that the problem is a stacking context: `isolation: isolate` on a component's root keeps its internal layers from competing with the page.

### Use inline styles only for runtime values

A value computed in JavaScript (scroll progress, a measured height, an image URL from the CMS) goes through `style`, usually as a custom property the stylesheet reads. Everything known when you write the component is a class.

```tsx
// Don't
<div style={{ display: "flex", gap: 16 }}>{children}</div>

// DO
<div className="flex gap-4" style={{ "--progress": progress } as CSSProperties}>
  {children}
</div>
```

### Animate named properties, and movement only when the user allows it

`transition: all` animates every property that changes, layout included, so a class toggle can animate a width or a padding nobody meant to animate. Name the properties, also in installed components: shadcn/ui, for example, ships `transition-all` on its button. Durations and easings come from tokens (`--duration-*`, `--ease-*`): no literal `ms` or `cubic-bezier()` in a component.

Transitions and animations of `transform`, `translate`, `scale` and `rotate`, and `scroll-behavior: smooth`, go behind `prefers-reduced-motion: no-preference` (`motion-safe:` in Tailwind). Opacity and colour transitions are not gated. A global rule that disables every animation under `reduce` is not a substitute: it also removes the fades we want to keep, and it needs `!important`. The [accessibility guide](/guides/a11y/for-engineers.md#ReducedMotion) lists the motion patterns to avoid.

```css
/* Don't */
.card {
  transition: all 300ms;
}

.card:hover {
  background-color: var(--muted);
  translate: 0 -4px;
}

/* DO */
.card {
  transition: background-color var(--duration-fast) var(--ease-out);
}

@media (hover: hover) {
  .card:hover {
    background-color: var(--muted);
  }
}

@media (hover: hover) and (prefers-reduced-motion: no-preference) {
  .card {
    transition-property: background-color, translate;
  }

  .card:hover {
    translate: 0 -4px;
  }
}
```

### Keep focus visible and hover for pointers that hover

Keep the outline and style it on `:focus-visible` with `outline` and `outline-offset` (`focus-visible:outline-2` in Tailwind): keyboard users get the ring, mouse clicks show nothing. Remove it only when the design asks for a ring an outline cannot draw, in the same rule that draws the replacement on `:focus-visible`; in Tailwind use `outline-hidden`, not `outline-none`, which also removes it in forced-colors mode. `:hover` rules go inside the `@media (hover: hover)` query, so a tap on a touch screen does not leave a stuck hover state. Tailwind v4's `hover:` already does this. Its docs show how to restore the v3 behaviour with `@custom-variant hover (&:hover);`: don't. The rest of interaction accessibility is in the [accessibility guide](/guides/a11y/for-engineers.md).

### Target Baseline widely available

Each project should state its browser floor in `browserslist`, which Autoprefixer and `postcss-preset-env` read. If there is no specific reason to differ, it is `baseline widely available`. Tailwind v4 has its own floor that browserslist cannot lower. Within that floor these are defaults, not options: logical properties (`padding-inline`, `margin-block`, `inset-inline-start`; `ps-`, `ms-`, `start-` in Tailwind), `aspect-ratio` instead of padding hacks, `overflow: clip` when all you need is clipping, container queries for components that respond to their container, native nesting.

Anything above the floor (Baseline newly available or limited availability) is a progressive enhancement: the page works without it, through a fallback declaration or an `@supports` block, and nothing breaks in a browser that lacks it.

### Self-host fonts

Font files live in the repository or go through the framework's font loader (`next/font` downloads them at build time and serves them from your domain). A `<link>` to a font CDN is the last option, when neither is possible. `@import` of a font URL inside CSS is never acceptable: it blocks rendering behind two round trips. Ship `woff2` only, with `font-display: swap`.

### Lint styles on every edit and before every commit

Stylelint with `stylelint-config-standard` should run in the post-edit hook for agents and in the pre-commit hook for everyone, as described in [AI Augmented Development](/guides/development/ai-augmented-development.md#hooks), next to the project's class-order tool. The standard config rejects three things we use, so each project overrides them: Tailwind's at-rules (`theme`, `utility`, `custom-variant`, `variant`, `apply`, `source`) go in `ignoreAtRules`; `selector-class-pattern` is set to the project's naming, BEM or camelCase; `custom-property-pattern` is relaxed to allow `--text-heading-l--line-height`. Lint findings are fixed, not disabled.

### Comment the origin of a magic number and delete dead CSS

A `calc()` or a hard-coded measure gets one line saying where it comes from: `/* header height plus the sticky offset */`. Unused tokens are cleaned up in a dedicated pass at the end of the project, not while features are still landing.

## Tailwind

### Use v4 and configure it in CSS

The configuration is the stylesheet: `@import "tailwindcss"`, `@theme`, `@custom-variant`, `@utility`. There is no `tailwind.config.ts` and no `@tailwind base` directive; both are v3, and models still produce them by default. A project on v3 migrates whenever possible, in one dedicated change.

### Split the stylesheet by layer

One file per concern, each imported into its layer from the entry file: tokens on their own, element defaults in `base`, CMS and third-party selectors in `components`. The entry file holds the layer order and the Tailwind directives.

```
src/styles/
|- application.css      # entry: layer order, imports, dark variant, @theme inline, @utility
|- tokens.css           # @theme primitives, :root and .dark semantic tokens
|- base/
|  |- index.css
|  |- global.css        # html, body, element defaults
|  |- keyframes.css
|- components/
   |- index.css         # CMS content, third-party DOM
```

```css
/* application.css */
@layer theme, base, vendor, components, utilities;

@import "tailwindcss";
@import "./tokens.css";
@import "vendor/datepicker.css" layer(vendor);
@import "./base/index.css" layer(base);
@import "./components/index.css" layer(components);

/* With a theme switcher. Without dark mode: @custom-variant dark (&:not(*)); */
@custom-variant dark (&:where(.dark, .dark *));

@theme inline {
  --color-primary: var(--primary);
  --color-background: var(--background);
  --text-display-l: var(--font-size-display-l);
}
```

### Put primitives in @theme and semantic aliases in @theme inline

`@theme` generates utilities from primitives: `--color-blue-8` gives `bg-blue-8`, `--text-heading-l` gives `text-heading-l`. Semantic tokens are plain custom properties on `:root`, so `.dark` can redefine them, and `@theme inline` turns them into utilities that read the live value.

```css
/* tokens.css */
@theme {
  --color-*: initial;
  --color-blue-8: oklch(0.32 0.09 262);
  --color-blue-3: oklch(0.75 0.1 262);
  --text-heading-l: 2.25rem;
  --text-heading-l--line-height: 1;
  --breakpoint-lg: 60rem;
}

:root {
  --primary: var(--color-blue-8);
}

.dark {
  --primary: var(--color-blue-3);
}

/* application.css */
@theme inline {
  --color-primary: var(--primary);
}
```

`bg-primary` compiles to `background-color: var(--primary)` and follows the theme. This is how shadcn/ui lays out its theme; keep it even without shadcn.

### Reset the default theme where the design replaces it

Tailwind's default theme is a placeholder, not a base to extend. When the design brings its own colours, type scale or shadows, reset that namespace at the top of `@theme` and define the project's primitives after it. `bg-neutral-200` or `shadow-md` then stop compiling, and nothing from the placeholder leaks into a component. `--*: initial` resets the whole theme when the design system is complete; after it, every namespace the project uses is defined again, including `--spacing` and `--breakpoint-*`.

```css
@theme {
  --color-*: initial;
  --font-*: initial;
  --shadow-*: initial;

  --color-blue-1: oklch(0.93 0.03 262);
  --color-blue-5: oklch(0.62 0.17 262);
  --color-blue-8: oklch(0.32 0.09 262);
  --font-sans: "Inter", ui-sans-serif, sans-serif;
  --shadow-card: 0 4px 50px 0 rgb(0 0 0 / 8%);
}
```

Keep the default theme only when there is no design to replace it: a proof of concept or an MVP styled from Tailwind's palette.

### Write CSS only for what a className cannot reach

Write CSS only for element defaults (`body`, headings inside rich text), third-party DOM and keyframes. Everything else is utilities on the element. HTML you do not control (rich text from a CMS, rendered markdown, a third-party widget) gets a wrapper class and `:where()` selectors in `@layer components`:

```css
.prose :where(h2) {
  @apply text-heading-l font-bold;
}

.prose :where(a) {
  @apply text-primary underline;
}
```

A declaration Tailwind has no utility for becomes an `@utility`, so it accepts variants (`md:scrollbar-none`), shows up in editor autocomplete and passes the class linter:

```css
@utility scrollbar-none {
  scrollbar-width: none;

  &::-webkit-scrollbar {
    display: none;
  }
}
```

### Restrict @apply to the base and components layers

`@apply` is fine on an element selector in `@layer base` or `@layer components`, where a className cannot go. It is never used to build a `.btn` or `.card` class: that recreates a second class system, hides the utilities from `tailwind-merge` and splits one component between the JSX and a stylesheet. A component with variants is a component.

```css
/* Don't */
.btn {
  @apply inline-flex bg-primary px-5 py-3 text-primary-foreground;
}
```

```tsx
// DO: a component built with cva
<Button variant="primary">Save</Button>
```

### Build variants with cva or tailwind-variants

One of the two per project, chosen by the framework: [class-variance-authority](https://cva.style/) with React, [tailwind-variants](https://www.tailwind-variants.org/) with Svelte. Other frameworks record the choice in the repository rules. Variants are typed with `VariantProps`, declare `defaultVariants`, and the component merges `className` last so a caller can adjust it.

```tsx
const buttonVariants = cva("inline-flex items-center px-5 py-3 text-body-s font-bold transition-colors", {
  variants: {
    variant: {
      primary: "bg-primary text-primary-foreground hover:bg-primary/90",
      secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
    },
  },
  defaultVariants: { variant: "primary" },
});

export type ButtonProps = ComponentProps<"button"> & VariantProps<typeof buttonVariants>;

export function Button({ variant, className, ...props }: ButtonProps) {
  return <button className={cn(buttonVariants({ variant }), className)} {...props} />;
}
```

### Compose with cn() and let the tool order the classes

`cn` is `clsx` plus `tailwind-merge`: conditionals are arguments, and a caller's `className` overrides what the component set. No string concatenation, no ternaries inside template literals.

Class order and line wrapping belong to a tool. Prefer [eslint-plugin-better-tailwindcss](https://github.com/schoero/eslint-plugin-better-tailwindcss), which fits the ESLint-only setup from the [React guidelines](/guides/development/react-guidelines.md); `prettier-plugin-tailwindcss` is fine on projects that run Prettier (Svelte projects, for example). Never sort or wrap by hand, and don't group classes "by concern": the canonical order already does.

```tsx
// Don't
<div className={`flex ${isActive ? "bg-primary" : ""} ${className}`}>{children}</div>

// DO
<div className={cn("flex", isActive && "bg-primary", className)}>{children}</div>
```

### Use arbitrary values only for measured one-offs and selectors

Brackets are right for a computed value (`h-[calc(100dvh-var(--header-height))]`), a child selector (`[&_svg]:size-6`) or a grid template (`grid-cols-[minmax(0,1fr)_20rem]`). A custom property goes through parentheses: `h-(--header-height)`.

A colour, a spacing step, a font size or a font family in brackets is a missing token. Add the token.

```tsx
// Don't
<p className="mt-[13px] text-[15px] text-[#1a3c74]">{summary}</p>

// DO: the value exists in the scale, or it joins it
<p className="mt-3 text-body-s text-primary">{summary}</p>
```

### Treat installed component code as your own

shadcn/ui and similar tools copy their components into `components/ui/`. From then on it is project code: map its colours to your tokens, replace `transition-all` with the properties that change, move each `dark:` override into a token redefined in `.dark` and delete it. Don't wrap a component to change what you could edit.

## Without Tailwind

For projects where Tailwind is not an option: legacy stylesheets, server-rendered templates without a JavaScript build, or a client constraint.

### Write plain CSS; add Sass only for mixins or loops

Nesting, variables and `color-mix()` are native, so the build only bundles and minifies. Add Sass only when the project needs mixins or loops, and then use `@use` and `@forward`, never Sass `@import`. Tokens stay custom properties; Sass variables are for compile-time constants only, such as the steps of a loop.

### Declare cascade layers once and mirror them in files

The entry file fixes the order, each file imports into its layer, and the folder names match. Use Tailwind's layer names plus `vendor`.

```css
/* application.css */
@layer theme, base, vendor, components;

@import "./tokens.css" layer(theme);
@import "./base/index.css" layer(base);
@import "vendor/datepicker.css" layer(vendor);
@import "./components/index.css" layer(components);
```

A rule in `components` beats any rule in `base` regardless of specificity or file order.

### Define tokens as custom properties on :root

Three tiers in `tokens.css`, with `.dark` next to them redefining only what changes.

```css
:root {
  /* primitives */
  --color-blue-10: oklch(0.15 0.05 262);
  --color-blue-8: oklch(0.32 0.09 262);
  --color-blue-3: oklch(0.75 0.1 262);
  --color-sand-1: oklch(0.99 0.003 90);
  --space-4: 1rem;
  --text-heading-l: 2.25rem;

  /* semantic */
  --primary: var(--color-blue-8);
  --background: var(--color-sand-1);
}

.dark {
  --primary: var(--color-blue-3);
  --background: var(--color-blue-10);
}
```

### Pick one scoping strategy, by stack

Without Tailwind, a class name is global by default, so the project needs one way of keeping component styles from colliding. The stack decides which:

- With a bundler and components (React, Vue, Svelte, Astro, Angular): CSS Modules or the framework's scoped styles. No CSS-in-JS: runtime libraries (styled-components, Emotion) inject styles outside the cascade layers and the CSS toolchain, and build-time ones (vanilla-extract, StyleX, Linaria) emit CSS but author it in JavaScript, where Stylelint and the rules of this guide cannot reach.
- With a global stylesheet and server-rendered templates (Rails, Django, a CMS theme): BEM with a project prefix.
- Legacy: whatever it has. New code follows the same convention until a dedicated migration.

One strategy per project.

**CSS Modules and scoped styles**

- One `Component.module.css` next to the component. camelCase class names, composed with `cva` for variants and `clsx` for the rest.
- `:global()` only inside a local selector (`.editor :global(.ql-editor)`), never at the top level.

**BEM**

- `prefix-block__element--modifier`. The prefix (`mb-`, `app-`) keeps project classes apart from vendor and CMS classes.
- Modifiers for variants (`--secondary`, `--large`). State through attributes (`[aria-expanded="true"]`, `[data-state="open"]`).
- A block's stylesheet nests one level at most. The class already carries the hierarchy.

### Write breakpoints with range syntax, from one list

Plain CSS cannot name a breakpoint: `var()` does not work inside `@media`. The values live in one list in the repository rules (and in a mixin when the project uses Sass), in `rem`, and every query copies them in range syntax. `(width < 48rem)` and `(width >= 48rem)` leave no width unmatched between them. A project that already runs PostCSS can name breakpoints with [`@custom-media`](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/@custom-media), which `postcss-custom-media` rewrites into the standard query at build time.

```css
.sidebar {
  display: none;

  @media (width >= 48rem) {
    display: block;
  }
}
```

### No utility classes

A layout wrapper gets a class in the component's stylesheet (`.actions { display: flex; gap: var(--space-2); }`), not a `.flex` or `.mt-4` in the markup. Two systems in one project means deciding which one applies on every element. A project that needs utilities is a project for Tailwind.

### Start from modern-normalize and a short reset

[modern-normalize](https://github.com/sindresorhus/modern-normalize) goes first in `base`: it evens out browser defaults (`box-sizing`, form controls, `text-size-adjust`) without styling anything. On top of it, a small reset, before anything else:

```css
/* base/index.css */
@import "modern-normalize";

* {
  margin: 0;
}

html {
  scrollbar-gutter: stable;
}

body {
  min-height: 100dvh; /* the body follows the mobile browser bar */
  line-height: 1.5;
  -webkit-font-smoothing: antialiased;
}

img,
picture,
video,
svg {
  display: block;
  max-width: 100%;
}

input,
button,
textarea,
select {
  font: inherit;
}
```

### Trim CSS frameworks and never override them with specificity

Bootstrap-style frameworks are imported module by module, only what the project uses, into the `vendor` layer. Never add a module back to style one component. An override lives in your layers and wins by layer order, not by a longer selector.

## Resources

- [CSS on MDN](https://developer.mozilla.org/en-US/docs/Web/CSS): the reference.
- [CSS on web.dev](https://web.dev/css): articles and guides on new features.
- [Baseline](https://web.dev/baseline) and [Can I use](https://caniuse.com/): a feature's support status.
- [Tailwind CSS v4 documentation](https://tailwindcss.com/docs).
- [shadcn/ui theming](https://ui.shadcn.com/docs/theming): the `:root`, `.dark` and `@theme inline` layout this guide follows.
- [CSS Modules](https://github.com/css-modules/css-modules): the specification and its `:global()` and `composes` syntax.
