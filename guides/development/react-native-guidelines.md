# MarsBased React Native Style Guide

We build mobile apps with [React Native](https://reactnative.dev/) through [Expo](https://expo.dev/) (managed workflow, Expo Router, New Architecture, React Compiler). This guide only covers what is specific to React Native and Expo. Everything else (TypeScript, function components, named exports, prop types, composition, state management, data fetching, ESLint) is the same as in our [React guidelines](/guides/development/react-guidelines.md): read that guide first and come back here for the mobile-specific parts.

<!-- vscode-markdown-toc -->
* 1. [Do's and Don'ts](#1-dos-and-donts)
	* 1.1. [Follow the React guidelines](#11-follow-the-react-guidelines)
	* 1.2. [Use Expo, managed workflow](#12-use-expo-managed-workflow)
	* 1.3. [Never touch the native folders](#13-never-touch-the-native-folders)
	* 1.4. [Install native packages with expo install](#14-install-native-packages-with-expo-install)
	* 1.5. [Read the versioned Expo docs](#15-read-the-versioned-expo-docs)
	* 1.6. [Only route files live in app/](#16-only-route-files-live-in-app)
	* 1.7. [Style with NativeWind, not StyleSheet](#17-style-with-nativewind-not-stylesheet)
	* 1.8. [Translate every user-facing string](#18-translate-every-user-facing-string)
	* 1.9. [Use kebab-case file names](#19-use-kebab-case-file-names)
	* 1.10. [Lint with expo lint and ESLint Stylistic](#110-lint-with-expo-lint-and-eslint-stylistic)
* 2. [Project organization and architecture](#2-project-organization-and-architecture)
	* 2.1. [Expo project structure](#21-expo-project-structure)
	* 2.2. [Components, hooks and domain folders](#22-components-hooks-and-domain-folders)
	* 2.3. [Path aliases](#23-path-aliases)
	* 2.4. [Tooling](#24-tooling)
* 3. [Common patterns](#3-common-patterns)
	* 3.1. [Routing with Expo Router](#31-routing-with-expo-router)
	* 3.2. [Components and platform APIs](#32-components-and-platform-apis)
	* 3.3. [Styling and theming](#33-styling-and-theming)
	* 3.4. [Server state with TanStack Query](#34-server-state-with-tanstack-query)
	* 3.5. [REST API client](#35-rest-api-client)
	* 3.6. [Forms](#36-forms)
	* 3.7. [Internationalization](#37-internationalization)
	* 3.8. [Configuration and environment](#38-configuration-and-environment)
	* 3.9. [Testing](#39-testing)
	* 3.10. [Authentication and secure storage](#310-authentication-and-secure-storage)
	* 3.11. [Builds and releases with EAS](#311-builds-and-releases-with-eas)
	* 3.12. [Third-party SDKs](#312-third-party-sdks)
* 4. [Libraries](#4-libraries)
	* 4.1. [Recommended libraries](#41-recommended-libraries)
	* 4.2. [Other libraries we have used](#42-other-libraries-we-have-used)
	* 4.3. [Libraries worth taking a look into](#43-libraries-worth-taking-a-look-into)
* 5. [Learning resources](#5-learning-resources)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

##  1. Do's and Don'ts

###  1.1. Follow the React guidelines

Everything in the [React guidelines](/guides/development/react-guidelines.md) applies unless this guide says otherwise. In particular:

- [Use TypeScript](/guides/development/react-guidelines.md#11-use-typescript) and the [TypeScript guidelines](/guides/typescript-guidelines.md)
- [Write function components](/guides/development/react-guidelines.md#13-write-function-components), [use function declarations](/guides/development/react-guidelines.md#16-do-use-function-declarations), [name exports](/guides/development/react-guidelines.md#17-do-name-exports) and [name prop types](/guides/development/react-guidelines.md#18-do-name-prop-types)
- [Make substantial compositions their own component](/guides/development/react-guidelines.md#110-make-substantial-compositions-their-own-component)
- [State management](/guides/development/react-guidelines.md#31-state-management): hooks for local state, TanStack Query for server state, Context for simple shared state, zustand for complex client state, no redux
- [External services](/guides/development/react-guidelines.md#32-external-services) and [REST](/guides/development/react-guidelines.md#34-rest): generated clients over hand-written ones
- React 19 and React Compiler: no hand-written `useMemo`, `useCallback` or `memo` (see [Server and client components](/guides/development/react-guidelines.md#36-server-and-client-components); the Server Components part does not apply, every React Native component is a client component)

The exception to the named exports rule is Expo Router: route files in `src/app/` require a default export, the same way Next.js special files do.

###  1.2. Use Expo, managed workflow

Always start from Expo: `bun create expo-app@latest` (the default template ships TypeScript, Expo Router and the `src/` folder question). Bare React Native (`react-native init`, now `@react-native-community/cli`) is only for projects that already exist in that shape or that need native code Expo cannot express with a config plugin, which is rare. We use [bun](https://bun.sh/) as the package and script manager: `bun install`, `bun add`, `bun run <script>` and `bunx <cli>` instead of their npm counterparts.

Expo gives us file-based routing, a versioned SDK that keeps native modules compatible, over-the-air updates, EAS builds and a dev client, and it lets the team ship without opening Xcode or Android Studio.

###  1.3. Never touch the native folders

The `android/` and `ios/` folders are generated by prebuild and are in `.gitignore`. Never create, edit or commit them. All native configuration goes through `app.json` (or `app.config.ts`) and [config plugins](https://docs.expo.dev/config-plugins/introduction/): icons, splash screen, permissions, deep link scheme, bundle identifiers, orientation.

If a library asks you to edit `AndroidManifest.xml`, `Info.plist` or a Gradle file, look for its config plugin first: the library itself, then the community [`@config-plugins/*`](https://github.com/expo/config-plugins) packages. Write your own config plugin if there is none. Build settings that Expo does not expose (iOS deployment target, Kotlin version, ProGuard) go through [expo-build-properties](https://docs.expo.dev/versions/latest/sdk/build-properties/), not through the native folders. Ejecting to a bare workflow is a team decision, not a shortcut.

###  1.4. Install native packages with expo install

Any package that contains native code goes in with `bunx expo install <pkg>`, so Expo picks the version compatible with the current SDK. Pure JavaScript packages go in with `bun add` as usual.

After adding, removing or upgrading dependencies run `bunx expo-doctor`, and fix version drift with `bunx expo install --fix`.

When a package must stay pinned outside the SDK's recommended version (a Reanimated major the app is not ready for), declare it in `package.json` under `expo.install.exclude` and say why in a comment next to the dependency or in `CLAUDE.md`. The same goes for `expo.doctor.reactNativeDirectoryCheck.exclude`. A pin without a reason gets "fixed" by the next `expo install --fix`.

###  1.5. Read the versioned Expo docs

Expo changes a lot between SDKs and the training data of AI assistants is usually behind. Before using an unfamiliar API, read the docs for the exact SDK the project uses (for example `https://docs.expo.dev/versions/v57.0.0/`), never the "latest" page. Put that URL in the project's `CLAUDE.md` so assistants read it too.

###  1.6. Only route files live in app/

`src/app/` is Expo Router's territory: every file there is a screen or a layout. Keep those files thin. They read route params, and render a screen component from `src/components/<feature>/`. Components, hooks, queries and types live in their own top-level folders (see [2](#2-project-organization-and-architecture)) and are imported into the route file.

```tsx
// src/app/(tabs)/posts/[id].tsx: route file, default export required by Expo Router
import { useLocalSearchParams } from "expo-router";

import { PostDetail } from "@/components/posts/post-detail/post-detail";

export default function PostScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();

  return <PostDetail id={id} />;
}
```

This is the mobile equivalent of the "only Next.js special files sit directly in a segment folder" rule from the React guide. A route file that grows `useState`, data hooks or JSX beyond a wrapper is a sign that a screen component is missing: move that code to `src/components/<feature>/` and leave the route file as a one-liner.

###  1.7. Style with NativeWind, not StyleSheet

Style exclusively with [NativeWind](https://www.nativewind.dev/) `className` utilities on top of the [gluestack-ui](https://gluestack.io/) primitives (see [3.3](#33-styling-and-theming)). No `StyleSheet.create`, no inline `style` objects, except for values that cannot be expressed as utilities: Reanimated animated styles, color props of native components (`SymbolView` tints, native tab colors) and third-party components that only accept `style`.

Theme tokens (colors, spacing, fonts) live in `global.css` following the Tailwind v4 architecture. Don't duplicate them in a `tailwind.config.js` theme block or in JavaScript constants.

###  1.8. Translate every user-facing string

All copy goes through [react-i18next](https://react.i18next.com/), from day one, even when the app ships in one language. Hardcoded user-visible strings in components are forbidden. English is the source language. See [3.7](#37-internationalization).

###  1.9. Use kebab-case file names

Expo's template uses kebab-case for every file (`post-detail.tsx`, `use-color-scheme.ts`, `_layout.tsx`), and file-based routing turns file names into URL segments. Follow it across the whole project, components included, instead of the PascalCase file names of our web projects. Component and hook identifiers stay PascalCase and camelCase as usual.

###  1.10. Lint with expo lint and ESLint Stylistic

Use `eslint-config-expo/flat` as the base (it includes `eslint-plugin-react-hooks` and the Expo rules) plus [ESLint Stylistic](https://eslint.style/) for formatting, exactly as in the [React guidelines](/guides/development/react-guidelines.md#19-lint-and-format-with-eslint). No Prettier. Run it through `bun run lint` (`expo lint`), which wires the Expo defaults. Ignore `src/lib/api/generated/**`, `android/**`, `.expo/**` and `coverage/**`.

```js
// eslint.config.js
const { defineConfig } = require("eslint/config");
const expoConfig = require("eslint-config-expo/flat");
const stylistic = require("@stylistic/eslint-plugin");

module.exports = defineConfig([
  expoConfig,
  stylistic.configs.customize({ semi: true, arrowParens: true, braceStyle: "1tbs" }),
  { ignores: ["dist/*", "coverage/**", "android/**", ".expo/**", "src/lib/api/generated/**"] },
]);
```

Add three more plugins on top of the Expo config: [@tanstack/eslint-plugin-query](https://tanstack.com/query/latest/docs/eslint/eslint-plugin-query) (catches wrong query keys and unstable deps), [eslint-plugin-react-you-might-not-need-an-effect](https://github.com/NickvanDyke/eslint-plugin-react-you-might-not-need-an-effect) (flags effects that derive state or sync props) and [eslint-plugin-simple-import-sort](https://github.com/lydell/eslint-plugin-simple-import-sort) (one import order, auto-fixed).

Generated gluestack components under `src/components/ui/` are linted like any other code. They are ours.

##  2. Project organization and architecture

Same `src/` conventions as the [React guide](/guides/development/react-guidelines.md#2-general-project-organization-and-architecture): `components/`, `hooks/`, `lib/`, `config.ts`. Folders are grouped **by role**, not by feature: every top-level folder holds one kind of file, and inside each folder things are grouped by domain (`posts`, `auth`, `cards`). Routing lives in `app/` following Expo Router's file conventions.

| Folder | Holds | Never holds |
| --- | --- | --- |
| `app/` | Expo Router routes only: screens and `_layout.tsx` | Business logic, reusable components, data fetching |
| `components/` | All React components: `ui/` primitives, `shared/` app-level, one folder per route feature | Routes, pure utilities |
| `hooks/` | Reusable hooks; `hooks/api/` for TanStack Query hooks | One-off logic that belongs in a component |
| `stores/` | zustand stores (session, wizards) | Server state |
| `contexts/` | React Context providers for rarely-changing app state | Server state, anything zustand should hold |
| `lib/` | Framework-agnostic code: API client, query client, i18n, icons | JSX |
| `types/` | Shared TypeScript types, grouped by domain | Runtime code |
| `constants/` | Static values grouped by domain | Logic, env reads |
| `config.ts` | The only reader of `process.env` | Anything else |

Older projects were bootstrapped without `src/`: the same folders sit at the repository root and `@/*` maps to the root. Expo supports both layouts. Don't migrate an existing project just for this, but never mix the two in one repo.

###  2.1. Expo project structure

```
app.json                  # Expo config: name, scheme, icons, plugins, experiments
eas.json                  # EAS build profiles and per-environment env (see 3.11)
plugins/                  # project-specific config plugins (see 3.8)
eslint.config.js
babel.config.js           # babel-preset-expo + nativewind/babel + module-resolver
metro.config.js           # withNativewind(getDefaultConfig())
openapi-ts.config.ts      # Hey API config (see 3.5)
lefthook.yml              # git hooks
assets/                   # images, fonts, icons
test/                     # Jest setup files (i18n, css stub)
src/
|- app/                   # Expo Router: routes only, thin wrappers (see 1.6)
|  |- _layout.tsx         # root layout: providers, splash screen, startup gating
|  |- index.tsx           # redirects to (auth) or (tabs) depending on the session
|  |- (auth)/             # public area: no tab bar
|  |  |- _layout.tsx      # Stack navigator
|  |  |- login.tsx        # /login
|  |  |- register.tsx     # /register
|  |- (tabs)/             # signed-in area, wrapped in AuthGuard
|     |- _layout.tsx      # Tabs navigator
|     |- home.tsx         # /home
|     |- posts/
|     |  |- _layout.tsx   # Stack navigator for this tab
|     |  |- index.tsx     # /posts
|     |  |- new.tsx       # /posts/new
|     |  |- [id].tsx      # /posts/:id
|     |- profile.tsx      # /profile
|- components/
|  |- ui/                 # design-system primitives: gluestack-ui CLI output (ours to edit, see 3.3)
|  |  |- index.ts         # barrel: import { Button, Text } from "@/components/ui"
|  |  |- button/
|  |  |- text/
|  |  |- form/            # react-hook-form kit (see 3.6)
|  |- shared/             # app-level components used by more than one feature
|  |  |- providers/
|  |  |  |- providers.tsx # provider stack used by the root layout (see 3.1)
|  |  |- error-boundary/
|  |  |  |- error-boundary.tsx
|  |  |- auth-guard/
|  |  |  |- auth-guard.tsx # redirects to (auth) when there is no session (see 3.10)
|  |  |- app-tabs/
|  |     |- app-tabs.tsx
|  |     |- app-tabs.web.tsx # platform-specific variant
|  |- auth/               # one folder per route feature, mirrors app/
|  |  |- login-form/
|  |  |  |- login-form.tsx
|  |  |- register-form/
|  |     |- register-form.tsx
|  |- posts/
|     |- post-list/       # one folder per component, always
|     |  |- post-list.tsx # screen component rendered by app/(tabs)/posts/index.tsx
|     |  |- post-list.spec.tsx
|     |- post-detail/
|     |  |- post-detail.tsx
|     |- post-form/
|     |  |- post-form.tsx
|     |  |- post-form.schema.ts
|     |- post-card/
|        |- post-card.tsx
|        |- components/   # local sub-components, same rule
|           |- post-card-footer/
|              |- post-card-footer.tsx
|- hooks/
|  |- api/                # TanStack Query hooks, one file per query or mutation (see 3.4)
|  |  |- use-posts.ts     # exports postKeys and usePosts
|  |  |- use-post.ts
|  |  |- use-create-post.ts
|  |  |- use-me.ts
|  |- use-color-scheme.ts
|  |- use-zod-form.ts
|  |- use-permissions.ts  # role booleans derived from useMe (see 3.10)
|- stores/
|  |- auth.store.ts       # zustand session store (see 3.10)
|- contexts/
|  |- theme-context.tsx
|- lib/
|  |- api/                # REST client (see 3.5)
|  |  |- client.ts        # base URL, auth headers, Accept-Language
|  |  |- generated/       # Hey API output, do not edit
|  |  |- posts.ts         # thin wrapper over the generated SDK
|  |- query/
|  |  |- client.ts        # QueryClient, onlineManager and focusManager wiring
|  |  |- invalidation.ts  # cross-domain invalidation groups (see 3.4)
|  |- i18n/
|  |  |- index.ts         # i18next instance and initI18n()
|  |  |- i18next.d.ts     # typed keys from en.json
|  |  |- locales/
|  |  |  |- en.json       # source of truth
|  |  |  |- es.json
|  |  |- native/          # expo.locales: app name and permission strings (see 3.7)
|  |     |- en.json
|  |     |- es.json
|  |- icons.ts            # lucide icons registered with cssInterop (see 3.3)
|- types/
|  |- posts/
|  |  |- post.types.ts    # domain types not covered by the generated client
|  |- auth/
|     |- auth.types.ts
|- constants/
|  |- theme.ts            # static token tables (theme colors for native props)
|  |- posts/
|     |- post-status.ts
|- config.ts              # the only reader of process.env.EXPO_PUBLIC_* (see 3.8)
|- global.css             # Tailwind v4 theme tokens (light and dark)
```

###  2.2. Components, hooks and domain folders

**Route feature to component folder, 1:1.** Every route feature under `app/` has a matching folder under `components/`: `app/(tabs)/posts/**` renders from `components/posts/**`, `app/(auth)/**` from `components/auth/**`. Adding a screen means adding or extending its component folder. The screen component (`post-list.tsx`) is the thing the route file renders; it composes smaller components from the same folder and hooks from `hooks/`.

**Three kinds of components.**

- `components/ui/`: design-system primitives with no domain knowledge (button, input, sheet, the form kit). gluestack-ui CLI output lives here. Re-exported from `components/ui/index.ts`, imported from the barrel
- `components/shared/`: app-level components used by more than one feature but too specific for `ui/` (`Providers`, `AuthGuard`, `EmptyState`, `AppTabs`)
- `components/<feature>/`: everything else, owned by one route feature

**One folder per component, always.** Every component lives in its own kebab-case folder containing a file of the same name (`post-card/post-card.tsx`). The folder is the unit of isolation: its spec, its zod schema, its styles helper and its local sub-components sit next to the component without cluttering the feature folder. Never drop loose `.tsx` files directly into `components/<feature>/`, `shared/` or `ui/`.

**Local sub-components stay local.** A component used only by one parent goes in a `components/` subfolder inside that parent's folder, following the same one-folder-per-component rule, not in the feature root or `shared/`:

```
components/posts/post-card/post-card.tsx
components/posts/post-card/post-card.spec.tsx
components/posts/post-card/components/post-card-footer/post-card-footer.tsx
components/posts/post-card/components/post-card-badge/post-card-badge.tsx
```

Promote to the feature root when a second component in the feature needs it, to `shared/` when a second feature needs it, and to `ui/` only when it has no domain knowledge left. This is the nearest common ancestor rule from the [React guide](/guides/development/react-guidelines.md#351-nextjs-app-router).

**Mirrored grouping.** `hooks/api/`, `types/`, `constants/` and `lib/api/` are grouped by the same domains as the route features (`posts`, `auth`, `cards`). A new type, constant or endpoint hook goes next to its domain siblings, so the domain is easy to grep across folders even though its files live in different roles.

###  2.3. Path aliases

Import from `src/` with the `@/` alias (`@/components/...`, `@/hooks/api/...`) and from `assets/` with `@/assets/...`. Configure it in three places and keep them in sync: `tsconfig.json` (`paths`), `babel.config.js` (`module-resolver`) and the Jest `moduleNameMapper`.

###  2.4. Tooling

- Package and script manager: [bun](https://bun.sh/) (`bun install`, `bun add`, `bun run <script>`, `bunx <cli>`), pinned with [mise](https://mise.jdx.dev/) (`mise.toml`) so everyone and CI run the same version
- Git hooks: [lefthook](https://github.com/evilmartians/lefthook), installed on `bun install` through the `prepare` script. Pre-commit lints staged files with `--fix` and `--max-warnings 0`; pre-push runs typecheck, lint and tests with coverage
- CI runs the same three commands: `lint -- --max-warnings 0`, `typecheck` and `test:cov`
- Scripts to expect in every project (run with `bun run <script>`): `start`, `android`, `ios`, `web`, `lint`, `lint:fix`, `typecheck`, `test`, `test:cov`, `api:generate`
- Projects with more than one service (the app plus its backend, a database, a mock server) run them together with [mprocs](https://github.com/pvolok/mprocs): one committed `mprocs.yaml` at the repository (or meta repository) root, one process per service, started with `bun run dev`. Every developer gets the same set of processes, one window, per-process logs and restarts. A single-service app doesn't need it: `bun run start` is enough

```yaml
# mprocs.yaml
procs:
  app:
    cwd: ./mobile
    shell: bun run start
  backend:
    cwd: ./backend
    shell: bun run dev
  db:
    shell: docker compose up postgres
```

##  3. Common patterns

###  3.1. Routing with Expo Router

[Expo Router](https://docs.expo.dev/router/introduction/) owns navigation. It is file-based like Next.js App Router, so the mental model from the React guide carries over:

- Files under `src/app/` are screens, folders are segments, `_layout.tsx` wraps its children with a navigator (`Stack`, `Tabs`, or `NativeTabs`) and persists across navigation
- `[id].tsx` for dynamic segments, `[...slug].tsx` for catch-all, `(group)` for route groups
- Navigation structure changes are file moves, not navigator config
- Enable **typed routes** (`experiments.typedRoutes: true` in `app.json`) and navigate with `Link` and `router` using typed hrefs. Never build route strings dynamically without the types catching it. Typed routes replace the `src/routes.ts` file of our web projects: the generated `.expo/types/router.d.ts` is the list of routes
- Read params with `useLocalSearchParams<{ id: string }>()` in the route file and pass them down as props
- Screen titles are set in the segment `_layout.tsx` with `Stack.Screen` options, translated with `useTranslation`. Never hardcode a title string, not even in the root layout
- Split public and authenticated areas into route groups: `(auth)/` for login, registration and onboarding, `(tabs)/` for the signed-in app. The `(tabs)/_layout.tsx` wraps its `Tabs` in an `AuthGuard` that renders `<Redirect>` when there is no session (see [3.10](#310-authentication-and-secure-storage)). `app/index.tsx` only decides where to redirect
- A tab that must exist as a route but not in the bar (a notifications list reached only from a bell icon) gets `href: null` in its `Tabs.Screen` options
- A screen that must react to becoming visible again (refresh a QR code, restart a timer) uses `useFocusEffect` from Expo Router, not `useEffect`. Screens in a stack stay mounted when covered, so `useEffect` does not fire on return
- Deep and universal links: declare the `scheme`, `ios.associatedDomains` and `android.intentFilters` in `app.json`. A link opened while logged out must survive the login: store the target (a `pendingPostId` in a small zustand store, for example) and redirect to it after authentication instead of dropping the user on the home screen

```tsx
// src/app/(tabs)/posts/_layout.tsx
import { Stack } from "expo-router";
import { useTranslation } from "react-i18next";

export default function PostsLayout() {
  const { t } = useTranslation();

  return (
    <Stack>
      <Stack.Screen name="index" options={{ title: t("posts.title") }} />
      <Stack.Screen name="new" options={{ title: t("posts.new_title") }} />
      <Stack.Screen name="[id]" options={{ title: t("posts.detail_title") }} />
    </Stack>
  );
}
```

```tsx
// Linking from a feature component
<Link href={`/posts/${post.id}`} asChild>
  <Button size="sm" variant="outline">
    <ButtonText>{t("posts.view")}</ButtonText>
  </Button>
</Link>
```

The root `_layout.tsx` is where providers go, where `initI18n()` runs and where the splash screen is held until the app is ready. Rules for it:

- Keep the provider stack in one `Providers` component (`src/components/shared/providers/providers.tsx`): `QueryClientProvider`, `GluestackUIProvider`, `SafeAreaProvider`, `KeyboardProvider` from [react-native-keyboard-controller](https://kirillzyusko.github.io/react-native-keyboard-controller/), `ThemeProvider`. The layout file stays readable and tests can reuse the same stack
- Wrap everything in an `ErrorBoundary` that renders a translated fallback with a retry action. An uncaught render error must never leave the user on a blank screen
- Call `SplashScreen.preventAutoHideAsync()` at module scope, load custom fonts with `useFonts` (expo-font) and restore the session (see [3.10](#310-authentication-and-secure-storage)), then hide the splash screen once both are ready. Render nothing before that: a flash of the wrong screen is worse than a slightly longer splash
- Initialize third-party SDKs from one place at startup, not from screens (see [3.12](#312-third-party-sdks))
- The root layout gates the app in a fixed order before rendering the main navigator: backend reachable (a health request with a short timeout, otherwise a `network-error` screen with retry), onboarding completed (a flag in AsyncStorage, otherwise `(onboarding)`), session present (otherwise `(auth)`), then `(tabs)`. Put that order in one hook (`useInitializeApp()`), not spread over screens

###  3.2. Components and platform APIs

- Images: [expo-image](https://docs.expo.dev/versions/latest/sdk/image/) (`Image`), never React Native core `Image`. Wrap it once with `styled(Image, { className: "style" })` from NativeWind and reuse that wrapper
- Lists: long or unbounded lists use `FlatList` (or [FlashList](https://shopify.github.io/flash-list/)), never `.map()` inside a `ScrollView`
- Animations: [react-native-reanimated](https://docs.swmansion.com/react-native-reanimated/), not the core `Animated` API. Gestures: [react-native-gesture-handler](https://docs.swmansion.com/react-native-gesture-handler/)
- Safe areas: [react-native-safe-area-context](https://github.com/AppAndFlow/react-native-safe-area-context) hooks and components, never hardcoded padding
- Platform differences: when a component diverges entirely per platform, use platform extensions (`component.web.tsx`, `component.ios.tsx`, `component.android.tsx`) next to the default file. Keep small inline differences in `Platform.select` or `Platform.OS` checks
- External links: open them with `expo-web-browser` on native and let `Link` behave as an anchor on web
- Screens that show secrets or payment material (QR codes, card numbers, one-time codes) call `usePreventScreenCapture()` from [expo-screen-capture](https://docs.expo.dev/versions/latest/sdk/screen-capture/) so they are blank in screenshots, recordings and the app switcher
- Haptics on meaningful actions (payment confirmed, code scanned) with [expo-haptics](https://docs.expo.dev/versions/latest/sdk/haptics/), never on every tap
- Follow the Rules of React strictly (no side effects during render, no mutating props or state): the React Compiler depends on them

###  3.3. Styling and theming

- Component library: [gluestack-ui](https://gluestack.io/) v5, built on NativeWind v5 and Tailwind v4. Do not install the legacy `@gluestack-ui/themed` packages
- Add components with the CLI (`bunx gluestack-ui add <component>`), never by hand-copying. Components are copied into `src/components/ui/` shadcn-style: they are ours to edit, so customize them in place instead of wrapping them in pass-through components. This mirrors the shadcn/ui setup of our web projects
- Recurring visual variations become variants on the copied component (its `tva` variant definitions), not ad-hoc `className` overrides at call sites
- Prefer an existing gluestack component or a variant of one over a one-off custom component
- Dark mode and theming go through the CSS variables in `global.css` (`:root`, `@media (prefers-color-scheme: dark)`, `:root.dark` and `:root.light` for the web class toggle), not through conditional `className` logic in components. NativeWind maps the media query to the device appearance on native
- The few native color props that cannot read CSS variables (`SymbolView`, native tabs, `tabBarActiveTintColor`) read a small `Colors` table in `src/constants/theme.ts` through a `useTheme()` hook. Keep that table minimal and never paste a hex value into a navigator option or a component
- Icons: [lucide-react-native](https://lucide.dev/guide/packages/lucide-react-native). Register every icon once with `cssInterop` in `src/lib/icons.ts` (so `className="text-muted-foreground"` colours it) and import icons from that file, never from the package directly
- Custom fonts: load them with `useFonts` in the root layout (Google fonts through `@expo-google-fonts/*`, brand fonts from `assets/fonts/`), register the families as theme tokens and use them through utilities (`font-heading`), never through `fontFamily` in a style
- Projects still on NativeWind v4 keep their tokens in `tailwind.config.ts` and use a `cn()` helper (clsx plus tailwind-merge) for conditional classes. That is fine for them: don't move tokens to `global.css` piecemeal. The upgrade to NativeWind v5 and gluestack-ui v5 is one dedicated change, not a side effect of a feature

###  3.4. Server state with TanStack Query

Same rules as in the [React guide](/guides/development/react-guidelines.md#312-global-state-management): TanStack Query v5 is the only manager for server state, and its cache is the global store for that data. Mobile additions:

- One `QueryClient` created in `src/lib/query.ts` and provided at the root layout. No per-feature clients
- Wire `onlineManager` to [@react-native-community/netinfo](https://github.com/react-native-netinfo/react-native-netinfo) and `focusManager` to `AppState`, so refetch-on-reconnect and refetch-on-focus work on native
- Every domain defines a query key factory (`postKeys`), exported from the hook file that owns the root key. Raw inline keys at call sites are forbidden, and invalidation always goes through the factory
- Components never call `useQuery` or `useMutation` directly. Every query and mutation is a named hook in its own file under `src/hooks/api/` (`use-posts.ts` exports `usePosts()`, `use-create-post.ts` exports `useCreatePost()`) that encapsulates key, query function and options. A mutation that must invalidate another domain imports that domain's key factory, so cross-domain cache wiring is explicit and greppable
- Mutations invalidate or update the cache in `onSuccess` or `onSettled` using the key factory. Use optimistic updates where waiting for the network feels sluggish, and always implement the rollback in `onError`
- Infinite queries for long lists set `maxPages` to bound memory
- Query keys include everything that changes the response: the params, but also the current user id, the selected tenant or company and `i18n.language` when the API returns localized content. Switching account, company or language must never show another scope's cached data
- Query hooks accept an `options` argument typed as `Pick<UseQueryOptions<...>, "enabled" | "placeholderData">` (add only what callers need) so a screen can tune a query without the hook exposing the whole TanStack surface
- Queries that depend on a param the screen may not have yet (an `id` from a deep link) set `enabled: !!id` instead of guarding in the component
- When one event changes several features at once (a new comment updates the post detail, the post list counters and the author profile), keep the list of affected key families in one helper (`src/lib/query/invalidation.ts`) and call it from the mutation. Don't spread `invalidateQueries` calls across hooks that then drift apart

```ts
// src/lib/query/client.ts
import NetInfo from "@react-native-community/netinfo";
import { QueryClient, focusManager, onlineManager } from "@tanstack/react-query";
import { AppState, Platform } from "react-native";

export const queryClient = new QueryClient({
  defaultOptions: { queries: { staleTime: 60 * 1000, retry: 2 } },
});

onlineManager.setEventListener((setOnline) =>
  NetInfo.addEventListener((state) => setOnline(!!state.isConnected)),
);

AppState.addEventListener("change", (status) => {
  if (Platform.OS !== "web") {
    focusManager.setFocused(status === "active");
  }
});
```

```ts
// src/hooks/api/use-posts.ts
export const postKeys = {
  all: ["posts"] as const,
  list: (status?: PostStatus) => [...postKeys.all, "list", status] as const,
  detail: (id: string) => [...postKeys.all, "detail", id] as const,
};

export function usePosts(status?: PostStatus) {
  return useQuery({ queryKey: postKeys.list(status), queryFn: () => postsApi.list(status) });
}
```

```ts
// src/hooks/api/use-create-post.ts
import { postKeys } from "./use-posts";

export function useCreatePost() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: CreatePostInput) => postsApi.create(input),
    onSettled: () => queryClient.invalidateQueries({ queryKey: postKeys.all }),
  });
}
```

###  3.5. REST API client

As in the [React guide](/guides/development/react-guidelines.md#34-rest), generate the client from the backend's OpenAPI spec with [Hey API](https://heyapi.dev/) into `src/lib/api/generated/` (plugins: `@hey-api/client-fetch`, `@hey-api/typescript`, `@hey-api/sdk`, `@tanstack/react-query`). Never edit the output; regenerate with `bun run api:generate`. Mobile specifics:

- `src/lib/api/client.ts` is the only hand-written configuration: base URL, auth header and `Accept-Language` set to the device language so API error messages come back translated
- In development, default the base URL to the Expo dev server host read from `Constants.expoConfig?.hostUri`. That way simulators, USB and Wi-Fi devices reach a backend running on the developer's machine with no configuration. `EXPO_PUBLIC_API_URL` only overrides it (Android emulator without adb: `http://10.0.2.2:<port>`)
- Wrap the generated SDK per resource in `src/lib/api/<resource>.ts`: re-export the DTO types under domain names (`Post`, `CreatePostInput`), call the generated functions with `throwOnError: true` and unwrap `data`. Query hooks consume these wrappers, never the generated code directly
- Types flow from the API contract. Never retype responses locally

```ts
// src/lib/api/client.ts
import Constants from "expo-constants";

import { deviceLanguage } from "@/lib/i18n";

import { client } from "./generated/client.gen";

const devServerHost = Constants.expoConfig?.hostUri?.split(":")[0];
const apiToken = process.env.EXPO_PUBLIC_API_TOKEN;

client.setConfig({
  baseUrl: process.env.EXPO_PUBLIC_API_URL ?? `http://${devServerHost ?? "localhost"}:3002`,
  headers: {
    "Accept-Language": deviceLanguage(),
    ...(apiToken === undefined ? {} : { Authorization: `Bearer ${apiToken}` }),
  },
});

export { client };
```

**No OpenAPI spec, or backend not ready yet.** Fall back to the repository pattern, one repository per domain, all under `src/lib/api/`:

- `src/lib/api/posts/posts.repository.ts` declares the interface (`IPostsRepository`) in terms of the domain types from `src/types/posts/`
- `src/lib/api/posts/rest-posts.repository.ts` implements it against a small hand-written `apiClient` (`src/lib/api/client.ts`: base URL, auth headers, JSON, an `ApiError` class carrying `statusCode` and `fieldErrors`). Wire types (`PostWire`, snake_case, exactly what the backend sends) and the `mapPost(wire): Post` functions live in this file and nowhere else. The rest of the app only sees camelCase entities
- `src/lib/api/posts/mock-posts.repository.ts` implements the same interface with fixtures and a `delay()`. It lets the UI ship before the backend exists and doubles as test data
- One typed registry (`src/lib/api/repository-registry.ts`) maps domain keys to instances: `getRepository("posts").getPost(id)`. Query hooks in `hooks/api/` call the registry, never a repository class, so switching from mock to REST is one line per domain
- Migrate to Hey API as soon as the backend publishes a spec. Wire types and mappers are exactly the code the generator would have written for you

###  3.6. Forms

[react-hook-form](https://react-hook-form.com/) plus [zod](https://zod.dev/) through `@hookform/resolvers`, as on the web. React Native has no `<form>` element and no native inputs that understand `onChange` events, so we keep a small form kit in `src/components/ui/form/`:

- `Form` renders the `FormProvider` plus a `Box`. Submission is a `Button` whose `onPress` calls `form.handleSubmit(onSubmit)()`
- `FormField`, `FormItem`, `FormLabel`, `FormControl` and `FormMessage` are the primitives (same names as the shadcn/ui form recipe). `FormControl` injects `isInvalid` into the gluestack input, so new wrappers around gluestack widgets should accept that prop
- Field components (`FormInput`, `FormTextarea`, `FormButtonGroup`) compose the primitives with the gluestack inputs and bind `value`, `onChangeText` and `onBlur`
- `useZodForm(schema, options)` in `src/hooks/` wraps `useForm` with the zod resolver, typed with the schema's input and output
- Validation messages are translated. Install [zod-i18n-map](https://github.com/aiji42/zod-i18n) as the global zod error map at i18n init so zod's built-in messages (required, too short, invalid email) come out in the user's language for free. Custom messages still go through `t`: schemas are factories taking `t` (`postSchema(t)`), built inside the component, with keys under `<feature>.form.errors.*`
- Single-choice fields with few options (statuses, roles) use `FormButtonGroup` with translated labels
- Type the schema against the API input type with `satisfies z.ZodType<CreatePostInput>` so the form and the contract cannot drift
- No English messages inside schemas. A shared `validation.ts` full of `"Password is required"` strings is a bug under the i18n rule even when the app ships in English only: use the `t` factory
- Server-side validation errors get the same treatment as client-side ones. Map the `fieldErrors` of an `ApiError` onto the form in one helper (`mapApiError(error, t, { fieldMap })`): known fields go to `form.setError(field, ...)`, `base` and unknown fields become a single global message shown above the submit button. Backend error symbols (`taken`, `invalid`) are translated through an `errors.<symbol>` key family, never shown raw
- Text inputs declare their intent: `keyboardType="email-address"`, `autoCapitalize="none"`, `autoCorrect={false}`, `secureTextEntry`, `textContentType`. It is the difference between a native-feeling form and a web form in a wrapper
- The submit button calls `Keyboard.dismiss()` before submitting, and forms live inside a keyboard-aware scroll view (react-native-keyboard-controller) so the focused field is never hidden behind the keyboard

###  3.7. Internationalization

[react-i18next](https://react.i18next.com/) with bundled JSON catalogs. Rules:

- The i18n instance lives in `src/lib/i18n/` and is created with `createInstance()`, not the implicit global. `initI18n()` runs once at the top of the root layout
- Language comes from the device ([expo-localization](https://docs.expo.dev/versions/latest/sdk/localization/) `getLocales()`), with `en` as fallback for unsupported languages. Never hardcode a language at call sites
- Catalogs are JSON files under `src/lib/i18n/locales/`, bundled with the app. No async backends
- `en.json` is the source of truth. Every other locale mirrors its key set exactly, enforced by a key-parity spec. Adding or removing a key touches every catalog in the same change
- Keys are snake_case, nested by feature (`posts.form.title`, `posts.detail_title`, `common.retry`), shared copy under `common`. Key names describe meaning, never the English text
- Keys are typed: `i18next.d.ts` augments `CustomTypeOptions` from `en.json`, so `t()` and `<Trans>` reject unknown keys. Props that carry a key are typed `ParseKeys`, not `string`
- Read translations with `useTranslation()` inside components. Never call `i18n.t()` in render code and never resolve translations at module scope
- One key per complete sentence. Dynamic values use interpolation, countable copy uses plurals, inline elements use `<Trans>` with named `components`. Never build sentences by concatenating keys
- Enum-like values rendered to users map through a key family (`posts.status.<value>`). Never render the raw value
- Dates and numbers are formatted with the active language (`i18n.language`), never the bare device default
- Not translated: code, commands, file paths, scientific names, brand names, keyboard shortcuts, version strings
- Native strings are translated too: permission usage descriptions (`NSLocationWhenInUseUsageDescription`) and the app display name go through `expo.locales` in `app.json`, one JSON per language under `src/lib/i18n/native/`. Set `CFBundleAllowMixedLocalizations` so iOS picks them up
- Namespaces are optional. A big app can split `en.json` into one i18next namespace per feature plus `common` and `errors`, read with `useTranslation("posts")`. Pick nested keys or namespaces at the start and stay with it. Either way the key casing is snake_case, and the typed keys and parity spec above still apply
- Tests run the real i18n with the English catalog (see [3.9](#39-testing)). Don't mock `react-i18next` to return keys: it hides missing keys and interpolation bugs, and it makes assertions read like `expect(getByText("auth:sign_in"))`

```ts
// src/lib/i18n/i18next.d.ts
import "i18next";

import type en from "./locales/en.json";

declare module "i18next" {
  interface CustomTypeOptions {
    defaultNS: "translation";
    resources: { translation: typeof en };
  }
}
```

###  3.8. Configuration and environment

- Runtime config comes from `app.json` through [expo-constants](https://docs.expo.dev/versions/latest/sdk/constants/). Static config stays in `app.json`. When native config needs values from the environment (Google Maps keys per platform, the path to `google-services.json`), switch to `app.config.ts`, spread the static config and override only those fields
- Read `process.env.EXPO_PUBLIC_*` in exactly one file, `src/config.ts`, which exports a typed `config` object (booleans parsed, defaults applied). Components and hooks import from it; the string `process.env` does not appear anywhere else. This is the same `src/config.ts` as in the React guide
- Environment variables exposed to the app must use the `EXPO_PUBLIC_` prefix. Anything without it is unavailable in app code by design: never work around that. Anything with it ships in the bundle, so it is never a secret. Real secrets stay on the backend
- `EXPO_PUBLIC_*` values load when the dev server starts: restart Expo after editing `.env`. Commit a `.env.example` that documents every variable
- Enable `experiments.typedRoutes` and `experiments.reactCompiler` in `app.json`
- Web output: `web.output: "single"` (SPA) while NativeWind v5 does not support Expo's static SSR. Revisit when it does
- Patched dependencies live in `patches/` (bun `patchedDependencies`). Keep the patch when bumping the package and document it in the project's `CLAUDE.md`
- Project-specific config plugins live in `plugins/` and are referenced from `app.json` by relative path (`"./plugins/with-android-manifest-fix"`). Keep them tiny and commented: they run on every prebuild and are the only native code in the repo
- Native permissions are declared in `app.json` with a user-facing reason (`ios.infoPlist.NSPhotoLibraryUsageDescription`) and requested lazily, right before the feature that needs them. Never request all permissions at startup
- Apps that QA tests on real devices ship a hidden developer menu behind `EXPO_PUBLIC_ENABLE_DEV_TOGGLES` (true in `development` and `preview` builds, false in `production`): a long press on the tab bar opens a sheet with persisted toggles such as API request logging, mocked location or data, and skipping SMS or OTP validation. Every toggle reads from one `devToggles` state and defaults to off, and none of that code is reachable when the flag is false
- Wire [@dev-plugins/react-query](https://docs.expo.dev/debugging/devtools-plugins/) in the root layout so the TanStack Query cache is inspectable from the Expo dev tools
- Ship the third-party licenses: generate `assets/third-party-licenses.txt` with [generate-license-file](https://generate-license-file.js.org/) on every dependency change and show it from a screen in settings. Some clients and stores require it

###  3.9. Testing

- Runner: [jest-expo](https://docs.expo.dev/develop/unit-testing/) with [React Native Testing Library](https://callstack.github.io/react-native-testing-library/). Config lives in the `jest` block of `package.json`
- Coverage is collected from the trees where logic lives (`src/lib`, `src/hooks`, `src/stores`, `src/contexts`) with a 100% threshold. `src/app/**` (route wiring) and `src/components/**` (generated primitives, navigation and animation wiring) are excluded by scope, although presentational components in `components/<feature>/` and `components/shared/` still get colocated specs. New logic goes in a collected tree with its spec; never park logic under an excluded tree to dodge coverage
- Specs sit next to their source (`post-list.spec.tsx`)
- Query hooks are tested with `renderHook` and a fresh `QueryClient` (`retry: false`) per test, mocking the `src/lib/api/<resource>` wrapper
- Screen components are tested by mocking the `hooks/api` hooks they use and asserting on rendered English copy. A setup file (`test/setup-i18n.ts`, wired through `setupFilesAfterEnv`) mocks `expo-localization` and initializes `en`
- CSS imports are stubbed in `moduleNameMapper`
- Native modules that don't run under Jest (secure store, notifications, purchases, analytics SDKs) are mocked once in the setup file, not in every spec. Anything mocked there needs its own contract test elsewhere
- Shared test helpers (`createTestQueryClient()`, `renderHookWithProviders()`) live in `test/` and are excluded from test discovery with `testPathIgnorePatterns`
- Repository implementations (see [3.5](#35-rest-api-client)) are unit tested against a mocked `fetch`: wire fixture in, domain entity out. Hooks are tested with the repository mocked, so each layer is covered once
- End-to-end tests on device are optional and project-specific ([Maestro](https://maestro.mobile.dev/) is the tool to evaluate). The general rules from our [Testing guidelines](/guides/development/testing-guidelines.md) still apply: critical paths first, pure business logic as unit-tested functions

###  3.10. Authentication and secure storage

- Tokens live in [expo-secure-store](https://docs.expo.dev/versions/latest/sdk/securestore/) (Keychain on iOS, Keystore on Android). Never in AsyncStorage, never in a zustand `persist` middleware backed by AsyncStorage. AsyncStorage is for non-sensitive preferences (onboarding seen, last tab)
- The session (`user`, `tokens`, `isAuthenticated`) is a small zustand store (`src/stores/auth.store.ts`). It is the only client state that is read from almost everywhere, which is exactly the zustand case from the React guide
- One `bootstrapAuth()` runs at startup before the splash screen hides: read the stored session, validate its shape, hand the tokens to the API client and hydrate the store. A half-present session (tokens without user or the reverse) is discarded, not repaired
- The store is the source of truth and storage follows it: one subscription persists token and user changes to secure storage and pushes tokens to the API client. Screens call `login()` or `logout()` on the store and never touch storage directly
- The API client owns token lifecycle details: it attaches the headers, captures rotated tokens from responses and, on a `401` while holding tokens, clears them and notifies the store so the `AuthGuard` redirects. No screen handles `401`
- With access and refresh tokens, refresh before the request when the access token is expired (store the expiry with the tokens) instead of waiting for a `401`. Refreshes are single-flight: one in-flight refresh promise, and every caller that arrives meanwhile awaits it, so ten queries mounting together produce one refresh, not ten. Debounce the "session expired" handling too: when a token dies, every in-flight query fails at once and the user must see one toast and one redirect
- Role and permission checks live in one `usePermissions()` hook that derives booleans (`canManageCards`, `canInviteUsers`) from the current user and the selected company. Screens and components read those booleans; they never compare roles themselves
- Logout clears the store, secure storage, the TanStack Query cache (`queryClient.clear()`) and the identity of every third-party SDK, in one `clearLocalSession()` helper
- Sign-up flows with several steps (account, membership, connect a provider) persist the current step next to the session, so a killed app resumes where the user left off instead of restarting registration

###  3.11. Builds and releases with EAS

- Builds, store submission and over-the-air updates go through [EAS](https://docs.expo.dev/eas/). Nobody builds release binaries on a laptop
- Triggering is a different matter. EAS can start builds automatically only through its [GitHub integration](https://docs.expo.dev/build/building-from-github/). When the client hosts the code elsewhere (GitLab, Bitbucket, Azure DevOps, a self-hosted Forgejo), release builds are triggered locally with `bunx eas build --profile production --platform all` (and `bunx eas submit`) from a clean checkout of the release tag. The build still runs on EAS servers; only the trigger is local. Document the release steps in the project's `README.md`, and keep `eas.json` as the single source of truth so a local trigger and a GitHub trigger produce the same binary
- `eas.json` declares three profiles: `development` (`developmentClient: true`, `distribution: "internal"`), `preview` (internal distribution for testers) and `production` (`autoIncrement: true`). Add an `ios-simulator` profile that `extends` `preview` with `simulator: true` for reviewers without a device
- `EXPO_PUBLIC_*` values that differ per environment (API URL, third-party public keys) are set per profile in `eas.json` `env`, not in committed `.env` files. `.env` is for the developer's machine only
- `cli.appVersionSource` is `remote`: EAS owns the build number, `app.json` `version` is the marketing version and is bumped by hand in a release commit
- Everyday development uses a development build (`expo-dev-client`), not Expo Go, as soon as the app has a dependency with native code Expo Go doesn't ship. Expo Go stays useful for quick UI work, and every SDK wrapper must tolerate its native module being absent (see [3.12](#312-third-party-sdks))
- Pin the EAS image per platform (`ios.image: "sdk-57"`) so builds don't change under you when Expo publishes a new default
- Native builds for a physical test device don't need the cloud: `bunx eas build --local --profile preview --platform android` produces the same binary on a laptop, without spending build minutes. Release builds still go through the cloud
- Secret files that native builds need (`google-services.json`, `GoogleService-Info.plist`) are not committed. Each developer copies them from the password manager, `.gitignore` excludes them, and EAS gets them as file environment variables (`GOOGLE_SERVICES_JSON`) read from `app.config.ts`
- Add a `submit` profile to `eas.json` (App Store Connect app id, Play track) and expose the two release commands as scripts: `deploy:preview` and `deploy:production` (`eas build --profile production --auto-submit`). Releases are a documented script, not a remembered command
- A non-GitHub CI can still queue builds with a robot `EXPO_TOKEN` and `eas build --non-interactive --no-wait`. Use it only when the client asks for automated builds; the default for those hosts is the local trigger described above, documented in `README.md`

###  3.12. Third-party SDKs

Analytics, marketing, payments and crash reporting SDKs are the code most likely to break a build, crash Expo Go or leak into every feature. Rules:

- One wrapper module per SDK (`src/lib/analytics.ts`, `src/lib/purchases.ts`) exposing the three or four functions the app needs (`initialize`, `identifyUser`, `reset`). Nothing else imports the SDK package
- Configure them in the `Providers` module at startup, guarded by a `configured` flag, and no-op with a `__DEV__` warning when the public key for the platform is missing
- Gate on the native module being linked (`NativeModules.X != null`) and lazy-`require` the SDK inside the wrapper when its package reads native constants at import time. In Expo Go the wrapper becomes inert instead of crashing the app at boot
- Identify the user after login, registration, password reset and session restore, from the auth flow, in one place. Reset the identity on logout
- Anything that touches purchases goes behind a repository interface (`IBillingRepository`), so the paywall UI does not know it is talking to RevenueCat and tests never load the SDK
- SDK calls are fire-and-forget from the user's point of view: never gate login or navigation on an analytics or marketing call succeeding

##  4. Libraries

###  4.1. Recommended libraries

- Framework: [Expo](https://expo.dev/) (managed workflow, New Architecture)
- Routing: [Expo Router](https://docs.expo.dev/router/introduction/) with typed routes
- Components: [gluestack-ui](https://gluestack.io/) v5 (copied into `components/ui/`)
- Styling: [NativeWind](https://www.nativewind.dev/) v5 on Tailwind v4
- Images: [expo-image](https://docs.expo.dev/versions/latest/sdk/image/)
- Animations and gestures: [react-native-reanimated](https://docs.swmansion.com/react-native-reanimated/), [react-native-gesture-handler](https://docs.swmansion.com/react-native-gesture-handler/)
- Safe areas: [react-native-safe-area-context](https://github.com/AppAndFlow/react-native-safe-area-context)
- Server state: [TanStack Query](https://tanstack.com/query) v5, with [@react-native-community/netinfo](https://github.com/react-native-netinfo/react-native-netinfo) for online status
- Typed REST client: [Hey API](https://heyapi.dev/)
- Forms: [react-hook-form](https://react-hook-form.com/) with [zod](https://zod.dev/) and `@hookform/resolvers`
- Internationalization: [react-i18next](https://react.i18next.com/) and [expo-localization](https://docs.expo.dev/versions/latest/sdk/localization/)
- Client state: [zustand](https://github.com/pmndrs/zustand) when Context is not enough (same criteria as the React guide)
- Secure storage: [expo-secure-store](https://docs.expo.dev/versions/latest/sdk/securestore/) for tokens; [@react-native-async-storage/async-storage](https://github.com/react-native-async-storage/async-storage) for non-sensitive preferences only
- Icons: [lucide-react-native](https://lucide.dev/guide/packages/lucide-react-native)
- Keyboard: [react-native-keyboard-controller](https://kirillzyusko.github.io/react-native-keyboard-controller/)
- Builds and releases: [EAS](https://expo.dev/eas) Build, Submit and Update, with [expo-dev-client](https://docs.expo.dev/versions/latest/sdk/dev-client/) for development builds
- Testing: [jest-expo](https://docs.expo.dev/develop/unit-testing/), [React Native Testing Library](https://callstack.github.io/react-native-testing-library/)
- Lint and format: `eslint-config-expo`, [ESLint Stylistic](https://eslint.style/), `@tanstack/eslint-plugin-query`, `eslint-plugin-react-you-might-not-need-an-effect`, `eslint-plugin-simple-import-sort`
- Tooling: [bun](https://bun.sh/), [mise](https://mise.jdx.dev/), [lefthook](https://github.com/evilmartians/lefthook), [mprocs](https://github.com/pvolok/mprocs) for multi-service dev environments

###  4.2. Other libraries we have used

- Push notifications and marketing: [expo-notifications](https://docs.expo.dev/versions/latest/sdk/notifications/), [Klaviyo](https://github.com/klaviyo/klaviyo-react-native-sdk) (through its Expo config plugin)
- In-app purchases and subscriptions: [RevenueCat](https://www.revenuecat.com/docs/getting-started/installation/reactnative) (`react-native-purchases`, `react-native-purchases-ui`)
- OAuth flows with third-party providers: [expo-auth-session](https://docs.expo.dev/versions/latest/sdk/auth-session/) and [expo-web-browser](https://docs.expo.dev/versions/latest/sdk/webbrowser/)
- SVG assets as components: [react-native-svg](https://github.com/software-mansion/react-native-svg) with `react-native-svg-transformer`
- Maps: [react-native-maps](https://github.com/react-native-maps/react-native-maps) with [react-native-map-clustering](https://github.com/venits/react-native-map-clustering), [expo-location](https://docs.expo.dev/versions/latest/sdk/location/)
- Bottom sheets: [@gorhom/bottom-sheet](https://gorhom.dev/react-native-bottom-sheet/)
- PDF viewing and downloads: [react-native-pdf](https://github.com/wonday/react-native-pdf) and [react-native-blob-util](https://github.com/RonRadtke/react-native-blob-util), both through `@config-plugins/*`

###  4.3. Libraries worth taking a look into

- [FlashList](https://shopify.github.io/flash-list/) for long lists
- [Maestro](https://maestro.mobile.dev/) for end-to-end tests on device
- [expo-sqlite](https://docs.expo.dev/versions/latest/sdk/sqlite/) with [Drizzle](https://orm.drizzle.team/) for local persistence

##  5. Learning resources

- Expo docs, always for the SDK you use: https://docs.expo.dev/
- Expo Router: https://docs.expo.dev/router/introduction/
- React Native docs: https://reactnative.dev/docs/getting-started
- NativeWind: https://www.nativewind.dev/
- gluestack-ui: https://gluestack.io/ui/docs
- TanStack Query React Native notes: https://tanstack.com/query/latest/docs/framework/react/react-native
