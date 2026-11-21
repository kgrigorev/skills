# Shared scaffold files

Every `scaffold-<stack>` skill installs on its own, so each holds its own copy of these files.
This folder is the source of truth. It has no `SKILL.md`, so `npx skills add` never installs it.

| File | Lands in each skill as |
| --- | --- |
| `scripts/scaffold-lib.sh` | `scripts/scaffold-lib.sh`, sourced by the skill's `scripts/scaffold` |
| `template/**` | the same path under the skill's `template/` |
| `AGENTS.tail.md` | `template/AGENTS.md.tmpl`, from the `## Writing` heading to the end |

Change a file here, then run `scripts/sync-scaffold-shared` from the repo root and commit the
copies with it. CI runs `scripts/sync-scaffold-shared --check` and fails on any drift.
Stack-specific text never goes here.

Rules for designing the gates themselves are in [`../GATES.md`](../GATES.md).
