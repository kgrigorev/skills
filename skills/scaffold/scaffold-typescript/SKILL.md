---
name: scaffold-typescript
description: Create a new TypeScript project (Node library and command-line program) with agent instructions and deterministic quality gates (format, type-aware lint, strict type check, unused code, tests, git hook, CI, agent stop hook). Use when the user wants to start, scaffold or bootstrap a TypeScript or Node project.
---

# Scaffold a TypeScript project

The template makes a Node project that agents can work in safely: a library in `src/`, a thin
program in `src/main.ts`, and tests. Node runs the `.ts` files directly, so there is no build
step. One script, `scripts/check`, holds every quality gate, and every runner calls it: people,
the git hook, CI and the agent hook. The rules for agents live in `AGENTS.md`. The quality floor
comes from the gates, so it holds whether or not an agent follows the rules.

The stack: Node and pnpm pinned by mise, TypeScript 7, oxlint with type information, oxfmt,
vitest with fast-check, and knip. The template is for Node programs only, not for browser apps.

Paths below are relative to this skill's folder unless they start with `<target>`.

## Steps

1. **Inputs.** Get four values. Take them from the request and ask once for the missing ones.
   - Target folder. It may exist, for example a fresh `gh repo clone`; the script never
     overwrites a file.
   - Package name: lower-case words joined by `-`. Offer the folder name as the default. It
     also names the library file: `my-tool` becomes `src/my-tool.ts`.
   - Synopsis: one noun phrase, capitalised, no final period, for example
     `A tool that renames photos`. It goes into `package.json`, `README.md`, `AGENTS.md` and the
     stub's banner.
   - Reader: who reads the code. Never guess it. A noun phrase that completes "The reader
     is ...". It starts in lower case and has no final period, for example
     `a Go developer new to TypeScript`. It goes into `AGENTS.md` and `CODING_STANDARDS.md` and
     sets how much the comments explain.

   Done when you have all four.

2. **Render.** Run `sh scripts/scaffold <target> <package> "<synopsis>" "<reader>"`. The
   script copies the template and fills in the names, the reader and the local mise version.
   Then it installs Node and pnpm with mise, writes `mise.lock` and `pnpm-lock.yaml`, formats
   the files, runs `git init` when needed and enables the hooks in `.githooks/`. It needs the
   network.
   - A tool is missing (`mise` or `git`): propose `brew install mise git` (macOS). Run it only
     after the user agrees, then retry. Without Homebrew, name the missing tools and stop.
   - A file exists: report it and stop. The user's files stay untouched.

   Done when the script prints `Created ...`, the versions and the file list.

3. **Verify.** Run `<target>/scripts/check`. It starts itself through `mise exec`, so it works
   in a shell without mise activated. Done when its last line is `All checks passed.` On red,
   read the output and fix the cause in `<target>`. When the template is at fault, tell the user
   what to change in `kgrigorev/skills`. This installed copy is overwritten on update. After two
   honest attempts, stop and report what is red.

4. **Hand over.** Report in one table: package, folder and the pinned versions from the
   script's output. Then list what is left for the owner:
   - Make the first commit. Commit only when the user asks.
   - Create the GitHub repository: `gh repo create <name> --private --source <target> --push`.
   - Protect `main` so the CI jobs `check` and `title` must pass. The job `lockfile-policy`
     asks the registry, so it stays optional.
   - Allow only squash merges, with the PR title and body as the commit message:

     ```sh
     gh repo edit --enable-squash-merge --squash-merge-commit-message pr-title-description \
       --enable-merge-commit=false --enable-rebase-merge=false --delete-branch-on-merge
     ```

   - Turn on Dependabot alerts in the repository settings. Security advisories change daily,
     so they stay out of `scripts/check`.
   - Editor: TypeScript 7's language server is `node_modules/.bin/tsc --lsp --stdio`. The older
     `typescript-language-server` does not work with TypeScript 7.
   - Vendor the skills this project needs into the repo: in `<target>`, run
     `npx skills add <source> -s <skill> -a <agents> -y`, without `-g`. `-a` names the harnesses
     that need links, such as `claude-code`; `-y` skips the prompts an agent cannot answer. This
     writes `.agents/skills/` and `skills-lock.json`.
   - For a harness that reads neither `AGENTS.md` nor `CLAUDE.md`, add its file as a one-line
     pointer to `AGENTS.md`, never a copy.

## Changing a gate

Each gate file states its reason in a comment. `DESIGN.md` holds the reasons a file cannot
carry. Read both before you change or loosen a gate.
