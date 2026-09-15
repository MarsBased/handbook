# MarsBased React Style Guide

We bootstrap React applications with [Next.js](https://nextjs.org/) (App Router) by default. Use [Vite](https://vite.dev/) for single-page apps that don't need server-side rendering, SEO or server code. [Create React App](https://react.dev/blog/2025/02/14/sunsetting-create-react-app), which we used on older projects, was deprecated by the React team in 2025 and must not be used for new projects. For mobile apps, see our [React Native guidelines](/guides/development/react-native-guidelines.md), which build on this guide.

<!-- vscode-markdown-toc -->
* 1. [Do's and Don'ts](#1-dos-and-donts)
	* 1.1. [Use TypeScript](#11-use-typescript)
	* 1.2. [Use a generator to bootstrap the project](#12-use-a-generator-to-bootstrap-the-project)
	* 1.3. [Write function components](#13-write-function-components)
	* 1.4. [Use hooks for state management](#14-use-hooks-for-state-management)
	* 1.5. [Use a declarative API library](#15-use-a-declarative-api-library)
	* 1.6. [Do use function declarations](#16-do-use-function-declarations)
	* 1.7. [Do name exports](#17-do-name-exports)
	* 1.8. [Do name prop types](#18-do-name-prop-types)
	* 1.9. [Lint and format with ESLint](#19-lint-and-format-with-eslint)
	* 1.10. [Make substantial compositions their own component](#110-make-substantial-compositions-their-own-component)
* 2. [General project organization and architecture](#2-general-project-organization-and-architecture)
	* 2.1. [Next.js project structure](#21-nextjs-project-structure)
	* 2.2. [Vite SPA project structure](#22-vite-spa-project-structure)
	* 2.3. [References (project structure)](#23-references-project-structure)
* 3. [Description of the most common patterns used to solve common problems](#3-description-of-the-most-common-patterns-used-to-solve-common-problems)
	* 3.1. [State management](#31-state-management)
		* 3.1.1. [Local state management](#311-local-state-management)
		* 3.1.2. [Global state management](#312-global-state-management)
	* 3.2. [External services](#32-external-services)
	* 3.3. [GraphQL](#33-graphql)
	* 3.4. [REST](#34-rest)
	* 3.5. [Routing](#35-routing)
		* 3.5.1. [Next.js App Router](#351-nextjs-app-router)
		* 3.5.2. [Route definitions](#352-route-definitions)
		* 3.5.3. [Access route parameters](#353-access-route-parameters)
		* 3.5.4. [SPA with Vite and react-router](#354-spa-with-vite-and-react-router)
	* 3.6. [Server and client components](#36-server-and-client-components)
	* 3.7. [Testing](#37-testing)
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

###  1.1. Use TypeScript

Always. Start from the TypeScript template of your framework and follow our [TypeScript guidelines](/guides/typescript-guidelines.md). The rules below (1.6 to 1.8) complement that guide with React-specific conventions.

###  1.2. Use a generator to bootstrap the project

A project generator saves a lot of boilerplate work and provides common conventions.

- Default: [Next.js](https://nextjs.org/) with the App Router: `npx create-next-app@latest` (pick TypeScript, ESLint, App Router and the `src/` directory).
- Single-page apps without SSR, SEO or server code: [Vite](https://vite.dev/): `npm create vite@latest -- --template react-ts`.

Older projects were bootstrapped with Create React App, but it's deprecated and must not be used for new projects.

###  1.3. Write function components

Functions and hooks are the standard. Class components are legacy: never write new ones, and migrate them when you touch them.

###  1.4. Use hooks for state management

- In general, prefer React's hooks for local state management
- For global state, prefer server-side state: keep the server as the source of truth and read it with Server Components or TanStack Query
- Keep shareable UI state (pagination, filters, search, sort, active tab) in the URL search params, so a link reproduces the exact view
- If server-side state is not possible, prefer React Context for simple state (theme, current user, feature flags)
- For more complex client-side state, use a library (with hooks), for example [zustand](https://github.com/pmndrs/zustand)
- Avoid redux. If a project already depends on it or it's unavoidable, use [Redux Toolkit](https://redux-toolkit.js.org/) and its hooks API

See patterns (below) for examples and usages.

###  1.5. Use a declarative API library

It reduces boilerplate code a lot.

We currently use:

- REST: [TanStack Query](https://tanstack.com/query) (formerly react-query)
- GraphQL: [apollo-client](https://github.com/apollographql/apollo-client)

Don't write API types by hand. For external REST APIs, generate the types and the client from their OpenAPI spec with [Hey API](https://heyapi.dev/) (`@hey-api/openapi-ts`). See [REST](#34-rest).

In Next.js, Server Components fetch data directly and don't need a client library. TanStack Query is for client components. See [Server and client components](#36-server-and-client-components).

###  1.6. Do use function declarations

For a better readability.

```tsx
// Don't declare arrow functions
const App = () => (
  <div>
    <Logo />
  </div>
);

// DO declare functions
function App() {
  return (
    <div>
      <Logo />
    </div>
  );
}
```

###  1.7. Do name exports

It allows to export multiple values and it encourages the use of the same naming.

```tsx
export function LoginPage() {
  ...
}
```

The exception is Next.js file conventions: `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx` and `not-found.tsx` require a default export, and route handlers export named `GET`, `POST`, etc. Use default exports only there.

###  1.8. Do name prop types

Declare an exported `XProps` type right above the component and use it in the signature. Don't use `React.FC` or anonymous object types in the signature. This follows the [Use named types](/guides/typescript-guidelines.md#use-named-types-avoid-anonymous-types) and "Export every type" rules from our TypeScript guidelines.

```tsx
export type LoginFormProps = { user?: string };

export function LoginForm({ user = "" }: LoginFormProps) {
  ...
}
```

###  1.9. Lint and format with ESLint

- Use [eslint-plugin-react-hooks](https://react.dev/reference/eslint-plugin-react-hooks) (`rules-of-hooks`, `exhaustive-deps`; version 6 and later also ships the React Compiler rules). `create-next-app` includes it through `eslint-config-next`. On Vite projects, add it to the ESLint config yourself.
- Format with [ESLint Stylistic](https://eslint.style/) (`@stylistic/eslint-plugin`) instead of Prettier. One tool, one config, one `--fix` pass: formatting rules live next to the rest of the lint rules and there is no conflict between two formatters.

###  1.10. Make substantial compositions their own component

A composition of components becomes a named component as soon as it has enough substance, even if it is used only once. Signs of substance: it represents a concept you can name (`UserCard`, `InvoiceSummary`), it has its own state, handlers or data needs, or it is more than a few lines of nested JSX. Give it a name, place it at the nearest common ancestor of its consumers (generic UI primitives go straight to `src/components/`, see [3.5.1](#351-nextjs-app-router)), type its props (see 1.8) and treat it like any other component: it gets its own file, its own tests and its own review.

Repetition is the second trigger: the same combination of components, wiring and props in more than one place is a component by definition. Don't copy-paste the JSX. Duplicated compositions drift apart, and every visual or behavioural change has to be hunted down in each copy.

```tsx
// Don't leave a substantial composition inline in the page, even if it appears only here
export default function ProfilePage({ user }: ProfilePageProps) {
  return (
    <main>
      <Card>
        <CardHeader>
          <Avatar src={user.avatarUrl} alt={user.name} />
          <CardTitle>{user.name}</CardTitle>
          <Badge>{user.role}</Badge>
        </CardHeader>
        <CardContent>{user.bio}</CardContent>
      </Card>
    </main>
  );
}

// DO name it and pass in only what varies
export type UserCardProps = { user: User };

export function UserCard({ user }: UserCardProps) {
  return (
    <Card>
      <CardHeader>
        <Avatar src={user.avatarUrl} alt={user.name} />
        <CardTitle>{user.name}</CardTitle>
        <Badge>{user.role}</Badge>
      </CardHeader>
      <CardContent>{user.bio}</CardContent>
    </Card>
  );
}

export default function ProfilePage({ user }: ProfilePageProps) {
  return (
    <main>
      <UserCard user={user} />
    </main>
  );
}
```

Small one-off layout fragments with no name of their own stay inline.

##  2. General project organization and architecture

We follow a conventional `src/` folder structure. Shared conventions, regardless of the framework:

- One config file: `src/config.ts`
- Declare all app route paths at `src/routes.ts` (see [Route definitions](#352-route-definitions))
- All non-route components under `components/` (can be nested)
- All hooks under `hooks/` (can expose Providers)
- One folder for each (external) service. For example `api/` (for REST APIs), `graphql/` for GraphQL or `auth/` for authorization service. They can include type definitions, data transformations, clients or anything related to that service and communication with it.
- One folder for locales: `locales/`
- The rest: utility functions, helpers, etc... under `lib/` (keep it clean, please)

Routing is where the two flavours differ: Next.js uses the `app/` folder, Vite SPAs use `pages/` plus a `Router.tsx`.

###  2.1. Next.js project structure

```
src/
|- app/                   # App Router: folders are URL segments, files are UI
|  |- layout.tsx          # root layout (html, body, providers)
|  |- page.tsx            # /
|  |- posts/
|  |  |- _components/     # segment-private UI (not routable, see 3.5.1)
|  |  |- _lib/            # segment-private actions/helpers (not routable)
|  |  |- page.tsx         # /posts
|  |  |- [id]/
|  |     |- page.tsx      # /posts/:id (dynamic segment)
|  |     |- loading.tsx   # streaming fallback (optional)
|  |- (admin)/            # route group: shared layout, adds no URL segment
|  |  |- layout.tsx
|  |  |- users/
|  |     |- page.tsx      # /users
|  |- api/                # Route Handlers (optional)
|     |- health/
|        |- route.ts
|- routes.ts              # typed route helpers (see 3.5.2)
|- config.ts              # application configuration
|- components/            # non-route components ("use client" only when needed)
|  |- ui/                 # component library primitives (shadcn/ui CLI output, see 4.1)
|  |  |- button.tsx
|  |  |- dialog.tsx
|  |- Spinner.tsx         # shared component
|  |- posts/              # folder for specific areas or sections
|     |- PostForm.tsx
|- hooks/
|  |- useUser.ts          # hook
|- locales/
|  |- type.d.ts           # Locale type definitions
|  |- en-GB.ts            # locale for en-GB
|- api/                   # REST client (optional, see 3.4)
|  |- client.ts           # client configuration (base URL, auth)
|  |- generated/          # Hey API output, do not edit
|- graphql/               # GraphQL folder (optional)
|  |- types.d.ts
|  |- schema.ts
|- auth/                  # Authorization service (optional)
|  |- types.d.ts
|  |- index.ts
|- lib/                   # internal libraries aka "Everything else"
   |- randomColor.ts
next-env.d.ts             # generated by Next.js at the project root, do not edit
```

There is no `pages/` folder: the Pages Router is legacy. Only Next.js special files (`page.tsx`, `layout.tsx`, `route.ts`, etc.) sit directly in a segment folder. Segment-scoped code is colocated in private folders (`_components/`, `_lib/`, see [3.5.1](#351-nextjs-app-router)); generic UI components and anything shared across unrelated areas go to `components/`. Component library primitives live in `components/ui/`: it's where the shadcn/ui CLI installs them, and we keep the same folder with other component libraries so the split between library primitives and our own components is always the same.

###  2.2. Vite SPA project structure

```
src/
|- main.tsx               # entry point (createRoot)
|- App.tsx                # Application setup (providers)
|- Router.tsx             # BrowserRouter and Routes (see 3.5.4)
|- routes.ts              # typed route helpers (see 3.5.2)
|- config.ts              # application configuration
|- pages/                 # page components, mimic the URL hierarchy
|  |- HomePage.tsx
|  |- PostListPage.tsx
|  |- PostPage.tsx
|  |- admin/
|     |- AdminUserListPage.tsx
|- components/            # same as Next.js
|- hooks/
|- locales/
|- api/                   # same as Next.js (optional)
|- graphql/
|- auth/
|- lib/
|- vite-env.d.ts          # Vite client types (from the template)
```

If using a repo for both api and client, put the above inside `client/` folder

###  2.3. References (project structure)

- Next.js [project structure](https://nextjs.org/docs/app/getting-started/project-structure) docs
- Route definitions idea taken from [Redwood](https://github.com/redwoodjs/redwood) framework

##  3. Description of the most common patterns used to solve common problems

###  3.1. State management

- In general, prefer hooks over any other solution
- Most "global state" is really server state. Keep it on the server and let the data layer cache it instead of copying it into a client store
- If a user could want to share, bookmark or reload a view, its state belongs in the URL, not in a store
- You probably don't need redux. Hooks, Context and zustand cover almost every case. If redux is unavoidable, use Redux Toolkit and its hooks API

####  3.1.1. Local state management

React hooks (`useState`, `useReducer`) are enough most of the time. Keep state as close as possible to the components that use it and lift it only when needed.

####  3.1.2. Global state management

Pick the simplest option that works, in this order:

1. **Server-side state.** Data that lives in a database or API belongs to the server. Read it in Server Components (Next.js) or with [TanStack Query](https://tanstack.com/query) in client components, and mutate it with Server Actions or mutations. TanStack Query's cache is the "global store" for that data: don't duplicate it in a client store
2. **URL state.** Anything that describes *which* view the user is looking at goes in the URL: current page, page size, filters, search query, sort column and direction, active tab, open drawer or selected item. Links become shareable, the back button works, reloads keep the view and Server Components can read the params on the server. See [URL state](#313-url-state)
3. **React Context.** For simple client-only state that rarely changes and is read by many components: theme, locale, current user, feature flags. Keep each context small and colocate the provider with the subtree that needs it
4. **zustand.** For complex client-only state: many writers, frequent updates, derived data or state that outlives a subtree (multi-step wizards, editors, carts). Prefer [zustand](https://github.com/pmndrs/zustand) over hand-rolled context plus reducers. Keep stores small and split them by domain
5. **redux.** Only when a project already depends on it. Use Redux Toolkit and its hooks API

Context is not a global store: every consumer re-renders when the value changes. If a context grows or updates often, move it to zustand.

####  3.1.3. URL state

The URL is the first place to put view state. Rules:

- Search params hold *view* state (`?page=2&q=react&sort=-createdAt&status=open`); the path holds *identity* (`/posts/42`). Never put secrets or large payloads in either
- Parse and validate search params with [zod](https://zod.dev/) in one place per route (`_lib/searchParams.ts` in Next.js). Defaults live in the schema, not spread over the components
- Omit a param when it has its default value so canonical URLs stay short and cache-friendly
- Reset dependent params together: changing a filter or the search query sends the user back to page 1
- Read the params on the server whenever possible. In Next.js, `page.tsx` receives `searchParams` (a Promise since Next.js 15): validate them and fetch in the Server Component. Client components that need to update them use `useSearchParams` with `router.replace` (or `push` when the change should create a history entry)
- In a Vite SPA use react-router's `useSearchParams` plus the same zod schema
- If the project handles many params, use [nuqs](https://nuqs.dev/): typed, `useState`-like search params with a shared parser for server and client. It works on Next.js App Router and react-router

```ts
// src/app/(dashboard)/posts/_lib/searchParams.ts
import { z } from "zod";

export const postsSearchParamsSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  q: z.string().trim().default(""),
  status: z.enum(["open", "closed", "all"]).default("all"),
  sort: z.enum(["createdAt", "-createdAt", "title"]).default("-createdAt"),
});

export type PostsSearchParams = z.infer<typeof postsSearchParamsSchema>;
export const defaults = postsSearchParamsSchema.parse({});
```

```tsx
// src/app/(dashboard)/posts/page.tsx
export type PostListPageProps = {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

export default async function PostListPage({ searchParams }: PostListPageProps) {
  const params = postsSearchParamsSchema.parse(await searchParams);
  const posts = await getPosts(params);
  return <PostList posts={posts} params={params} />;
}
```

```tsx
// src/app/(dashboard)/posts/_components/PostFilters.tsx
"use client";

import { usePathname, useRouter, useSearchParams } from "next/navigation";

export function PostFilters({ params }: { params: PostsSearchParams }) {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();

  function update(patch: Partial<PostsSearchParams>) {
    const next = new URLSearchParams(searchParams);
    // any filter change resets pagination; default values are dropped from the URL
    for (const [key, value] of Object.entries({ ...patch, page: 1 })) {
      value === defaults[key as keyof PostsSearchParams]
        ? next.delete(key)
        : next.set(key, String(value));
    }
    router.replace(`${pathname}?${next}`);
  }

  return (
    <input
      defaultValue={params.q}
      onChange={(e) => update({ q: e.target.value })}
      placeholder="Search posts"
    />
  );
}
```

###  3.2. External services

- Create a clean interface for each service. For example: `src/api/index.ts` (functions to send http requests to a REST API) or `src/graphql/index.ts` (queries and mutations of a GraphQL endpoint)
- Prefer generated types over hand-written ones: Hey API for REST, GraphQL Code Generator for GraphQL. Fall back to `<service-name>/types.ts` when there is no schema to generate from
- Use declarative data fetching: prefer `useQuery` over `fetch` (available both in Apollo client and TanStack Query)

###  3.3. GraphQL

We currently use [apollo-client](https://www.apollographql.com/docs/react/)

Generate types and code as much as possible with [GraphQL Code Generator](https://the-guild.dev/graphql/codegen).

In general, keep all graphql related code inside `graphql/` folder.

###  3.4. REST

- Generate the client and its types from the OpenAPI spec with [Hey API](https://heyapi.dev/) (`@hey-api/openapi-ts`) into `src/api/generated/`. Its TanStack Query plugin produces ready-to-use query and mutation options. See our [TypeScript guidelines](/guides/typescript-guidelines.md)
- Hand-write only `src/api/client.ts` (base URL, auth headers, interceptors) and thin wrappers around the generated code
- No spec? Fall back to a single `src/api/index.ts` exporting all API interactions and `src/api/types.ts` for entity type definitions
- If Auth and API are different services, is common to have two folders (`src/auth` and `src/api`) and the API depends on authorization (JWT tokens, for example). If auth and API are in the same service, the `src/auth` folder can be omitted.

###  3.5. Routing

Next.js routes are defined by the file system (App Router). Vite SPAs use react-router. In both cases keep the route paths in `src/routes.ts` (see [Route definitions](#352-route-definitions)).

####  3.5.1. Next.js App Router

- Folders under `app/` are URL segments. `page.tsx` is the route UI, `layout.tsx` wraps its children and persists across navigation
- `[id]` for dynamic segments, `[...slug]` for catch-all routes, `(group)` for route groups (shared layout, no URL segment)
- `loading.tsx`, `error.tsx` and `not-found.tsx` are the Suspense, error boundary and 404 conventions
- Navigate with `next/link`
- Only Next.js special files (`page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`, `route.ts`) sit directly in a segment folder. Cross-cutting reusable components still go to `components/`; code that belongs to one route segment is colocated inside the segment using **private folders**.

**Private folders.** Prefixing a folder with an underscore (`_folder`) opts it and all its children out of routing: the router never turns it into a URL segment, even if it contains files named like special files. Use them to colocate segment-scoped code without polluting the segment root:

- `_components/`: UI components used only by that segment.
- `_lib/`: logic: Server Actions, validation, search params parsing (see [3.1.3](#313-url-state)), helpers.
- Tests stay next to their source inside the same private folder.

```
app/
|- (dashboard)/
|  |- _components/        # shared by every dashboard route
|  |  |- AppHeader.tsx
|  |- _lib/
|  |  |- searchParams.ts
|  |- layout.tsx
|  |- posts/
|     |- _components/
|     |  |- PostRow.tsx
|     |- _lib/
|     |  |- actions.ts    # Server Actions for this segment
|     |- page.tsx
```

Place shared code at the **nearest common ancestor** of its consumers: used by one route, that segment's private folders; used by several routes under a layout, the private folders of the segment that owns the layout; used across unrelated areas, `src/components/` and `src/lib/` as before. Exception: generic, purely UI components with no domain knowledge (a combobox, a modal, a button) skip this rule and always live in the root `src/components/`, even if only one segment uses them today. They are the project's design system, not segment code. Two notes: colocation in `app/` is safe even without the underscore (only `page.tsx` and `route.ts` create URLs), so the prefix's value is signalling intent and protecting against future special-file collisions; and if a real URL segment must start with an underscore, name the folder `%5FfolderName`. Reference: Next.js docs, [Project structure: private folders](https://nextjs.org/docs/app/getting-started/project-structure#private-folders).

```tsx
// src/app/posts/[id]/page.tsx (Server Component; default export required by Next.js)
// params is a Promise since Next.js 15
export type PostPageProps = { params: Promise<{ id: string }> };

export default async function PostPage({ params }: PostPageProps) {
  const { id } = await params;
  const post = await getPost(id);
  return <PostDetail post={post} />;
}
```

####  3.5.2. Route definitions

It's a file to generate route paths. Advantages:

- You get an overview of all available routes on the app
- It helps to prevent errors when declaring routes
- Route completion via editor
- In Next.js it keeps links in sync with the `app/` folder structure

```ts
export default {
  posts: () => `/posts`,
  post: (id: string) => `/posts/${id}`,
  admin: {
    users: () => `/admin/users`,
  },
};
```

Usage:

```tsx
import routes from "./routes";

// Next.js
<Link href={routes.post(post.id)}>Read more</Link>;

// react-router
<Link to={routes.post(post.id)}>Read more</Link>;
```

####  3.5.3. Access route parameters

For a route like `/posts/:postId/comments/:commentId`:

```tsx
// Next.js Server Component: read the params prop (see 3.5.1)
const { postId, commentId } = await params;

// Next.js client component
"use client";
import { useParams } from "next/navigation";
const { postId, commentId } = useParams<{ postId: string; commentId: string }>();

// react-router
import { useParams } from "react-router";
const { postId, commentId } = useParams();
```

####  3.5.4. SPA with Vite and react-router

- Use [react-router](https://reactrouter.com/) v7 with hooks. Install the `react-router` package: `react-router-dom` is now a thin re-export kept for compatibility
- A page is a component rendered from `Router.tsx`. It can access route parameters and lives in `src/pages/` (nested to reflect the URL structure)
- react-router v7 also has a *framework mode* (loaders, actions, SSR) that is the successor of Remix. It's a valid option for projects that don't fit Next.js

```tsx
// src/Router.tsx
import { BrowserRouter, Routes, Route } from "react-router";
import routes from "./routes";

export function Router() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path={routes.posts()} element={<PostListPage />} />
        <Route path={routes.post(":id")} element={<PostPage />} />
        <Route path={routes.admin.users()} element={<AdminUserListPage />} />
      </Routes>
    </BrowserRouter>
  );
}
```

###  3.6. Server and client components

Only applies to Next.js. In a Vite SPA every component is a client component.

- Every component under `app/` is a Server Component by default: it can be `async`, fetches data directly (database via Drizzle, API client) and has no hooks or event handlers
- Add `"use client"` only to the leaves that need state, effects or browser APIs. Keep the boundary as low in the tree as possible
- Data: Server Components fetch directly, client components use TanStack Query
- Mutations: Server Actions (`"use server"`) with `useActionState`. Keep react-hook-form for client-side validation UX
- React 19: `use()` reads promises and context, `ref` is a normal prop (no `forwardRef`), `<Context value={...}>` renders as a provider
- React Compiler: enable it (`reactCompiler: true` in `next.config.ts`, `babel-plugin-react-compiler` on Vite) and stop hand-writing `useMemo`, `useCallback` and `memo` unless profiling shows a need

###  3.7. Testing

- Unit and component tests: [Vitest](https://vitest.dev/) with [React Testing Library](https://testing-library.com/docs/react-testing-library/intro/). Async Server Components are not supported by React Testing Library yet: cover them with end-to-end tests
- End-to-end tests: [Playwright](https://playwright.dev/)
- Favour end-to-end testing over component tests
- More important to cover critical paths than general coverage
- Ensure business logic are pure functions and write unit tests for them when needed

See also our [Testing guidelines](/guides/development/testing-guidelines.md).

##  4. Libraries

###  4.1. Recommended libraries

- Framework: [Next.js](https://nextjs.org/) (default), [Vite](https://vite.dev/) for SPAs
- Components: [shadcn/ui](https://ui.shadcn.com/) (our default choice; copies the components into `components/ui/`)
- Styling: [tailwindcss](https://tailwindcss.com/) (used by default in all our frontend projects)
- Internationalization: [react-intl](https://formatjs.github.io/docs/react-intl/), or [next-intl](https://next-intl.dev/) on Next.js App Router
- Forms: [react-hook-form](https://react-hook-form.com/)
- Validation: [zod](https://zod.dev/) (with `@hookform/resolvers` for forms)
- Global state management: [zustand](https://github.com/pmndrs/zustand)
- Server state / data fetching: [TanStack Query](https://tanstack.com/query) (formerly react-query)
- Tables: [TanStack Table](https://tanstack.com/table) (headless; pair it with shadcn/ui's `Table` or the `Data Table` recipe)
- Typed REST client: [Hey API](https://heyapi.dev/)
- Http: [ky](https://github.com/sindresorhus/ky)
- Utilities: [es-toolkit](https://es-toolkit.dev/) (modern, tree-shakeable lodash replacement; prefer it over lodash and over hand-written helpers in `lib/`)
- GraphQL API: [apollo-client](https://www.apollographql.com/docs/react/)
- Routing: Next.js App Router, or [react-router](https://reactrouter.com/) v7 for SPAs
- Testing: [Vitest](https://vitest.dev/), [React Testing Library](https://testing-library.com/docs/react-testing-library/intro/), [Playwright](https://playwright.dev/)
- Lint and format: [eslint-plugin-react-hooks](https://react.dev/reference/eslint-plugin-react-hooks), [ESLint Stylistic](https://eslint.style/)

###  4.2. Other libraries we have used

- Components (we prefer shadcn/ui, see 4.1; these appear in existing projects or when a client requires them)
  - [antd](https://ant.design/docs/react/introduce)
  - [PrimeReact](https://primereact.org/)
- Hooks:
  - [react-use](https://github.com/streamich/react-use)

###  4.3. Libraries worth taking a look into

- State management
  - [jotai](https://github.com/pmndrs/jotai)
- Component library
  - [Chakra UI](https://chakra-ui.com/)

##  5. Learning resources

- React docs are quite good. Recommended reading: https://react.dev/learn
- Next.js official course: https://nextjs.org/learn
- egghead.io is one of our favourite places to learn and Kent C. Dodds is a master, so this can't fail: https://egghead.io/courses/the-beginner-s-guide-to-react
