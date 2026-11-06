---
name: mise
description: >-
  Expert guidance for managing development environments with mise (mise-en-place) —
  pinning and bumping tool/runtime versions, configuring per-project environment variables
  and secrets, and wiring task entrypoints in mise.toml. Strongly prefer this skill on any
  mise-related work. Trigger on any mention of mise, mise.toml, .mise.toml,
  mise/config.toml, .config/mise/config.toml, mise.<env>.toml, .tool-versions, mise-en-place,
  `mise run`, or mise tasks — and whenever you are working in a directory containing a mise
  config and the task involves: pinning/bumping a runtime or CLI tool (Go, Node, Bun,
  Python/uv, Rust, JDK/Java/Scala, C/C++ build tools); bootstrapping or reproducing a dev
  environment; managing project env vars or secrets; defining or running tasks; deciding
  what belongs in mise versus npm/uv/cargo/nx/scala-cli scripts; or setting up the mise MCP
  server. Skip only for pure application-code bugs, UI work, or CI failures that make no
  reference to mise configuration.
---

# mise (mise-en-place)

**Researched against mise `v2026.6.x` (latest tested `v2026.6.11`, 2026-06-16).** mise uses
CalVer (`YYYY.MM.PATCH`) and releases several times per week, so commands evolve fast. If
something here conflicts with `mise --version` on the machine, trust the live `mise help
<cmd>` output and treat this skill as needing an update. Version-sensitive claims are
flagged inline with **(since vYYYY.MM)** where it matters.

mise is an all-in-one dev-environment manager that does **three** distinct jobs, often
confused with each other:

1. **Tool/runtime versions** — installs and pins Node, Python, Go, Rust, Java, etc., plus
   thousands of CLI tools, and puts the right versions on `PATH` per directory. (Supersedes
   asdf/nvm/pyenv/rbenv.)
2. **Environment variables** — sets per-project env vars and loads dotenv files, with
   secret redaction. (Supersedes direnv for most needs — do not run both; see
   [troubleshooting.md](references/troubleshooting.md).)
3. **Tasks** — a polyglot task runner (`mise run test`) with dependencies, file-watching,
   and up-to-date checks.

The single most important design question in any mise repo is **who owns what** between
mise and the ecosystem tools it manages (uv, npm/bun, cargo, nx, scala-cli, go). Get this
right and the repo stays clean; get it wrong and you duplicate logic in two places. The
doctrine below is the heart of this skill.

## When this applies — detecting a mise project

A directory is mise-managed if any of these exist (search the current dir and parents up to
the repo root):

- `mise.toml` (most common), `mise.local.toml`, `.mise.toml`
- `mise/config.toml`, `.mise/config.toml`, `.config/mise.toml`, `.config/mise/config.toml`,
  `.config/mise/conf.d/*.toml`
- `mise.<env>.toml` (e.g. `mise.ci.toml`, `mise.production.toml`)
- `.tool-versions` (legacy asdf format, fully supported)

Quick check: `mise config` lists every active config file and the project root; `mise tasks`
lists available tasks; `mise ls` shows active tool versions. Run these first to orient
yourself before editing anything.

## The boundary doctrine — who owns what

This is the rule that keeps mise repos maintainable. Internalize it before writing config.

**mise OWNS exactly three things:**

- **Tool & runtime versions** — the `[tools]` table. The pinned Node/Python/Go/Rust/JDK and
  the CLI tools (linters, formatters, codegen) the project needs.
- **Environment & secrets** — the `[env]` table, dotenv loading, `PATH` additions (e.g.
  `node_modules/.bin`), redactions.
- **Canonical, cross-ecosystem entrypoints** — the handful of verbs a human or CI types:
  `mise run test`, `mise run dev`, `mise run lint`, `mise run build`. These are the stable
  "front door" regardless of what language is underneath.

**Ecosystem runners OWN the actual build/test/lint logic:**

- `package.json` scripts (npm/pnpm/yarn/bun), `uv run …`, `cargo …`, `nx run-many …`,
  `scala-cli …`, `go test/build`.

**The connecting principle: mise tasks _delegate_, they do not _duplicate_.** A mise task
should be a thin wrapper that calls the native runner:

```toml
[tasks.test]
run = "uv run pytest"          # not a reimplementation of pytest invocation logic
[tasks.build]
run = "nx run-many -t build"   # nx still owns the graph, caching, affected detection
```

**Why delegate instead of moving logic into mise?** Two reasons. (1) The ecosystem tool
keeps its full feature set — nx's affected-graph, npm's lifecycle hooks, cargo's profiles —
which a reimplemented mise task would lose. (2) The team's existing muscle memory and CI
keep working; mise becomes an additive, uniform entrypoint rather than a migration.

**Important nuance (don't expect magic):** mise deliberately does **not** fall through to
`npm run <x>` when a task is undefined — the maintainer rejected transparent delegation
because delegated tasks would lose mise's feature set. So a mise task must *explicitly*
call the underlying tool (`run = "npm run build"`); there is no automatic proxy.

**When it IS fine to put logic directly in a mise task** (not just delegate):

- Small or polyglot repos with no established ecosystem runner.
- Cross-cutting glue that spans ecosystems (e.g. "regen protobufs, then build the Go server
  *and* the TS client").
- CI orchestration steps and one-off scripts.

**When to defer and keep mise thin:** mature ecosystems that already own their task graph —
**nx monorepos especially** (let nx run the graph), and repos with an established
`package.json` scripts convention the team relies on. Here mise should provision tools+env
and stay out of the runner's way.

Full per-ecosystem rules, the uv-vs-mise Python overlap, and anti-patterns are in
[tasks-and-boundary.md](references/tasks-and-boundary.md).

## Running tools as an agent — prefer `exec`/`run`, never rely on `activate`

This is the most common way agents get a mise repo wrong. There are four ways to invoke
mise-managed tools; they are **not** interchangeable for an automated, non-interactive
context:

| Mechanism | What it does | Use it when |
|---|---|---|
| `mise activate` | Shell hook; rewrites `PATH`/env **on every prompt** | Interactive human shells only (`.bashrc`/`.zshrc`). |
| `mise exec -- <cmd>` (`mise x`) | Runs one command with the right tools+env, no shell mutation | **Default for agents/scripts/CI** — ad-hoc commands. |
| `mise run <task>` | Runs a defined task with tools+env loaded (auto-installs first) | Anything that is (or should be) a task. |
| shims (`~/.local/share/mise/shims` on `PATH`) | Static per-tool launchers | IDEs, non-interactive login shells, when you need a persistent `PATH`. |

**Why this matters for you as an agent:** `mise activate` works by hooking the shell
*prompt*. Your Bash tool runs **non-interactive** shells with no prompt, so the hook never
fires, `PATH` is never rewritten, and tools appear silently missing. Do **not** write
`eval "$(mise activate bash)"` and assume tools are available. Instead:

```bash
mise exec -- go test ./...        # one-off command with Go on PATH + env loaded
mise x -- node --version
mise run test                     # preferred when a task exists
mise exec node@22 -- node app.js  # pin an ad-hoc version without touching config
```

If you genuinely need a persistent `PATH` for a sequence of commands in one shell, prepend
the shims dir or use `eval "$(mise activate bash --shims)"` (the `--shims` variant works in
non-interactive shells; plain `activate` does not). Details and the env-not-loading failure
mode are in [troubleshooting.md](references/troubleshooting.md).

## Everyday command cheatsheet

```bash
# Orient
mise config              # which config files are active + project root
mise ls                  # installed/active tool versions for this dir
mise ls --current        # only what's active here
mise tasks               # list tasks (also: mise tasks --json)
mise doctor              # diagnose problems (untrusted configs, PATH issues, …)

# Install / pin tools  (edit config + install in one step with `use`)
mise install             # install everything pinned in config
mise use node@22         # add/pin node 22 to the nearest mise.toml AND install it
mise use -g node@lts     # pin in the GLOBAL config (~/.config/mise/config.toml)
mise use python@3.12 uv@latest
mise unuse node          # remove a tool from config
mise ls-remote node      # list installable versions

# Run things
mise exec -- <cmd>       # run a command with tools+env (agent default)
mise run <task> [-- args]
mise run                 # interactive task picker (humans)
mise watch <task>        # re-run task on file change

# Upgrade / maintain
mise upgrade             # upgrade tools within pinned constraints
mise up --bump           # bump pinned versions in config to latest
mise self-update         # update mise itself
mise prune               # remove unused tool versions

# Trust & lock (security — see below)
mise trust               # trust the config files in this dir tree
mise lock                # generate/refresh mise.lock with checksums
```

**`mise install` vs `mise use`:** `install` downloads what's already pinned but does **not**
add new pins; `use` edits the config *and* installs. To add a tool, reach for `use`. (asdf
users expect the opposite — a common trip-up.)

## Editing config safely — trust and idempotency

- **Trust:** mise refuses to load "unsafe" config (anything with `[env]`, hooks, settings,
  templates, or tool *options*) until you run `mise trust`. Plain `[tools]` version strings
  and simple `[tasks]` load without trust. After you add an `[env]` block or a templated
  value to a previously-trusted file, the trust may need re-confirming. If config seems
  ignored, run `mise doctor` and `mise trust`. In detected CI mise auto-trusts; in
  non-interactive non-CI shells it silently skips untrusted config — pre-run `mise trust`.
- **Prefer `mise use` over hand-editing** when adding a tool: it writes correct TOML, picks
  a sensible version spec, and installs in one step, avoiding format mistakes.
- **Pin for reproducibility.** Loose specs (`node = "22"`, `"latest"`) are convenient but
  drift. For anything that must be reproducible (CI, teams), pin precisely and/or commit a
  `mise.lock` (`mise lock`) so installs are checksum-verified and don't hit upstream APIs.
- **Idiomatic version files are OFF by default.** mise does *not* read `.nvmrc`/
  `.python-version` unless you opt in per tool via
  `idiomatic_version_file_enable_tools = ["node", "python"]`. Migrators from nvm/pyenv hit
  this constantly.

Full config-file format, precedence/merge order, environments/profiles, hooks, lockfiles,
and the security model: [configuration.md](references/configuration.md).

## The mise MCP server

mise ships an MCP server (`mise mcp`, stable **since v2026.6.6**) that exposes the active
environment to an agent over stdio. It is useful for **introspection and task execution**,
not for installing tools. Resources: `mise://tools`, `mise://tasks`, `mise://env`,
`mise://config`; one working tool: `run_task`. (`install_tool` is defined but a no-op stub
— use the CLI for installs.)

To wire it into Claude Code, add to project `.mcp.json`:

```json
{ "mcpServers": { "mise": { "command": "mise", "args": ["mcp"] } } }
```

When MCP beats shelling out (structured env/task introspection, clean task-result capture)
and when the CLI is still required (install, version queries, any write): see
[mcp-server.md](references/mcp-server.md).

## Reference map — read the right file for the task

Load only what the task needs (progressive disclosure):

- **Setting up / editing tools for a specific language** (Go, Node/Bun/TS, nx monorepos,
  Python+uv, Rust, C/C++, Scala) → [languages.md](references/languages.md). Per-ecosystem
  `mise.toml` recipes, which *backend* to use, env vars mise sets, and the exact boundary
  with the native tool.
- **Deciding where logic lives** (mise task vs npm/uv/cargo/nx) or **authoring tasks** →
  [tasks-and-boundary.md](references/tasks-and-boundary.md).
- **Config files, precedence, env/secrets, profiles, trust, lockfiles** →
  [configuration.md](references/configuration.md).
- **Wiring or using the MCP server** → [mcp-server.md](references/mcp-server.md).
- **Something is broken, slow, or surprising** (env not loading, wrong version active,
  Windows, IDE, CI trust, direnv conflict) → [troubleshooting.md](references/troubleshooting.md).

## Helper script

`scripts/mise_env_report.py` prints a fast, structured snapshot of a mise project (version,
active configs, tools, tasks, trust status, doctor warnings). Run it to orient yourself in
an unfamiliar repo instead of issuing several `mise` commands by hand:

```bash
python3 <this-skill-dir>/scripts/mise_env_report.py [project-dir]
```
