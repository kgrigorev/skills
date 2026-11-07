# mise troubleshooting

Checked against mise `2026.11.3`. Start with `mise doctor` (exits 1 on a problem, names the
fix), then `mise config` (what loaded), `mise ls --current` (what's active), `which -a <tool>`
(PATH order), `mise env --paths` (the PATH entries mise adds).

## Tools or env missing in a script, CI step or agent shell

`mise activate` updates PATH and env from the shell prompt hook. Non-interactive shells
(agent Bash tools, `bash script.sh`, CI steps) have no prompt, so nothing changes. Run through
mise instead:

```bash
mise x -- <cmd>
mise run <task>
eval "$(mise activate bash --shims)"   # persistent PATH via shims; shims load [env] per call
```

## "Config files in … are not trusted"

`mise ls`, `env`, `tasks` and `config` fail on an untrusted config; shell activation skips it
with a warning. `mise run`, `exec`, `install` and `watch` trust it implicitly. Ask the user,
then `mise trust`. To look first without trusting: `MISE_SAFE=1 mise tasks` (safe mode ignores
project `[env]` and refuses tasks and hooks). A project's `[settings]` takes effect only after
trust. Details: [configuration.md](configuration.md#trust).

## Wrong version active

Another manager or a system binary is ahead on PATH. Compare `which -a <tool>` with
`mise ls --current`; put mise's activation or shims first. `mise doctor` warns when other
paths take precedence.

## `.nvmrc` / `.python-version` / `go.mod` / `rust-toolchain.toml` ignored

Idiomatic files are opt-in per tool:
`mise settings add idiomatic_version_file_enable_tools node --local`. Node reads
`devEngines.runtime`, never `engines.node`. Go reads only `toolchain` or exact `go X.Y.Z`.
`.tool-versions` needs no opt-in.

## Install fails

- **"no versions found"** for a release under a day old: the default 24 h
  `minimum_release_age`. Pin the exact version, or set `minimum_release_age` lower.
- **"option '…' is not used by the … backend"**: tool options are now checked. Remove it or
  move it to the right setting (`node.corepack` is a setting, for example).
- **`--locked` fails on missing checksums or URLs**: run `mise lock` to fill the lockfile.
- **"unsupported lockfile version 4"**: someone on mise ≥ 2026.11.1 wrote the lockfile. Upgrade
  mise (`mise self-update`, or the package manager that installed it).
- **npm provenance failure**: the package was built from a different repository than the one
  pinned in `mise.lock`. Investigate before overriding.
- **asdf-style `mise install` didn't add my tool**: `install` only installs pins. `mise use`
  adds them.

## `node = "24"` isn't the newest 24.x

A prefix resolves to the newest _installed_ match. `mise install node@24` or `mise upgrade`
fetches newer; `mise up --bump` rewrites the pin in config.

## direnv

mise `[env]` replaces direnv. Running both fights over PATH, and the maintainers won't treat
conflicts as bugs. Pick mise. `mise direnv` is deprecated and goes in 2027.10.4.

## IDEs

An IDE sees mise's tools and `[env]` only through shims or a mise extension (`mise-vscode`,
`intellij-mise`). Point it at shims (`mise activate <shell> --shims` in the login profile) or
at the stable `global` link inside each tool's install dir. Restart the IDE after switching
versions it reads at startup (`JAVA_HOME`). `mise lsp` gives editors diagnostics and
completion for `mise.toml`.

## Windows

Native Windows runs tools through shims; `mise x` and `mise run` load `[env]`. WSL behaves
like Linux. Long install paths: `experimental = true` switches new installs to the shorter
identity layout. `asdf:` plugins never run on Windows.

## Slow prompt

`mise hook-env` runs on every prompt. Profile with `MISE_TIMINGS=1 mise hook-env -s bash`; expensive
`_.source` scripts and `exec()` templates are the usual cause.
