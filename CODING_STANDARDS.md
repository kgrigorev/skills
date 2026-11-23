# Coding standards

Rules for writing and reviewing changes in this repository. Apply every rule below whose path and artefact match the diff, and skip what `scripts/check`, `.githooks/` or `.github/workflows/` already enforce.

## Agent documents (`AGENTS.md`, `CLAUDE.md`, `CODING_STANDARDS.md`, `skills/**/SKILL.md`, disclosed skill `.md` files, `skills/scaffold/_shared/AGENTS.tail.md`, `skills/scaffold/**/AGENTS.md.tmpl`)

- **Progressive disclosure**: inline what every run uses, and push platform-, stack- or mode-specific reference into disclosed files behind a context pointer.
- **Context pointers**: in model-invoked `SKILL.md` `description` fields, `AGENTS.md` lines and links to disclosed files, front-load the trigger word, keep one trigger per distinct branch, and cut detail the target already carries. On skills only the human invokes, set `disable-model-invocation: true` and write `description` as a one-line human summary without trigger lists.
- **Co-location**: keep a concept's definition, rules and caveats under one heading rather than scattering them into separate `Notes` or `Caveats` sections.
- **Completion criteria**: end each procedure and multi-part step on a checkable, exhaustive bound (`Done when ...` naming an observable state across every item, or per-rule `**Test:**` questions plus `## Done` in reference skills).
- **Positive instructions**: state what to do rather than what to avoid; keep negation only for hard guardrails with no positive form, paired with what to do instead.
- **Pruning**: keep each rule or command in one authoritative file, leave one-command or one-file lookups (`--help`, config files, directory layout) to the environment, state durable rules and pointers rather than project status, and delete whole sentences the model already follows by default.

## Commands, flags and APIs

- **Live or upstream check**: verify every CLI subcommand, flag, exit code, JSON/`jq` path and REST or GraphQL field in docs, code blocks, scripts and workflows against `--help`, live schema or upstream source rather than memory, and note anything you could not verify. Apply the same check to every command or flag proposed in a review finding before reporting it.

## Scripts and stateful git or API loops (`scripts/**`, `skills/**/scripts/**`, `skills/scaffold/**`, `.githooks/**`, `.github/workflows/**`, `tests/**`, `skills/pull-request/**`, `skills/archive-project/**`)

- **BSD and GNU portability**: `shellcheck -s sh` checks shell syntax, not utility flags; reject GNU- or BSD-only options on `sed` (`-i` without suffix or `-i ''`), `grep` (`-P`), `find` (`-printf`), `xargs` (`-r`), `mktemp`, `stat` or `date`, and resolve `pwd -P` on both sides when comparing paths that may cross symlinked `TMPDIR`.
- **Three-layer trace**: trace stack procedures across at least three layers so step 2 runs after step 1 has mutated branch ancestry (`-s ours` merges, retargeted base branches or deleted refs).
- **Asynchronous host transitions**: account for stale host fields and registration windows after retargeting, pushing or enqueuing (`mergeable`, `mergeStateStatus`, `detailed_merge_status`, target retargeting, check or pipeline registration, merge queues and merge trains).

## Quality gates, scaffolds and tests

- **Quality gates** (`skills/scaffold/**`, `scripts/check`, `scripts/no-ai-attribution`, `scripts/sync-scaffold-shared`, `.githooks/**`, `.github/workflows/**`, `mise.toml`, `mise.lock`): read and apply [`skills/scaffold/GATES.md`](skills/scaffold/GATES.md).
- **Scaffold templates** (`skills/scaffold/**`): check template edits against that stack's `template/CODING_STANDARDS.md.tmpl` and `DESIGN.md`, and keep stack-specific text out of `skills/scaffold/_shared/**`.
- **Tests** (`tests/**`, `scripts/**`, `skills/**/scripts/**`, `.githooks/**`): read and apply [`skills/test-design/SKILL.md`](skills/test-design/SKILL.md). New behaviour or a bug fix in executable scripts or gates comes with a test seen red first (or states why only a live check applies).

## Research notes (`docs/research/**`)

- **Primary, dated sources**: cite primary sources (specifications, official docs, peer-reviewed studies, maintainer benchmarks, upstream code), record versions or commit SHAs with dates on version-sensitive claims, and label source-only facts, unverified claims and policy choices.
- **Adoption preface**: when an adopted house rule departs from a note's conclusions, record the departure in the preface and leave the historical findings in the body intact.
