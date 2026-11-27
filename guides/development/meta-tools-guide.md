# Our meta tools guide

Meta tools are the tools that sit around the code rather than inside it: they install the right language versions, run the project's tasks, wire up Git hooks, start the development processes, and manage the services and repositories a project depends on.

Every step in a typical "Getting started" README is one of these tools' job, not a human's job. "Install Node 20.11, the newer ones break the build", "copy `.env.example` and ask someone for the values", "open four terminals", "remember to run the linter before you commit": each of those is an instruction the repository should carry itself, in a file the machine reads.

We standardise these tools so that every project feels the same. Regardless of the stack, a new team member should be able to get a project running with three commands:

```bash
mise install    # language runtimes and CLI tools, pinned by the project
mise run setup  # .env, dependencies, database, migrations, seeds
mise run dev    # every development process, one task each
```

The tools come from different authors and do not know about each other. That is a feature: you adopt them one at a time, in the order a growing codebase starts to hurt, and you can drop any of them without touching the rest.

As with our other guides, some clients have their own tooling; you can suggest ours, but there will be projects where it is not possible to use it.

- **1.** [Principles](#principles)
- **2.** [Which tool for what](#which-tool-for-what)
- **3.** [mise: versions, environment and tasks](#mise-versions-environment-and-tasks)
- **4.** [Docker: local services](#docker-local-services)
- **5.** [lefthook: Git hooks](#lefthook-git-hooks)
- **6.** [dekit: development processes](#dekit-development-processes)
- **7.** [Workspaces: one repository, many packages](#workspaces-one-repository-many-packages)
- **8.** [moon: monorepo task graph](#moon-monorepo-task-graph)
- **9.** [mani: multiple repositories](#mani-multiple-repositories)
- **10.** [Agent rules](#agent-rules)
- **11.** [How they compose](#how-they-compose)
- **12.** [Adoption order](#adoption-order)
- **13.** [New project checklist](#new-project-checklist)

## Principles

Five rules decide most of the questions this guide answers. When a situation is not covered below, apply these.

**One command per intent, one owner per command.** There will be four things in a repository able to run the tests: a `package.json` script, a mise task, a moon task and a mani task. If all four are wired, nobody knows which one is canonical and two of them are quietly out of date. Each tool owns one layer, and calls flow in one direction only (see [How they compose](#how-they-compose)).

**By default, things that execute our code run natively under mise, and things we talk to over a socket run in containers.** Node, Bun, Ruby, the linter, the CLIs: mise. PostgreSQL, Redis, the search engine, the message broker: Docker Compose. A runtime that runs natively is faster, works on the real file system and is easier to debug. A service in a container is identical for everyone and can be deleted and recreated.

The exception is a project that cannot run natively. Some old projects that we have not been able to upgrade depend on libraries that can no longer be installed on a current machine, for example gems that only work with OpenSSL 1.1. Those projects also run the application in a container, with the "services + application" setup of our [Docker guide](/guides/development/docker-guide.md).

**People run mise tasks. CI runs standard scripts.** Everything CI or a deployment runs lives in the ecosystem's standard files (`package.json` scripts, Rake tasks, `bin/` scripts), and mise tasks wrap those same commands for development. See [Tasks CI runs](#tasks-ci-runs).

**Hooks are early warnings and can be skipped when the situation calls for it.** CI enforces every check required to merge.

**The README describes what the project is, not how to get it running.** The repository already knows how to get itself running. The README carries the three commands and points here.

## Which tool for what

| Problem it removes | Tool | Config file |
|---|---|---|
| "Install these versions, set these env vars" | [mise](https://mise.jdx.dev/) | `mise.toml` |
| "Run the linter / tests / migrations like this" | mise, wrapping the scripts CI runs | `mise.toml`, `package.json` |
| "Install PostgreSQL 18 and Redis locally" | [Docker Compose](https://docs.docker.com/compose/) | `.dockerdev/compose.yml` |
| "Remember to lint before you commit" | [lefthook](https://lefthook.dev/) | `lefthook.yml` |
| "Open four terminals" | [dekit](https://github.com/pvolok/dekit) | `dekit.yaml` |
| "These five packages depend on each other" | Bun / pnpm workspaces | `package.json` |
| "The build takes nine minutes and rebuilds everything" | [moon](https://moonrepo.dev/) | `.moon/`, `moon.yml` |
| "We have twelve repositories, not one" | [mani](https://manicli.com/) | `mani.yaml` |
| "The coding agent also reads the stale README" | `CLAUDE.md` | root + one per area |

The default toolset for a single-repository project is **mise + Docker Compose + lefthook + dekit**. Add **workspaces** when a second package appears, **mani** when the project is spread across repositories, and **moon** only for monorepos where the build has become slow enough to hurt.

Every one of these tools is installed by mise, so `mise install` is always the first and only manual step.

## mise: versions, environment and tasks

[mise](https://mise.jdx.dev/) replaces `rbenv`, `nvm`, `pyenv`, `asdf`, `direnv` and `make` in one Rust binary: it installs the versions a project declares, injects the project's environment variables and runs the project's tasks. It is the entry point for everything else in this guide: every version a project needs is either in `mise.toml` or in a standard version file that `mise.toml` tells mise to read.

### Installation and shell activation

Install mise with your package manager or the [official installer](https://mise.jdx.dev/getting-started.html), then activate it in your shell so that entering a project directory puts the right versions on your `PATH`:

```bash
# ~/.zshrc
eval "$(mise activate zsh)"

# ~/.bashrc
eval "$(mise activate bash)"
```

Other shells (fish, nushell, PowerShell) are covered in the [mise docs](https://mise.jdx.dev/installing-mise.html#shells). Tools that bypass the shell (IDEs, CI steps) can use `mise exec -- node --version` or `mise which node`.

mise refuses to load a config's environment and templates until you run `mise trust`, and asks again when the file changes, because a config that sets environment variables and runs commands can execute code. Review the file before trusting it.

### Tool versions

Language runtimes and tools are pinned in two different places, depending on who else has to read the version.

**Language runtimes go in their ecosystem's standard version file.** CI and deployment platforms do not run mise (see [Tasks CI runs](#tasks-ci-runs)), but every ecosystem has a version file that its own tooling already reads: the official setup actions, the buildpacks, the hosting platforms and other version managers. mise reads that same file, so the laptop and the deployment use the same version:

| Runtime | Version file | Also read by |
|---|---|---|
| Ruby | `.ruby-version` | `ruby/setup-ruby`, Render, rbenv, chruby |
| Python | `.python-version` | `actions/setup-python` (`python-version-file`), uv, Heroku, Render, pyenv |
| Go | `toolchain` line in `go.mod` | `actions/setup-go` (`go-version-file`), the `go` command itself |
| Node | `.nvmrc` | `actions/setup-node` (`node-version-file`), Netlify, Render, Cloudflare Pages, nvm |
| Bun | `.bun-version` | `oven-sh/setup-bun` (`bun-version-file`) |
| Rust | `rust-toolchain.toml` | rustup, and therefore every Rust CI image |
| Java | `.java-version` | `actions/setup-java` (`java-version-file`), jenv |

For any other runtime, check the [list of idiomatic version files](https://mise.jdx.dev/configuration.html#idiomatic-version-files) mise supports and use the one its ecosystem treats as standard. If there is none, the version goes in `[tools]` like any other tool.

mise ignores these files by default. Enable them per tool in the `[settings]` section of the project's `mise.toml`, so that every clone gets the same behaviour without anyone touching their personal settings. List only the runtimes the project uses:

```toml
[settings]
# Read runtime versions from the standard files that CI and deploy platforms also read
idiomatic_version_file_enable_tools = ["ruby", "node"]
```

**Everything else goes in the `[tools]` section of `mise.toml`**, committed at the root of the repository. These are the meta tools and CLIs that only developers and CI steps call, and no platform needs to know about them:

```toml
[tools]
lefthook = "2.1.9"
dekit = "0.10.3"
```

Rules:

- **Pin exact versions in projects.** `3.4.5`, not `3.4`, `lts/*` or `stable`. `"latest"` belongs in your personal `~/.config/mise/config.toml`, not in a repository. A project must build the same way on every laptop, in CI and in production.
- **Each version lives in exactly one file.** A runtime that has a version file must not also appear in `[tools]`. `mise.toml` takes precedence over idiomatic files, so a duplicate makes the laptop ignore the file that the deploy reads, and the two drift apart again.
- **Commit one version file per runtime.** Some runtimes accept several (Node also reads `.node-version` and `package.json`, Go also reads `.go-version`). Commit only the one in the table above, so there is never a question of which one wins.
- **Declare the meta tools too.** lefthook, dekit, mani and any other CLI the tasks call go in `[tools]`. Beyond runtimes, mise has `npm:`, `cargo:`, `pipx:`, `go:`, `ubi:` and `aqua:` backends, so your formatter, `terraform` or any release binary from GitHub can be pinned in the same file.
- **Point CI at the version file too.** Every official setup action has a `*-version-file` input (see the table). Use it instead of repeating the version in the workflow.
- **When a platform ignores the version file, pin it there and say so.** For example, Vercel takes the Node major from `engines.node` in `package.json` or from the project settings, and Heroku takes Ruby from the `ruby` line in the `Gemfile` (`ruby file: ".ruby-version"` makes it read the file). Set the platform to the same version and add a comment above `idiomatic_version_file_enable_tools` in `mise.toml` saying where the second copy lives. Version files do not reliably support comments.
- **Bumping a runtime is a one-file change.** Edit the version file, run `mise install`, and commit with a message that says why the version changed. `mise use` writes to `mise.toml`, so only use it for tools that live there.

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
description = "PostgreSQL, API and web in watch mode, one dekit task each"
depends = ["env:check"]
raw = true
run = "dekit"

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

# CI runs these package.json scripts directly; the tasks are the development entry point.
[tasks.lint]
run = "bun run lint"

[tasks."lint:staged"]
# For the pre-commit hook. mise appends trailing arguments to the command.
run = "bun x biome check --write --no-errors-on-unmatched"

[tasks.test]
run = "bun run test"

[tasks."db:studio"]
description = "Database GUI"
raw = true
run = "bunx drizzle-kit studio"
```

Things worth knowing:

- **`run` accepts a string, a list or a multi-line script.** Lists run in series. For scripts, start with `set -e` so the task fails at the first error.
- **`depends` runs in parallel.** When order matters, chain the dependencies (`db:seed` depends on `db:migrate`, which depends on `db:wait`) instead of listing them all in one `depends`.
- **Trailing arguments are appended to the command.** `mise run lint:staged file.ts` runs `biome check --write --no-errors-on-unmatched file.ts`, which is how lefthook passes the staged files.
- **Interactive tasks need `raw = true`.** mise captures task output by default; anything that draws a UI or asks for confirmation (dekit, database GUIs, Playwright's UI mode) needs the raw terminal.
- **`sources` and `outputs` give a cheap `make`-style skip.** If no source changed, the task does not run. Use it for generated code and single-package builds. Do not use it in a repository where moon owns the cache: two caches that disagree is worse than one.
- **Long scripts become files in `mise-tasks/`.** An executable with a shebang and a `#MISE description=` comment is a task. Real bash or Python with arguments and a linter beats ten lines of TOML-escaped shell.
- **Write inline scripts in POSIX shell.** Tasks run in `sh`, not in each developer's login shell.
- **Comment the non-obvious.** A task file is read by the next person at 6pm on a Friday when the database is broken. Say why a task exists and when to reach for it, not what the command does.

### Tasks CI runs

Many CI runners and deployment platforms do not allow installing mise. So anything CI or a deployment runs is **not** defined in mise. It lives in the ecosystem's standard file, which every runner can execute with only the official setup action:

| Ecosystem | Where CI commands live | CI calls |
|---|---|---|
| JavaScript / TypeScript | `scripts` in `package.json` | `bun run lint`, `npm run test` |
| Ruby | Rake tasks and `bin/` scripts | `bin/rspec spec` |
| Anything else | An executable in `bin/` | `bin/lint` |

```jsonc
// package.json
{
  "scripts": {
    "lint": "biome check .",
    "typecheck": "tsc --noEmit",
    "test": "bun test apps packages",
    "build": "vite build"
  }
}
```

The matching mise tasks are one-line wrappers (`run = "bun run lint"`), so the command is defined once and both sides stay in sync.

Rules:

- **Development only uses mise tasks.** Developers, hooks, dekit tasks and agents call `mise run lint`, never `bun run lint`. The mise task is where the environment, the `.env` and the `depends` chain come from.
- **Development-only tasks live only in mise.** `setup`, `dev`, `db:up`, `db:reset` and `lint:staged` need no standard script.

### Standard task names

Use the same names in every project so that nobody has to read `mise.toml` to get started:

| Task | Purpose |
|---|---|
| `setup` | Fresh clone to running stack. Safe to rerun: it never overwrites an existing `.env`, migrations are incremental and seeds only add what is missing. |
| `dev` | Start every development process through dekit. |
| `lint` / `lint:fix` | Linting and formatting, check and autofix. |
| `typecheck` | Static type checks (`tsc --noEmit`, Sorbet, mypy...). |
| `test` | Fast test suite with no external infrastructure beyond the database. |
| `e2e` | Browser or end-to-end suite. Boots what it needs. |
| `ci` | Runs locally what CI runs, by calling the same standard scripts. In a moon repository, wraps the `ci` script that runs `moon ci`. |
| `db:up` / `db:down` | Start and stop the service containers on their own. |
| `db:migrate` / `db:seed` | Apply migrations, load fixtures. |
| `db:reset` | Drop the volume, migrate, seed. The database back to its initial state. |
| `reset` | Everything `setup` does from a clean slate: no containers, no volumes, no stray processes. |

**`setup` and `reset` are idempotent.** Running either twice in a row leaves the machine in the same state as running it once, and running it on a half-broken checkout repairs it instead of failing. In practice: guard anything that creates a file (`[ -f .env ] || cp .env.example .env`), rely on installers that are no-ops when nothing changed (`bun install`, `bundle install`, `lefthook install`), keep migrations incremental and seeds additive, and in `reset` tear down with commands that tolerate absence (`docker compose down --volumes --remove-orphans` succeeds when nothing is running).

Group related tasks with a colon prefix (`db:`, `docker:`, `test:`), and keep the plain name (`test`) for the thing you run most.

## Docker: local services

Docker runs the infrastructure a project depends on locally: PostgreSQL, Redis, Elasticsearch, Mailpit. The application itself runs on the host with the runtime mise installs, which keeps it fast and keeps debugging simple. Our [Docker guide](/guides/development/docker-guide.md) describes this "services only" setup in depth, along with the "services + application" alternative for projects that cannot run natively.

In the context of this guide, Docker is a dependency of mise tasks:

```yaml
# .dockerdev/compose.yml
name: acme

services:
  postgres:
    image: postgres:18
    # Credentials must match DATABASE_URL in the root .env (see .env.example).
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

- **Services only by default.** The application runs in a container only when the project cannot run natively (see the [Principles](#principles)). Before writing a `Dockerfile` for the application in development, read the Docker guide and make sure you need it.
- **Keep it in `.dockerdev/`**, away from any production `Dockerfile` in the root.
- **Set `name`** so containers and volumes are not called after the directory, which is `dockerdev` for every project.
- **Add a `healthcheck` to every service** and start them with `docker compose up --detach --wait`, so the task that follows (`db:migrate`) does not race the database.
- **Pin image versions** the same way you pin runtimes: `postgres:18`, not `postgres:latest`. Match the version the project runs in production, down to the extensions.
- **Wrap every `docker compose` call in a mise task.** Nobody should have to remember the `-f .dockerdev/compose.yml` flag. `db:up`, `db:down`, `db:reset` and a foreground `dev:db` for the dekit task cover the usual needs.
- **Connection strings live in `[env]` or `.env.example`** next door, so a fresh clone is still one `mise run setup`.
- **Volumes are disposable.** `db:reset` drops them and rebuilds from migrations and seeds. If losing a local volume would hurt, the seeds are incomplete.

## lefthook: Git hooks

[lefthook](https://lefthook.dev/) manages Git hooks from a `lefthook.yml` committed to the repository, so that checks run automatically before committing. It is a single Go binary, so it works the same for a Rails, Next.js or Python project, and it runs jobs in parallel.

### Setup

Add it to `[tools]` in `mise.toml`, and make `mise run setup` call `lefthook install`. That writes the hooks into `.git/hooks`, which is local to each clone, so the install step has to run on every machine. Putting it in `setup` is the way to make sure nobody has to remember. Do not put it in a `postinstall` script: that runs on every dependency install, including in CI and in image builds, where hooks should not be installed. `setup` is a development-only task that CI never calls.

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

The four features this config relies on:

- **`parallel: true`.** The linter, the type checker and the formatter run at the same time to speed up checks.
- **`glob` + `{staged_files}`.** The job only runs when matching files are staged, and only receives those files. Touching a README does not trigger a type check.
- **`stage_fixed: true`.** Autofixes get staged, so the commit contains the fixed code instead of failing and making you re-add everything.
- **`skip: [merge, rebase]`.** Hooks do not run on every commit of a rebase, and formatting a merge commit does not rewrite files you did not touch.

Conventions:

- **Hooks call mise tasks.** When the lint command changes, `lefthook.yml` stays correct. lefthook never defines real work.
- **`pre-commit` must be fast.** Lint and format staged files, type-check when it takes seconds. A test suite is `pre-push`.
- **`pre-push` runs the tests.** Unit tests before end-to-end. If the end-to-end suite takes minutes and CI already gates merges on it, leave it out of the hook.
- **Do not validate commit messages in a hook.** Our [Git guidelines](/guides/development/git-guidelines.md) only enforce the message format on the squashed commit, and intermediate commits are free-form.
- **Use the `jobs` syntax.** The older `commands` map still works in lefthook 2; do not rewrite a working config for it, but new files use `jobs`.

### Day to day

- `lefthook run pre-commit --all-files` runs a hook by hand on the whole repository. CI does not run hooks: it calls the [standard scripts](#tasks-ci-runs) the hooks' mise tasks wrap.
- `LEFTHOOK=0 git commit` or `git commit --no-verify` skips the hooks. CI still runs every required check.
- Personal overrides go in a git-ignored `lefthook-local.yml`, which merges into the main file. Skipping the end-to-end suite on push because you are on a train is a valid use:

```yaml
# lefthook-local.yml
pre-push:
  jobs:
    - name: e2e
      skip: true
```

## dekit: development processes

Your application is not one process. API, front end, worker, CSS watcher, the service containers. Six terminal tabs lose track of which is which and one crashes silently; `concurrently` interleaves everything into one stream and cannot restart just the worker; tmux is great if everyone on the team knows tmux.

[dekit](https://github.com/pvolok/dekit) is a process manager with a TUI: a list of tasks on the left, the selected task's output on the right. Each keeps its own scrollback, each can be started, stopped and restarted on its own, and the output pane is interactive, so a dev server asking "port 3000 in use, use 3001?" can be answered.

dekit is the successor of mprocs, from the same author. It keeps the mprocs interface and adds three things mprocs did not have:

- **A runner that outlives the terminal.** Each project's tasks belong to a background process, not to the window that started them. Close the terminal and they keep running; `mise run dev` opens the console on them again.
- **Dependencies and ready checks.** The API waits until PostgreSQL answers instead of crashing on its first connection and being restarted by hand.
- **A command line for everything the console does**, with JSON output, so a coding agent can read a task's output or restart it and wait until it is back up, instead of starting a second dev server next to yours.

### Configuration

```yaml
# dekit.yaml
# Tasks for `mise run dev`. Each task runs its mise task instead of repeating the
# command, so this file stays correct when the tasks change and every process
# still gets the root .env that mise injects.
# Services: the db task owns the container (see "Where the services go").
defaults:
  scrollback_len: 10000

tasks:
  db:
    cmd: mise run dev:db
    # Dependents wait until PostgreSQL answers, not just until the container is up.
    ready: {cmd: mise run db:wait, interval: 2s, timeout: 60s}
    # The task owns the container, so stop it the way it was started.
    stop: {cmd: mise run db:down}
  migrate:
    # A job runs to completion; tasks that depend on it start once it exits with 0.
    type: job
    cmd: mise run db:migrate
    deps: [db]
  api:
    cmd: mise run dev:api
    deps: [db, migrate]
    autostart: true
  web:
    cmd: mise run dev:web
    autostart: true
  # No autostart: select it and press `s` when you need it.
  studio:
    cmd: mise run db:studio
```

Conventions:

- **Start it through `mise run dev`**, a task with `run = "dekit"` and `raw = true`. With no command, `dekit` starts the runner and the `autostart` tasks when they are not running, and opens the console either way. Going through mise keeps any `depends` the task declares, like an `.env` drift check.
- **Tasks call mise tasks**, for the same reason hooks do. Split `dev` into `dev:db`, `dev:api` and `dev:web` tasks and give each dekit task one of them. Because every task runs mise when it starts, restarting a task also picks up a changed `.env`, even in a runner that has been up for days.
- **`cmd` is not a shell.** dekit runs it as a program and its arguments: `mise run dev:api` works, `cd api && bun dev` is a config error. Anything that needs a pipe, `&&` or a variable belongs in the mise task.
- **Let `deps` and `ready` do the ordering.** Put `autostart: true` on the tasks you work on (`api`, `web`). `dekit up` starts what they depend on first, and a `ready` check holds the dependents until it passes. Steps that run once and finish, like migrations, are `type: job`. No `sleep 5`, no "wait for the database, then press `r` on the API".
- **Optional tasks have no `autostart`.** In dekit that is the default, the opposite of mprocs. Database GUIs, Storybook, mobile emulators, the type checker in watch mode: present in the list, started with a keystroke instead of found with a README grep.
- **The default stop is usually right.** dekit sends `SIGTERM` to the task's whole process group, so watchers and bundlers die with their parent instead of staying alive and holding ports. Override it only when a tool needs it: `stop: SIGINT` for one that only cleans up on Ctrl+C, `stop: {cmd: ...}` for containers.
- **Key bindings are personal.** They live in your own `~/.config/dekit/config.yaml`, never in `dekit.yaml`, so a project cannot rebind your keys.
- **For multi-directory setups** set `cwd` on the task. It defaults to the project root (the directory that holds `dekit.yaml`), and relative paths resolve from the file that declares them.

### The runner

The runner changes how a dev session ends. Closing the terminal no longer stops anything, so stop on purpose:

- **`q` in the console asks how to quit.** `q` again stops every task and the runner, and remembers which tasks were running; the next `mise run dev` brings those back. `d` detaches and leaves everything running. `x` stops without remembering, so the next start begins from `dekit.yaml`.
- **`dekit down`** from any terminal inside the project does the same as `q` `q`.
- **Quit with `q` `q` at the end of the day**, unless you mean to leave the stack running. A forgotten runner keeps holding ports and the database container, and the next person to debug "port 5432 is already in use" is you.
- **A running runner keeps the `dekit.yaml` it started with.** After pulling or switching branches, the console's header says the file changed; accept the reload there or run `dekit reload`.

### Where the services go

Two options for the containers, both fine:

- **A `db` task running `docker compose up` in the foreground** (above). Logs are one keypress away, the `ready` check gates every task that needs the database, and `dekit down` stops the stack with everything else. Our default: a project's dev session and its database start and stop together.
- **`docker compose up --detach` in `setup` and `db:up`, no task.** Services outlive the dev session and are shared by anything else that needs them, which you want when you restart the runner itself often or several projects use the same containers. Keep a `logs` task without `autostart` for when something is wrong.

Pick one per project and say which in a comment at the top of `dekit.yaml`.

### Keys

Document these in the project README, since they are the first thing a new team member needs. `?` inside dekit shows the full keymap.

| Key | Action |
|---|---|
| `j` / `k` | Select the next or previous task |
| `C-a` | Move focus between the task list and the task output |
| `s` | Start the selected task |
| `x` / `X` | Stop the selected task (soft / kill) |
| `r` / `R` | Restart the selected task (soft / force) |
| `z` | Zoom the selected task's output |
| `v` | Copy mode, to scroll and select output |
| `q` | Quit menu: `q` stops everything, `d` detaches and leaves it running |

### From the command line

Every command acts on the runner of the project you are in, whether or not the console is open:

```bash
dekit ls                          # every task and its state
dekit why api                     # why a task is, or is not, running
dekit screen api                  # the task's current output
dekit restart api --wait          # restart and return once it is ready again
dekit down                        # stop everything for the day
```

`--wait` returns once the task passes its `ready` check, and when it fails it says why and prints the end of the task's output. This is the command to give a coding agent (see [Agent rules](#agent-rules)): it can check on and restart the processes you already have, instead of starting its own copy of the dev server.

### Coming from mprocs

mprocs 0.9.6 was the last mprocs release; dekit replaced it in September 2026. For a project that still uses mprocs:

1. In `mise.toml`, replace `mprocs = "0.9.6"` with `dekit = "0.10.3"`.
2. As a stopgap, change the `dev` task to `run = "dekit mprocs"`. It runs the existing `mprocs.yaml` unchanged, with the classic keys and without the runner. A `Procfile.dev` (Rails 7+ `bin/dev`) keeps working the same way, with `dekit mprocs --procfile Procfile.dev`.
3. Convert `mprocs.yaml` to `dekit.yaml`, then set the `dev` task back to `run = "dekit"`:
   - `procs:` becomes `tasks:`, and each task is a mapping with a `cmd`: `shell: "mise run dev:api"` becomes `cmd: mise run dev:api`.
   - mprocs started every process; dekit starts only the tasks with `autostart: true` and what they depend on. Add `autostart: true` to the main tasks and remove every `autostart: false`.
   - Drop `stop: {send-keys: ["<C-c>"]}` workarounds: dekit's default signal already reaches the whole process group. Where you still need one, `send-keys` is `keys` and `hard-kill` is `SIGKILL`.
   - `autorestart: true` becomes `autorestart: on-failure`, and the top-level `scrollback` becomes `scrollback_len` under `defaults`.
   - Replace `<CONFIG_DIR>` in `cwd` with a relative path.
   - Add `deps` and `ready` where tasks used to race each other.
   - Delete `mprocs.yaml` and remove `mprocs.log` from `.gitignore`.

The upstream [Coming from mprocs](https://dekit.run/docs/start/from-mprocs) page lists the remaining differences.

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

Workspaces solve dependency resolution, not builds. `bun run --filter '*' build` rebuilds everything every time and does not know that `packages/types` must build before `apps/api`. That is fine for a few packages. When the repository has many packages and CI runs on every pull request, the build becomes slow, and that is the problem [moon](#moon-monorepo-task-graph) solves.

## moon: monorepo task graph

[moon](https://moonrepo.dev/) is a task runner and build system for monorepos, in the same category as Turborepo and Nx. Where mise tasks and workspace scripts are a flat list, moon knows which project depends on which, hashes inputs and outputs to skip work that has not changed, and can run only what a change affected.

It is the heaviest tool in this guide: `.moon/workspace.yml`, `.moon/toolchains.yml`, inherited tasks in `.moon/tasks.yml` and a `moon.yml` per project, plus the time needed to get `inputs` right. **Do not adopt it on a small repository.** Bun workspaces plus mise tasks cover most of our monorepos. Adopt it when:

- CI is slow enough that people stop waiting for it.
- There are enough packages that build order is a source of bugs.
- The repository is polyglot enough that `bun run --filter` stops covering it.

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
# No versions here on purpose: the standard version files own them. mise (locally)
# and the setup actions (CI) read those files and put the binaries on PATH.
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
      - "/.nvmrc"
      - "/.bun-version"
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

### What moon adds

1. **The graph is explicit.** `deps: ["^:build"]` declares that a project's build needs the builds of its dependencies first. No shell script hardcodes the build order.
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

**mise owns the toolchain, moon owns the graph.** mise already has to exist for the CLIs moon does not know about. moon itself is the exception: CI runs it too (see [Tasks CI runs](#tasks-ci-runs)), so it is a dev dependency in the root `package.json` (`@moonrepo/cli`) instead of a mise tool. Leave versions out of `.moon/toolchains.yml` so moon uses whatever is on `PATH`.

**Calls flow in one direction only:**

```
mise run test  →  moon run :test --affected  →  bun test  (package.json script)
bun run ci     →  moon ci                    →  bun test  (CI, no mise)
```

Never the reverse. A `moon.yml` that shells out to `mise run` nests the two runners, and mise's `sources`/`outputs` skipping then fights moon's cache.

**Two correctness gotchas that follow from this split:**

- moon hashes the toolchain version into its cache key only when it manages the toolchain. Since mise does, moon cannot see a Node bump and will happily replay a cache entry built with the old version. Fix: `/mise.toml` and the runtime version files (here `/.nvmrc` and `/.bun-version`) are inputs of every inherited task, as in `.moon/tasks.yml` above.
- mise exports env vars into the shell and moon inherits them, but moon does not hash what it was never told about. Any env var that changes a task's output gets declared in the task's `env`.

**CI calls moon through a standard script.** A `ci` script in the root `package.json` runs `moon ci`, and `mise run ci` wraps that same script locally:

```yaml
steps:
  - uses: oven-sh/setup-bun@v2
    with:
      bun-version-file: .bun-version
  - run: bun install   # dependencies, plus moon itself
  - run: bun run ci    # → moon ci
```

## mani: multiple repositories

Everything so far assumed one repository. Client work often does not: a backend, a mobile app, an admin panel, each with its own history, access and deployment. A monorepo is not on the table, but you still want to ask cross-cutting questions ("which of these have uncommitted changes?", "update the CI workflow in all of them") and you want a new person to get the whole working set on disk with one command.

[mani](https://manicli.com/) is a small Go CLI for exactly this: a declarative list of repositories plus tasks you can run across them. We keep it in a small **meta repository** that holds the `mani.yaml`, the shared `.dockerdev/` services and the `dekit.yaml` that starts everything.

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
    desc: Run services, backend and mobile in one dekit console; q q stops everything
    target:
      projects: [acme]
    # tty hands the terminal to dekit. tty tasks run through the developer's
    # login shell, so the cmd must be a single plain command.
    tty: true
    cmd: dekit
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
mise install        # mani, dekit, bun...
mani sync           # clones every project into its path
mani run setup      # tasks with a target run without flags
mani run status -a  # tasks without a target need one: -a, -t backend, -p mobile
mani exec -t active "git log -1 --format=%cr"
mani tui            # browse projects and tasks interactively
```

Conventions:

- **mani never defines real work.** It fans out a command that already exists in each repository (`mise run setup`, `git pull`). The work lives in the child repository's `mise.toml`.
- **The meta repository is the project's front door.** Its README carries the three commands, and its `mise.toml` pins mani and dekit. Each child repository keeps its own `mise.toml`, `lefthook.yml` and CI.
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
- Development processes run in dekit. Check them with `dekit ls` and `dekit screen <task>`, restart one with `dekit restart <task> --wait --wait-timeout 90s`, and never start a second dev server.
- Commits go through lefthook. Do not pass `--no-verify`.
- Internal packages are referenced as `workspace:*`, never a published version.
```

## How they compose

```
mani            → across repos:  sync, fan out a command that already exists
  └── mise      → per repo:      runtimes, env vars, the entry-point commands
        │                         (Docker Compose holds the backing services)
        ├── lefthook  → at commit:    fast checks on staged files, via mise tasks
        ├── dekit     → while coding: the multi-process dev loop, via mise tasks
        └── workspaces → in repo:     packages resolve to each other
              └── moon → CI & local:  the task graph, the cache, affected-only
        └── CLAUDE.md (root + per area) → for the agent: which command for which intent
```

And the overlap trap, stated as who owns what:

- **`package.json` scripts** are the primitive. One package, one command, no cross-package knowledge. Everything else calls these.
- **moon** owns the graph and the cache, and nothing else. If a task depends on another package's output or benefits from caching, it belongs to moon. CI runs it. It does not own the toolchain.
- **mise** owns runtimes, env vars and the human-facing entry points. It holds every version number, directly or through the standard version files it reads, and it installs every other tool here. Its tasks are thin wrappers (`mise run dev`, `mise run test`) and the only way developers run commands. CI never calls them. It is the thing you tell a new person about.
- **Docker Compose** owns the services, and only the services.
- **lefthook** never defines real work. It calls mise tasks, on staged files, fast.
- **dekit** never defines real work. It runs mise tasks, in order, one each.
- **mani** never defines real work. It fans out a command that already exists.
- **`CLAUDE.md`** never defines work at all. It tells the agent which of the above to use for which intent.

One command per intent, one owner per command.

The project README repeats the three commands and the dekit keys, then points here. A minimal template:

```markdown
## Development

Requirements: [mise](https://mise.jdx.dev/) and Docker.

    mise install    # Bun, Node, lefthook, dekit
    mise run setup  # .env, dependencies, PostgreSQL, migrations, seeds
    mise run dev    # PostgreSQL + API + web, one task each

`setup` is safe to rerun. When the database is confusing, `mise run db:reset`.
Inside `dev`: `j`/`k` select a task, `r` restarts it, `x` stops it, `q` `q` stops everything.
Closing the terminal leaves the tasks running; `mise run dev` reopens them.
```

Files a standard project commits:

```
mise.toml               tools, env, tasks
package.json etc.       scripts CI runs, wrapped by mise tasks
.ruby-version etc.      runtime versions, read by mise, CI and deploys
.env.example            every variable, with safe local defaults
.dockerdev/compose.yml  local services
lefthook.yml            hooks that call mise tasks
dekit.yaml              tasks that call mise tasks
CLAUDE.md               global rules and entry points
```

And git-ignores:

```
.env
mise.local.toml
lefthook-local.yml
```

## Adoption order

Starting from a normal repository, in the order a growing codebase starts to hurt:

1. **mise** first, always. Highest value, lowest cost, reversible with one `rm`.
2. **Docker Compose** for the services, the moment the project needs a database.
3. **lefthook**. Half an hour, pays back the first time it catches a broken commit.
4. **dekit** when you catch yourself with four terminals open. Fifteen minutes.
5. **Workspaces** when you have a second package that is not a fork of the first.
6. **moon** only when the build is slow enough to hurt. Not before.
7. **mani** only when you genuinely have many repositories to herd.
8. **Agent rules** any time after step 1. They get better as the steps above give them real commands to point at.

Six small files, each about twenty lines, each doing one thing, each deletable on its own. The alternative is not zero config; it is config that lives in people's heads and in a stale README.

## New project checklist

- [ ] Runtimes are pinned to exact versions in their standard version file (`.ruby-version`, `.python-version`, `go.mod`, `.nvmrc`, ...), and `mise.toml` enables them with `idiomatic_version_file_enable_tools`.
- [ ] `mise.toml` pins exact versions for every other CLI tool, including lefthook and dekit. No runtime appears both in a version file and in `[tools]`.
- [ ] CI and the deployment platform read the same version files, or the second copy is documented in `mise.toml`.
- [ ] `.env.example` lists every variable and `mise.toml` loads `.env` with `_.file`.
- [ ] `setup`, `dev`, `lint`, `test`, `db:up`, `db:reset` tasks exist and have descriptions.
- [ ] Every command CI or the deployment runs is a standard script (`package.json`, Rake, `bin/`) that a mise task wraps. CI never installs mise.
- [ ] `setup` and `reset` are idempotent: running either twice leaves the machine in the same state as running it once. `setup` runs `lefthook install`.
- [ ] `.dockerdev/compose.yml` holds services only, sets `name`, pins images and has health checks.
- [ ] `lefthook.yml` lints staged files on commit and runs tests on push, through mise tasks.
- [ ] `dekit.yaml` gives each process a task that calls a mise task, `autostart` on the main ones, `deps` and `ready` instead of races, and says whether services live in a task or detached.
- [ ] `.gitignore` covers `.env`, `mise.local.toml`, `lefthook-local.yml`.
- [ ] The README starts with the three commands and the dekit keys, and describes what the project is rather than how to run it.
- [ ] `CLAUDE.md` names the real entry points and never a command that does not exist.
- [ ] Workspaces: internal packages use `workspace:*`, shared versions use a catalog, `package.json` scripts stay the primitive.
- [ ] moon (if adopted): no versions in `.moon/toolchains.yml`, `/mise.toml` is an input of inherited tasks, `@moonrepo/cli` is a root dev dependency, a `ci` script runs `moon ci` and `mise run ci` wraps it, no `moon.yml` calls `mise run`.
- [ ] Multi-repository project: a meta repository with `mani.yaml`, tags by role and state, `shell: bash -c`, tasks that only fan out.
