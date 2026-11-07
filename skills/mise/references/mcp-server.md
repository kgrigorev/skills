# mise MCP server

Checked against mise `2026.11.3` by listing the server's tools and resources. Docs:
<https://mise.jdx.dev/mcp.html>.

`mise mcp` serves the active mise environment over stdio. Stable since 2026.6.6; older
versions need `MISE_EXPERIMENTAL=1` in the server's env.

## What it exposes

| Kind | Name | Does |
|---|---|---|
| resource | `mise://tools` | installed tools, version, active status (`?include_inactive=true` for all) |
| resource | `mise://tasks` | tasks with descriptions, deps, env directives; monorepo subprojects included |
| resource | `mise://env` | env vars from mise config |
| resource | `mise://config` | active config files and project root |
| tool | `run_task` (`task`, `args`) | runs a task, returns stdout, stderr, exit status |
| tool | `install_tool` (`tool`, `version`) | installs a version (or the configured one, or latest), returns version and path; since 2026.10.5 |
| tool | `list_commands` (`include_hidden`) | every mise command with its effect: `read`, `write` or `destructive` |

`run_task` and `install_tool` refuse untrusted config, and an MCP call never grants trust. The
user runs `mise trust` first.

The CLI still owns: config writes (`mise use`, `mise set`, `mise tasks add`), version queries
(`mise ls-remote`, `mise latest`), locking, upgrades, trust.

## Wiring it into Claude Code

```bash
claude mcp add --scope project mise -- mise mcp
```

or `.mcp.json` at the repo root:

```json
{ "mcpServers": { "mise": { "command": "mise", "args": ["mcp"] } } }
```

`mise` must be on `PATH` when Claude Code starts. If PATH comes from shell init, use the
absolute path from `command -v mise` (e.g. `/opt/homebrew/bin/mise`, `~/.local/bin/mise`).

## MCP or the CLI

Reach for MCP when it is already wired: structured reads of tools, env and config without
parsing text, task runs with clean stdout/stderr/exit capture, and `list_commands` to check a
command's effect before running it. Everything else, and every session where the server isn't
configured, goes through Bash: `mise ls --json`, `mise tasks ls --json`, `mise env --json`,
`mise run`.
