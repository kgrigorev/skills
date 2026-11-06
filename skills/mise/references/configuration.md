# mise configuration reference

Researched against mise `v2026.6.x`. Authoritative source:
<https://mise.jdx.dev/configuration.html> and `/configuration/settings.html`.

## Table of contents

1. [Config files and precedence](#config-files-and-precedence)
2. [Commit vs gitignore](#commit-vs-gitignore)
3. [The mise.toml sections](#the-misetoml-sections)
4. [`[tools]` in depth](#tools-in-depth)
5. [`[env]` — environment & secrets](#env--environment--secrets)
6. [Environments / profiles (`MISE_ENV`)](#environments--profiles-mise_env)
7. [Trust & the security model](#trust--the-security-model)
8. [Lockfiles (`mise.lock`)](#lockfiles-miselock)
9. [Hooks](#hooks)
10. [Templating (Tera)](#templating-tera)
11. [Settings reference (selected)](#settings-reference-selected)

---

## Config files and precedence

mise merges every config file it finds from the current directory up to the root, plus
global and system configs. **Higher in this list wins** (more specific overrides less
specific):

1. `mise.local.toml` — local developer overrides (**gitignore**)
2. `mise.<env>.local.toml` — local + env-specific overrides (**gitignore**)
3. `mise.<env>.toml` — env-specific shared config, e.g. `mise.ci.toml` (commit)
4. `mise.toml` — primary project config (commit)
5. `mise/config.toml`, `.mise/config.toml`, `.config/mise.toml`,
   `.config/mise/config.toml` — alternate project locations (commit)
6. `.config/mise/conf.d/*.toml` — fragments, loaded alphabetically (commit)
7. `~/.config/mise/config.toml` — global user config
8. `/etc/mise/config.toml` — system-wide

Legacy / idiomatic files also participate as fallbacks: `.tool-versions` (asdf format, fully
supported) and — only when explicitly enabled per tool — `.nvmrc`, `.node-version`,
`.python-version`, `.ruby-version`, `.go-version`, `.sdkmanrc`, `.java-version`.

**Platform-specific variants** (auto-enabled when `auto_env = true`): `mise.unix.toml`,
`mise.linux.toml`, `mise.macos.toml`, `mise.windows.toml`, and arch-qualified forms like
`mise.macos-arm64.toml`. Precedence low→high: `unix` < `{os}` < `{os}-{arch}` < explicit
`MISE_ENV` entries.

**Merge semantics:** `[tools]`, `[env]`, `[settings]` merge additively with child-overrides-
parent per key. `[tasks]` are replaced wholesale per task key (a child task fully replaces a
parent task of the same name — they are not deep-merged).

## Commit vs gitignore

| Pattern | Action | Why |
|---|---|---|
| `mise.toml`, `mise.<env>.toml`, alternate locations, `conf.d/*.toml` | **commit** | shared, reproducible |
| `.tool-versions` | **commit** | legacy version pins |
| `mise.lock` | **commit** | reproducible, checksum-verified installs |
| `mise.local.toml`, `mise.*.local.toml` | **gitignore** | per-dev overrides, may hold secrets |

Recommended `.gitignore`:

```gitignore
mise.local.toml
mise.*.local.toml
```

## The mise.toml sections

```toml
min_version = "2026.6.0"        # hard error if mise is older; { soft = "…" } only warns

[tools]                          # versions — see "in depth" below
node = "22"

[env]                            # env vars + dotenv + PATH — see "in depth" below
NODE_ENV = "development"

[settings]                       # mise behavior (see settings reference)
idiomatic_version_file_enable_tools = ["node", "python"]

[tasks.test]                     # tasks — see tasks-and-boundary.md
run = "uv run pytest"

[tool_alias.node.versions]       # version aliases (current syntax; old `[alias.node]` works)
my_lts = "20"

[hooks]                          # lifecycle hooks — see below
enter = "echo entering"

[vars]                           # template variables reusable in tasks/env
region = "eu-central-1"

[redactions]                     # secret masking in task output (see security)
```

Anything under a top-level `[_]` table is ignored by mise — a place for arbitrary metadata.

## `[tools]` in depth

```toml
[tools]
# simple pin
go = "1.26"
node = "22"            # = "latest matching 22"; resolves to latest INSTALLED match, not newest available
python = "3.12"
rust = "stable"

# table form with options
node = { version = "22", postinstall = "corepack enable" }
go   = { version = "1.26", postinstall = "go install golang.org/x/tools/cmd/goimports@latest" }

# multiple versions of one tool
python = ["3.12", "3.11"]

# backend-qualified tools (CLI utilities, not just runtimes)
"npm:prettier"        = "3"
"cargo:sqlx-cli"      = "latest"
"go:github.com/pressly/goose/v3/cmd/goose" = "latest"
"pipx:ruff"           = "latest"
"aqua:golangci/golangci-lint" = "latest"
```

Tool-table options worth knowing: `version`, `postinstall` (shell after install),
`os = ["linux","macos"]` (restrict by platform), `depends` (install ordering),
`install_env` (env vars set only during install — e.g. `GOPRIVATE`). Backends and
per-language specifics are in [languages.md](languages.md).

Version-spec forms: exact (`1.26.1`), partial (`1.26`, `22`), `latest`, `lts`, prefix ranges,
`ref:<git-ref>`/`tag:<tag>` for some backends, and aliases. `mise ls-remote <tool>` lists
installable versions.

## `[env]` — environment & secrets

mise sets these env vars when the directory is active (via `activate`) or for the duration
of a `mise exec`/`mise run`. Special `_.` keys are directives, not literal vars:

```toml
[env]
# literal vars
NODE_ENV = "development"
DATABASE_URL = "postgres://localhost/dev"

# load a dotenv file (STRING, never an array — array form crashes)
_.file = ".env"
_.file = { path = ".env.json", redact = true }     # JSON dotenv + mark all values secret

# prepend to PATH (config_root = dir containing the config file)
_.path = ["{{ config_root }}/node_modules/.bin", "{{ config_root }}/bin"]

# run a script and import the env vars it exports
_.source = "./scripts/load-secrets.sh"

# auto-create/activate a Python venv (non-uv projects) — see languages.md
_.python.venv = { path = ".venv", create = true }

# per-variable secret redaction
SECRET = { value = "…", redact = true }

# reference a value computed from a tool path (templating + tools = true)
UV_PYTHON = { value = "{{ tools.python.path }}", tools = true }
```

Enable shell expansion in values with `env_shell_expand = true` in `[settings]` if you need
`$VAR`/`$(cmd)` interpolation (off by default).

## Environments / profiles (`MISE_ENV`)

Layer alternate configs (dev/ci/prod) on top of the base `mise.toml`. Activate via:

```bash
mise -E ci install          # global flag, applies to all subcommands
MISE_ENV=ci mise run test    # env var
# or commit a .miserc.toml:    env = ["ci"]
```

`MISE_ENV=ci,test` activates multiple (last wins). With env `ci` active, precedence high→low:
`mise.ci.local.toml` > `mise.local.toml` > `mise.ci.toml` > `mise.toml`.

**Constraint:** `MISE_ENV` cannot be set *inside* `mise.toml` — it decides which files load
before any are parsed. Set it in the shell, CI, or `.miserc.toml`.

## Trust & the security model

mise will execute code from config (env scripts, hooks, `postinstall`, templates), so it
gates loading behind explicit trust to stop a freshly-cloned repo from running arbitrary
code.

- **Loads without trust:** `min_version`, `[tools]` with plain version strings/arrays, and
  `[tasks]` with no templates and no tool options — nothing there executes at load time.
- **Requires trust:** `[env]`, hooks, `[settings]`, aliases, templates, and tool *options*.

Commands:

```bash
mise trust                 # trust configs in this dir + parents
mise trust --all           # …everywhere up the tree
mise trust --show          # show trust status, change nothing
mise untrust               # revoke (future loads re-prompt)
```

Behavior by context:

- **Detected CI:** auto-trusts (unless paranoid mode). Standard CI "just works."
- **Non-interactive, non-CI** (IDE extensions, TTY-less scripts): mise can't prompt, so it
  **silently skips** untrusted config — no obvious error. Pre-run `mise trust`, or set
  `trusted_config_paths` globally.
- Denied-by-accident configs land in `~/.local/state/mise/ignored-configs/`; delete the
  symlink there to un-ignore.
- **Monorepo:** trusting the root implicitly trusts all descendant configs.

Global auto-trust (in `~/.config/mise/config.toml`):

```toml
trusted_config_paths = ["~/work/my-trusted-projects"]
# env: MISE_TRUSTED_CONFIG_PATHS (":"-separated). ["/"] disables trust entirely (not advised).
```

**Secret redaction:** mark env vars whose values must not appear in task logs.

```toml
redactions = ["API_KEY", "*_TOKEN", "SECRET_*"]   # exact names or globs
[env]
API_KEY = { value = "…", redact = true }
```

Redaction works by filtering task output line-by-line, so it requires non-`raw` task output
(`raw = true` tasks bypass it). View with `mise env --redacted`.

**Paranoid mode** (`MISE_PARANOID=1`): every config must be trusted (even otherwise-safe
ones), files are hashed to detect tampering, short-name community plugins are blocked
(full git URLs required), all fetches use HTTPS, and provenance is re-verified on every
install.

## Lockfiles (`mise.lock`)

Pins exact versions + SHA256/Blake3 checksums + download URLs + per-platform metadata for
reproducible, tamper-checked installs. **Not automatic** — generate with `mise lock`, then
mise keeps it current as tools change. Each config variant gets its own lock
(`mise.ci.toml` → `mise.ci.lock`).

Enable and enforce via `[settings]`:

```toml
[settings]
lockfile = true                 # read/update lockfiles (lets mise.toml hold loose specs, lock holds exact)
locked   = true                 # FAIL install if no pre-resolved entry for this platform → no upstream API calls
locked_verify_provenance = true # re-verify SLSA/cosign/minisign/GitHub attestations at install
```

`mise lock --platform linux-x64,macos-arm64` pre-resolves for CI platforms you don't build
on locally. `mise lock --minimum-release-age 90d` only locks versions older than N days
(supply-chain hardening). Commit `mise.lock`.

## Hooks

```toml
[hooks]
enter = "echo entering"                 # requires `mise activate`
leave = "echo leaving"                   # requires `mise activate`
cd    = "echo dir changed"               # requires `mise activate`
preinstall  = "echo before install"      # works without activate
postinstall = "echo after install"       # works without activate
enter = { task = "setup" }               # delegate a hook to a task

[[watch_files]]                          # requires `mise activate`
patterns = ["src/**/*.rs"]
run = "cargo fmt"
```

`enter`/`leave`/`cd`/`watch_files` only fire under `mise activate` (the shell-hook
mechanism). `preinstall`/`postinstall` fire during `mise install` regardless. Available hook
env vars include `MISE_PROJECT_ROOT`, `MISE_PREVIOUS_DIR`, `MISE_INSTALLED_TOOLS`.

## Templating (Tera)

mise renders config values through the Tera template engine. Common helpers: `{{
config_root }}` (dir of the config file), `{{ cwd }}`, `{{ env.FOO }}`, `{{ tools.python.path
}}` (needs `tools = true` on that value), `{{ vars.region }}` (from `[vars]`), `{{
exec(command="…") }}`. Use templates for paths and computed env; keep them simple — heavy
logic belongs in a task or script, not a template.

> Deprecation note: old Tera arg-functions for tasks (`{{arg()}}`, `{{flag()}}`) are
> deprecated in favor of the `usage` spec (see [tasks-and-boundary.md](tasks-and-boundary.md))
> and are slated for removal in late 2026.
