# Coding standards

Rules for reviewing changes in this repository. Apply every rule below whose path or artefact matches the diff, and skip what `scripts/check`, `.githooks/` or `.github/workflows/` already enforce.

## Agent documents (`skills/**`, `AGENTS.md`, `CLAUDE.md`, `CODING_STANDARDS.md`)

- **Progressive disclosure**: inline what every run uses, and push platform-, stack- or mode-specific reference into disclosed files behind a context pointer.
- **Context pointers**: in `SKILL.md` `description` fields, `AGENTS.md` lines and links to disclosed files, front-load the trigger word, keep one trigger per distinct branch, and cut detail the target already carries. Set `disable-model-invocation: true` on skills only the human invokes.
- **Co-location**: keep a concept's definition, rules and caveats under one heading rather than scattering them into separate `Notes` or `Caveats` sections.
- **Completion criteria**: end each step and procedure on a checkable, exhaustive bound (`Done when ...` naming an observable state across every item, or per-rule `**Test:**` questions plus `## Done` in reference skills) rather than an open-ended goal.
- **Positive instructions**: state what to do rather than what to avoid; keep negation only for hard guardrails with no positive form, paired with what to do instead.
- **Pruning**: keep each rule or command in one authoritative file, leave one-command or one-file lookups (`--help`, config files, directory layout) to the environment, keep project status out of docs, and delete whole sentences the model already follows by default.

## Commands, flags and APIs

- **Live or upstream check**: verify every CLI subcommand, flag, exit code, JSON/`jq` path and REST or GraphQL field in docs, code blocks, scripts and workflows against `--help`, live schema or upstream source rather than memory, and note anything you could not verify. Apply the same check to every command or flag proposed in a review finding before reporting it.

## Scripts and stateful git or API loops (`scripts/**`, `skills/**/scripts/**`, `.githooks/**`, `tests/**`, `skills/pull-request/**`, `skills/archive-project/**`)

- **BSD and GNU portability**: `shellcheck -s sh` checks shell syntax, not utility flags; reject GNU- or BSD-only options on `sed` (`sed -i`), `grep` (`-P`), `find` (`-printf`), `xargs` (`-r`), `mktemp`, `stat` or `date`, and resolve `pwd -P` on both sides when comparing paths that may cross symlinked `TMPDIR`.
- **Three-layer trace**: trace stack procedures across at least three layers so step 2 runs after step 1 has mutated branch ancestry (`-s ours` merges, retargeted base branches or deleted refs).
- **Asynchronous host transitions**: account for stale host fields and registration windows after retargeting, pushing or enqueuing (`mergeable`, `mergeStateStatus`, `detailed_merge_status`, target retargeting, check or pipeline registration, merge queues and merge trains) rather than assuming synchronous updates.

## Quality gates, scaffolds and tests

- **Quality gates** (`skills/scaffold/**`, `scripts/check`, `scripts/no-ai-attribution`, `scripts/sync-scaffold-shared`, `.githooks/**`, `.github/workflows/**`, `mise.toml`): read and apply [`skills/scaffold/GATES.md`](skills/scaffold/GATES.md).
- **Scaffold templates** (`skills/scaffold/**`): check template edits against that stack's `template/CODING_STANDARDS.md.tmpl` and `DESIGN.md`, and keep stack-specific text out of `skills/scaffold/_shared/**`.
- **Tests** (`tests/**`, `scripts/**`, `skills/**/scripts/**`, `.githooks/**`): read and apply [`skills/test-design/SKILL.md`](skills/test-design/SKILL.md). New behaviour or a bug fix in executable scripts or gates comes with a test seen red first (or states why only a live check applies).

## Research notes (`docs/research/**`)

- **Primary, dated sources**: cite primary sources (specifications, official docs, peer-reviewed studies, maintainer benchmarks, upstream code), record versions or commit SHAs with dates on version-sensitive claims, and label source-only facts, unverified claims and policy choices.
- **Adoption preface**: when an adopted house rule departs from a note's conclusions, record the departure in the preface and leave the historical findings in the body intact.
