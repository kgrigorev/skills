# mise troubleshooting, limitations & gotchas

Researched against mise `v2026.6.x`. Sources: `mise.jdx.dev/faq.html`,
`/troubleshooting.html`, `/dev-tools/comparison-to-asdf.html`, `/direnv.html`,
`/ide-integration.html`.

First move when anything is off: **`mise doctor`** (alias `mise dr`). It reports untrusted
configs, PATH problems, missing tools, and shim issues. Then `mise config` (what's loaded),
`mise ls --current` (what's active), `which -a <tool>` (PATH ordering).

## The big one: tools/env "missing" in non-interactive shells

**Symptom:** a script or agent runs `node`/`go`/etc. and gets "command not found," or env
vars from `[env]` aren't set — even though `mise.toml` pins them.

**Cause:** `mise activate` works by hooking the **shell prompt**. Non-interactive shells (agent
Bash tools, `bash script.sh`, CI steps, tmux panes, `.profile`/`.bash_profile`) have no
prompt, so the hook never fires and `PATH`/env are never modified. `mise activate` only
belongs in interactive RC files (`.bashrc`/`.zshrc`).

**Fix — use a mechanism that doesn't depend on the prompt:**

```bash
mise exec -- <cmd>                  # one command, tools+env loaded, no shell mutation
mise run <task>                     # tasks load tools+env automatically
eval "$(mise activate bash --shims)"  # persistent PATH for a non-interactive session
export PATH="$HOME/.local/share/mise/shims:$PATH"   # or add shims dir directly
```

Inside a mise *task* (file or TOML), tools+env are already loaded — no `mise exec` needed
there.

## Trust prompts silently swallowed

In non-interactive, non-CI contexts mise can't prompt for trust, so it **silently skips**
untrusted config (no clear error). Pre-run `mise trust` (or `mise trust --all`), or set
`trusted_config_paths` globally. Denied configs hide in
`~/.local/state/mise/ignored-configs/` — delete the symlink to recover. Detected CI auto-
trusts (unless paranoid mode). See [configuration.md](configuration.md#trust--the-security-model).

## Wrong version active despite mise

PATH-ordering issue — another manager or a system binary shadows mise. Diagnose with
`which -a <tool>` and `mise ls --current`. Ensure mise's activation/shims come first on PATH.
`MISE_ACTIVATE_AGGRESSIVE=1` forces mise's paths to the front as a workaround.

## Idiomatic version files ignored

`.nvmrc`, `.python-version`, etc. are **disabled by default**. Enable per tool:

```toml
[settings]
idiomatic_version_file_enable_tools = ["node", "python"]
```

Migrators from nvm/pyenv hit this constantly. `.tool-versions` (asdf format) *is* read without
opt-in.

## `mise install` didn't add my tool

`mise install` only installs what's already pinned; it does not add pins. Use `mise use
<tool>@<ver>` to add to config *and* install. (asdf's semantics are reversed — a common
trip-up.)

## `node = "22"` isn't the newest 22

A partial spec resolves to the latest **installed** match, not the latest *available*. Run
`mise install node@22` / `mise upgrade` / `mise up --bump` to advance. `mise up --bump` can get
confused by non-semver version strings.

## `_.file` array crash

`_.file` (dotenv) takes a **string**, not an array: `_.file = ".env"`. The array form crashes.
For multiple files, use multiple mechanisms or a `conf.d` fragment.

## Don't run mise + direnv together

mise's `[env]` replaces direnv's core use. Running both causes **PATH-ordering conflicts**
(both fighting over the same tool's path). The mise maintainers explicitly do not treat
mise/direnv incompatibilities as bugs and won't accept compatibility PRs. Pick one. Unrelated,
non-PATH env vars can coexist, but anything touching PATH is fragile. The old `use mise`
direnv function was removed.

## IDE integration

IDEs launched before mise is configured won't pick up env/PATH changes, and **arbitrary `[env]`
vars only reach the IDE if a shim is executed** (env doesn't propagate just by opening the
editor). Use shims for IDEs (`mise activate <shell> --shims`). VS Code on macOS doesn't read
login-shell profiles by default. Helpers: the `mise-vscode` and `intellij-mise` extensions;
JetBrains sometimes needs a symlink mimicking asdf's layout (`ln -s ~/.local/share/mise
~/.asdf`). Xcode needs the config added to build-phase Input Files.

## Windows

- **Native Windows: shims only.** `[env]` var support from `mise.toml` is not available
  natively — use `mise exec`/`mise run`. **WSL is fully supported.**
- Path-length limits bite — use a short `MISE_INSTALLS_DIR`.
- WSL shim leakage from Windows: set `appendWindowsPath = false` in `/etc/wsl.conf`.
- VS Code `spawn EINVAL`: set `windows_shim_mode` to `exe`/`hardlink`/`symlink`.
- PowerShell task support is comparatively recent and still maturing.

## Performance

`mise hook-env` runs on every prompt/`cd` (~5–10 ms typical). It can drag in large monorepos
with many tools or expensive `_.source` scripts. Profile with `MISE_TIMINGS=1 mise hook-env`.
mise is still much faster than asdf's shim model (no per-invocation shim overhead under
`activate`).

## Maturity edges to keep in mind

- Precompiled Python binaries "aren't 100% reliable" (a first-use warning shows). Set
  `python.compile = true` to build from source if a prebuilt misbehaves.
- Lockfiles work but the format is still maturing — commit them, but re-verify after mise
  upgrades.
- The registry of shorthands is large and may be reorganized over time; prefer explicit
  backend prefixes (`aqua:`/`github:`/`cargo:`) when you need stability.
- Some backends were experimental in early 2025 (go, rust, spm, vfox, dotnet, gem); most have
  since stabilized, but verify with the installed version if a backend behaves oddly.

## How mise compares (for choosing/justifying)

- **vs asdf:** faster (no per-call shim overhead; up to ~7× faster installs), reads
  `.tool-versions` natively (one-way — asdf can't read `mise.toml`), adds cargo/npm/go/aqua/
  github backends, better supply-chain story (provenance verification, mise-plugins org).
  Not 100% asdf-compatible by design; incompatible with asdf-go (≥0.16) commands. Switching
  reinstalls tools into mise's own dir.
- **vs direnv:** mise's `[env]` covers most needs; don't run both (see above).
- **vs nvm/pyenv/rbenv:** one tool for everything; remember idiomatic version files are
  opt-in.

## Where mise genuinely shines

Polyglot repos (one tool for every runtime + CLI), per-project env without direnv, layered
team/personal config, a uniform task entrypoint across languages, and clean CI via shims/
`mise exec` without shell-activation gymnastics. The boundary doctrine in
[tasks-and-boundary.md](tasks-and-boundary.md) is what keeps those benefits from turning into
duplication.
