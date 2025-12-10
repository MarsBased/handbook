# Accessibility for Designers

Accessibility starts at design time, not at the implementation stage.

- Design decisions influence whether a component can ever be made accessible.
- Engineers can fix some issues, but not all (e.g., insufficient contrast, overly complex layouts).
- Treat accessibility as a shared responsibility across the team: designers provide accessible structures, and engineers implement them robustly.

The following sections outline the core areas designers can influence the most.

## Table of Contents

- [1. Color & Contrast](#ColorContrast)
- [2. Typography & Legibility](#TypographyLegibility)
- [3. Layout & Cognitive Load](#LayoutCognitiveLoad)
- [4. Motion & Reduced Motion](#MotionReducedMotion)
- [5. Touch Targets](#TouchTargets)
- [6. Handoff for Accessible Implementation](#HandoffforAccessibleImplementation)
- [7. Design Accessibility Checklist](#DesignAccessibilityChecklist)

## 1. <a name='ColorContrast'></a>Color & Contrast

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
- Document intended usage so engineers can apply colors consistently.

### Testing color contrast early

Identify issues before implementation by testing:

- text over backgrounds
- interactive elements in all states (hover, active, disabled)
- text over gradients or images
- components in both light and dark themes

Chrome DevTools and tools like [WebAIM](https://webaim.org/resources/) or [Stark](https://www.getstark.co/) make this process straightforward.

## 2. <a name='TypographyLegibility'></a>Typography & Legibility

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
- Allow text to reflow naturally on mobile. Don't force fixed container widths.

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
- Add overlays or scrims when necessary; don't rely on "hopefully the image is dark enough".
- Test multiple image variations if the content is dynamic.

#### Responsive text behavior

- Avoid pixel-perfect typography specs that break when the viewport changes.
- Allow accessible zooming: users must be able to scale text up to **200%** without breaking layout.
- Avoid fixed heights on text containers.

## 3. <a name='LayoutCognitiveLoad'></a>Layout & Cognitive Load

Accessible layouts help users understand information quickly and navigate without confusion. This matters particularly for people with cognitive disabilities, ADHD, dyslexia, or anyone dealing with fatigue, stress, or a noisy environment.

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
- Maintain consistent labeling ("Submit" shouldn't become "Go!" elsewhere).
- Provide clear error messages that explain both the problem and how to fix it.
- Make interactive elements clearly interactive through styling, affordances and consistent focus/hover states.

## 4. <a name='MotionReducedMotion'></a>Motion & Reduced Motion

Motion can enhance clarity, but it can also cause distraction, disorientation or even physical discomfort for some users (motion sensitivity, vestibular disorders, migraines, ADHD). Accessible motion means using animation intentionally and providing a way to reduce it.

#### Use motion with purpose

- Use animation to clarify, not to decorate.
- Prefer small, meaningful transitions: fade, scale, slide with subtle easing.
- Avoid motion that feels abrupt, fast or directionally intense.

#### Respect the user's "prefers-reduced-motion" setting

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
- Don't rely on animation to convey essential information.

## 5. <a name='TouchTargets'></a>Touch Targets

Touch interactions must be easy, forgiving and reliable, especially on mobile. Small or tightly packed targets are one of the most common accessibility failures, affecting users with motor impairments, tremors, larger fingers, or simply using the phone while walking or holding something.

#### Minimum target size & spacing

- Aim for **44×44px** minimum ([Apple](https://developer.apple.com/design/human-interface-guidelines/accessibility#Mobility)) or **48×48px** ([Material Design](https://m3.material.io/foundations/designing/structure#dab862b1-e042-4c40-b680-b484b9f077f6)) for **all** tappable elements: buttons, icons, toggles, menu items, close icons, etc.
- The visible icon can be smaller, the tappable area should not.
- Leave enough separation between interactive elements to avoid accidental taps.
- Avoid placing small actions too close to destructive ones (e.g., "Delete" next to "Edit" without spacing).
- At least 8px spacing between touch elements is recommended.

#### Make actions clear

- Pair icons with text when clarity matters. Text improves accuracy for users with motor issues and reduces ambiguity.
- Don't hide primary actions behind long-press gestures or tiny affordances.
- Make interactive elements look interactive through shape, color, and clear states.
- Provide clear visual feedback: pressed, active and disabled states.
- Avoid animations that move the target during the tap (shifting position makes selection harder).

## 6. <a name='HandoffforAccessibleImplementation'></a>Handoff for Accessible Implementation

When delivering designs, include the essential information engineers need to implement accessibility correctly.

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

## 7. <a name='DesignAccessibilityChecklist'></a>Design Accessibility Checklist

A fast, practical checklist to review designs before shipping.

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
