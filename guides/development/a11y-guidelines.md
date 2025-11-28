# Accessibility Guidelines

Accessibility is a core part of building high-quality digital products. These guidelines are not a full accessibility manual, but a practical reference with simple, high-impact practices that designers and frontend developers at MarsBased can apply in their daily work.

The goal is to help us:

- design and build interfaces that more people can use
- avoid common accessibility pitfalls early, before implementation
- ensure consistency when collaborating with clients and external designers
- follow industry-standard best practices without overcomplicating workflows

This guide is intentionally lightweight and opinionated. It focuses on what we can implement easily in our projects, from basic contrast checks to semantic HTML, keyboard navigation, and accessible component patterns.

Every improvement here benefits real users in real conditions: people with permanent, temporary, or situational limitations, but also search engines, voice assistants, and any system that needs to understand our interfaces.

According to the [Centers for Disease Control and Prevention](https://www.cdc.gov/disability-and-health/articles-documents/disabilities-health-care-access.html), 1 in 4 adults lives with some form of disability. Accessibility isn't about edge cases, it's about designing for a significant portion of your users.

Accessibility is not extra work. It's part of building things well.

## Table of Contents

- [1. Accessibility for Designers](#AccessibilityforDesigners)
  - [1.1. Color & Contrast](#ColorContrast)
  - [1.2. Typography & Legibility](#TypographyLegibility)
  - [1.3. Layout & Cognitive Load](#LayoutCognitiveLoad)
  - [1.4. Motion & Reduced Motion](#MotionReducedMotion)
  - [1.5. Touch Targets](#TouchTargets)
  - [1.6. Handoff for Accessible Implementation](#HandoffforAccessibleImplementation)
- [2. Accessibility for Frontend Developers](#AccessibilityforFrontendDevelopers)
  - [2.1. Semantic HTML First](#SemanticHTMLFirst)
  - [2.2. Labels & Forms](#LabelsForms)
  - [2.3. Keyboard Navigation](#KeyboardNavigation)
  - [2.4. Images & Alt Text](#ImagesAltText)
  - [2.5. ARIA](#ARIA)
  - [2.6. Custom UI Components](#CustomUIComponents)
  - [2.7. Reduced Motion in Code](#ReducedMotioninCode)
  - [2.8. Basic Accessibility Testing](#BasicAccessibilityTesting)
- [3. Accessibility Quick Checklist](#AccessibilityQuickChecklist)
- [4. Resources](#Resources)

## 1. <a name='AccessibilityforDesigners'></a>Accessibility for Designers

Accessibility starts at design time, not at the implementation stage.

- Design decisions influence whether a component can ever be made accessible.
- Developers can fix some issues, but not all (e.g., insufficient contrast, overly complex layouts).
- Treat accessibility as a shared responsibility across the team: designers provide accessible structures, and developers implement them robustly.

The following sections outline the core areas designers can influence the most.

### 1.1. <a name='ColorContrast'></a>Color & Contrast

Color is a critical part of accessible design. Many users rely on sufficient contrast and clear visual distinctions to understand content, navigate interfaces, and identify actions. Poor contrast affects people with visual impairments, color blindness, or ageing vision, but also users in bright environments or using low-quality displays.

### Minimum contrast ratios

Follow the WCAG contrast ratios for text and interactive elements:

- **4.5:1** for regular text
- **3:1** for large text (18px regular, or 14px bold)
- **3:1** for UI components and graphical objects (icons, inputs, borders)

Use a contrast checker during the design process. Avoid relying on #999, #AAA or similarly light greys for essential text.

### Do not rely on color alone

Color must not be the only indicator of meaning.  
For example, error messages should not be communicated only using red. Always pair color with another cue:

- an icon
- a pattern
- a label
- bold text
- a border style

This ensures users with color blindness or low vision can understand the information.

### Consistent and accessible color tokens

When defining or reviewing a design system:

- Ensure color tokens (`primary`, `danger`, `success`, etc.) meet contrast requirements by default.
- Provide accessible variants for light and dark mode.
- Document intended usage so developers can apply colors consistently.

### Testing color contrast early

Identify issues before implementation by testing:

- text over backgrounds
- interactive elements in all states (hover, active, disabled)
- text over gradients or images
- components in both light and dark themes

Chrome DevTools and tools like [WebAIM](https://webaim.org/resources/) or [Stark](https://www.getstark.co/) make this process straightforward.

### 1.2. <a name='TypographyLegibility'></a>Typography & Legibility

Good typography is essential for accessibility. It ensures users can read, scan and understand content without unnecessary effort. This applies to everyone: people with low vision, dyslexia, attention difficulties, or simply reading on a small/mobile screen.

#### Font size

- Use a **minimum of 16px** for body text.
- Larger text (18–20px) improves readability on mobile and for long-form content.
- Avoid locking text sizes inside fixed components (modals, cards); let them scale with user preferences.

#### Line height & spacing

- Use **1.4–1.6** line-height for paragraphs.
- Keep line spacing consistent for predictable rhythm.
- Provide adequate spacing between paragraphs and headings; avoid cramped blocks of text.

#### Line length

- Aim for **45–75 characters per line** on desktop for optimal readability and to avoid excessive line breaks.
- Allow text to reflow naturally on mobile. Don’t force fixed container widths.

#### Typeface choices

- Prefer simple, readable sans-serif fonts for UI.
- Avoid ultra-light, condensed or decorative typefaces for body text.
- Check that the chosen font renders well in multiple languages (accents, special characters).

#### Text weight & emphasis

- Use **font-weight 400–600** for most UI text.
- Avoid relying solely on color for emphasis (pair it with bold, underline or patterns).
- Use italics sparingly; they reduce legibility, especially on low-resolution screens.

#### When designing text over background images

- Ensure strong contrast between text and background.
- Add overlays or scrims when necessary; don’t rely on “hopefully the image is dark enough”.
- Test multiple image variations if the content is dynamic.

#### Responsive text behavior

- Avoid pixel-perfect typography specs that break when the viewport changes.
- Allow accessible zooming: users must be able to scale text up to **200%** without breaking layout.
- Avoid fixed heights on text containers.

### 1.3. <a name='LayoutCognitiveLoad'></a>Layout & Cognitive Load

Accessible layouts help users understand information quickly and navigate without confusion. This is especially important for people with cognitive disabilities, ADHD, dyslexia, or anyone dealing with fatigue, stress, or a noisy environment.

#### Visual hierarchy & organization

- Use clear hierarchy (headings, subheadings, body, captions) and ensure one main focal point per screen.
- Group related content together; separate sections with spacing, dividers or background changes.
- Use predictable patterns: consistent card structures, consistent placement of actions, consistent navigation across the product.
- Avoid sudden layout shifts or reorganizing key sections between screens.

#### Reduce cognitive load

- Minimize competing elements and visual noise (too many icons, colors, borders, animations).
- Use whitespace strategically; it improves comprehension and helps users focus.
- Prefer single-column layouts for text-heavy content (forms, articles, instructions).
- Avoid long uninterrupted blocks of text or UI elements.

#### Clear content & language

- Use short sentences, straightforward language, and avoid unnecessary jargon.
- Break complex tasks into smaller steps with step-by-step flows.
- Maintain consistent labeling (“Submit” shouldn’t become “Go!” elsewhere).
- Provide clear error messages that explain both the problem and how to fix it.
- Make interactive elements clearly interactive through styling, affordances and consistent focus/hover states.

### 1.4. <a name='MotionReducedMotion'></a>Motion & Reduced Motion

Motion can enhance clarity, but it can also cause distraction, disorientation or even physical discomfort for some users (motion sensitivity, vestibular disorders, migraines, ADHD). Accessible motion means using animation intentionally and providing a way to reduce it.

#### Use motion with purpose

- Use animation to clarify, not to decorate.
- Prefer small, meaningful transitions: fade, scale, slide with subtle easing.
- Avoid motion that feels abrupt, fast or directionally intense.

#### Respect the user’s “prefers-reduced-motion” setting

- When enabled, remove or drastically simplify animations.
- Replace long or looping motion with instant or minimal alternatives.
- Apply it to micro-interactions, page transitions and any auto-moving content (carousels, auto-scrolling, background motion).

#### Avoid problematic movement

- Avoid parallax and continuous background animations.
- Avoid scroll-hijacking.
- Avoid large element movements that slide big chunks of the UI across the screen.
- Be especially careful with motion that feels like camera movement (zooming, panning, spinning).

#### Timing and pacing

- Keep transitions short (150–250ms for most UI). Longer animations can cause discomfort.
- For complex motions, ensure they can be interrupted or skipped.
- Don’t rely on animation to convey essential information.

### 1.5. <a name='TouchTargets'></a>Touch Targets

Touch interactions must be easy, forgiving and reliable, especially on mobile. Small or tightly packed targets are one of the most common accessibility failures, affecting users with motor impairments, tremors, larger fingers, or simply using the phone while walking or holding something.

#### Minimum target size & spacing

- Aim for **44×44px** minimum ([Apple](https://developer.apple.com/design/human-interface-guidelines/accessibility#Mobility)) or **48×48px** ([Material Design](https://m3.material.io/foundations/designing/structure#dab862b1-e042-4c40-b680-b484b9f077f6)) for **all** tappable elements: buttons, icons, toggles, menu items, close icons, etc.
- The visible icon can be smaller, the tappable area should not.
- Leave enough separation between interactive elements to avoid accidental taps.
- Avoid placing small actions too close to destructive ones (e.g., “Delete” next to “Edit” without spacing).
- At least 8px spacing between touch elements is recommended.

#### Make actions clear

- Pair icons with text when clarity matters. Text improves accuracy for users with motor issues and reduces ambiguity.
- Don’t hide primary actions behind long-press gestures or tiny affordances.
- Make interactive elements look interactive through shape, color, and clear states.
- Provide clear visual feedback: pressed, active and disabled states.
- Avoid animations that move the target during the tap (shifting position makes selection harder).

### 1.6. <a name='HandoffforAccessibleImplementation'></a>Handoff for Accessible Implementation

When delivering designs, include the essential information developers need to implement accessibility correctly.

#### Communicate semantic intent

- Indicate which elements are buttons, links, headings, lists or form fields.
- Mark which icons are decorative and which convey meaning.

#### Labels, alt text & forms

- Provide the **visible label** for every form field. Visually hidden labels are fine for simple fields (e.g., search), but **long forms require visible labels** for clarity and faster scanning.
- Supply the **intended alt text** for meaningful images.
- Include examples of **error states** for each field type: error message text, placement, and when it should appear.
- Define the **expected keyboard order** (Tab flow) for complex forms or multi-step flows to avoid confusion.

#### States & interactions

- Deliver the basic interaction states: focus, active, hover, disabled, error.
- For modals, dropdowns or other complex components, clarify how they open and close.
- Provide keyboard behavior expectations.

#### Color & spacing

- Confirm that color choices meet contrast requirements.
- Ensure interactive elements meet minimum target size and spacing.

## 2. <a name='AccessibilityforFrontendDevelopers'></a>Accessibility for Frontend Developers

Many accessibility issues arise during implementation, but the good news is that most disappear when we use the web platform as intended.

Your default mindset should be:

**Start with semantic HTML. Add ARIA only when necessary. Never remove built-in accessibility.**

Small decisions in markup have a huge impact: keyboard navigation, screen reader output, SEO, machine readability and maintainability all depend on correct semantics.

### 2.1. <a name='SemanticHTMLFirst'></a>Semantic HTML First

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

#### Don’t replace native controls with divs

Avoid patterns like:

```html
<div onclick="submitForm()">Send</div>
```

They're not focusable, not operable by keyboard and not announced properly by screen readers.

If you must build a custom component, you’ll need to manually add:

- correct `role`
- `tabIndex="0"`
- full keyboard support (`Enter`, `Space`, arrow keys when needed)
- proper focus states
- ARIA attributes where appropriate

This is significantly more work and easier to get wrong.

#### Keep your HTML predictable

- Respect the natural heading hierarchy (`h1 → h2 → h3` …).
- Avoid skipping levels (don’t jump from `h1` to `h4`).
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

### 2.2. <a name='LabelsForms'></a>Labels & Forms

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

- Labels should be visible and placed consistently (top or left) when possible. **If the UI doesn’t allow labels** (e.g., search bars or very short forms), use a visually hidden label:

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

- **Never rely on placeholders as labels**. Placeholders disappear on typing, offer poor contrast, and are not consistently announced by screen readers. Use them only for hints or examples (e.g., “you@example.com”), never as the main label.

#### Required fields

- Mark required fields using the native `required` attribute; this automatically exposes the information to assistive tech.
- When necessary, reinforce with `aria-required="true"` (e.g., in custom components).
- Provide a **clear visual indicator** like “(required)” or “Required”.  
  Avoid using a lone asterisk `*` without context. Many users don’t understand what it means.

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
- Avoid disabling fields without explanation; many users won’t know why they can’t interact.
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

- Provide short, actionable instructions near the field (“Must be 8–20 characters”).
- Use `aria-describedby` for hints that should be announced:

```html
<input id="username" aria-describedby="username-hint" />
<p id="username-hint">Must be unique and contain only letters or numbers.</p>
```

#### Accessible errors

- Errors should describe the actual problem (“Password must be at least 8 characters”, not “Invalid input”) and be announced to screen readers.
- They should appear near the field, not at the bottom of the form, and be visually distinct with both **color + text** (don’t rely on red alone).
- Use `aria-invalid` and `role="alert"` when errors are present, and associate the message via `aria-describedby`.

```html
<label for="email">Email</label>
<input id="email" aria-invalid="true" aria-describedby="email-error" />
<p id="email-error" role="alert">Enter a valid email address</p>
```

#### Success messages

Users should be informed, not only visually, when an action succeeded.

- For non-critical updates (e.g., “Saved”), use `role="status"`, which announces the message politely without interrupting screen reader flow.
- For important confirmations (e.g., “Payment complete”), use `role="alert"` to announce it immediately.

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

- Don’t remove focus outlines: they’re essential for keyboard and low-vision users.
- If you customize focus styles, ensure they're clearly visible (sufficient contrast, adequate size).
- Prefer `:focus-visible` to style only real keyboard focus, leaving mouse focus clean:

```css
button:focus-visible,
input:focus-visible {
  outline: 2px solid #005fcc;
  outline-offset: 2px;
}
```

### 2.3. <a name='KeyboardNavigation'></a>Keyboard Navigation

Keyboard accessibility is essential for users who cannot use a mouse (motor disabilities, repetitive strain injuries, temporary injuries) and for power-users who simply prefer keyboard interaction. If a UI can’t be operated with a keyboard, it is not accessible.

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

- Don’t move elements into a different DOM position on focus: it breaks tab order.
- If you manually call `.focus()`, make sure it’s predictable and not surprising.
- Returning focus to the trigger element after closing overlays improves usability.
- Keep focus out of hidden or collapsed content (`display:none` elements should not be focusable).

#### Don't hijack keyboard behavior

- Don’t override arrow keys unless you're building a component that traditionally uses them (menus, sliders, carousels).
- Don’t trap the user inside components unintentionally (e.g., in carousels or chat windows).
- Avoid global `keydown` listeners that swallow Escape or Tab.

#### Quick test

A 10-second test to catch most issues:

1. Put your mouse aside.
2. Press **Tab**.
3. Can you see where you are? (focus indicator)
4. Try to reach all interactive elements.
5. Try to operate the entire flow: open menus, submit forms, close dialogs.

If something can’t be done with the keyboard, it’s a red flag.

### 2.4. <a name='ImagesAltText'></a>Images & Alt Text

Images need meaningful text alternatives so assistive technologies can convey their purpose or content. The goal is not to describe the pixels, but to communicate the **intent**.

#### When an image conveys information

Provide a short, specific description that reflects what the user needs to understand.

```html
<img
  src="team-photo.jpg"
  alt="The MarsBased team standing in front of the office"
/>
```

- Avoid vague alt text such as “image”, “photo”, or the filename.
- Keep it concise; screen readers read it inline with the rest of the content.

#### When an image is decorative

If an image adds visual flavour but no essential meaning, use an **empty alt attribute** so screen readers skip it.

```html
<img src="divider.svg" alt="" aria-hidden="true" />
```

- Never leave out the `alt` attribute completely; `<img>` without alt is announced as “unlabeled graphic”.

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
  - If the caption already _fully_ describes the visual, provide an empty alt so screen readers don’t read everything twice.

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
- If the design doesn't require a visible caption (e.g., the insight is already in the UI), hide it visually using the `.sr-only` utility class (see [Labels & Forms](#always-provide-a-real-label) for implementation details). This keeps the content accessible while preserving the intended layout.

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

### 2.5. <a name='ARIA'></a>ARIA

**ARIA** (Accessible Rich Internet Applications) provides attributes that help assistive technologies understand the structure, state and behavior of custom UI components.
It is **not** a replacement for semantic HTML; it does **not** fix inaccessible markup, and it does not add keyboard behavior automatically. Moreover, it often adds complexity and can break accessibility if misused. Use it sparingly, and only when native elements cannot express the needed behavior.

#### General rule

> **“Use native HTML whenever possible.  
> If you can use a `<button>`, `<a>`, `<label>`, `<fieldset>`, `<dialog>`, don’t recreate them with `div`s and ARIA.”**

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

### 2.6. <a name='CustomUIComponents'></a>Custom UI Components

Custom UI components need to offer the same accessibility guarantees as their native HTML equivalents.  
Buttons, links, checkboxes, dialogs and selects already come with built-in semantics, keyboard behavior, and assistive-technology support. When we replace them with `div`-based widgets, we must recreate all of that manually.

Whenever possible, prefer native elements or accessibility-focused headless libraries like [React Aria](https://react-spectrum.adobe.com/react-aria/), [Radix UI](https://www.radix-ui.com/) or [Headless UI](https://headlessui.com/). When selecting any UI library, make sure its components have documented accessibility patterns and ARIA support.

Use a custom component only when the native option truly doesn’t meet the product requirements.

#### What every custom component must support

If a component is custom, it must:

- Be reachable via keyboard (`Tab`, `Shift + Tab`).
- Support expected interaction keys for its pattern (e.g. `Enter`/`Space` to activate, arrows to navigate lists, `Esc` to close).
- Expose a clear accessible name (using text, `aria-label`, or `aria-labelledby`).
- Announce its role and state (`aria-expanded`, `aria-selected`, `aria-checked`, etc.).
- Manage focus consistently (no unexpected jumps, no “lost” focus).
- Provide visible focus styles.
- Respect user settings such as reduced motion and high-contrast modes.
- Work reliably with assistive technologies.

If any of these are missing, the component isn’t complete.

#### Follow established patterns

For complex widgets (selects, tabs, dialogs, disclosures, listboxes, comboboxes), use the official patterns documented in the [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)

These patterns define how the component should behave (roles, expected keyboard interactions, states, relationships).  
They’re not optional: assistive technologies rely on them.

#### Common mistakes

- Using a `div` as a button without adding semantics or keyboard support.
- Creating dropdowns that don’t announce whether they’re open or that can't be opened with the keyboard.
- Closing dropdowns on click but not on Escape.
- Building “fake inputs” that don’t expose a real value to assistive tech or autocomplete.
- Tabs without `role="tablist"` and correct arrow-key navigation.
- Modals that don’t trap focus or don’t return focus when closed.
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

### 2.7. <a name='ReducedMotioninCode'></a>Reduced Motion in Code

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

### 2.8. <a name='BasicAccessibilityTesting'></a>Basic Accessibility Testing

Accessibility doesn't require a full audit to catch the biggest issues.  
A few quick checks during development can prevent most blockers before they ship.

#### Keyboard testing (the fastest and most important check)

Try navigating your page with only:

- **Tab** → move forward
- **Shift+Tab** → move backward
- **Enter / Space** → activate
- **Esc** → close modals or menus
- **Arrow keys** → navigate lists, tabs, menus if applicable

If you get stuck, lose focus, or can’t activate something, it’s inaccessible.

#### Screen reader smoke test

You don’t need to be an expert. Just test the basics:

- Turn on **VoiceOver** (macOS: Cmd+F5) or **NVDA** (Windows).
- Navigate headings (VoiceOver: VO+Cmd+H, NVDA: H).
- Navigate links (VoiceOver: VO+Cmd+L, NVDA: K).
- Navigate form controls (VoiceOver: VO+Cmd+J, NVDA: F).
- Open your UI menus and dialogs.

Check that elements:

- Have a meaningful accessible name
- Are announced with the correct role
- Have states (“expanded”, “selected”, etc.)

A short 3-minute test can reveal missing labels, broken structure or incorrect roles.

#### Built-in browser tools

Use Chrome DevTools → **Accessibility** pane:

- Check the **Accessibility Tree** (is the element exposed correctly?)
- Look for missing labels or incorrect roles
- Verify contrast directly in DevTools
- Inspect focus order with “Tab” focus highlighting

#### Automated tools (first pass)

Automated tools won't catch everything, but they're excellent for fast feedback:

- **Lighthouse Accessibility** (Chrome DevTools → Lighthouse tab → Accessibility audit)
- **[eslint-plugin-jsx-a11y](https://github.com/jsx-eslint/eslint-plugin-jsx-a11y)** (during development)

Run these early; treat errors as code smells.

#### Test with reduced motion & zoom

- Enable **Reduce Motion** in OS settings
- Ensure the UI still works and doesn’t flicker or jump
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

## 3. <a name='AccessibilityQuickChecklist'></a>Accessibility Quick Checklist

A fast, practical checklist to review designs and implementations before shipping.

### For Designers

- **Color & contrast** meet WCAG AA (4.5:1 for text, 3:1 for large text).
- **Text size** is readable (16px+ body, avoid ultra-light fonts).
- **Clear hierarchy**: headings, spacing and grouping guide the eye.
- **Minimal cognitive load**: simple layouts, predictable patterns.
- **Reduced motion** considerations: avoid parallax and heavy animations.
- **Touch targets** are 44–48px minimum.
- **Interactive elements look interactive** (clear states, labels, icons).
- **Forms have visible labels**, not placeholders.
- **Images have context**: decorative vs informative is clear.
- **Interactive states**: provide hover, focus and active states in design handoff.

### For Frontend Developers

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

If most answers are “yes”, the UI is in good shape.

## 4. <a name='Resources'></a>Resources

A curated list of reliable, practical resources to go deeper into accessibility.  
These are the references we recommend for both design and development work.

### Official Standards & Reference Material

- **[WAI-ARIA Authoring Practices (APG)](https://www.w3.org/WAI/ARIA/apg/)** - Canonical reference on how interactive components should behave: expected roles, keyboard interaction, states and markup.

- **[WCAG Guidelines (Beginner-Friendly Overview)](https://www.w3.org/WAI/standards-guidelines/wcag/)** - High-level accessibility standards. You don't need to memorise them, but useful to understand the principles.

- **[MDN Accessibility](https://developer.mozilla.org/en-US/docs/Web/Accessibility)** - Clear explanations of semantics, focus management, roles, and browser behavior.

### UI Libraries with Strong Accessibility

When choosing a UI library, prefer options that include correct keyboard behavior, ARIA patterns and predictable focus management out of the box.

- **[Radix UI](https://www.radix-ui.com/)** – Headless, unstyled primitives with excellent accessibility

- **[React Aria (Adobe)](https://react-spectrum.adobe.com/react-aria/)** – Hooks implementing correct ARIA and keyboard behavior

- **[Headless UI](https://headlessui.com/)** – Accessible primitives for React/Vue

- **[Chakra UI](https://chakra-ui.com/)** – Component library with accessible defaults

### Accessibility Utility Libraries

Lightweight libraries to help implement specific accessibility patterns when building custom components.

- **[focus-trap](https://github.com/focus-trap/focus-trap)** / **[focus-trap-react](https://github.com/focus-trap/focus-trap-react)** – Trap focus inside modals, dropdowns, or any container. Essential for accessible dialogs.

- **[tabbable](https://github.com/focus-trap/tabbable)** – Find all focusable (tabbable) elements within a container. Useful for focus management and keyboard navigation.

- **[react-focus-lock](https://github.com/theKashey/react-focus-lock)** – React component that locks focus within its children. Simpler alternative to focus-trap for React apps.

- **[react-aria-live](https://github.com/AlmeroSteyn/react-aria-live)** – React hooks for managing live regions (`aria-live`) to announce dynamic content changes to screen readers.

### Pattern Libraries & Examples

Useful when building a component from scratch or validating a third-party design.

- **[Inclusive Components (Heydon Pickering)](https://inclusive-components.design/)** – Practical, detailed breakdowns of real UI patterns.

- **[A11y Project Patterns](https://www.a11yproject.com/patterns/)** – Curated and approachable examples.

- **[GOV.UK Design System](https://design-system.service.gov.uk/components/)** – Very robust, production-tested components.

- **[Carbon Design System (IBM)](https://carbondesignsystem.com/components/overview/components/)** – Includes accessibility notes per component.

### Testing Tools

- **[WAVE](https://wave.webaim.org/)** (Web Accessibility Evaluation Tool) – Browser extension for quick accessibility checks.

- **[Accessibility Insights](https://accessibilityinsights.io/)** – Free tool from Microsoft for testing web and Windows apps.

- **Lighthouse Accessibility Audits** (Chrome DevTools) – Built-in accessibility scoring and quick wins.

- **NVDA / VoiceOver / TalkBack** – Screen readers you can use to test critical flows.

- **Color Contrast Checkers**  
  [WebAIM](https://webaim.org/resources/contrastchecker/) / [Contrast Ratio](https://contrast-ratio.org/) / Chrome DevTools: "Accessibility → Contrast"

### Design Tools

Tools to help designers check accessibility during the design phase.

- **[Stark](https://www.getstark.co/)** – Plugin for Figma, Sketch, and Adobe XD to check contrast, simulate color blindness, and test touch targets.

- **[Contrast](https://usecontrast.com/)** – Mac app and Figma plugin for checking color contrast ratios.

- **[Color Oracle](https://colororacle.org/)** – Free color blindness simulator for Windows, Mac and Linux.

- **[Accessible Palette](https://accessiblepalette.com/)** – Create color systems with consistent lightness and contrast using CIELAB/LCh instead of HSL. Generates color ranges that meet WCAG contrast requirements automatically, solving the problem of inconsistent perceived lightness in HSL-based color systems.

### General Learning

- **[The A11y Project](https://www.a11yproject.com/)** – Beginner-friendly accessibility tutorials and articles.

- **[WebAIM](https://webaim.org/)** – Deep explanations on contrast, forms, ARIA, screen readers, etc.

- **[Smashing Magazine – Accessibility Articles](https://www.smashingmagazine.com/category/accessibility/)**

- **[CSS-Tricks – Accessibility Articles](https://css-tricks.com/tag/accessibility/)**
