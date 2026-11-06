# mise MCP server

Researched against mise `v2026.6.x`. Sources: <https://mise.jdx.dev/mcp.html>,
`mise.jdx.dev/cli/mcp.html`, `github.com/jdx/mise/blob/main/src/cli/mcp.rs`.

mise ships a built-in MCP (Model Context Protocol) server that exposes the active mise
environment to an agent over JSON-RPC on stdio.

- **Command:** `mise mcp`
- **Stability:** introduced experimental in v2025.8.5; **graduated to stable in v2026.6.6**
  (2026-06-13). On current versions no experimental flag is needed.
- **Version caveat:** the docs page still shows `MISE_EXPERIMENTAL=1` in its example — that's
  documentation lag. Only add the flag if targeting mise older than v2026.6.6.

## What it exposes

**Resources (read-only):**

| URI | Returns |
|---|---|
| `mise://tools` | Installed tools with version + active status (`?include_inactive=true` for all). |
| `mise://tasks` | Task names, descriptions, dependencies. |
| `mise://env` | Env vars sourced from mise config. |
| `mise://config` | Active config files + project root. |

**Tools (callable):**

| Tool | Status |
|---|---|
| `run_task` (`task`, optional `args[]`) | **Works** — spawns the task, returns stdout/stderr/exit. |
| `install_tool` (`tool`, optional `version`) | **Stub** — defined in schema but unimplemented; always errors. Use the CLI. |

It does **not** expose: querying installable versions (no `ls-remote` equivalent), `mise
use`/`set`/pin or any write to config, or backend/plugin management.

## Wiring it into Claude Code

Project-level `.mcp.json` at the repo root:

```json
{
  "mcpServers": {
    "mise": {
      "command": "mise",
      "args": ["mcp"]
    }
  }
}
```

Or via CLI:

```bash
claude mcp add --scope project mise -- mise mcp
```

For mise older than v2026.6.6, add the experimental flag:

```json
{ "mcpServers": { "mise": { "command": "mise", "args": ["mcp"],
  "env": { "MISE_EXPERIMENTAL": "1" } } } }
```

`mise` must be resolvable on `PATH` at Claude Code startup. On macOS with shell-init-based
PATH, you may need the absolute path (`~/.local/bin/mise` or `/opt/homebrew/bin/mise`) as the
`command`.

## When to use MCP vs the CLI

**Use the MCP server for:**

- **Introspection without parsing** — read `mise://tools`/`env`/`config`/`tasks` as structured
  data instead of shelling out and parsing text. Good for "what's active here?" orientation.
- **Task execution with clean result capture** — `run_task` runs the task and returns its
  stdout/stderr and exit status as a structured result, avoiding the shell
  escaping/interleaving issues of capturing raw terminal output. (The exact result fields are
  an MCP protocol detail and may vary by mise version; don't hardcode a specific shape.)
- **Restricted-PATH environments** — if the Bash tool's shell has an odd PATH, an MCP server
  configured at startup with the right PATH is more reliable.

**Stay on the CLI (Bash) for:**

- **Installing tools / pinning versions** — `install_tool` is a stub; use `mise use …` /
  `mise install`.
- **Querying available versions** — `mise ls-remote <tool>` (no MCP equivalent).
- **Any config write** — `mise use`, `mise set`, editing `mise.toml`.
- **Token economy** — for a single quick fact, terse `mise ls --json` via Bash is cheaper than
  an MCP round-trip.

**Bottom line:** MCP is a convenience layer for *read + run*, not a replacement for the CLI.
You can complete every mise task with Bash alone; the MCP server just makes environment
introspection and task execution cleaner when it's already wired up. If it isn't configured,
don't block on it — use `mise config`/`mise ls`/`mise tasks --json`/`mise run` directly.
