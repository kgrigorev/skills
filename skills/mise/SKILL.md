---
name: mise
description: Manage dev tools, env vars and tasks with mise. Use in any repo with a mise config (mise.toml, mise.<env>.toml, .tool-versions), or when you pin or bump a tool version, run commands or tasks through mise, set project env vars or secrets, decide whether logic belongs in a mise task or the ecosystem's own runner, or wire up `mise mcp`.
---

# mise

Checked against mise `2026.11.3` (2026-11-06). mise ships several releases a week. When
`mise --version` is newer and a claim here disagrees with `mise <cmd> --help` or
`mise config explain`, the CLI wins.

## Steps

1. **Orient.** Run `python3 <this-skill-dir>/scripts/mise_env_report.py [dir]`: version,
   trust, config files, tools, tasks, env, doctor problems in one pass. Done when you know
   which config file owns each tool and task you will touch.
2. **Trust.** An untrusted config makes `mise ls`/`env`/`tasks` fail, and `mise exec`,
   `mise run`, `mise install` and `mise watch` trust it silently, which runs the repo's hooks,
   `_.source` scripts and tasks. In a repo the user did not author, ask before the first of
   those commands. Inspect without trusting via `MISE_SAFE=1 mise <cmd>`. Done when the user
   approved trust, or the repo is theirs.
3. **Change.** Write config through the CLI: `mise use tool@ver` (pin + install),
   `mise set KEY=val`, `mise tasks add name -- cmd`. Hand-edit only what the CLI can't
   express. Every task you add _delegates_ (see below).
4. **Verify.** Done when `mise doctor` exits 0, `mise tasks validate` passes, and every task
   you added or changed is green through `mise run <task>`.

## Run tools through `mise exec` and `mise run`

`mise activate` hooks the shell prompt. Your Bash tool has no prompt, so activation never
fires there and pinned tools and `[env]` are missing. Run everything through mise instead:

```bash
mise run test                     # a task: tools + env loaded, missing tools installed
mise x -- go test ./...           # one ad-hoc command (x = exec)
mise x node@24 -- node app.js     # ad-hoc version, config untouched
mise run lint test -o summary     # one line per passing task, full output of failures
```

Inside a task, tools and env are already loaded: call `go`, `node`, `uv` directly. For a
persistent `PATH` across many commands, `eval "$(mise activate bash --shims)"`.

## The boundary: mise is the front door, runners own the logic

mise owns three things: tool versions (`[tools]`), environment and secrets (`[env]`), and the
few _front door_ verbs a human or CI types (`mise run test`, `dev`, `lint`, `build`).
Ecosystem runners (`package.json` scripts, `uv run`, `cargo`, `go`, `nx`, `scala-cli`,
`cmake`) own build, test and lint logic. A mise task _delegates_ to the runner in one line:

```toml
[tasks.test]
run = "uv run pytest"
[tasks.build]
run = "nx run-many -t build"   # nx keeps its graph, cache and affected detection
```

Delegation keeps the runner's own features (nx cache, npm lifecycle hooks, cargo profiles)
and keeps the commands where that ecosystem's contributors look for them. mise never falls
through to `npm run x` on its own, so every delegation is explicit. Logic lives in a mise
task only when it has no ecosystem home: cross-language glue, CI orchestration, small repos
without a runner. Per-ecosystem split, exceptions and anti-patterns:
[tasks-and-boundary.md](references/tasks-and-boundary.md).

## Rules for editing config

- **`use` adds, `install` installs.** `mise install` only installs what config already pins;
  `mise use` writes the pin and installs. asdf users expect the reverse.
- **Pin to the precision the repo needs.** `node = "24"` resolves to the newest _installed_
  24.x. For reproducible teams and CI, commit `mise.lock` (`mise lock`); bump with
  `mise up --bump` (config) or `mise lock --bump` (lockfile only).
- **New releases wait 24 hours.** The default `minimum_release_age` hides versions younger
  than a day on every backend; a tool whose only release is that new reports "no versions
  found". Pin the exact version to skip the wait.
- **Tool options are checked.** An option the backend doesn't read fails the install. Check
  keys with `mise config explain`.
- **Idiomatic version files are opt-in.** `.nvmrc`, `.python-version`, `go.mod`,
  `package.json` count only for tools listed in `idiomatic_version_file_enable_tools`.
  `.tool-versions` is always read.

## Reference map

- Recipes for Go, Node/Bun, nx, Python + uv, Rust, C/C++, Scala/JVM, and which backend to
  pick → [languages.md](references/languages.md)
- Task syntax, arguments, deps, caching, agent-friendly run flags, the per-ecosystem split →
  [tasks-and-boundary.md](references/tasks-and-boundary.md)
- Config files and precedence, `[env]` and secrets, environments, trust, safe mode,
  lockfiles, hooks, templates → [configuration.md](references/configuration.md)
- `mise mcp` setup and what it can do → [mcp-server.md](references/mcp-server.md)
- Env not loading, wrong version, install failures, direnv, IDE, Windows →
  [troubleshooting.md](references/troubleshooting.md)
