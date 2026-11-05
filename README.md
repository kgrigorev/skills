# skills

Agent skills in the open `SKILL.md` format, for Claude Code, Codex, Cursor and other harnesses.

| Skill | What it does |
| --- | --- |
| `scaffold-haskell` | Creates a Haskell project with agent rules and quality gates. |
| `commit-message` | Writes short conventional commits without attribution. |
| `pull-request` | Opens small PRs with short bodies from the repo's template, and stacks. |

## Install

```sh
npx skills add kgrigorev/skills -g                    # every skill, for every project
npx skills add kgrigorev/skills -s pull-request -g    # one skill
npx skills update
```

While you change a skill, link it from your clone instead, so edits take effect at once:

```sh
ln -s ~/src/skills/skills/pull-request ~/.claude/skills/pull-request
```
