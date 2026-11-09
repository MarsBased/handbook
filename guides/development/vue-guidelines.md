# MarsBased Vue Style Guide

We bootstrap Vue applications with [Nuxt](https://nuxt.com/) by default. Use [Vite](https://vite.dev/) with [Vue Router](https://router.vuejs.org/) for single-page apps that don't need server-side rendering, SEO or server code. Vue 2 reached its end of life in 2023 and must not be used for new projects. This guide mirrors our [React guidelines](/guides/development/react-guidelines.md): most principles are shared, only the tools change.

<!-- vscode-markdown-toc -->
* 1. [Do's and Don'ts](#1-dos-and-donts)
	* 1.1. [Use TypeScript](#11-use-typescript)
	* 1.2. [Use a generator to bootstrap the project](#12-use-a-generator-to-bootstrap-the-project)
	* 1.3. [Write Composition API components](#13-write-composition-api-components)
	* 1.4. [Use composables for state management](#14-use-composables-for-state-management)
	* 1.5. [Use a declarative API library](#15-use-a-declarative-api-library)
	* 1.6. [Use multi-word PascalCase component names](#16-use-multi-word-pascalcase-component-names)
	* 1.7. [Do name exports](#17-do-name-exports)
	* 1.8. [Do name prop types](#18-do-name-prop-types)
	* 1.9. [Lint and format with ESLint](#19-lint-and-format-with-eslint)
	* 1.10. [Make substantial compositions their own component](#110-make-substantial-compositions-their-own-component)
* 2. [General project organization and architecture](#2-general-project-organization-and-architecture)
	* 2.1. [Nuxt project structure](#21-nuxt-project-structure)
	* 2.2. [Vite SPA project structure](#22-vite-spa-project-structure)
	* 2.3. [References (project structure)](#23-references-project-structure)
* 3. [Description of the most common patterns used to solve common problems](#3-description-of-the-most-common-patterns-used-to-solve-common-problems)
	* 3.1. [State management](#31-state-management)
		* 3.1.1. [Local state management](#311-local-state-management)
		* 3.1.2. [Global state management](#312-global-state-management)
		* 3.1.3. [URL state](#313-url-state)
	* 3.2. [External services](#32-external-services)
	* 3.3. [GraphQL](#33-graphql)
	* 3.4. [REST](#34-rest)
	* 3.5. [Routing](#35-routing)
		* 3.5.1. [Nuxt file-based routing](#351-nuxt-file-based-routing)
		* 3.5.2. [Route definitions](#352-route-definitions)
		* 3.5.3. [Access route parameters](#353-access-route-parameters)
		* 3.5.4. [SPA with Vite and Vue Router](#354-spa-with-vite-and-vue-router)
	* 3.6. [Server-side rendering and data fetching in Nuxt](#36-server-side-rendering-and-data-fetching-in-nuxt)
	* 3.7. [Testing](#37-testing)
* 4. [Libraries](#4-libraries)
	* 4.1. [Recommended libraries](#41-recommended-libraries)
	* 4.2. [Other libraries we have used](#42-other-libraries-we-have-used)
* 5. [Learning resources](#5-learning-resources)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

##  1. Do's and Don'ts

###  1.1. Use TypeScript

Always. Every single-file component (SFC) uses `<script setup lang="ts">`, and the project type-checks with `vue-tsc` (Nuxt: `nuxi typecheck`) in CI. Follow our [TypeScript guidelines](/guides/typescript-guidelines.md). The rules below (1.6 to 1.8) complement that guide with Vue-specific conventions.

###  1.2. Use a generator to bootstrap the project

A project generator saves a lot of boilerplate work and provides common conventions.

- Default: [Nuxt](https://nuxt.com/): `bun create nuxt@latest`. Add the official modules you need with `bunx nuxi module add` (`@nuxt/eslint`, `@pinia/nuxt`, `@nuxtjs/i18n`, `@nuxt/test-utils`...).
- Single-page apps without SSR, SEO or server code: [create-vue](https://github.com/vuejs/create-vue): `bun create vue@latest` (pick TypeScript, Vue Router, Pinia, Vitest, Playwright and ESLint; skip Prettier, see 1.9).

We use [bun](https://bun.sh/) as the package and script manager: `bun install`, `bun add`, `bun run <script>` and `bunx <cli>` instead of their npm counterparts. Pin its version with [mise](https://mise.jdx.dev/) (`mise.toml`) so everyone and CI run the same one.

Bun is only the package manager: the code still runs on Node.js LTS. `bun run dev` starts Vite and Nuxt on Node, and Nuxt builds for Nitro's default `node-server` preset. Don't force the Bun runtime (`bun --bun run`, Nitro's `bun` preset) without a concrete reason, and keep Vitest instead of `bun test`.

###  1.3. Write Composition API components

`<script setup>` and the Composition API are the standard. The Options API is legacy: never write new components with it, and migrate them when you touch them. Don't write render functions or JSX unless a library forces you to: templates are easier to read and the compiler optimises them better.

SFC blocks go in this order: `<script setup>`, `<template>`, `<style>` (scoped, if any. See our [CSS guidelines](/guides/development/css-guidelines.md)).

###  1.4. Use composables for state management

- In general, prefer Vue's reactivity primitives (`ref`, `computed`) for local state
- For global state, prefer server-side state: keep the server as the source of truth and read it with [Pinia Colada](https://pinia-colada.esm.dev/)
- Keep shareable UI state (pagination, filters, search, sort, active tab) in the URL query, so a link reproduces the exact view
- If server-side state is not possible, prefer `provide`/`inject` (or Nuxt's `useState`) for simple state (theme, current user, feature flags)
- For more complex client-side state, use [Pinia](https://pinia.vuejs.org/) with setup stores
- Extract reusable stateful logic into composables (`useSomething`) under `composables/`

See patterns (below) for examples and usages.

###  1.5. Use a declarative API library

It reduces boilerplate code a lot.

We currently use:

- REST: [Pinia Colada](https://pinia-colada.esm.dev/) (`useQuery`, `useMutation`). It's built on top of Pinia, so the cache shows up in Vue DevTools, and it supports SSR on Nuxt through `@pinia/colada-nuxt`
- GraphQL: [Vue Apollo](https://apollo.vuejs.org/) (`@vue/apollo-composable`)

Don't write API types by hand. For external REST APIs, generate the types and the client from their OpenAPI spec with [Hey API](https://heyapi.dev/) (`@hey-api/openapi-ts`). Its Pinia Colada plugin generates ready-to-use query and mutation options. See [REST](#34-rest).

In Nuxt, `useFetch` is fine for a trivial one-off load in a page. As soon as data is shared, cached, invalidated after a mutation or paginated, use Pinia Colada. See [Server-side rendering and data fetching in Nuxt](#36-server-side-rendering-and-data-fetching-in-nuxt).

###  1.6. Use multi-word PascalCase component names

Follow the official [Vue style guide](https://vuejs.org/style-guide/):

- Component names are always multi-word (`TodoItem`, not `Todo`), so they never clash with current or future HTML elements. The exceptions are the root `App.vue` and Nuxt pages and layouts, whose file names are routes
- SFC file names are PascalCase (`UserCard.vue`), and templates use PascalCase too (`<UserCard />`)
- One component per file

```vue
<!-- Don't -->
<!-- components/card.vue -->
<card />

<!-- DO -->
<!-- components/UserCard.vue -->
<UserCard />
```

###  1.7. Do name exports

An SFC is always its file's default export, so this applies to everything else: composables, stores, utilities and types use named exports. It allows to export multiple values and it encourages the use of the same naming.

```ts
// composables/useUser.ts
export function useUser() {
  ...
}
```

The exception is framework file conventions that require a default export: `nuxt.config.ts`, plugins (`defineNuxtPlugin`), route middleware (`defineNuxtRouteMiddleware`) and server routes (`defineEventHandler`). Use default exports only there.

###  1.8. Do name prop types

Declare an exported `XProps` type at the top of `<script setup>` and pass it to `defineProps`. Don't use the runtime object syntax (`defineProps({ user: String })`) or anonymous inline types. Type emits and models too. This follows the [Use named types](/guides/typescript-guidelines.md#use-named-types-avoid-anonymous-types) and "Export every type" rules from our TypeScript guidelines.

```vue
<!-- components/LoginForm.vue -->
<script setup lang="ts">
export type LoginFormProps = { user?: string };

const { user = "" } = defineProps<LoginFormProps>();
const emit = defineEmits<{ submit: [credentials: Credentials] }>();
const remember = defineModel<boolean>("remember", { default: false });
</script>
```

Destructured props stay reactive since Vue 3.5, and defaults go in the destructuring (no `withDefaults`). To watch a destructured prop, wrap it in a getter: `watch(() => user, ...)`. Use `defineModel` for `v-model` instead of a `modelValue` prop plus an `update:modelValue` emit.

###  1.9. Lint and format with ESLint

- Use [eslint-plugin-vue](https://eslint.vuejs.org/) with its `flat/recommended` config, plus `@vue/eslint-config-typescript`. `create-vue` sets both up. On Nuxt, use the [`@nuxt/eslint`](https://eslint.nuxt.com/) module instead: it ships the same rules and generates a project-aware config
- Format with [ESLint Stylistic](https://eslint.style/) (`@stylistic/eslint-plugin`) instead of Prettier. One tool, one config, one `--fix` pass: formatting rules live next to the rest of the lint rules and there is no conflict between two formatters. On Nuxt, enable it with `features: { stylistic: true }` in the `eslint` options of `nuxt.config.ts`

###  1.10. Make substantial compositions their own component

A composition of components becomes a named component as soon as it has enough substance, even if it is used only once. Signs of substance: it represents a concept you can name (`UserCard`, `InvoiceSummary`), it has its own state, handlers or data needs, or it is more than a few lines of nested template. Give it a name, place it where it belongs (on Nuxt, `components/` or `components/<area>/`, see [2.1](#21-nuxt-project-structure); on a Vite SPA, the nearest common ancestor of its consumers, see [3.5.4](#354-spa-with-vite-and-vue-router)), type its props (see 1.8) and treat it like any other component: it gets its own file, its own tests and its own review.

Repetition is the second trigger: the same combination of components, wiring and props in more than one place is a component by definition. Don't copy-paste the template. Duplicated compositions drift apart, and every visual or behavioural change has to be hunted down in each copy.

```vue
<!-- Don't leave a substantial composition inline in the page, even if it appears only here -->
<!-- app/pages/profile.vue -->
<template>
  <main>
    <Card>
      <CardHeader>
        <Avatar :src="user.avatarUrl" :alt="user.name" />
        <CardTitle>{{ user.name }}</CardTitle>
        <Badge>{{ user.role }}</Badge>
      </CardHeader>
      <CardContent>{{ user.bio }}</CardContent>
    </Card>
  </main>
</template>
```

```vue
<!-- DO name it and pass in only what varies -->
<!-- app/components/user/UserCard.vue -->
<script setup lang="ts">
export type UserCardProps = { user: User };

const { user } = defineProps<UserCardProps>();
</script>

<template>
  <Card>
    <CardHeader>
      <Avatar :src="user.avatarUrl" :alt="user.name" />
      <CardTitle>{{ user.name }}</CardTitle>
      <Badge>{{ user.role }}</Badge>
    </CardHeader>
    <CardContent>{{ user.bio }}</CardContent>
  </Card>
</template>
```

```vue
<!-- app/pages/profile.vue -->
<template>
  <main>
    <UserCard :user="user" />
  </main>
</template>
```

Small one-off layout fragments with no name of their own stay inline.

##  2. General project organization and architecture

We follow a conventional folder structure. Shared conventions, regardless of the framework:

- Application configuration in one place: `runtimeConfig` in `nuxt.config.ts` on Nuxt, `src/config.ts` on Vite
- Declare all app route paths at `routes.ts` (see [Route definitions](#352-route-definitions))
- Shared components under `components/` (can be nested). Vite SPAs also colocate area-specific code in private folders (see [3.5.4](#354-spa-with-vite-and-vue-router))
- All composables under `composables/`, all Pinia stores under `stores/`
- One folder for each (external) service. For example `api/` (for REST APIs), `graphql/` for GraphQL or `auth/` for authorization service. They can include type definitions, data transformations, clients or anything related to that service and communication with it.
- One folder for locales: `locales/`
- The rest: utility functions, helpers, etc... under `lib/` (keep it clean, please)

Routing is where the two flavours differ: Nuxt uses the `app/pages/` folder, Vite SPAs use `src/pages/` plus a `src/router/index.ts`.

###  2.1. Nuxt project structure

Nuxt 4 puts the application code under `app/` and the server code under `server/`:

```
app/
|- app.vue                # root component (<NuxtLayout> and <NuxtPage>)
|- routes.ts              # typed route helpers (see 3.5.2)
|- pages/                 # file-based routing: every .vue file is a route
|  |- index.vue           # /
|  |- posts/
|  |  |- index.vue        # /posts
|  |  |- [id].vue         # /posts/:id (dynamic segment)
|  |- admin/
|     |- users.vue        # /admin/users
|- layouts/
|  |- default.vue
|  |- admin.vue           # selected with definePageMeta({ layout: "admin" })
|- middleware/
|  |- auth.ts             # route middleware
|- plugins/
|  |- api.ts              # configures the REST client (see 3.4)
|- components/            # auto-imported components
|  |- ui/                 # component library primitives (shadcn-vue CLI output, see 4.1)
|  |  |- button/
|  |  |- dialog/
|  |- AppSpinner.vue      # shared component
|  |- post/               # folder for specific areas or sections
|     |- PostForm.vue     # auto-imported as <PostForm>
|- composables/           # auto-imported composables
|  |- useUser.ts
|- stores/                # Pinia stores
|- locales/
|  |- en-GB.json          # locale for en-GB (@nuxtjs/i18n)
|- api/                   # REST client (optional, see 3.4)
|  |- generated/          # Hey API output, do not edit
|- graphql/               # GraphQL folder (optional)
|- auth/                  # Authorization service (optional)
|- lib/                   # internal libraries aka "Everything else"
server/
|- api/                   # Nitro server routes (optional), not to confuse with app/api/
|  |- health.get.ts
shared/                   # code imported by both app/ and server/ (types, validation)
nuxt.config.ts
```

Nuxt turns every `.vue` and `.ts` file under `pages/` into a route, so components never live there: area-specific components go to `components/<area>/` and area-specific logic to `composables/` or `lib/`. We follow Nuxt's standard layout and don't use private folders on Nuxt (see [3.5.4](#354-spa-with-vite-and-vue-router) for the SPA approach): fighting the framework's conventions costs more than it saves. Nested components are auto-imported with their folder as a prefix, so name the file to start with it (`components/post/PostForm.vue` is `<PostForm>`, `components/post/Form.vue` would be `<PostForm>` too but is harder to find). Component library primitives live in `components/ui/`: it's where the shadcn-vue CLI installs them. Nuxt UI and Vuetify are installed as packages, so there is nothing to copy, but any thin wrapper we write around their components goes there too, so the split between library primitives and our own components is always the same.

###  2.2. Vite SPA project structure

```
src/
|- main.ts                # entry point (createApp, router, Pinia, Pinia Colada)
|- App.vue                # root component (<RouterView>)
|- router/
|  |- index.ts            # createRouter (see 3.5.4)
|- routes.ts              # typed route helpers (see 3.5.2)
|- config.ts              # application configuration
|- pages/                 # page components, mimic the URL hierarchy
|  |- HomePage.vue
|  |- posts/
|  |  |- _components/     # area-private UI (see 3.5.4)
|  |  |  |- PostRow.vue
|  |  |- _lib/            # area-private composables/helpers
|  |  |  |- usePostsSearchParams.ts
|  |  |- PostListPage.vue # /posts
|  |  |- PostPage.vue     # /posts/:id
|  |- admin/
|     |- AdminUserListPage.vue
|- components/            # generic UI and components shared across unrelated areas
|- composables/
|- stores/
|- locales/
|- api/                   # same as Nuxt (optional)
|- graphql/
|- auth/
|- lib/
```

`create-vue` names the pages folder `views/`. Rename it to `pages/` so all our projects look the same.

If using a repo for both api and client, put the above inside `client/` folder

###  2.3. References (project structure)

- Nuxt [directory structure](https://nuxt.com/docs/guide/directory-structure) docs
- Vue [style guide](https://vuejs.org/style-guide/)
- Route definitions idea taken from [Redwood](https://github.com/redwoodjs/redwood) framework

##  3. Description of the most common patterns used to solve common problems

###  3.1. State management

- In general, prefer Vue's reactivity and composables over any other solution
- Most "global state" is really server state. Keep it on the server and let the data layer cache it instead of copying it into a client store
- If a user could want to share, bookmark or reload a view, its state belongs in the URL, not in a store
- When you need a store, use Pinia

####  3.1.1. Local state management

`ref` and `computed` are enough most of the time. Keep state as close as possible to the components that use it and lift it only when needed.

- Derive with `computed`, don't sync with `watch`. A watcher that copies one ref into another is a bug waiting to happen
- Prefer `ref` over `reactive`: it works with any value, survives destructuring and makes reactive access explicit (`.value`)
- Vue's reactivity is fine-grained: there is no equivalent to React's `useMemo`/`useCallback` to hand-write. Use `shallowRef` for large data you replace as a whole (API responses, big lists)

####  3.1.2. Global state management

Pick the simplest option that works, in this order:

1. **Server-side state.** Data that lives in a database or API belongs to the server. Read it with [Pinia Colada](https://pinia-colada.esm.dev/) queries and change it with mutations that invalidate the affected keys. Pinia Colada's cache is the "global store" for that data: don't copy it into a Pinia store
2. **URL state.** Anything that describes *which* view the user is looking at goes in the URL: current page, page size, filters, search query, sort column and direction, active tab, open drawer or selected item. Links become shareable, the back button works, reloads keep the view and Nuxt can read the query on the server. See [URL state](#313-url-state)
3. **provide/inject.** For simple client-only state that rarely changes and is read by many components: theme, locale, current user, feature flags. Wrap each one in a composable (`provideTheme()`/`useTheme()`) with a typed `InjectionKey`. On Nuxt, `useState` is the SSR-safe alternative for small shared values
4. **Pinia.** For complex client-only state: many writers, frequent updates, derived data or state that outlives a subtree (multi-step wizards, editors, carts). Write [setup stores](https://pinia.vuejs.org/core-concepts/#Setup-Stores) (a function using `ref` and `computed`, same as a composable). Keep stores small and split them by domain

Never share state through a module-level `ref` (`export const user = ref()` in a `.ts` file) on Nuxt: on the server that module lives across requests, so one user's data leaks into another user's page. Use `useState`, Pinia or Pinia Colada, which are scoped to the request.

####  3.1.3. URL state

The URL is the first place to put view state. Rules:

- Query params hold *view* state (`?page=2&q=vue&sort=-createdAt&status=open`); the path holds *identity* (`/posts/42`). Never put secrets or large payloads in either
- Parse and validate the query with [zod](https://zod.dev/) in one place per page (a composable such as `usePostsSearchParams`, in `app/composables/` on Nuxt or the page's `_lib/` on a Vite SPA). Defaults live in the schema, not spread over the components
- Omit a param when it has its default value so canonical URLs stay short and cache-friendly
- Reset dependent params together: changing a filter or the search query sends the user back to page 1
- Update the URL with `router.replace` (or `router.push` when the change should create a history entry). The same code works on Nuxt and on Vue Router, since Nuxt uses Vue Router underneath
- Use the parsed params as part of the Pinia Colada query key, so the list refetches when the URL changes
- For a single param, [`useRouteQuery`](https://vueuse.org/router/useRouteQuery/) from `@vueuse/router` gives a two-way bound ref

```ts
// app/composables/usePostsSearchParams.ts
import { z } from "zod";

export const postsSearchParamsSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  q: z.string().trim().default(""),
  status: z.enum(["open", "closed", "all"]).default("all"),
  sort: z.enum(["createdAt", "-createdAt", "title"]).default("-createdAt"),
});

export type PostsSearchParams = z.infer<typeof postsSearchParamsSchema>;
const defaults = postsSearchParamsSchema.parse({});

export function usePostsSearchParams() {
  const route = useRoute();
  const router = useRouter();

  const params = computed(() => postsSearchParamsSchema.parse(route.query));

  function update(patch: Partial<PostsSearchParams>) {
    const query = { ...route.query };
    // any filter change resets pagination; default values are dropped from the URL
    for (const [key, value] of Object.entries({ ...patch, page: 1 })) {
      if (value === defaults[key as keyof PostsSearchParams]) {
        delete query[key];
      } else {
        query[key] = String(value);
      }
    }
    router.replace({ query });
  }

  return { params, update };
}
```

```vue
<!-- app/pages/posts/index.vue -->
<script setup lang="ts">
const { params, update } = usePostsSearchParams();
const { data: posts } = useQuery({
  key: () => ["posts", params.value],
  query: () => getPosts(params.value),
});
</script>

<template>
  <input
    :value="params.q"
    placeholder="Search posts"
    @input="update({ q: ($event.target as HTMLInputElement).value })"
  >
  <PostList :posts="posts ?? []" />
</template>
```

###  3.2. External services

- Create a clean interface for each service. For example: `api/index.ts` (functions to send http requests to a REST API) or `graphql/index.ts` (queries and mutations of a GraphQL endpoint)
- Prefer generated types over hand-written ones: Hey API for REST, GraphQL Code Generator for GraphQL. Fall back to `<service-name>/types.ts` when there is no schema to generate from
- Use declarative data fetching: prefer `useQuery` over calling `fetch` in `onMounted` (available both in Vue Apollo and Pinia Colada)

###  3.3. GraphQL

We currently use [Vue Apollo](https://apollo.vuejs.org/) and its composables (`useQuery`, `useMutation`).

Generate types and code as much as possible with [GraphQL Code Generator](https://the-guild.dev/graphql/codegen).

In general, keep all graphql related code inside `graphql/` folder.

###  3.4. REST

- Generate the client and its types from the OpenAPI spec with [Hey API](https://heyapi.dev/) (`@hey-api/openapi-ts`) into `api/generated/`. Enable its Pinia Colada plugin to get ready-to-use query and mutation options. See our [TypeScript guidelines](/guides/typescript-guidelines.md)
- Hand-write only the client configuration (base URL, auth headers, interceptors) and thin wrappers around the generated code
- Resolve the base URL once, from where the code runs. When the platform exposes the API over an internal network, Nuxt server-side code (SSR and server routes) must use that internal URL and fall back to the public one; the browser only ever knows the public URL. Going out through the public hostname from the server pays for DNS, TLS and a round trip outside the network on every request

```ts
// app/plugins/api.ts
import { client } from "~/api/generated/client.gen";

export default defineNuxtPlugin(() => {
  const config = useRuntimeConfig();
  // internalApiUrl is a private runtime config key, so it only exists on the server
  const baseUrl = import.meta.server
    ? config.internalApiUrl || config.public.apiUrl
    : config.public.apiUrl;

  client.setConfig({ baseUrl });
});
```

- Configure the client in that one place and import it everywhere else, never build a new one with its own base URL. Repeating `internalApiUrl || apiUrl` in every service or composable is a step someone eventually forgets, the app still works, and the cost shows up as latency instead of as an error. If you need a client for a second backend on a different host, configure it in the same place
- On a Vite SPA there is no server: set the base URL once in `src/api/client.ts` from `src/config.ts`
- No spec? Fall back to a single `api/index.ts` exporting all API interactions and `api/types.ts` for entity type definitions
- If Auth and API are different services, is common to have two folders (`auth/` and `api/`) and the API depends on authorization (JWT tokens, for example). If auth and API are in the same service, the `auth/` folder can be omitted.

###  3.5. Routing

Nuxt routes are defined by the file system. Vite SPAs use Vue Router. In both cases keep the route paths in `routes.ts` (see [Route definitions](#352-route-definitions)).

####  3.5.1. Nuxt file-based routing

- Files under `app/pages/` are routes. `index.vue` is the folder's root route
- `[id].vue` for dynamic segments, `[...slug].vue` for catch-all routes, `[[id]].vue` for optional ones
- Layouts live in `app/layouts/` and are picked per page with `definePageMeta({ layout: "admin" })`
- Route middleware lives in `app/middleware/` and is attached with `definePageMeta({ middleware: "auth" })`
- `app/error.vue` renders errors and 404s
- Navigate with `<NuxtLink>` and `navigateTo()`

```vue
<!-- app/pages/posts/[id].vue -->
<script setup lang="ts">
const route = useRoute();
const { data: post } = useQuery({
  key: () => ["posts", route.params.id],
  query: () => getPost(route.params.id as string),
});
</script>

<template>
  <PostDetail v-if="post" :post="post" />
</template>
```

####  3.5.2. Route definitions

It's a file to generate route paths. Advantages:

- You get an overview of all available routes on the app
- It helps to prevent errors when declaring routes
- Route completion via editor
- In Nuxt it keeps links in sync with the `pages/` folder structure

```ts
export const routes = {
  posts: () => `/posts`,
  post: (id: string) => `/posts/${id}`,
  admin: {
    users: () => `/admin/users`,
  },
};
```

Usage:

```vue
<!-- Nuxt -->
<NuxtLink :to="routes.post(post.id)">Read more</NuxtLink>

<!-- Vue Router -->
<RouterLink :to="routes.post(post.id)">Read more</RouterLink>
```

####  3.5.3. Access route parameters

For a route like `/posts/:postId/comments/:commentId`:

```ts
// Nuxt (auto-imported) and Vue Router (import { useRoute } from "vue-router")
const route = useRoute();
const postId = computed(() => route.params.postId as string);
const commentId = computed(() => route.params.commentId as string);
```

Keep reads inside `computed` (or a getter in a query key): the component is reused when only the params change, so a value read once in `setup` goes stale.

####  3.5.4. SPA with Vite and Vue Router

- Use [Vue Router](https://router.vuejs.org/) with its composables (`useRoute`, `useRouter`)
- A page is a component rendered from `src/router/index.ts`. It can access route parameters and lives in `src/pages/` (nested to reflect the URL structure)
- Lazy-load pages with dynamic imports so each one gets its own chunk

```ts
// src/router/index.ts
import { createRouter, createWebHistory } from "vue-router";
import { routes } from "@/routes";

export const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: routes.posts(), component: () => import("@/pages/posts/PostListPage.vue") },
    { path: routes.post(":id"), component: () => import("@/pages/posts/PostPage.vue") },
    { path: routes.admin.users(), component: () => import("@/pages/admin/AdminUserListPage.vue") },
  ],
});
```

**Private folders.** Routes are declared in code, so folders under `src/pages/` never become URLs by themselves. We use that to colocate area-scoped code next to the pages that use it, in folders prefixed with an underscore (the same convention as our [React guidelines](/guides/development/react-guidelines.md#351-nextjs-app-router)). The prefix signals intent: nothing inside is a page.

- `_components/`: UI components used only by that area.
- `_lib/`: logic: composables, validation, query parsing (see [3.1.3](#313-url-state)), helpers.
- Tests stay next to their source inside the same private folder.

```
pages/
|- dashboard/
|  |- _components/        # shared by every dashboard page
|  |  |- DashboardHeader.vue
|  |- _lib/
|  |  |- useDashboardFilters.ts
|  |- DashboardPage.vue
|  |- posts/
|     |- _components/
|     |  |- PostRow.vue
|     |- _lib/
|     |  |- usePostsSearchParams.ts
|     |- PostListPage.vue
```

Place shared code at the **nearest common ancestor** of its consumers: used by one page, that page folder's private folders; used by several pages under the same folder, that folder's private folders; used across unrelated areas, `src/components/` and `src/lib/`. Exception: generic, purely UI components with no domain knowledge (a combobox, a modal, a button) skip this rule and always live in the root `src/components/`, even if only one area uses them today. They are the project's design system, not area code.

This applies only to Vite SPAs. On Nuxt, follow its standard layout (see [2.1](#21-nuxt-project-structure)).

###  3.6. Server-side rendering and data fetching in Nuxt

Only applies to Nuxt. In a Vite SPA everything runs in the browser.

- Every page and component renders on the server first and then hydrates in the browser. `setup` runs in both places, so it must not touch `window`, `document` or `localStorage` directly. Do that in `onMounted`, behind `import.meta.client`, or wrap the component in `<ClientOnly>`
- Avoid hydration mismatches: the server and the first client render must produce the same HTML. Values like `Date.now()`, `Math.random()` or the user's timezone belong in `onMounted` or in state fetched on the server
- Data: Pinia Colada queries (with `@pinia/colada-nuxt`) run on the server and their cache is serialized into the page, so the browser doesn't refetch. `useFetch`/`useAsyncData` do the same for simple cases. Both go through the same API client, which already targets the internal URL on the server (see [REST](#34-rest))
- Don't call `$fetch` directly in `setup`: it runs twice (server and client) and its result is not transferred. Use it inside query functions, mutations and event handlers
- Server routes (`server/api/`) are for things the browser must not do: hiding secrets, proxying third-party APIs, webhooks. Don't build a full backend in Nitro when the project has a real API
- Use `shared/` for code that both `app/` and `server/` import, such as zod schemas and types

###  3.7. Testing

- Unit and component tests: [Vitest](https://vitest.dev/) with [Vue Testing Library](https://testing-library.com/docs/vue-testing-library/intro/). On Nuxt, add [`@nuxt/test-utils`](https://nuxt.com/docs/getting-started/testing) and use `mountSuspended` for components that rely on auto-imports or Nuxt composables
- End-to-end tests: [Playwright](https://playwright.dev/)
- Favour end-to-end testing over component tests
- More important to cover critical paths than general coverage
- Ensure business logic are pure functions and write unit tests for them when needed

See also our [Testing guidelines](/guides/development/testing-guidelines.md).

##  4. Libraries

###  4.1. Recommended libraries

- Framework: [Nuxt](https://nuxt.com/) (default), [Vite](https://vite.dev/) for SPAs
- Components:
  - [shadcn-vue](https://www.shadcn-vue.com/) (our default choice; built on [Reka UI](https://reka-ui.com/), copies the components into `components/ui/`)
  - [Nuxt UI](https://ui.nuxt.com/) (Nuxt projects that want a complete, ready-made kit; built on Reka UI and Tailwind like shadcn-vue, but installed as a module instead of copied)
  - [Vuetify](https://vuetifyjs.com/) (Material Design and data-heavy back offices; it ships its own styling system, so don't mix it with Tailwind utilities for the same components)
- Styling: [tailwindcss](https://tailwindcss.com/) (used by default in all our frontend projects). See our [CSS guidelines](/guides/development/css-guidelines.md)
- Internationalization: [@nuxtjs/i18n](https://i18n.nuxtjs.org/) on Nuxt, [vue-i18n](https://vue-i18n.intlify.dev/) on SPAs
- Forms: [VeeValidate](https://vee-validate.logaretm.com/)
- Validation: [zod](https://zod.dev/) (with `@vee-validate/zod` for forms)
- Global state management: [Pinia](https://pinia.vuejs.org/)
- Server state / data fetching: [Pinia Colada](https://pinia-colada.esm.dev/)
- Tables: [TanStack Table](https://tanstack.com/table) (headless; pair it with shadcn-vue's `Table` or the `Data Table` recipe)
- Typed REST client: [Hey API](https://heyapi.dev/)
- Http: [ofetch](https://github.com/unjs/ofetch) (Nuxt's `$fetch`), [ky](https://github.com/sindresorhus/ky) on SPAs
- Composables: [VueUse](https://vueuse.org/) (check it before writing a composable for browser APIs, timers or sensors)
- Utilities: [es-toolkit](https://es-toolkit.dev/) (modern, tree-shakeable lodash replacement; prefer it over lodash and over hand-written helpers in `lib/`)
- GraphQL API: [Vue Apollo](https://apollo.vuejs.org/)
- Routing: Nuxt file-based routing, or [Vue Router](https://router.vuejs.org/) for SPAs
- Testing: [Vitest](https://vitest.dev/), [Vue Testing Library](https://testing-library.com/docs/vue-testing-library/intro/), [@nuxt/test-utils](https://nuxt.com/docs/getting-started/testing), [Playwright](https://playwright.dev/)
- Lint and format: [eslint-plugin-vue](https://eslint.vuejs.org/), [@nuxt/eslint](https://eslint.nuxt.com/), [ESLint Stylistic](https://eslint.style/)
- Tooling: [bun](https://bun.sh/) as package and script manager (Node.js LTS as runtime), pinned with [mise](https://mise.jdx.dev/)

###  4.2. Other libraries we have used

- Components (we prefer the ones in 4.1; these appear in existing projects or when a client requires them)
  - [PrimeVue](https://primevue.org/)
  - [Element Plus](https://element-plus.org/)
- Data fetching:
  - [TanStack Query](https://tanstack.com/query/latest/docs/framework/vue/overview) (`@tanstack/vue-query`)

##  5. Learning resources

- Vue docs are excellent. Recommended reading: https://vuejs.org/guide/introduction.html
- Nuxt docs: https://nuxt.com/docs
- Pinia Colada docs: https://pinia-colada.esm.dev/
- Vue School has courses for every level, from the basics to Nuxt and Pinia: https://vueschool.io/
