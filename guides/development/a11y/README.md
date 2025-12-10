# Accessibility Guidelines

Accessibility is a core part of building high-quality digital products. These guidelines are not a full accessibility manual, but a practical reference with simple, high-impact practices that designers and frontend engineers at MarsBased can apply in their daily work.

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

- [1. Accessibility for Designers](/guides/development/a11y/for-designers.md)
  - [1.1. Color & Contrast](/guides/development/a11y/for-designers.md#ColorContrast)
  - [1.2. Typography & Legibility](/guides/development/a11y/for-designers.md#TypographyLegibility)
  - [1.3. Layout & Cognitive Load](/guides/development/a11y/for-designers.md#LayoutCognitiveLoad)
  - [1.4. Motion & Reduced Motion](/guides/development/a11y/for-designers.md#MotionReducedMotion)
  - [1.5. Touch Targets](/guides/development/a11y/for-designers.md#TouchTargets)
  - [1.6. Handoff for Accessible Implementation](/guides/development/a11y/for-designers.md#HandoffforAccessibleImplementation)
- [2. Accessibility for Frontend Engineers](/guides/development/a11y/for-engineers.md)
  - [2.1. Semantic HTML First](/guides/development/a11y/for-engineers.md#SemanticHTMLFirst)
  - [2.2. Labels & Forms](/guides/development/a11y/for-engineers.md#LabelsForms)
  - [2.3. Keyboard Navigation](/guides/development/a11y/for-engineers.md#KeyboardNavigation)
  - [2.4. Images & Alt Text](/guides/development/a11y/for-engineers.md#ImagesAltText)
  - [2.5. ARIA](/guides/development/a11y/for-engineers.md#ARIA)
  - [2.6. Custom UI Components](/guides/development/a11y/for-engineers.md#CustomUIComponents)
  - [2.7. Reduced Motion](/guides/development/a11y/for-engineers.md#ReducedMotion)
  - [2.8. Basic Accessibility Testing](/guides/development/a11y/for-engineers.md#BasicAccessibilityTesting)
- [3. Accessibility Quick Checklist](#AccessibilityQuickChecklist)
  - [3.1. For Designers](/guides/development/a11y/for-designers.md#DesignAccessibilityChecklist)
  - [3.2. For Engineers](/guides/development/a11y/for-engineers.md#EngineeringAccessibilityChecklist)
- [4. Resources](/guides/development/a11y/resources.md)

## 1. Accessibility for Designers

Accessibility starts at design time, not at the implementation stage. Design decisions determine whether a component can ever be made accessible. Engineers can solve some issues, but not all (e.g., low contrast, overly complex layouts).

[Read the full guide for designers →](/guides/development/a11y/for-designers.md)

## 2. Accessibility for Frontend Engineers

Many accessibility issues arise during implementation, but most disappear when we use the web platform as intended. Start with semantic HTML. Add ARIA only when necessary. Don't remove built-in accessibility.

[Read the full guide for engineers →](/guides/development/a11y/for-engineers.md)

## 3. <a name='AccessibilityQuickChecklist'></a>Accessibility Quick Checklist

A fast, practical checklist you can use before handing off designs or shipping frontend work.

- [Checklist for Designers →](/guides/development/a11y/for-designers.md#DesignAccessibilityChecklist)
- [Checklist for Engineers →](/guides/development/a11y/for-engineers.md#EngineeringAccessibilityChecklist)

## 4. Resources

A curated list of reliable, practical resources to go deeper into accessibility.

[View all resources →](/guides/development/a11y/resources.md)
