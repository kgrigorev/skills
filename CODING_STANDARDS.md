# Coding Standards

Review-stage rules for changes in this repository. Skip anything automated checks, git hooks, or CI workflows already enforce; apply every rule below whose path or artefact matches the diff.

## Agent documents (`skills/**`, `AGENTS.md`, `CODING_STANDARDS.md`)

- **Progressive disclosure by branch**: keep shared workflow in `SKILL.md` and move host-, stack-, or mode-specific reference into sibling files reached by a front-loaded context pointer with one trigger per branch.
- **Co-location**: keep a concept's definition, rules, and caveats under a single heading rather than splitting one rule across multiple sections.
- **Checkable, exhaustive bounds**: end multi-step procedures on observable completion criteria (`Done when ...`) rather than open-ended goals.
- **Positive target behaviour**: state what the agent should do rather than listing prohibitions; reserve negation for hard guardrails that have no positive equivalent, paired with the target action.
- **No environment caches or no-ops**: leave single-command or single-file lookups (`--help`, config files, directory layout) to the environment instead of restating them in prose, and cut sentences the model already follows by default.

## Commands, flags, and APIs in prose

- **Primary verification**: verify every CLI subcommand, flag, exit code, JSON/`jq` field, and REST or GraphQL field in prose against `--help`, live API schema, or upstream source rather than memory. Apply the same check to every command or flag proposed in a review finding before reporting it.

## Stateful git and API loops (`skills/pull-request/**`, `scripts/**`)

- **Three-layer trace**: trace stack algorithms across at least three layers so Iteration 2 runs after Iteration 1 has mutated branch ancestry (`-s ours` merges, retargeted base branches, or deleted refs).
- **Asynchronous host transitions**: account for stale host fields and registration windows after retargeting, pushing, or enqueuing (`mergeable`, `mergeStateStatus`, check registration, merge queues, and merge trains) rather than assuming synchronous updates.

## Quality gates and tests

- **Quality gates** (`skills/scaffold/**`, `scripts/check`): read and apply [`skills/scaffold/GATES.md`](skills/scaffold/GATES.md).
- **Tests** (`tests/**`, `scripts/test-*`): read and apply [`skills/test-design/SKILL.md`](skills/test-design/SKILL.md).

## Research notes (`docs/research/**`)

- Cite primary sources (specifications, official docs, maintainer benchmarks, upstream code) and date version-sensitive claims. When a preface records a house-rule departure from a note's conclusions, leave the historical findings in the body intact rather than editing them to match the preface.
