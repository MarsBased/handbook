# Our meta tools guide

Meta tools are the tools that sit around the code rather than inside it: they install the right language versions, run the project's tasks, wire up Git hooks, start the development processes, and manage the services and repositories a project depends on.

Every step in a typical "Getting started" README is one of these tools' job, not a human's job. "Install Node 20.11, the newer ones break the build", "copy `.env.example` and ask someone for the values", "open four terminals", "remember to run the linter before you commit": each of those is an instruction the repository should carry itself, in a file the machine reads.

We standardise these tools so that every project feels the same. Regardless of the stack, a new team member should be able to get a project running with three commands:

```bash
mise install    # language runtimes and CLI tools, pinned by the project
mise run setup  # .env, dependencies, database, migrations, seeds
mise run dev    # every development process, one pane each
```

The tools come from different authors and do not know about each other. That is a feature: you adopt them one at a time, in the order a growing codebase starts to hurt, and you can drop any of them without touching the rest.

As with our other guides, some clients have their own tooling; you can suggest ours, but there will be projects where it is not possible to use it.

- **1.** [Principles](#principles)
- **2.** [Which tool for what](#which-tool-for-what)
- **3.** [mise: versions, environment and tasks](#mise-versions-environment-and-tasks)
- **4.** [Docker: local services](#docker-local-services)
- **5.** [lefthook: Git hooks](#lefthook-git-hooks)
- **6.** [mprocs: development processes](#mprocs-development-processes)
- **7.** [Workspaces: one repository, many packages](#workspaces-one-repository-many-packages)
- **8.** [moon: monorepo task graph](#moon-monorepo-task-graph)
- **9.** [mani: multiple repositories](#mani-multiple-repositories)
- **10.** [Agent rules](#agent-rules)
- **11.** [How they compose](#how-they-compose)
- **12.** [Adoption order](#adoption-order)
- **13.** [New project checklist](#new-project-checklist)

## Principles

Four rules decide most of the questions this guide answers. When a situation is not covered below, apply these.

**One command per intent, one owner per command.** There will be four things in a repository able to run the tests: a `package.json` script, a mise task, a moon task and a mani task. If all four are wired, nobody knows which one is canonical and two of them are quietly out of date. Each tool owns one layer, and calls flow in one direction only (see [How they compose](#how-they-compose)).

**Things that execute our code run natively under mise. Things we talk to over a socket run in containers.** Node, Bun, Ruby, the linter, the CLIs: mise. PostgreSQL, Redis, S3, the search engine, the message broker: Docker Compose, every time. A runtime wants to be fast, on the real file system, with a debugger attached and the editor resolving it. A service wants to be disposable and identical for everyone, down to the extensions, with a volume you can delete when the data gets weird.

**Hooks are a fast feedback loop, not a security boundary. CI is the boundary.** A check that must never be skipped belongs in CI. The hook is the early warning, and an escape hatch for it is fine.

**The README describes what the project is, not how to get it running.** The repository already knows how to get itself running. The README carries the three commands and points here.

## Which tool for what

| Problem it removes | Tool | Config file |
|---|---|---|
| "Install these versions, set these env vars" | [mise](https://mise.jdx.dev/) | `mise.toml` |
| "Run the linter / tests / migrations like this" | mise | `mise.toml` |
| "Install PostgreSQL 18 and Redis locally" | [Docker Compose](https://docs.docker.com/compose/) | `.dockerdev/compose.yml` |
| "Remember to lint before you commit" | [lefthook](https://lefthook.dev/) | `lefthook.yml` |
| "Open four terminals" | [mprocs](https://github.com/pvolok/dekit/blob/master/README-mprocs.md) | `mprocs.yaml` |
| "These five packages depend on each other" | Bun / pnpm workspaces | `package.json` |
| "The build takes nine minutes and rebuilds everything" | [moon](https://moonrepo.dev/) | `.moon/`, `moon.yml` |
| "We have twelve repositories, not one" | [mani](https://manicli.com/) | `mani.yaml` |
| "The coding agent also reads the stale README" | `CLAUDE.md` | root + one per area |

The default toolset for a single-repository project is **mise + Docker Compose + lefthook + mprocs**. Add **workspaces** when a second package appears, **mani** when the project is spread across repositories, and **moon** only for monorepos where the build has become slow enough to hurt.

Every one of these tools is installed by mise, so `mise install` is always the first and only manual step.

## mise: versions, environment and tasks

[mise](https://mise.jdx.dev/) replaces `rbenv`, `nvm`, `pyenv`, `asdf`, `direnv` and `make` in one Rust binary: it installs the versions a project declares, injects the project's environment variables and runs the project's tasks. It is the entry point for everything else in this guide, and the only file in a repository where a version number lives.

### Installation and shell activation

Install mise with your package manager or the [official installer](https://mise.jdx.dev/getting-started.html), then activate it in your shell so that entering a project directory puts the right versions on your `PATH`:

```bash
# ~/.zshrc
eval "$(mise activate zsh)"

# ~/.bashrc
eval "$(mise activate bash)"
```

Other shells (fish, nushell, PowerShell) are covered in the [mise docs](https://mise.jdx.dev/installing-mise.html#shells). Tools that bypass the shell (IDEs, CI steps) can use `mise exec -- node --version` or `mise which node`.

**Trust is a security feature, not a nuisance.** A config file that sets environment variables and runs commands is a code execution vector. The first time mise sees a config it refuses to load its environment and templates until you run `mise trust`, and asks again when the file changes. Review the file before trusting it, and do not train yourself to type `mise trust` reflexively on repositories cloned from the internet.

### Tool versions

Declare every runtime and CLI tool the project needs in the `[tools]` section of `mise.toml`, committed at the root of the repository:

```toml
[tools]
ruby = "3.4.5"
node = "24"
lefthook = "2.1.9"
mprocs = "0.9.6"
"npm:@moonrepo/cli" = "2.5.5"   # only in monorepos that use moon
```

Rules:

- **Pin exact versions in projects.** `"latest"` belongs in your personal `~/.config/mise/config.toml`, not in a repository. A project must build the same way on every laptop and in CI.
- **Declare the meta tools too.** lefthook, mprocs, mani, moon and any other CLI the tasks call go in `[tools]`. Beyond runtimes, mise has `npm:`, `cargo:`, `pipx:`, `go:`, `ubi:` and `aqua:` backends, so your formatter, `terraform` or any release binary from GitHub can be pinned in the same file.
- **Idiomatic version files are opt-in.** mise ignores `.ruby-version`, `.node-version` and friends unless you enable them in your settings. Keep them only when a deploy platform reads them, and make sure they match `mise.toml`.
- **`mise use node@24` writes to `mise.toml` and installs.** Fine for adding a tool; commit the change with a message that says why the version changed.

Useful commands: `mise install` installs what the config declares, `mise ls` shows what is active in the current directory and `mise outdated` lists newer versions.

### Environment

The `[env]` section replaces `direnv`. Use it for variables that every developer needs and that are safe to commit, and load the rest from a git-ignored `.env`:

```toml
[env]
NODE_ENV = "development"
# Single root .env for every workspace. Frameworks only auto-load .env from their
# own directory, so processes must run through mise tasks to get it.
_.file = ".env"
_.path = ["bin", "node_modules/.bin"]
```

- `_.file` loads a dotenv file. Secrets stay in a git-ignored file while the *shape* of the environment is committed and reviewable through `.env.example`.
- `_.path` prepends directories to `PATH`, so `bin/rails` or `node_modules/.bin` binaries work without a prefix.
- **Per-developer overrides go in `mise.local.toml`**, which mise reads with higher precedence and which must be git-ignored. Never commit secrets in `mise.toml`.

### Tasks

Tasks are the project's scripts. They live in `mise.toml` under `[tasks]` and run with `mise run <name>` (or `mise r <name>`). `mise tasks` lists them with their descriptions, which is why every task has one: a new person clones, runs `mise install` and `mise tasks`, and the repository tells them what it can do.

```toml
[tasks.setup]
description = "Fresh clone to running stack: .env, dependencies, database, seeds"
run = """
set -e
[ -f .env ] || cp .env.example .env
bun install
lefthook install
mise run db:up
mise run db:seed
"""

[tasks.dev]
description = "PostgreSQL, API and web in watch mode, one mprocs pane each"
depends = ["env:check"]
raw = true
run = "mprocs"

[tasks."db:up"]
description = "Start PostgreSQL and wait until it is healthy"
run = "docker compose -f .dockerdev/compose.yml up --detach --wait"

[tasks."db:wait"]
description = "Block until PostgreSQL answers, without starting it"
run = "docker compose -f .dockerdev/compose.yml exec -T postgres pg_isready -U postgres"

[tasks."db:migrate"]
depends = ["db:wait"]
run = "bun run --cwd packages/db db:migrate"

[tasks."db:seed"]
# depends run in parallel, so ordering is a chain: seed after migrate, migrate after db:wait
depends = ["db:migrate"]
run = "bun run --cwd packages/db db:seed"

[tasks.lint]
run = "bun x biome check ."

[tasks."lint:staged"]
# For the pre-commit hook. mise appends trailing arguments to the command.
run = "bun x biome check --write --no-errors-on-unmatched"

[tasks.test]
run = "bun test apps packages"

[tasks."db:studio"]
description = "Database GUI"
raw = true
run = "bunx drizzle-kit studio"
```

Things worth knowing:

- **`run` accepts a string, a list or a multi-line script.** Lists run in series. For scripts, start with `set -e` so the task fails at the first error.
- **`depends` runs in parallel.** When order matters, chain the dependencies (`db:seed` depends on `db:migrate`, which depends on `db:wait`) instead of listing them all in one `depends`.
- **Trailing arguments are appended to the command.** `mise run lint:staged file.ts` runs `biome check --write --no-errors-on-unmatched file.ts`, which is how lefthook passes the staged files.
- **Interactive tasks need `raw = true`.** mise captures task output by default; anything that draws a UI or asks for confirmation (mprocs, database GUIs, Playwright's UI mode) needs the raw terminal.
- **`sources` and `outputs` give a cheap `make`-style skip.** If no source changed, the task does not run. Use it for generated code and single-package builds. Do not use it in a repository where moon owns the cache: two caches that disagree is worse than one.
- **Long scripts become files in `mise-tasks/`.** An executable with a shebang and a `#MISE description=` comment is a task. Real bash or Python with arguments and a linter beats ten lines of TOML-escaped shell.
- **Write inline scripts in POSIX shell.** Tasks run in `sh`, not in each developer's login shell.
- **Comment the non-obvious.** A task file is read by the next person at 6pm on a Friday when the database is broken. Say why a task exists and when to reach for it, not what the command does.

### Standard task names

Use the same names in every project so that nobody has to read `mise.toml` to get started:

| Task | Purpose |
|---|---|
| `setup` | Fresh clone to running stack. Safe to rerun: it never overwrites an existing `.env`, migrations are incremental and seeds only add what is missing. |
| `dev` | Start every development process through mprocs. |
| `lint` / `lint:fix` | Linting and formatting, check and autofix. |
| `typecheck` | Static type checks (`tsc --noEmit`, Sorbet, mypy...). |
| `test` | Fast test suite with no external infrastructure beyond the database. |
| `e2e` | Browser or end-to-end suite. Boots what it needs. |
| `ci` | What CI runs. In a moon repository, `moon ci`. |
| `db:up` / `db:down` | Start and stop the service containers on their own. |
| `db:migrate` / `db:seed` | Apply migrations, load fixtures. |
| `db:reset` | Drop the volume, migrate, seed. The database back to its initial state. |
| `reset` | Everything `setup` does from a clean slate: no containers, no volumes, no stray processes. |

Group related tasks with a colon prefix (`db:`, `docker:`, `test:`), and keep the plain name (`test`) for the thing you run most.

## Docker: local services

Docker runs the infrastructure a project depends on locally: PostgreSQL, Redis, Minio, Elasticsearch, Mailpit. The application itself runs on the host with the runtime mise installs, which keeps it fast and keeps debugging simple. Our [Docker guide](/guides/development/docker-guide.md) describes this "services only" setup in depth, along with the "services + application" alternative for when the whole stack has to run in containers.

In the context of this guide, Docker is a dependency of mise tasks:

```yaml
# .dockerdev/compose.yml
# Local development infrastructure only; production uses a managed database.
# Credentials must match DATABASE_URL in the root .env (see .env.example).
name: acme

services:
  postgres:
    image: postgres:18
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: acme
    ports:
      - "5432:5432"
    volumes:
      - postgres-data:/var/lib/postgresql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d acme"]
      interval: 2s
      timeout: 5s
      retries: 15

  redis:
    image: redis:8-alpine
    ports:
      - "6379:6379"

volumes:
  postgres-data:
```

Conventions:

- **Services only, never runtimes.** See the [Principles](#principles). If you find yourself writing a `Dockerfile` for the application in development, read the Docker guide first and make sure you need it.
- **Keep it in `.dockerdev/`**, away from any production `Dockerfile` in the root.
- **Set `name`** so containers and volumes are not called after the directory, which is `dockerdev` for every project.
- **Add a `healthcheck` to every service** and start them with `docker compose up --detach --wait`, so the task that follows (`db:migrate`) does not race the database.
- **Pin image versions** the same way you pin runtimes: `postgres:18`, not `postgres:latest`. Match the version the project runs in production, down to the extensions.
- **Wrap every `docker compose` call in a mise task.** Nobody should have to remember the `-f .dockerdev/compose.yml` flag. `db:up`, `db:down`, `db:reset` and a foreground `dev:db` for the mprocs pane cover the usual needs.
- **Connection strings live in `[env]` or `.env.example`** next door, so a fresh clone is still one `mise run setup`.
- **Volumes are disposable.** `db:reset` drops them and rebuilds from migrations and seeds. If losing a local volume would hurt, the seeds are incomplete.

## lefthook: Git hooks

Everyone has been told to run the linter before committing. Nobody does it reliably. [lefthook](https://lefthook.dev/) manages Git hooks from a `lefthook.yml` committed to the repository. It is a single Go binary, so it works the same for a Rails, Next.js or Python project, and it runs jobs in parallel.

### Setup

Add it to `[tools]` in `mise.toml`, and make `mise run setup` call `lefthook install`. That writes the hooks into `.git/hooks`, which is local to each clone, so the install step has to run on every machine. Putting it in `setup` (or in a `postinstall` script) is the way to make sure nobody has to remember.

### Configuration

```yaml
# lefthook.yml
min_version: 2.0.0

pre-commit:
  parallel: true
  skip:
    - merge
    - rebase
  jobs:
    - name: lint
      glob: "*.{ts,tsx,js,json,css}"
      run: mise run lint:staged {staged_files}
      stage_fixed: true
    # Type-checks run across the whole project: partial checks are unsound.
    - name: typecheck
      glob: "*.{ts,tsx}"
      run: mise run typecheck

pre-push:
  jobs:
    # Fast suite first, so we fail before the expensive one spins up services.
    - name: test
      run: mise run test
    - name: e2e
      run: mise run e2e
```

Four features carry the whole thing:

- **`parallel: true`.** The linter, the type checker and the formatter run at the same time. This is the difference between a 1.5 second hook and a 6 second hook, and 6 seconds is where people start typing `--no-verify`.
- **`glob` + `{staged_files}`.** The job only runs when matching files are staged, and only receives those files. Touching a README does not trigger a type check.
- **`stage_fixed: true`.** Autofixes get staged, so the commit contains the fixed code instead of failing and making you re-add everything.
- **`skip: [merge, rebase]`.** Hooks do not fire forty times during an interactive rebase, and formatting a merge commit does not rewrite files you did not touch.

Conventions:

- **Hooks call mise tasks.** The hook is a trigger, the task is the truth. When the lint command changes, `lefthook.yml` stays correct. lefthook never defines real work.
- **`pre-commit` must be fast.** Lint and format staged files, type-check when it takes seconds. A test suite is `pre-push`.
- **`pre-push` runs the tests.** Unit tests before end-to-end. If the end-to-end suite takes minutes and CI already gates merges on it, leave it out of the hook.
- **Do not validate commit messages in a hook.** Our [Git guidelines](/guides/development/git-guidelines.md) only enforce the message format on the squashed commit, and intermediate commits are free-form.
- **Use the `jobs` syntax.** The older `commands` map still works in lefthook 2; do not rewrite a working config for it, but new files use `jobs`.

### Day to day

- `lefthook run pre-commit --all-files` runs a hook by hand on the whole repository, which is also how CI can run the same checks.
- `LEFTHOOK=0 git commit` or `git commit --no-verify` skips the hooks. That is fine: hooks are the early warning, CI is the boundary. Do it knowingly, not by habit.
- Personal overrides go in a git-ignored `lefthook-local.yml`, which merges into the main file. Skipping the end-to-end suite on push because you are on a train is a valid use:

```yaml
# lefthook-local.yml
pre-push:
  jobs:
    - name: e2e
      skip: true
```

## mprocs: development processes

Your application is not one process. API, front end, worker, CSS watcher, the service containers. Six terminal tabs lose track of which is which and one crashes silently; `concurrently` interleaves everything into one stream and cannot restart just the worker; tmux is great if everyone on the team knows tmux.

[mprocs](https://github.com/pvolok/dekit/blob/master/README-mprocs.md) is a small TUI: a list of processes on the left, the selected process's output on the right. Each keeps its own scrollback, each can be stopped, started and restarted on its own, and panes are interactive, so a dev server asking "port 3000 in use, use 3001?" can be answered.

mprocs is being succeeded by [dekit](https://github.com/pvolok/dekit) from the same author. mprocs 0.9.6 remains available and installable through mise, and dekit keeps a compatible `dekit mprocs` command line. Pin `mprocs = "0.9.6"` in `mise.toml` and revisit when dekit ships.

### Configuration

```yaml
# mprocs.yaml
# Panes for `mise run dev`; never run mprocs directly. Each pane shells out to its
# mise task instead of repeating the command, so this file stays correct when the
# tasks change and every process still gets the root .env that mise injects.
scrollback: 10000

procs:
  db:
    shell: "mise run dev:db"
    # The pane owns the container, so stop it the way it was started.
    stop:
      cmd: "docker compose -f .dockerdev/compose.yml down"
  api:
    shell: "mise run dev:api"
    # Ctrl+C into the pty instead of SIGTERM to the direct child: the signal
    # reaches the whole process group, so watchers die with their parent.
    stop:
      send-keys: ["<C-c>"]
  web:
    shell: "mise run dev:web"
    stop:
      send-keys: ["<C-c>"]
  # Start on demand with `s` on the pane.
  studio:
    shell: "mise run db:studio"
    autostart: false
```

Conventions:

- **Start it through `mise run dev`**, with `raw = true` on the task. Running mprocs directly skips the environment mise injects and any `depends` the task declares (like an `.env` drift check).
- **Panes call mise tasks**, for the same reason hooks do. Split `dev` into `dev:db`, `dev:api`, `dev:web` tasks and give each pane one of them.
- **Stop processes the way they expect.** Watchers and bundlers spawn children; a plain `SIGTERM` to the parent leaves them alive and holding ports. Use `send-keys: ["<C-c>"]` for those, and an explicit `cmd` for containers.
- **Optional processes get `autostart: false`.** Database GUIs, Storybook, mobile emulators, the type checker in watch mode: present in the list, started with a keystroke instead of found with a README grep.
- **Git-ignore `mprocs.log`.** mprocs writes it next to the config when something goes wrong internally.
- **For multi-directory setups** use `cwd` with the `<CONFIG_DIR>` placeholder, which mprocs replaces with the directory that holds `mprocs.yaml`.

### Where the services go

Two options for the containers, both fine:

- **A `db` pane running `docker compose up` in the foreground** (above). Logs are one keypress away, and `q` stops the stack with everything else. Our default: a project's dev session and its database start and stop together.
- **`docker compose up --detach` in `setup` and `db:up`, no pane.** Services outlive the dev session, which you want when restarting the app forty times a day must not mean restarting PostgreSQL forty times a day. Keep a `logs` pane with `autostart: false` for when something is wrong.

Pick one per project and say which in `mprocs.yaml`.

### Keys

Document these in the project README, since they are the first thing a new team member needs. `?` inside mprocs shows the full keymap.

| Key | Action |
|---|---|
| `j` / `k` | Select the previous or next pane |
| `C-a` | Move focus between the process list and the process output |
| `s` | Start the selected process |
| `x` / `X` | Stop the selected process (soft / hard) |
| `r` / `R` | Restart the selected process (soft / hard) |
| `v` | Copy mode, to scroll and select output |
| `q` / `Q` | Quit and stop everything (soft / hard) |

If a project already has a `Procfile.dev` (Rails 7+ `bin/dev`), `mprocs --procfile Procfile.dev` runs it as is. Migrate to `mprocs.yaml` when you need per-process `stop` or `autostart` settings.

## Workspaces: one repository, many packages

When a codebase grows into a web app, an admin app, a shared UI library and an API that are released together, one repository with several packages usually beats several repositories. Workspaces are the npm-standard way to do that; [Bun](https://bun.sh/docs/install/workspaces) and pnpm implement the same `package.json` field.

```jsonc
// package.json (root)
{
  "name": "@acme/root",
  "private": true,
  "workspaces": {
    "packages": ["apps/*", "packages/*"],
    // Declare a version once; packages reference it with "catalog:"
    "catalog": { "react": "^19.0.0", "zod": "^4.0.0" }
  }
}
```

```jsonc
// apps/web/package.json
{
  "name": "@acme/web",
  "dependencies": {
    "@acme/ui": "workspace:*",
    "react": "catalog:"
  }
}
```

```bash
bun install                            # every workspace, one lockfile
bun add --cwd apps/web zod             # add a dependency to one workspace
bun run --filter '*' typecheck         # run a script in every workspace that has it
bun run --filter './packages/*' test   # or a subset, by path
```

Conventions:

- **Internal packages are referenced as `workspace:*`**, never a published version. Edit `packages/ui`, the change is live in `apps/web`.
- **Use catalogs** so React does not drift to three different minors across the monorepo.
- **Keep the lockfile in text form** (`bun.lock`). Binary lockfiles are unreviewable when five people touch dependencies in the same week.
- **`package.json` scripts are the primitive.** One package, one command, no cross-package knowledge. mise tasks and moon tasks call them; they never call mise or moon.

The honest limitation: workspaces solve dependency resolution, not builds. `bun run --filter '*' build` rebuilds everything every time and does not know that `packages/types` must build before `apps/api`. With five packages that is fine. With forty packages and CI on every pull request, that is where your afternoon goes, and where moon starts.

## moon: monorepo task graph

[moon](https://moonrepo.dev/) is a task runner and build system for monorepos, in the same category as Turborepo and Nx. Where mise tasks and workspace scripts are a flat list, moon knows which project depends on which, hashes inputs and outputs to skip work that has not changed, and can run only what a change affected.

It is the heaviest tool in this guide: `.moon/workspace.yml`, `.moon/toolchains.yml`, inherited tasks in `.moon/tasks.yml`, a `moon.yml` per project, an afternoon of setup and a week of getting `inputs` right. **Do not adopt it on a three-package repository.** Bun workspaces plus mise tasks cover most of our monorepos. The honest triggers are:

- CI is slow enough that people stop waiting for it.
- There are enough packages that build order is a source of bugs.
- The repository is polyglot enough that `bun run --filter` stops covering it.

A build system adopted too early is a config file nobody understands, maintained by whoever adopted it.

### Shape

```yaml
# .moon/workspace.yml
projects:
  - "apps/*"
  - "packages/*"

vcs:
  defaultBranch: "main"
```

```yaml
# .moon/toolchains.yml
# No versions here on purpose: mise owns them and puts the binaries on PATH.
bun: {}
node: {}
```

```yaml
# .moon/tasks.yml, inherited by every project
fileGroups:
  sources:
    - "src/**/*"

tasks:
  build:
    inputs:
      - "@group(sources)"
      - "package.json"
      - "/mise.toml"   # a runtime bump must bust the cache; see below
  test:
    inputs:
      - "@group(sources)"
      - "tests/**/*"
```

```yaml
# apps/web/moon.yml
language: "typescript"
type: "application"

dependsOn:
  - "ui"
  - "types"

tasks:
  build:
    command: "bun run build"
    deps:
      - "^:build"       # ^ = the build task of every project I depend on
    outputs:
      - "dist"
  test:
    command: "bun test"
    deps:
      - "~:build"       # ~ = a task in this same project
  dev:
    command: "bun run dev"
    options:
      persistent: true
      cache: false
```

```bash
moon run web:build            # this project and everything it needs, in order
moon run :test                # every project that has a test task
moon run :test --affected     # only projects touched by uncommitted changes
moon check --all              # every project's build and test tasks
moon ci                       # what CI runs: affected tasks against the base branch
```

### The three ideas that earn the config

1. **The graph is explicit.** `deps: ["^:build"]` is the whole trick. No shell script hardcodes the build order, and nobody discovers the order was wrong by seeing a stale `dist/` in production.
2. **Caching is content-based.** A task's cache key hashes its `inputs`, the command, the declared env vars, and its dependencies' hashes. Same hash, no rerun: moon replays the stored output and restores the `outputs`. This is why declaring `inputs` honestly is the highest-leverage thing in a moon config. Too broad (`**/*`) and you never get a hit; too narrow and you get a *wrong* hit, a build that silently skipped a change, which is far worse.
3. **Affected detection.** `moon ci` compares against the base branch, works out which projects the changed files belong to, walks the graph to find what depends on them, and runs only that. A pull request touching one README runs nothing. Remote caching lets CI warm a cache that laptops read from.

### moon and mise overlap in two places

Both can install runtimes and both can run tasks. You have to pick an owner for each, and the failure when you get it wrong is not a crash, it is a stale cache.

| Concern | mise | moon | Owner |
|---|---|---|---|
| Installing runtimes and CLIs | yes | yes | **mise** |
| Environment variables | yes | per task | mise, declared again in moon tasks that depend on them |
| Human-facing entry points | yes | yes | **mise** |
| Task graph, caching, affected-only | no | yes | **moon** |
| Non-JS tooling (terraform, CLIs) | yes | no | mise |

**mise owns the toolchain, moon owns the graph.** mise already has to exist for the CLIs moon does not know about, and it installs moon itself (`"npm:@moonrepo/cli"` in `[tools]`). Leave versions out of `.moon/toolchains.yml` so moon uses whatever mise put on `PATH`.

**Calls flow in one direction only:**

```
mise run test  →  moon run :test --affected  →  bun test  (package.json script)
```

Never the reverse. A `moon.yml` that shells out to `mise run` nests the two runners, and mise's `sources`/`outputs` skipping then fights moon's cache.

**Two correctness gotchas that follow from this split:**

- moon hashes the toolchain version into its cache key only when it manages the toolchain. Since mise does, moon cannot see a Node bump and will happily replay a cache entry built with the old version. Fix: `/mise.toml` is an input of every inherited task, as in `.moon/tasks.yml` above.
- mise exports env vars into the shell and moon inherits them, but moon does not hash what it was never told about. Any env var that changes a task's output gets declared in the task's `env`.

**In CI it is two lines**, because mise must set `PATH` before moon starts (moon spawns processes directly, not through a login shell):

```yaml
steps:
  - run: mise install   # runtimes, plus moon itself
  - run: mise run ci    # → moon ci
```

## mani: multiple repositories

Everything so far assumed one repository. Client work often does not: a backend, a mobile app, an admin panel, each with its own history, access and deployment. A monorepo is not on the table, but you still want to ask cross-cutting questions ("which of these have uncommitted changes?", "update the CI workflow in all of them") and you want a new person to get the whole working set on disk with one command.

[mani](https://manicli.com/) is a small Go CLI for exactly this: a declarative list of repositories plus tasks you can run across them. We keep it in a small **meta repository** that holds the `mani.yaml`, the shared `.dockerdev/` services and the `mprocs.yaml` that starts everything.

### Configuration

```yaml
# mani.yaml
# Tasks always run under bash regardless of each developer's login shell,
# so POSIX syntax like `&&` is safe in every cmd.
shell: bash -c

projects:
  backend:
    path: backend
    url: git@github.com:MarsBased/acme-backend.git
    desc: NestJS backend API
    tags: [backend, active]
  mobile:
    path: mobile
    url: git@github.com:MarsBased/acme-mobile.git
    desc: React Native app built with Expo
    tags: [mobile, active]
  acme:
    path: .
    url: git@github.com:MarsBased/acme-base.git
    desc: Meta repository holding the mani configuration
    tags: [meta]

tasks:
  dev:
    desc: Run services, backend and mobile in one mprocs window; q stops everything
    target:
      projects: [acme]
    # tty hands the terminal to mprocs. tty tasks run through the developer's
    # login shell, so the cmd must be a single plain command.
    tty: true
    cmd: mprocs
  setup:
    desc: Bootstrap every repo; env file, dependencies, database, seeds
    target:
      all: true
    commands:
      - name: env file
        cmd: if [ -f .env.example ] && [ ! -f .env ]; then cp .env.example .env; fi
      - name: dependencies
        cmd: if [ -f mise.toml ]; then mise install && mise run setup; fi
  pull:
    desc: Pull the current branch in every repo
    cmd: git pull --ff-only
  status:
    desc: Short git status across all repos
    cmd: git status --short --branch
```

### Workflow

```bash
git clone git@github.com:MarsBased/acme-base.git acme && cd acme
mise install        # mani, mprocs, bun...
mani sync           # clones every project into its path
mani run setup      # tasks with a target run without flags
mani run status -a  # tasks without a target need one: -a, -t backend, -p mobile
mani exec -t active "git log -1 --format=%cr"
mani tui            # browse projects and tasks interactively
```

Conventions:

- **mani never defines real work.** It fans out a command that already exists in each repository (`mise run setup`, `git pull`). The work lives in the child repository's `mise.toml`.
- **The meta repository is the project's front door.** Its README carries the three commands, and its `mise.toml` pins mani and mprocs. Each child repository keeps its own `mise.toml`, `lefthook.yml` and CI.
- **`mani sync` and `mani.yaml` are the onboarding doc.** One committed file lists every repository a project touches, with the directory layout everyone else has.
- **Set `shell: bash -c`** so tasks behave the same for everyone, whatever their login shell.
- **Tag projects by role and state** (`backend`, `mobile`, `meta`, `active`, `dormant`) and target tasks with tags rather than names, so adding a repository does not mean editing every task.
- **Tasks that touch a single directory get an explicit `target`.** Tasks meant to fan out (`pull`, `status`) leave it to the caller.
- **Put `.dockerdev/` in the meta repository** when several services share the database or cache, and point each child's `.env.example` at it.

Output is tabular and supports other formats, which is unreasonably useful when the task is "produce a table of which repositories are still on Node 18 and paste it in the channel".

## Agent rules

Every tool above moves knowledge out of people's heads and into a file the machine reads. There is one more reader: the coding agent also reads the README, and it is also out of date for it.

Our [AI Augmented Development guide](/guides/development/ai-augmented-development.md) covers `CLAUDE.md` and `.claude/rules/` in general. The part that belongs here is how the rules meet the toolchain:

- **Rules name the real entry point.** "Run the tests before opening a PR" is useless. The rule is `Run tests with mise run test. Never bun test or npm test directly.` If a human is told to use `mise run test` and the agent is told to use `bun test`, you have two conventions and the agent will quietly drift the repository toward the wrong one.
- **Rules never define work.** They tell the agent which of the tools above to use for which intent. If a rule names a command that does not exist, the rule is the bug.
- **Scope rules to the directory they govern.** A Rails naming rule is correct in `apps/api` and is wrong advice inside a React component. Global rules (commit format, PR flow, entry points) go in the root `CLAUDE.md`; stack-specific rules go in a `CLAUDE.md` inside the subtree, or in `.claude/rules/` with a path glob, so they are loaded only where they are true and deleted with the code they describe.
- **Extract, do not link.** A rule that says "see the handbook" costs a tool call the agent will often skip, may be unreachable from a sandbox, and drifts invisibly. The rule text goes in the file, where a reviewer sees it change in a diff.

A minimal entry-points block for a standard project:

```markdown
## Entry points

- Install tools with `mise install`; never install runtimes another way.
- Run tasks with `mise run <task>`; see `mise tasks`. Never call `bun run`, `npm run` or `docker compose` directly.
- Tests: `mise run test`. End-to-end: `mise run e2e`. Lint: `mise run lint:fix`.
- Commits go through lefthook. Do not pass `--no-verify`.
- Internal packages are referenced as `workspace:*`, never a published version.
```

## How they compose

```
mani            → across repos:  sync, fan out a command that already exists
  └── mise      → per repo:      runtimes, env vars, the entry-point commands
        │                         (Docker Compose holds the backing services)
        ├── lefthook  → at commit:    fast checks on staged files, via mise tasks
        ├── mprocs    → while coding: the multi-process dev loop, via mise tasks
        └── workspaces → in repo:     packages resolve to each other
              └── moon → CI & local:  the task graph, the cache, affected-only
        └── CLAUDE.md (root + per area) → for the agent: which command for which intent
```

And the overlap trap, stated as who owns what:

- **`package.json` scripts** are the primitive. One package, one command, no cross-package knowledge. Everything else calls these.
- **moon** owns the graph and the cache, and nothing else. If a task depends on another package's output or benefits from caching, it belongs to moon. CI runs it. It does not own the toolchain.
- **mise** owns runtimes, env vars and the human-facing entry points. It is the only file with a version number in it, and it installs every other tool here. Its tasks are thin wrappers (`mise run dev`, `mise run test`). It is the thing you tell a new person about.
- **Docker Compose** owns the services, and only the services.
- **lefthook** never defines real work. It calls mise tasks, on staged files, fast.
- **mprocs** never defines real work. It gives mise tasks a pane each.
- **mani** never defines real work. It fans out a command that already exists.
- **`CLAUDE.md`** never defines work at all. It tells the agent which of the above to use for which intent.

One command per intent, one owner per command.

The project README repeats the three commands and the mprocs keys, then points here. A minimal template:

```markdown
## Development

Requirements: [mise](https://mise.jdx.dev/) and Docker.

    mise install    # Bun, Node, lefthook, mprocs
    mise run setup  # .env, dependencies, PostgreSQL, migrations, seeds
    mise run dev    # PostgreSQL + API + web, one pane each

`setup` is safe to rerun. When the database is confusing, `mise run db:reset`.
Inside `dev`: `j`/`k` select a pane, `r` restarts it, `x` stops it, `q` quits everything.
```

Files a standard project commits:

```
mise.toml               tools, env, tasks
.env.example            every variable, with safe local defaults
.dockerdev/compose.yml  local services
lefthook.yml            hooks that call mise tasks
mprocs.yaml             panes that call mise tasks
CLAUDE.md               global rules and entry points
```

And git-ignores:

```
.env
mise.local.toml
lefthook-local.yml
mprocs.log
```

## Adoption order

Starting from a normal repository, in the order a growing codebase starts to hurt:

1. **mise** first, always. Highest value, lowest cost, reversible with one `rm`.
2. **Docker Compose** for the services, the moment the project needs a database.
3. **lefthook**. Half an hour, pays back the first time it catches a broken commit.
4. **mprocs** when you catch yourself with four terminals open. Fifteen minutes.
5. **Workspaces** when you have a second package that is not a fork of the first.
6. **moon** only when the build is slow enough to hurt. Not before.
7. **mani** only when you genuinely have many repositories to herd.
8. **Agent rules** any time after step 1. They get better as the steps above give them real commands to point at.

Six small files, each about twenty lines, each doing one thing, each deletable on its own. The alternative is not zero config; it is config that lives in people's heads and in a stale README.

## New project checklist

- [ ] `mise.toml` pins exact versions for every runtime and CLI tool, including lefthook and mprocs. No other file carries a version number.
- [ ] `.env.example` lists every variable and `mise.toml` loads `.env` with `_.file`.
- [ ] `setup`, `dev`, `lint`, `test`, `db:up`, `db:reset` tasks exist and have descriptions.
- [ ] `setup` runs `lefthook install` and is safe to rerun.
- [ ] `.dockerdev/compose.yml` holds services only, sets `name`, pins images and has health checks.
- [ ] `lefthook.yml` lints staged files on commit and runs tests on push, through mise tasks.
- [ ] `mprocs.yaml` gives each process a pane, a correct `stop` strategy, and says whether services live in a pane or detached.
- [ ] `.gitignore` covers `.env`, `mise.local.toml`, `lefthook-local.yml`, `mprocs.log`.
- [ ] The README starts with the three commands and the mprocs keys, and describes what the project is rather than how to run it.
- [ ] `CLAUDE.md` names the real entry points and never a command that does not exist.
- [ ] Workspaces: internal packages use `workspace:*`, shared versions use a catalog, `package.json` scripts stay the primitive.
- [ ] moon (if adopted): no versions in `.moon/toolchains.yml`, `/mise.toml` is an input of inherited tasks, `mise run ci` wraps `moon ci`, no `moon.yml` calls `mise run`.
- [ ] Multi-repository project: a meta repository with `mani.yaml`, tags by role and state, `shell: bash -c`, tasks that only fan out.
