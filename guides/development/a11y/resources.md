# Accessibility Resources

A curated list of reliable, practical resources to go deeper into accessibility.  
These are the references we recommend for both design and development work.

## Official Standards & Reference Material

- **[WAI-ARIA Authoring Practices (APG)](https://www.w3.org/WAI/ARIA/apg/)** - Canonical reference on how interactive components should behave: expected roles, keyboard interaction, states and markup.

- **[WCAG Guidelines (Beginner-Friendly Overview)](https://www.w3.org/WAI/standards-guidelines/wcag/)** - High-level accessibility standards. You don't need to memorise them, but useful to understand the principles.

- **[MDN Accessibility](https://developer.mozilla.org/en-US/docs/Web/Accessibility)** - Clear explanations of semantics, focus management, roles, and browser behavior.

## UI Libraries with Strong Accessibility

When choosing a UI library, prefer options that include correct keyboard behavior, ARIA patterns and predictable focus management out of the box.

- **[Radix UI](https://www.radix-ui.com/)** – Headless, unstyled primitives with excellent accessibility

- **[React Aria (Adobe)](https://react-spectrum.adobe.com/react-aria/)** – Hooks implementing correct ARIA and keyboard behavior

- **[Headless UI](https://headlessui.com/)** – Accessible primitives for React/Vue

- **[Chakra UI](https://chakra-ui.com/)** – Component library with accessible defaults

## Accessibility Utility Libraries

Lightweight libraries to help implement specific accessibility patterns when building custom components.

- **[focus-trap](https://github.com/focus-trap/focus-trap)** / **[focus-trap-react](https://github.com/focus-trap/focus-trap-react)** – Trap focus inside modals, dropdowns, or any container. Essential for accessible dialogs.

- **[tabbable](https://github.com/focus-trap/tabbable)** – Find all focusable (tabbable) elements within a container. Useful for focus management and keyboard navigation.

- **[react-focus-lock](https://github.com/theKashey/react-focus-lock)** – React component that locks focus within its children. Simpler alternative to focus-trap for React apps.

- **[react-aria-live](https://github.com/AlmeroSteyn/react-aria-live)** – React hooks for managing live regions (`aria-live`) to announce dynamic content changes to screen readers.

## Pattern Libraries & Examples

Useful when building a component from scratch or validating a third-party design.

- **[Inclusive Components (Heydon Pickering)](https://inclusive-components.design/)** – Practical, detailed breakdowns of real UI patterns.

- **[A11y Project Patterns](https://www.a11yproject.com/patterns/)** – Curated and approachable examples.

- **[GOV.UK Design System](https://design-system.service.gov.uk/components/)** – Very robust, production-tested components.

- **[Carbon Design System (IBM)](https://carbondesignsystem.com/components/overview/components/)** – Includes accessibility notes per component.

## Testing Tools

- **[WAVE](https://wave.webaim.org/)** (Web Accessibility Evaluation Tool) – Browser extension for quick accessibility checks.

- **[Accessibility Insights](https://accessibilityinsights.io/)** – Free tool from Microsoft for testing web and Windows apps.

- **Lighthouse Accessibility Audits** (Chrome DevTools) – Built-in accessibility scoring and quick wins.

- **NVDA / VoiceOver / TalkBack** – Screen readers you can use to test critical flows.

- **Color Contrast Checkers**  
  [WebAIM](https://webaim.org/resources/contrastchecker/) / [Contrast Ratio](https://contrast-ratio.org/) / Chrome DevTools: "Accessibility → Contrast"

## Design Tools

Tools to help designers check accessibility during the design phase.

- **[Stark](https://www.getstark.co/)** – Plugin for Figma, Sketch, and Adobe XD to check contrast, simulate color blindness, and test touch targets.

- **[Contrast](https://usecontrast.com/)** – Mac app and Figma plugin for checking color contrast ratios.

- **[Color Oracle](https://colororacle.org/)** – Free color blindness simulator for Windows, Mac and Linux.

- **[Accessible Palette](https://accessiblepalette.com/)** – Create color systems with consistent lightness and contrast using CIELAB/LCh instead of HSL. Generates color ranges that meet WCAG contrast requirements automatically, solving the problem of inconsistent perceived lightness in HSL-based color systems.

## General Learning

- **[The A11y Project](https://www.a11yproject.com/)** – Beginner-friendly accessibility tutorials and articles.

- **[WebAIM](https://webaim.org/)** – Deep explanations on contrast, forms, ARIA, screen readers, etc.

- **[Smashing Magazine – Accessibility Articles](https://www.smashingmagazine.com/category/accessibility/)**

- **[CSS-Tricks – Accessibility Articles](https://css-tricks.com/tag/accessibility/)**
