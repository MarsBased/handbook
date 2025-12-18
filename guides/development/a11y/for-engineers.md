# Accessibility for Frontend Engineers

Many accessibility issues arise during implementation, but the good news is that most disappear when we use the web platform as intended.

Your default mindset should be:

**Start with semantic HTML. Add ARIA only when necessary. Never remove built-in accessibility.**

Small decisions in markup have a huge impact: keyboard navigation, screen reader output, SEO, machine readability and maintainability all depend on correct semantics.

## Table of Contents

- [1. Semantic HTML First](#SemanticHTMLFirst)
- [2. Labels & Forms](#LabelsForms)
- [3. Keyboard Navigation](#KeyboardNavigation)
- [4. Images & Alt Text](#ImagesAltText)
- [5. ARIA](#ARIA)
- [6. Custom UI Components](#CustomUIComponents)
- [7. Reduced Motion](#ReducedMotion)
- [8. Basic Accessibility Testing](#BasicAccessibilityTesting)
- [9. Engineering Accessibility Checklist](#EngineeringAccessibilityChecklist)

## 1. <a name='SemanticHTMLFirst'></a>Semantic HTML First

Native HTML elements come with accessibility built in: roles, keyboard behavior, focus handling, and meaningful semantics. Using them correctly is the easiest and most reliable way to build accessible interfaces.

#### Use the right element for the job

- `<button>` for actions
- `<a>` for navigation
- `<form>` and real form controls (`<input>`, `<select>`, `<textarea>`) for data entry
- `<header>`, `<main>`, `<nav>`, `<section>`, `<article>`, `<footer>` for structure
- `<ul>/<ol>/<li>` for lists

This immediately gives you:

- correct semantics for screen readers
- predictable keyboard behavior (Enter, Space, Tab, Escape)
- proper focus management without extra JS
- better SEO and machine readability

#### Don't replace native controls with divs

Avoid patterns like:

```html
<div onclick="submitForm()">Send</div>
```

They're not focusable, not operable by keyboard and not announced properly by screen readers.

If you must build a custom component, you'll need to manually add:

- correct `role`
- `tabIndex="0"`
- full keyboard support (`Enter`, `Space`, arrow keys when needed)
- proper focus states
- ARIA attributes where appropriate

This is significantly more work and easier to get wrong.

#### Keep your HTML predictable

- Respect the natural heading hierarchy (`h1 → h2 → h3` …).
- Avoid skipping levels (don't jump from `h1` to `h4`).
- Use one `<main>` landmark per page.
- Wrap related controls in a `<fieldset>` with a `<legend>` when appropriate.

Good structure helps not only assistive tech but also users scanning the page visually.

#### Bonus: Accessible = Machine-readable

Accessibility isn't just about people; it's about making content understandable to machines too.

Clear semantic HTML is easier for:

- search engines (better SEO)
- voice assistants (Siri, Alexa, Google Assistant)
- browser accessibility APIs
- AI-powered tools and summarizers
- automated testing and maintenance

Good markup benefits **every layer of the ecosystem**, not just screen readers. When you build accessible interfaces, you're also building machine-readable, maintainable code that works better for everyone.

## 2. <a name='LabelsForms'></a>Labels & Forms

Forms must be identifiable, operable, and understandable, both visually and with assistive technologies.  
Good markup solves most accessibility issues automatically.

#### Forms must be real `<form>` elements

A search bar is still a form and it should use `<form>` and a submit button.  
This improves semantics, keyboard support, and allows assistive tools to trigger the action correctly.

```html
<form action="/search">
  <label for="q" class="sr-only">Search</label>
  <input id="q" name="q" type="search" placeholder="Search…" />
  <button type="submit">Search</button>
</form>
```

#### Always provide a real label

- Every form control needs an associated `<label>` that must be programmatically associated with the field:

```html
<label for="email">Email address</label> <input id="email" type="email" />
```

- Labels should be visible and placed consistently (top or left) when possible. **If the UI doesn't allow labels** (e.g., search bars or very short forms), use a visually hidden label:

```html
<label for="search" class="sr-only">Search</label>
<input id="search" type="text" placeholder="Search..." />
```

> **Note:** `.sr-only` (screen-reader-only) is a utility class that visually hides content while keeping it accessible to assistive technologies. Most CSS frameworks include this class. If you need to implement it yourself:

```css
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
```

> Hidden labels are acceptable only in **very short** forms.  
> For login, registration, or any multi-field flow, **visible labels are required**.

- **Never rely on placeholders as labels**. Placeholders disappear on typing, offer poor contrast, and are not consistently announced by screen readers. Use them only for hints or examples (e.g., "you@example.com"), never as the main label.

#### Required fields

- Mark required fields using the native `required` attribute; this automatically exposes the information to assistive tech.
- When necessary, reinforce with `aria-required="true"` (e.g., in custom components).
- Provide a **clear visual indicator** like "(required)" or "Required".  
  Avoid using a lone asterisk `*` without context. Many users don't understand what it means.

```html
<label for="name">Full name <span aria-hidden="true">(required)</span></label>
<input id="name" name="name" required />
```

#### Autocomplete

Autocomplete helps users with cognitive disabilities, dyslexia, ADHD, or memory difficulties by reducing the amount of information they must recall and type.

- Always add `autocomplete` when the field has a known purpose.
- Use specific values such as `email`, `name`, `address-line1`, `tel`, `current-password`, `new-password`, etc.
- This improves speed, accuracy, and reduces form abandonment.

```html
<input type="email" id="email" name="email" autocomplete="email" required />
```

#### Disabled fields

- Disabled native inputs are skipped by keyboard navigation and screen readers.
- Avoid disabling fields without explanation; many users won't know why they can't interact.
- When a field is intentionally unavailable, provide context:

```html
<label for="coupon">Coupon</label>
<input id="coupon" disabled aria-describedby="coupon-info" />
<p id="coupon-info">Coupons are not available for this plan.</p>
```

- For custom components, you have two options:
  - Match native behavior: remove from tab order (`tabindex="-1"`) and mark as disabled (`aria-disabled="true"`) so it behaves like a disabled native input.
  - Keep it discoverable: use `aria-disabled="true"` when users need to understand why it's unavailable (especially with explanatory text via `aria-describedby`).

```html
<div
  role="textbox"
  contenteditable="true"
  tabindex="0"
  aria-disabled="true"
  aria-label="Coupon code"
  aria-describedby="coupon-info"
></div>
<p id="coupon-info">Coupons are not available for this plan.</p>
```

#### Group related fields

For radios, checkboxes or grouped selections, use `<fieldset>` and `<legend>`:

```html
<fieldset>
  <legend>Payment method</legend>
  <label><input type="radio" name="payment" />Card</label>
  <label><input type="radio" name="payment" />PayPal</label>
</fieldset>
```

#### Helpful hints & instructions

- Provide short, actionable instructions near the field ("Must be 8–20 characters").
- Use `aria-describedby` for hints that should be announced:

```html
<input id="username" aria-describedby="username-hint" />
<p id="username-hint">Must be unique and contain only letters or numbers.</p>
```

#### Accessible errors

- Errors should describe the actual problem ("Password must be at least 8 characters", not "Invalid input") and be announced to screen readers.
- They should appear near the field, not at the bottom of the form, and be visually distinct with both **color + text** (don't rely on red alone).
- Use `aria-invalid` and `role="alert"` when errors are present, and associate the message via `aria-describedby`.

```html
<label for="email">Email</label>
<input id="email" aria-invalid="true" aria-describedby="email-error" />
<p id="email-error" role="alert">Enter a valid email address</p>
```

#### Success messages

Users should be informed, not only visually, when an action succeeded.

- For non-critical updates (e.g., "Saved"), use `role="status"`, which announces the message politely without interrupting screen reader flow.
- For important confirmations (e.g., "Payment complete"), use `role="alert"` to announce it immediately.

```html
<p role="status">Your changes have been saved.</p>

<p role="alert">Your payment was successful.</p>
```

These roles ensure the message is spoken automatically without requiring the user to focus it.

#### Predictable keyboard flow

- Users must be able to complete the form with Tab, Shift+Tab, and Enter.
- Maintain logical field order in the DOM. Do **not** rearrange form fields visually via CSS only.
- Avoid trapping focus inside custom widgets unless necessary (e.g., date pickers), and provide a clear escape path.

#### Provide focus styles

- Don't remove focus outlines: they're essential for keyboard and low-vision users.
- If you customize focus styles, ensure they're clearly visible (sufficient contrast, adequate size).
- Prefer `:focus-visible` to style only real keyboard focus, leaving mouse focus clean:

```css
button:focus-visible,
input:focus-visible {
  outline: 2px solid #005fcc;
  outline-offset: 2px;
}
```

## 3. <a name='KeyboardNavigation'></a>Keyboard Navigation

Keyboard accessibility is essential for users who cannot use a mouse (motor disabilities, repetitive strain injuries, temporary injuries) and for power-users who simply prefer keyboard interaction. If a UI can't be operated with a keyboard, it is not accessible.

#### Ensure all interactive elements are reachable

- Links, buttons, inputs, and controls must be focusable with **Tab**.
- Use **semantic elements first**: `<button>`, `<a>`, `<input>`, `<select>`, `<textarea>`.
- If you create a custom interactive component (e.g., `<div>` acting as a button), you **must** add:
  - `tabindex="0"`
  - Keyboard handlers for **Enter** and **Space**
  - A visible focus state

```html
<div
  role="button"
  tabindex="0"
  onkeydown="if (event.key === 'Enter' || event.key === ' ') this.click()"
>
  Custom button
</div>
```

But: **prefer a real `<button>` whenever possible**.

#### Logical tab order

- The tab order must follow the visual reading order.
- Avoid large jumps caused by:
  - Absolutely positioned elements
  - Portalled modals without proper focus handling
  - Moving elements into a new DOM position on focus or hover
- Hidden elements (`display:none`, `visibility:hidden`) should not be focusable.

#### Visible focus styles

Users must always see **where they are** on the screen.

- Never remove the outline without providing an accessible replacement.
- Prefer `:focus-visible` for modern browsers:

```css
button:focus-visible,
a:focus-visible {
  outline: 3px solid #3b82f6;
  outline-offset: 3px;
}
```

This avoids showing focus on mouse click, but keeps it for keyboard users.

#### Focus behavior in complex UI

Some components require explicit focus management:

- **Modals:**
  - Trap focus inside the modal.
  - Return focus to the trigger when the modal closes.
- **Menus and dropdowns:**
  - Move focus to the first menu item when opened.
  - Close on Escape.
- **Tabs:**
  - Arrow keys should navigate between tabs.
  - Tab should move into/out of the tab panel content.

A minimal focus trap example:

```js
const focusable = modal.querySelectorAll("button, a, input, select, textarea");
const first = focusable[0];
const last = focusable[focusable.length - 1];

modal.addEventListener("keydown", (e) => {
  if (e.key !== "Tab") return;

  if (e.shiftKey && document.activeElement === first) {
    e.preventDefault();
    last.focus();
  } else if (!e.shiftKey && document.activeElement === last) {
    e.preventDefault();
    first.focus();
  }
});
```

For more complex scenarios, consider using libraries like [focus-trap](https://github.com/focus-trap/focus-trap) or [focus-trap-react](https://github.com/focus-trap/focus-trap-react) for React applications.

#### Managing focus responsibly

- Don't move elements into a different DOM position on focus: it breaks tab order.
- If you manually call `.focus()`, make sure it's predictable and not surprising.
- Returning focus to the trigger element after closing overlays improves usability.
- Keep focus out of hidden or collapsed content (`display:none` elements should not be focusable).

#### Don't hijack keyboard behavior

- Don't override arrow keys unless you're building a component that traditionally uses them (menus, sliders, carousels).
- Don't trap the user inside components unintentionally (e.g., in carousels or chat windows).
- Avoid global `keydown` listeners that swallow Escape or Tab.

#### Quick test

A 10-second test to catch most issues:

1. Put your mouse aside.
2. Press **Tab**.
3. Can you see where you are? (focus indicator)
4. Try to reach all interactive elements.
5. Try to operate the entire flow: open menus, submit forms, close dialogs.

If something can't be done with the keyboard, it's a red flag.

## 4. <a name='ImagesAltText'></a>Images & Alt Text

Images need meaningful text alternatives so assistive technologies can convey their purpose or content. The goal is not to describe the pixels, but to communicate the **intent**.

#### When an image conveys information

Provide a short, specific description that reflects what the user needs to understand.

```html
<img
  src="team-photo.jpg"
  alt="The MarsBased team standing in front of the office"
/>
```

- Avoid vague alt text such as "image", "photo", or the filename.
- Keep it concise; screen readers read it inline with the rest of the content.

#### When an image is decorative

If an image adds visual flavour but no essential meaning, use an **empty alt attribute** so screen readers skip it.

```html
<img src="divider.svg" alt="" aria-hidden="true" />
```

- Never leave out the `alt` attribute completely; `<img>` without alt is announced as "unlabeled graphic".

#### Icons inside buttons or links

If the text already communicates the action, the icon is decorative.

```html
<button type="button">
  <img src="icon-save.svg" alt="" aria-hidden="true" />
  Save
</button>
```

If the icon is the **only** content, give it a meaningful label:

```html
<button type="button" aria-label="Open settings">
  <img src="icon-settings.svg" alt="" />
</button>
```

#### Complex images & visual content (charts, diagrams, prototypes)

Some visuals contain more than a simple picture: they convey data, relationships or meaning.  
Avoid placing essential explanations _only_ in tooltips, background images, or hover states, as they are not consistently accessible.
Use a **short `alt`** (if applicable) plus a **longer explanation**, ideally using `<figure>` and `<figcaption>`.

- `alt` → concise summary
- `figcaption` → extended description, context or insights
- **Do not repeat** the same text in both.
  - If the image needs _no_ extended explanation, use only `alt`.
  - If the caption already _fully_ describes the visual, provide an empty alt so screen readers don't read everything twice.

##### Using `<figure>` with images

```html
<figure>
  <img
    src="sales-chart.png"
    alt="Bar chart showing a 20% increase this quarter"
  />
  <figcaption>
    Revenue grew steadily from January to March, mainly driven by the Pro plan.
  </figcaption>
</figure>
```

Screen readers treat the `figcaption` as the **semantic description** of the figure, but **only the non-duplicate parts** should appear there, not a copy of the `alt`.

##### `<figure>` is not limited to `<img>`

You can use it with **any standalone visual**: `<canvas>`, `<svg>`, `<video>`, or a rendered component.  
In these cases, there is **no `alt` attribute**, so the description must be provided entirely in the caption.

```html
<figure>
  <canvas id="revenueChart" aria-hidden="true"></canvas>
  <figcaption>
    Revenue doubled in Q4, with the strongest growth in December.
  </figcaption>
</figure>
```

- `aria-hidden="true"` ensures the canvas (which exposes no semantic info) is skipped by assistive tech.
- The **caption becomes the only accessible description**, which is what users need.
- If the design doesn't require a visible caption (e.g., the insight is already in the UI), hide it visually using the `.sr-only` utility class (see [Labels & Forms](#LabelsForms) for implementation details). This keeps the content accessible while preserving the intended layout.

#### Background images

Background images (CSS) **cannot** have `alt`. Ensure the essential content is in HTML, not CSS.

```css
/* Good: purely decorative */
.hero {
  background-image: url("pattern.svg");
}

/* Avoid: meaningful content in CSS background */
.hero {
  background-image: url("fancy-tagline.png");
}
```

#### Do not encode text inside images

Text embedded inside an image is invisible to screen readers, translators, and search engines.

- Prefer real HTML text on top of a background.
- If unavoidable, duplicate the text as `alt` or nearby content.

#### Emojis and accessibility

Screen readers read emoji names, which can be awkward or confusing. If an emoji conveys important meaning, use `aria-label` to control what gets announced:

```html
<span role="img" aria-label="Warning">⚠️</span>
```

For decorative emojis, you can use `aria-hidden="true"` to hide them from screen readers, similar to decorative images.

## 5. <a name='ARIA'></a>ARIA

**ARIA** (Accessible Rich Internet Applications) provides attributes that help assistive technologies understand the structure, state and behavior of custom UI components.
It is **not** a replacement for semantic HTML; it does **not** fix inaccessible markup, and it does not add keyboard behavior automatically. Moreover, it often adds complexity and can break accessibility if misused. Use it sparingly, and only when native elements cannot express the needed behavior.

#### General rule

> **"Use native HTML whenever possible.  
> If you can use a `<button>`, `<a>`, `<label>`, `<fieldset>`, `<dialog>`, don't recreate them with `div`s and ARIA."**

#### Appropriate ARIA use

Use ARIA only to **add** missing semantics to custom components:

- `role="dialog"` for custom modals
- `aria-expanded` for disclosure widgets
- `aria-controls` to indicate what element a control affects
- `role="alert"` or `role="status"` to announce dynamic messages
- `aria-live` regions for dynamic content
- `aria-current="page"` for navigation
- `aria-selected` for tabs, listboxes, custom selects

```html
<button aria-expanded="false" aria-controls="filters">Filters</button>

<div id="filters" hidden>...</div>
```

#### When not to use ARIA

Avoid adding ARIA roles that duplicate or override native behaviors:

- Do not use `role="button"` on a `<button>`
- Do not use `role="link"` on an `<a>`
- Do not use `role="heading"` instead of using `<h1>…<h6>`
- Do not add interactive roles to `div` or `span` elements unless you fully implement keyboard interaction, focus handling and states.

ARIA attributes alone do not provide keyboard support or focus behavior. If you add `role="button"` to a `div`, you also need to handle:

- `tabindex="0"`
- `onKeyDown` for Space and Enter
- focus styling
- preventing unexpected behavior

Which is why native elements are almost always better.

#### Attributes that require caution

Use these only when you have a specific reason:

- `aria-hidden="true"` hides content from assistive tech. Only use when elements are truly decorative or duplicated visually.
- `aria-label` can provide an accessible name for icon-only buttons, but prefer visible text whenever possible.
- `aria-labelledby` is often better than `aria-label` because it references existing visible text.

```html
<button aria-label="Open settings">
  <svg aria-hidden="true">…</svg>
</button>
```

#### ARIA is not a substitute for correct structure

Avoid using ARIA to compensate for:

- missing labels
- incorrect heading hierarchy
- broken tab order
- inaccessible custom components
- poor contrast or unreadable text
- missing focus management
- images without alt text

All of these should be fixed with HTML, CSS and proper component design.

#### Quick mental model

- **First:** Use the correct native element
- **Then:** Fix semantics with structure (labels, headings, lists)
- **Finally:** Add ARIA only where necessary to fill a real gap

For more detailed guidance, refer to **WAI-ARIA (W3C Web Accessibility Initiative)**:  
https://www.w3.org/WAI/standards-guidelines/aria/

## 6. <a name='CustomUIComponents'></a>Custom UI Components

Custom UI components need to offer the same accessibility guarantees as their native HTML equivalents.  
Buttons, links, checkboxes, dialogs and selects already come with built-in semantics, keyboard behavior, and assistive-technology support. When we replace them with `div`-based widgets, we must recreate all of that manually.

Whenever possible, prefer native elements or accessibility-focused headless libraries like [React Aria](https://react-spectrum.adobe.com/react-aria/), [Radix UI](https://www.radix-ui.com/) or [Headless UI](https://headlessui.com/). When selecting any UI library, make sure its components have documented accessibility patterns and ARIA support.

Use a custom component only when the native option truly doesn't meet the product requirements.

#### What every custom component must support

If a component is custom, it must:

- Be reachable via keyboard (`Tab`, `Shift + Tab`).
- Support expected interaction keys for its pattern (e.g. `Enter`/`Space` to activate, arrows to navigate lists, `Esc` to close).
- Expose a clear accessible name (using text, `aria-label`, or `aria-labelledby`).
- Announce its role and state (`aria-expanded`, `aria-selected`, `aria-checked`, etc.).
- Manage focus consistently (no unexpected jumps, no "lost" focus).
- Provide visible focus styles.
- Respect user settings such as reduced motion and high-contrast modes.
- Work reliably with assistive technologies.

If any of these are missing, the component isn't complete.

#### Follow established patterns

For complex widgets (selects, tabs, dialogs, disclosures, listboxes, comboboxes), use the official patterns documented in the [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)

These patterns define how the component should behave (roles, expected keyboard interactions, states, relationships).  
They're not optional: assistive technologies rely on them.

#### Common mistakes

- Using a `div` as a button without adding semantics or keyboard support.
- Creating dropdowns that don't announce whether they're open or that can't be opened with the keyboard.
- Closing dropdowns on click but not on Escape.
- Building "fake inputs" that don't expose a real value to assistive tech or autocomplete.
- Tabs without `role="tablist"` and correct arrow-key navigation.
- Modals that don't trap focus or don't return focus when closed.
- Carousels or sliders that auto-rotate without user control or reduced-motion support.

#### Example (simplified)

**Incorrect**

```html
<div class="dropdown" onclick="toggle()">Selected option</div>
<div class="menu hidden">
  <div class="item">One</div>
  <div class="item">Two</div>
  <div class="item">Three</div>
</div>
```

Issues: no semantics, no states, no keyboard behavior, no accessible name.

**Correct (simplified structure + minimal keyboard behavior)**

```html
<button
  id="trigger"
  aria-expanded="false"
  aria-haspopup="listbox"
  aria-controls="options-list"
>
  Selected option
</button>

<ul id="options-list" role="listbox" hidden>
  <li role="option" tabindex="-1">One</li>
  <li role="option" tabindex="-1">Two</li>
  <li role="option" tabindex="-1">Three</li>
</ul>
```

```js
const trigger = document.getElementById("trigger");
const list = document.getElementById("options-list");
const options = Array.from(list.querySelectorAll("[role=option]"));
let currentIndex = 0;

// Make an option focusable by setting tabindex to 0, others to -1
function setActiveOption(index) {
  options.forEach((option, i) => {
    option.setAttribute("tabindex", i === index ? "0" : "-1");
  });
  options[index].focus();
}

// Open the listbox and focus the first option
function openList() {
  list.hidden = false;
  trigger.setAttribute("aria-expanded", "true");
  setActiveOption(currentIndex);
}

// Close the listbox and return focus to the trigger
function closeList() {
  list.hidden = true;
  trigger.setAttribute("aria-expanded", "false");
  trigger.focus();
}

// Open listbox with trigger button
trigger.addEventListener("keydown", (e) => {
  if (e.key === "ArrowDown" || e.key === "Enter" || e.key === " ") {
    e.preventDefault();
    openList();
  }
});

// Navigate and select options in the listbox
list.addEventListener("keydown", (e) => {
  if (e.key === "Escape") return closeList();
  if (e.key === "ArrowDown") currentIndex = (currentIndex + 1) % options.length;
  if (e.key === "ArrowUp")
    currentIndex = (currentIndex - 1 + options.length) % options.length;
  if (e.key === "Enter" || e.key === " ") {
    // Do something with options[currentIndex]
    closeList();
  }
  setActiveOption(currentIndex);
});
```

This is still simplified, but shows the minimum expected behavior: keyboard support, state management, and predictable focus handling.

## 7. <a name='ReducedMotion'></a>Reduced Motion

Some users experience motion sensitivity, vertigo or cognitive overload when exposed to large, fast or unexpected animations.  
CSS gives us tools to respect user preferences automatically, and we should use them whenever we animate UI elements.

#### Respect `prefers-reduced-motion`

Always wrap non-essential animations in a media query that checks for reduced-motion preferences:

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

This should not remove _all_ transitions everywhere by default, but it shows the pattern.  
Apply it selectively to components with significant movement.

#### Avoid motion-heavy patterns

- Big parallax effects
- Auto-scrolling or scroll-jacking
- Continuous background animations
- Large zooms, bounces or slides
- Animations that move content unexpectedly

Prefer small opacity or color transitions that feel stable.

#### Provide stable alternatives

If your component uses motion to communicate state, ensure the same information is available without animation:

- A menu should not rely solely on slide-in movement to indicate it opened.
- A snackbar should not require motion to be noticed. Also use `role="status"` or clear styling.
- A tooltip should not animate from far away; keep movement minimal.

#### Animation libraries

If you use animation libraries ([Motion (formerly Framer Motion)](https://motion.dev/), [GSAP](https://gsap.com/), [React Spring](https://react-spring.dev/)):

- Check if they provide reduced-motion helpers
- Prefer opacity/fade transitions over positional movement
- Avoid timeline-driven continuous loops unless essential

Motion example:

```jsx
import { motion, useReducedMotion } from "motion/react";

function FadeIn({ children }) {
  const shouldReduceMotion = useReducedMotion();

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: shouldReduceMotion ? 0 : 0.3 }}
    >
      {children}
    </motion.div>
  );
}
```

#### When motion is essential

If motion is part of the interaction (carousel, slider, drag & drop):

- Make movement short, predictable and slow
- Allow pause/stop if it auto-advances
- Provide visible focus outlines for keyboard users

Respecting reduced-motion settings is not only an accessibility requirement, it also makes interfaces feel calmer, more stable and more professional.

## 8. <a name='BasicAccessibilityTesting'></a>Basic Accessibility Testing

Accessibility doesn't require a full audit to catch the biggest issues.  
A few quick checks during development can prevent most blockers before they ship.

#### Keyboard testing (the fastest and most important check)

Try navigating your page with only:

- **Tab** → move forward
- **Shift+Tab** → move backward
- **Enter / Space** → activate
- **Esc** → close modals or menus
- **Arrow keys** → navigate lists, tabs, menus if applicable

If you get stuck, lose focus, or can't activate something, it's inaccessible.

#### Screen reader smoke test

You don't need to be an expert. Just test the basics:

- Turn on **VoiceOver** (macOS: Cmd+F5) or **NVDA** (Windows).
- Navigate headings (VoiceOver: VO+Cmd+H, NVDA: H).
- Navigate links (VoiceOver: VO+Cmd+L, NVDA: K).
- Navigate form controls (VoiceOver: VO+Cmd+J, NVDA: F).
- Open your UI menus and dialogs.

Check that elements:

- Have a meaningful accessible name
- Are announced with the correct role
- Have states ("expanded", "selected", etc.)

A short 3-minute test can reveal missing labels, broken structure or incorrect roles.

#### Built-in browser tools

Use Chrome DevTools → **Accessibility** pane:

- Check the **Accessibility Tree** (is the element exposed correctly?)
- Look for missing labels or incorrect roles
- Verify contrast directly in DevTools
- Inspect focus order with "Tab" focus highlighting

#### Automated tools (first pass)

Automated tools won't catch everything, but they're excellent for fast feedback:

- **Lighthouse Accessibility** (Chrome DevTools → Lighthouse tab → Accessibility audit)
- **[eslint-plugin-jsx-a11y](https://github.com/jsx-eslint/eslint-plugin-jsx-a11y)** (during development)

Run these early; treat errors as code smells.

#### Test with reduced motion & zoom

- Enable **Reduce Motion** in OS settings
- Ensure the UI still works and doesn't flicker or jump
- Zoom to **200%** in the browser
- Check that layout still holds and nothing becomes unreachable

#### When working on components

Test your component in isolation:

1. Can I reach it with keyboard?
2. Does focus go where I expect when it opens/closes?
3. Does it expose the right role and state?
4. Does it still work with reduced motion?
5. Does it behave consistently across devices?

These checks take seconds and prevent major downstream issues.

#### When QA time is limited

At minimum, test:

- Keyboard navigation
- Labels on forms
- Focus visibility
- Alt text on images
- Color contrast
- Modals opening/closing correctly
- Error messages being announced

Small habits → huge accessibility wins for the whole product.

## 9. <a name='EngineeringAccessibilityChecklist'></a>Engineering Accessibility Checklist

A fast, practical checklist to review implementations before shipping.

- **Use semantic HTML first** (`button`, `nav`, `header`, `form`, `fieldset`).
- **Every input has a label** (visible or visually hidden in short forms).
- **Correct form semantics**: required fields, autocomplete, error messages.
- **Keyboard navigation works** everywhere (Tab, Enter, Space, Esc).
- **No `outline: none`**, focus is always visible.
- **Focus management**: modals trap focus, restore on close.
- **Meaningful alt text**; decorative images use `alt=""`.
- **ARIA is used only when needed** and according to authoring practices.
- **Custom components** support roles, states, keyboard, and focus.
- **Respect prefers-reduced-motion** for animations and transitions.
- **Run automated checks** (Lighthouse, eslint-plugin-jsx-a11y).
- **Test with a screen reader** (basic navigation).
- **Test at 200% zoom** to ensure layout resilience.

### Before shipping

- Can I navigate the UI without a mouse?
- Can a screen reader user understand structure and purpose?
- Are errors and confirmations announced properly?
- Are forms usable and predictable?
- Are animations optional and non-invasive?
- Does the app behave correctly in high zoom or reduced motion mode?

If most answers are "yes", the UI is in good shape.
