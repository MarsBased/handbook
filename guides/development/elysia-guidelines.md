# MarsBased Elysia Style Guide

We build TypeScript APIs with [Elysia](https://elysiajs.com/) 2 on [Bun](https://bun.sh/). Elysia gives us end-to-end type safety: one schema validates the request, types the handler and documents the endpoint, and the client is generated from that documentation. This guide targets Elysia 2, which is not source-compatible with Elysia 1 (see [1.2](#12-know-what-changed-in-elysia-2)). For the front end that consumes these APIs, see our [React guidelines](/guides/development/react-guidelines.md).

<!-- vscode-markdown-toc -->
* 1. [Do's and Don'ts](#1-dos-and-donts)
	* 1.1. [Use TypeScript](#11-use-typescript)
	* 1.2. [Know what changed in Elysia 2](#12-know-what-changed-in-elysia-2)
	* 1.3. [Always chain methods](#13-always-chain-methods)
	* 1.4. [One Elysia instance is one controller](#14-one-elysia-instance-is-one-controller)
	* 1.5. [Never pass the Context around](#15-never-pass-the-context-around)
	* 1.6. [Schemas are the single source of truth](#16-schemas-are-the-single-source-of-truth)
	* 1.7. [Name every plugin](#17-name-every-plugin)
	* 1.8. [Document every route](#18-document-every-route)
	* 1.9. [Read configuration in one place](#19-read-configuration-in-one-place)
	* 1.10. [Lint and format with Biome](#110-lint-and-format-with-biome)
* 2. [General project organization and architecture](#2-general-project-organization-and-architecture)
	* 2.1. [Project structure](#21-project-structure)
	* 2.2. [Dependency arrows](#22-dependency-arrows)
	* 2.3. [Deciding where a file goes](#23-deciding-where-a-file-goes)
	* 2.4. [Module file layout](#24-module-file-layout)
	* 2.5. [Tooling](#25-tooling)
* 3. [Description of the most common patterns used to solve common problems](#3-description-of-the-most-common-patterns-used-to-solve-common-problems)
	* 3.1. [Controllers](#31-controllers)
	* 3.2. [Services](#32-services)
	* 3.3. [Models and validation](#33-models-and-validation)
	* 3.4. [Plugins and scope](#34-plugins-and-scope)
	* 3.5. [Authentication and authorization](#35-authentication-and-authorization)
	* 3.6. [Error handling](#36-error-handling)
	* 3.7. [API conventions](#37-api-conventions)
	* 3.8. [OpenAPI documentation](#38-openapi-documentation)
	* 3.9. [API clients](#39-api-clients)
	* 3.10. [Background jobs](#310-background-jobs)
		* 3.10.1. [Choosing a job library](#3101-choosing-a-job-library)
		* 3.10.2. [pg-boss](#3102-pg-boss)
		* 3.10.3. [BullMQ](#3103-bullmq)
	* 3.11. [Logging](#311-logging)
	* 3.12. [Testing](#312-testing)
* 4. [Libraries](#4-libraries)
	* 4.1. [Recommended libraries](#41-recommended-libraries)
	* 4.2. [Libraries to avoid](#42-libraries-to-avoid)
* 5. [Learning resources](#5-learning-resources)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

##  1. Do's and Don'ts

###  1.1. Use TypeScript

Always, and follow our [TypeScript guidelines](/guides/typescript-guidelines.md). Elysia's value is type inference: a route that compiles has a validated input and a checked response. Never weaken it with `any` or type assertions around the framework.

###  1.2. Know what changed in Elysia 2

Most tutorials, answers and AI suggestions still show Elysia 1 code. The differences we rely on:

- **Route options come before the handler**: `.get(path, options, handler)`, not `(path, handler, hook)`.
- **Hook scope is a positional first argument**: `.derive("global", fn)`, `.onAfterResponse("global", fn)`, not `{ as: "global" }`. The scopes are `local` (default), `plugin` (Elysia 1's `scoped`) and `global`.
- **Global error handling is `.onError("global", fn)`**. The handler context has no `code` string: discriminate with `instanceof` on the exported classes (`NotFound`, `ParseError`, `ValidationError`, `ElysiaStatus`).
- **TypeBox is the `typebox` package (1.x)**, a peer dependency. Never install `@sinclair/typebox` (0.x). Static types come from `Static<typeof schema>`; schemas no longer have a `.static` property.
- **Official plugins live under the `@elysia` npm scope** (`@elysia/cors`, `@elysia/eden`, `@elysia/openapi`). The `@elysiajs` scope continues Elysia 1.
- **`.guard()` and `.group()` default to override scope.** Pass `schema: "standalone"` for the old additive behaviour.

```ts
// Don't: Elysia 1 signature
app.get("/health", () => checkHealth(), { response: "health" });

// DO: Elysia 2 signature
app.get("/health", { response: "health" }, () => checkHealth());
```

Migrating an Elysia 1 project: run the official codemod (`bunx @elysia/codemod@latest`) and review the result against the release notes.

###  1.3. Always chain methods

Type inference (context decorations, models, macros) only accumulates through the chained return type. Breaking the chain loses types silently.

```ts
// Don't assign the instance and call methods on separate lines
const app = new Elysia();
app.use(authSession);
app.get("/me", { auth: true }, ({ user }) => user); // `auth` and `user` are unknown here

// DO chain
export const app = new Elysia()
  .use(authSession)
  .get("/me", { auth: true }, ({ user }) => user);
```

###  1.4. One Elysia instance is one controller

Define routes directly on an Elysia instance and export it. Never write controller classes: they add a layer that Elysia cannot type.

###  1.5. Never pass the Context around

Don't hand the whole `Context` (or a destructured copy of it) to a service. It loses type integrity, couples the business logic to the framework and makes it hard to test. Pass only the values the service needs.

```ts
// Don't
.post("", { body: "teamWrite" }, (context) => createTeam(context))

// DO
.post("", { body: "teamWrite" }, ({ body }) => createTeam(body.name))
```

###  1.6. Schemas are the single source of truth

Declare request and response shapes once as TypeBox schemas (`t.*`) and derive the TypeScript types from them. Never hand-write an interface that duplicates a schema.

```ts
import { t } from "elysia";
import type { Static } from "typebox";

export const team = t.Object({
  id: t.String({ format: "uuid" }),
  name: t.String(),
  createdAt: t.String(),
});

export type Team = Static<typeof team>;
```

###  1.7. Name every plugin

Every reusable instance gets a `name` (plus a `seed` if it takes options): `new Elysia({ name: "Auth.Session" })`. Elysia deduplicates plugins by name; an unnamed plugin runs again on every `.use()`.

###  1.8. Document every route

Every route declares `detail: { tags, summary }`. Body and response schemas come from the TypeBox models, never hand-written inside `detail`. See [OpenAPI documentation](#38-openapi-documentation).

###  1.9. Read configuration in one place

Environment variables are read and validated once, at boot, against a TypeBox schema in `platform/config/`. No `process.env` anywhere else in `src/`: a variable read outside the schema is unvalidated and invisible. The app refuses to start with an invalid configuration and reports every problem at once.

Where the variables come from in development is covered in the [meta tools guide](/guides/development/meta-tools-guide.md#environment).

###  1.10. Lint and format with Biome

On Bun projects we use [Biome](https://biomejs.dev/) for both linting and formatting: one tool, one config, one pass. Biome does not type-check, so the `typecheck` task (`tsc --noEmit`) is mandatory next to `lint`. How both run locally, in Git hooks and in CI is in the [meta tools guide](/guides/development/meta-tools-guide.md).

##  2. General project organization and architecture

An Elysia app is a modular monolith. Business logic lives in domain modules. Every way execution enters the app (HTTP, background jobs, crons) is a thin adapter that delegates to the domains. A route-first layout breaks down as soon as a resource is exposed at two URLs, a job needs the same logic as an endpoint, or a process spans several entities. With domains first, each of those cases has an obvious home.

###  2.1. Project structure

```
src/
|- app.ts                 # composition: platform plugins + the API surface
|- index.ts               # entry point: load config, wire dependencies, listen
|- api/                   # HTTP adapters; the folder path IS the URL prefix
|  |- index.ts            # mounts every controller in one explicit chain
|  |- health/
|  |  |- index.ts         # new Elysia({ name: "Health", prefix: "/health" })
|  |  |- model.ts
|  |  |- service.ts       # exception: an infrastructure probe has no domain
|  |- teams/
|  |  |- index.ts         # new Elysia({ name: "Teams", prefix: "/api/teams" })
|  |  |- model.ts         # DTOs (TypeBox) and row-to-DTO mappers
|  |  |- index.test.ts
|  |- issues/
|     |- index.ts         # prefix: "/api/issues"
|     |- events/          # nested resource: /api/issues/:issueId/events
|        |- index.ts
|- domains/               # business logic, one module per entity or aggregate
|  |- teams/
|  |  |- model.ts         # domain types
|  |  |- service.ts
|  |- issues/
|- queues/                # queue adapters: workers that delegate to domains
|  |- dispatch-alert/
|- workflows/             # orchestration across several domains, named by verb
|  |- dispatch-alert/
|- views/                 # read-only models that fan in over several domains
|  |- project-setup/
|- platform/              # framework plumbing with no domain meaning
   |- auth/
   |- config/
   |- cors/
   |- error-handler/
   |- log/
   |- openapi/
   |- runtime/            # composition root (dependency wiring)
```

- `api/<url-path>/` holds controllers and DTOs, nothing else. The controller declares a `prefix` equal to its folder path and its routes relative to it. Never repeat the prefix in the route paths.
- When the prefix is the whole route, declare the path as `""` (not `"/"`), so the OpenAPI spec documents it without a trailing slash.
- Compose controllers with an explicit, static `.use()` chain in `api/index.ts`. No directory-scanning auto-loader: dynamic mounting breaks the `App` type that Eden Treaty depends on (see [3.9](#39-api-clients)).
- A route with a leading path parameter (`/api/:projectId/...`) is mounted last, after every static path.
- Don't create empty categories up front. The first consumer creates the folder.
- In a monorepo (see [Workspaces](/guides/development/meta-tools-guide.md#workspaces-one-repository-many-packages)), the database schema and shared queries live in their own package (`packages/db`). Only the Elysia app imports it; the front end never talks to the database.

###  2.2. Dependency arrows

```
api / queues   ->  workflows, views, domains, platform
workflows      ->  domains
views          ->  domains (read-only)
domains        ->  other domains (sparingly, one-way), platform
platform       ->  nothing above it
```

- Domains never import from `api/`, `queues/`, `workflows/` or `views/`.
- A two-way dependency between two domains means the shared piece belongs in a third domain.
- The one exception is `platform/runtime/`, the composition root: it imports domains, workflows and queues to wire them, and contains no logic of its own.

###  2.3. Deciding where a file goes

1. HTTP mapping or validation (controller, DTO)? `api/<url-path>/`
2. Another entry point (job worker, cron)? `queues/<name>/`
3. A rule about one entity? `domains/<noun>/`
4. A process spanning several entities? `workflows/<verb>/`
5. A read across several entities? `views/<name>/`
6. Framework plumbing? `platform/<item>/`

###  2.4. Module file layout

Every module, whatever its category, keeps the same shape:

```
<category>/<name>/
|- index.ts        # module entry (the Elysia instance, for adapters)
|- service.ts      # logic: plain functions, no Elysia types
|- model.ts        # schemas and types (DTOs only in api/)
|- index.test.ts   # tests next to the code
```

###  2.5. Tooling

Versions, environment, tasks, Git hooks, development processes and local services follow our [meta tools guide](/guides/development/meta-tools-guide.md). This guide does not repeat it. The only parts specific to an Elysia project:

- The runtime is [Bun](https://bun.sh/), not only the package manager
- The `dev` process for the API is `bun run --watch src/index.ts`
- The `typecheck` task is not optional (see [1.10](#110-lint-and-format-with-biome))

##  3. Description of the most common patterns used to solve common problems

###  3.1. Controllers

A controller validates input, calls a service with plain arguments and maps the result to a response DTO. Nothing else.

```ts
// src/api/teams/index.ts
import { Elysia } from "elysia";
import { createTeam, listTeams } from "../../domains/teams/service";
import { authSession } from "../../platform/auth/session";
import { apiError, errorResponse } from "../../platform/error-handler";
import { team, teamList, teamOf, teamWrite } from "./model";

export const teams = new Elysia({ name: "Teams", prefix: "/api/teams" })
  .use(authSession)
  .model({ team, teamList, teamWrite })
  .get(
    "",
    {
      auth: "admin",
      response: { 200: "teamList", 401: errorResponse, 403: errorResponse },
      detail: { tags: ["Teams"], summary: "List teams" },
    },
    async () => (await listTeams()).map(teamOf),
  )
  .post(
    "",
    {
      auth: "admin",
      body: "teamWrite",
      response: {
        201: "team",
        400: errorResponse,
        401: errorResponse,
        403: errorResponse,
        409: errorResponse,
      },
      detail: { tags: ["Teams"], summary: "Create a team" },
    },
    async ({ body, status }) => {
      const result = await createTeam(body.name.trim());

      return result.ok
        ? status(201, teamOf(result.team))
        : status(409, apiError("conflict", "A team with that name already exists."));
    },
  );
```

- Declare every status the route can answer in `response`. It types `status()` and feeds the OpenAPI spec, which is where the front end's client gets its error types from.
- Return `status(code, body)` for non-200 answers. Don't throw for expected outcomes.
- A resource may be exposed at several URLs by thin controllers over the same domain service.

###  3.2. Services

- **Logic that does not depend on the request** is plain functions (or a static class) in `service.ts`. No Elysia import anywhere in it.
- **Logic that does depend on the request** (session, client IP) is an Elysia instance used as a plugin, exposing values through `.macro()`, `.derive()` or `.resolve()`. Decorate only request-dependent properties.
- Domain services return rows or domain types. They never see request or response DTOs.
- Report expected failures as values, not exceptions: a discriminated result (`{ ok: true, team } | { ok: false, reason: "not_found" }`) lets the controller map each case to a status and lets TypeScript check that none is forgotten.
- Services receive their data access through dependencies wired at the composition root, so a test can replace the database with a stub without mocking modules.

###  3.3. Models and validation

- Register shared schemas with `.model({ name: schema })` and reference them by name in the route options (`body: "teamWrite"`).
- Be strict on your own API: `additionalProperties: false` on write DTOs. An unknown property is a caller's mistake, and answering 200 to it hides the mistake behind a no-op.
- Be permissive on payloads you don't control (webhooks, third-party SDKs): accept and drop unknown fields. Strict validation there breaks compatibility the day the sender adds a field.
- Responses are explicit projections: camelCase, ISO-8601 UTC timestamps. Never serialize a raw database row. Keep the mapper next to the DTO:

```ts
// src/api/teams/model.ts
export const teamWrite = t.Object(
  { name: t.String({ minLength: 1, maxLength: 80 }) },
  { additionalProperties: false },
);

export function teamOf(row: TeamRow): Team {
  return { id: row.id, name: row.name, createdAt: row.createdAt.toISOString() };
}
```

###  3.4. Plugins and scope

- Lifecycle hooks are **local by default**: they apply to the current instance and its descendants only. Pass the scope as the first argument (`"plugin"` to reach the parent, `"global"` for everything), or lift a whole instance with `.as("plugin" | "global")`. Never assume a hook propagates upward: check the scope.
- Each instance is standalone. Declare its dependencies explicitly with `.use()`, even if a parent already mounts the same plugin. Naming ([1.7](#17-name-every-plugin)) makes that free.
- Don't mount twice a plugin that registers global hooks: they run once per mount. Split the opt-in part (a macro) from the global part (the hooks) into two plugins.
- A plugin that takes options is a function returning a configured Elysia instance.
- Use `.guard(options, (app) => ...)` to apply a schema or hook to a group of routes instead of repeating it per route.
- `.onRequest()` runs before routing, so it is global by nature. A `Response` returned from it short-circuits the request and no route schema applies.

###  3.5. Authentication and authorization

We use [Better-Auth](https://www.better-auth.com/), mounted in Elysia. The front end only uses its session client.

Routes opt in to authentication through a macro, so the access rule is declared next to the route and enforced before the handler runs:

```ts
// src/platform/auth/session.ts
export const authSession = new Elysia({ name: "Auth.Session" }).macro({
  auth: (minimum: true | UserRole) => ({
    derive: async ({ request, status }) => {
      const session = await getAuth().api.getSession({ headers: request.headers });

      if (session === null) {
        return status(401, unauthenticatedBody());
      }

      if (minimum !== true && !roleAtLeast(session.user.role, minimum)) {
        return status(403, forbiddenBody());
      }

      return { user: session.user, session: session.session };
    },
  }),
});
```

- `auth: true` means any signed-in user; `auth: "admin"` sets a minimum role. The handler receives a typed `user` and `session`.
- Validate the session on the server on every request.
- A resource outside the user's scope answers `404`, not `403`: don't leak that it exists. `403` means "you can see it, but your role forbids the action".
- Cookie-authenticated APIs must refuse a `POST` whose body is not JSON (`415`): an HTML form can send one cross-origin without a preflight. Keep CORS closed for every route the browser does not need to call directly.

See also our [security guidelines](/guides/security/README.md).

###  3.6. Error handling

One global error handler, one error shape for the whole API:

```json
{ "error": { "code": "validation_failed", "message": "Expected string" } }
```

```ts
// src/platform/error-handler/index.ts
export const errorHandler = new Elysia({ name: "ErrorHandler" }).onError(
  "global",
  ({ error, set }): ErrorResponse => {
    if (error instanceof NotFound) {
      set.status = 404;
      return apiError("not_found", "Route not found");
    }

    if (error instanceof ParseError) {
      set.status = 400;
      return apiError("invalid_json", "Request body is not valid JSON");
    }

    // A response-schema violation is a server bug, not a client error
    if (error instanceof ValidationError && error.type !== "response") {
      set.status = 400;
      return apiError("validation_failed", firstReadableMessage(error.all));
    }

    log.error(error);
    set.status = 500;
    return apiError("internal_server_error", "Something went wrong");
  },
);
```

- `code` is a stable, machine-readable string; `message` is for humans. Clients branch on `code`, never on `message`.
- Never return stack traces or internal messages to the client. Log the error, answer a generic 500.
- The handler covers the unexpected. Expected outcomes (not found, conflict) are returned by the controller with `status()`.

###  3.7. API conventions

- Every endpoint is a REST resource. A resource need not be a database entity: an export or a resolution is one too. Use an action verb (`POST /api/issues/:id/resolve`) only when no noun fits. See our [Back-end guidelines](/guides/development/back-end-development-guidelines.md).
- No URL versioning. Version through `Accept`-header content negotiation with a vendor media type (`application/vnd.<app>+json; version=1`). An unknown version answers `406`; plain `application/json` means the current version.
- List endpoints paginate by opaque cursor (keyset, never `OFFSET`): `?limit=&cursor=` returns `{ items, nextCursor }`.
- `PUT` and `DELETE` are idempotent: adding a member twice leaves one membership; removing a missing one succeeds.

###  3.8. OpenAPI documentation

Serve interactive docs with `@elysia/openapi`, configured in `platform/openapi/`.

- One tag per feature module, named like the module, registered with a description in the plugin's `documentation.tags`.
- Add a `description` to a route when the summary alone does not explain its behaviour (uniqueness rules, idempotency, side effects).
- Keep a route out of the public docs with the plugin's `exclude` option, never by leaving `detail` off.
- Add a test that walks the generated spec and fails on any operation without tags or a summary. Don't weaken it to make an undocumented route pass.

###  3.9. API clients

One rule, whatever the repository structure (monorepo or separate repositories):

- **Front ends consume the API with [Hey API](https://heyapi.dev/)**, generated from the OpenAPI spec.
- **[Eden Treaty](https://elysiajs.com/eden/overview) stays on the Elysia side**: tests, and calls from one Elysia service to another.

Why not Eden Treaty in the front end, even in a monorepo: it ties the front end to the server's `elysia` and `typebox` versions and to its source code, and it only works while both live in the same repository and both are TypeScript. The OpenAPI spec is a contract that every consumer can read: our front ends, a mobile app, a client's team. One rule also means a project does not change its client the day it is split into two repositories.

**Front ends: Hey API**

- The OpenAPI spec is the contract, so it has to be complete: every route documented, with a response schema for every status it can answer (see [3.8](#38-openapi-documentation)). What is missing from the spec is missing from the client.
- Generate the client into the front end's `src/api/generated/` and never edit it, as the [React guidelines](/guides/development/react-guidelines.md#34-rest) describe. Hey API also generates TanStack Query options and validation schemas for forms from the same spec.
- Produce the spec without booting the server: ask the app for it with `app.handle()` and write the answer to a file. In a monorepo the front end generates from that file; in separate repositories, publish it as a build artifact.
- Regenerate in CI and fail the build when the generated code differs from what is committed. A stale client is a bug that compiles.

```ts
// scripts/openapi.ts
import { app } from "../src/app";

const response = await app.handle(new Request("http://localhost/openapi/json"));
await Bun.write("openapi.json", await response.text());
```

**Elysia side: Eden Treaty**

- Still export the app type from the composition file. Eden Treaty and the tests are typed by it.
- In tests, pass the app instance to `treaty()`: requests and responses are typed, and no server is started.
- A second Elysia service that calls this one imports the app as a **type only** and creates its client from the base URL.
- Set `parseDate: false`. Eden revives ISO-8601 strings into `Date` objects by default, which contradicts a contract that types timestamps as `string`.
- Never ship Eden Treaty to a front end.

```ts
// src/app.ts
export const app = new Elysia().use(errorHandler).use(apiDocs).use(api);
export type App = typeof app;
```

```ts
// src/api/teams/index.test.ts
import { treaty } from "@elysia/eden";
import { app } from "../../app";

const client = treaty(app, { parseDate: false });

const { data, status } = await client.api.teams.get();
```

###  3.10. Background jobs

The rules below hold whatever the library:

- **Every worker is idempotent.** A job can be retried and delivered twice. Check the state before acting, or make the repeated write a no-op.
- Payloads carry identifiers (`issueId`), never entity snapshots. The worker reads the current state through the domain.
- The worker is a thin adapter, like a controller: it validates the payload (`Value.Check` against a TypeBox schema), delegates to a workflow or domain service, and logs the outcome. The side effect (a webhook call, a deletion) lives in the service, where callers can see it.
- Throw from the worker to hand the job back to the retry policy. Swallowing the error marks a failed job as done.
- One queue per job kind. Never a catch-all queue. Queue names and payload types live with the owning domain.
- Only `platform/jobs/` and `queues/` import the job library. Domains enqueue through a function they receive, so the library can change without touching them.
- Export the handler as a plain function and unit-test it without the queue.
- Stop the workers on `SIGTERM` and wait for the running jobs before the process exits.

####  3.10.1. Choosing a job library

The job library never touches Elysia: the choice depends on the infrastructure the project already has, not on the framework.

| | [pg-boss](https://github.com/timgit/pg-boss) | [BullMQ](https://docs.bullmq.io/) |
|---|---|---|
| Backed by | PostgreSQL | Redis |
| Extra infrastructure | None | A Redis instance that must never evict keys |
| Enqueue inside the database transaction | Yes | No |
| Throughput | Enough for most products | High |
| Rate limiting, job flows, dashboards | Basic or missing | Built in |

- **The project only has PostgreSQL and a modest volume of jobs:** pg-boss. One less service to run, and a job is committed together with the data it refers to.
- **The project already runs Redis, or needs high volume, rate limiting or job flows:** BullMQ.
- Don't add Redis only to run a few low-volume jobs.

####  3.10.2. pg-boss

- Jobs live in the application database, so only the Elysia app talks to it and no new connection rules are needed.
- Enqueue inside the same transaction as the write that causes the job. Either both are committed or neither is: there is no job for a row that was rolled back, and no committed row without its job.
- Workers run in the API process until their load justifies a process of their own.
- It polls the database. Don't use it for thousands of jobs per second or for sub-second scheduling.

####  3.10.3. BullMQ

BullMQ supports Bun officially, and its test suite runs on Bun. Use it on the same runtime as the API: there is no need for a Node.js process for the workers.

- **Use ioredis, the default client.** Pass connection options (`host`, `port`), not a client instance: BullMQ then creates and configures every connection it needs. Bun's built-in Redis client is supported through an adapter, but it is newer and does not cover Cluster or Sentinel.
- **Write inline processors.** Don't use sandboxed processors (a file path as the processor) on Bun until they are proven on the project: there is a long-standing open issue about them.
- **Run the workers in their own process** (`src/worker.ts` next to `src/index.ts`, same code base), so a busy queue does not slow down the API and each side scales separately.
- **Redis must not evict keys**: `maxmemory-policy noeviction`. An evicted key is a lost job, so the job Redis is never the cache Redis.
- **Bound what Redis keeps**: set `removeOnComplete` and `removeOnFail` limits in the queue defaults.
- **Set `attempts` and an exponential `backoff`** in the queue defaults. Throw `UnrecoverableError` when a retry cannot help.
- **Use `jobId` to deduplicate** an enqueue that may be repeated.
- **Recurring work uses job schedulers** (`upsertJobScheduler`), not a system cron.
- **There is no transactional enqueue.** Enqueue after the database transaction commits, never inside it. A job that must not be lost needs an outbox table, or a handler that tolerates a row that is not there.
- Redis runs in Docker Compose locally, as the [meta tools guide](/guides/development/meta-tools-guide.md#docker-local-services) describes.

```ts
// src/platform/jobs/index.ts
import { Queue } from "bullmq";
import { config } from "../config";

export const connection = { host: config.REDIS_HOST, port: config.REDIS_PORT };

export function queueOf<Payload>(name: string): Queue<Payload> {
  return new Queue<Payload>(name, {
    connection,
    defaultJobOptions: {
      attempts: 5,
      backoff: { type: "exponential", delay: 1000 },
      removeOnComplete: { count: 1000 },
      removeOnFail: { count: 5000 },
    },
  });
}
```

```ts
// src/queues/dispatch-alert/index.ts
import { type Job, Worker } from "bullmq";
import { Value } from "typebox/value";
import { alertSignal, DISPATCH_ALERT_QUEUE } from "../../domains/alerts/model";
import { connection } from "../../platform/jobs";
import { log } from "../../platform/log";
import { dispatchAlert } from "../../workflows/dispatch-alert/service";

export async function handleDispatchAlertJob(job: Job): Promise<void> {
  if (!Value.Check(alertSignal, job.data)) {
    log.error({ jobId: job.id }, "Discarding a dispatch-alert job with an invalid payload");
    return;
  }

  await dispatchAlert(job.data);
}

export function registerDispatchAlertWorker(): Worker {
  return new Worker(DISPATCH_ALERT_QUEUE, handleDispatchAlertJob, { connection, concurrency: 5 });
}
```

###  3.11. Logging

- One logger: [pino](https://getpino.io/), structured JSON to stderr, created once per app in `platform/log/`. Never `console.log`.
- The request log records method, path, status and duration. Never headers, bodies or query strings.
- Log chosen fields (`{ userId, action }`), not whole objects. Configure redaction paths at startup for credentials, and add new sensitive field names in the same change that introduces them.
- Routes polled by probes (health checks) log only failures.

###  3.12. Testing

- Unit tests use Bun's test runner, are named `*.test.ts` and live next to the code. Reserve `*.spec.ts` for Playwright end-to-end tests.
- Run them through the standard `test` and `e2e` tasks of the [meta tools guide](/guides/development/meta-tools-guide.md#standard-task-names).
- Test controllers with `app.handle(new Request(...))`. No server and no port are needed.
- For typed requests and responses, wrap the same app with Eden Treaty (see [3.9](#39-api-clients)). Keep raw `Request` objects for what a typed client cannot send: a malformed body, a wrong content type, a missing header.
- Mount the controller with the plugins its behaviour depends on (at least the error handler), so the test sees the real status codes and bodies.
- Replace the domain's dependencies with stubs instead of mocking modules.

```ts
// src/api/teams/index.test.ts
import { describe, expect, it } from "bun:test";
import { Elysia } from "elysia";
import { errorHandler } from "../../platform/error-handler";
import { teams } from ".";

const app = new Elysia().use(errorHandler).use(teams);

describe("GET /api/teams", () => {
  it("answers 401 when nobody is signed in", async () => {
    signedOut();

    const response = await app.handle(new Request("http://localhost/api/teams"));

    expect(response.status).toBe(401);
    expect(await response.json()).toEqual({
      error: { code: "unauthenticated", message: "Authentication required" },
    });
  });
});
```

See also our [Testing guidelines](/guides/development/testing-guidelines.md).

##  4. Libraries

###  4.1. Recommended libraries

- Runtime and package manager: [Bun](https://bun.sh/)
- Framework: [Elysia](https://elysiajs.com/) 2
- Validation: [TypeBox](https://github.com/sinclairzx81/typebox) 1.x (the `typebox` package, through Elysia's `t`)
- Official plugins: `@elysia/cors`, `@elysia/openapi`
- API client for front ends: [Hey API](https://heyapi.dev/), generated from the OpenAPI spec
- Typed client on the Elysia side (tests, service-to-service calls): [Eden Treaty](https://elysiajs.com/eden/overview) (`@elysia/eden`)
- Database: [PostgreSQL](https://www.postgresql.org/) with [Drizzle ORM](https://orm.drizzle.team/)
- Authentication: [Better-Auth](https://www.better-auth.com/)
- Background jobs: [pg-boss](https://github.com/timgit/pg-boss) on PostgreSQL, or [BullMQ](https://docs.bullmq.io/) with ioredis when the project has Redis (see [3.10.1](#3101-choosing-a-job-library))
- Logging: [pino](https://getpino.io/)
- Testing: Bun's test runner, [Playwright](https://playwright.dev/) for end-to-end
- Lint and format: [Biome](https://biomejs.dev/)
- Tooling: mise, lefthook, dekit and Docker Compose as in the [meta tools guide](/guides/development/meta-tools-guide.md)

###  4.2. Libraries to avoid

- `@sinclair/typebox` (0.x): Elysia 2 uses `typebox` 1.x. Tools built on the old package (for example `@hookform/resolvers`' TypeBox resolver) don't accept the new schemas.
- Plugins under the `@elysiajs` scope and community plugins written for the Elysia 1 hook API. Check that a plugin supports Elysia 2 before adding it; when it doesn't and the need is small (request logging), write a small plugin of your own.

##  5. Learning resources

- Elysia docs: https://elysiajs.com/ (start with the best practice and plugin pages)
- Eden Treaty docs: https://elysiajs.com/eden/overview
- Bun docs: https://bun.sh/docs
- TypeBox docs: https://github.com/sinclairzx81/typebox
