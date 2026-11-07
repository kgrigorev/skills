---
name: scaffold-haskell
description: Create a new Haskell project with agent instructions and deterministic quality gates (format, lint, warnings as errors, tests, git hook, CI, agent stop hook). Use when the user wants to start, scaffold or bootstrap a Haskell project.
---

# Scaffold a Haskell project

The template makes a cabal project that agents can work in safely. One script,
`scripts/check`, holds every quality gate, and every runner calls it: people, the git hook, CI
and the agent hook. The rules for agents live in `AGENTS.md`. The quality floor comes from the
gates, so it holds whether or not an agent follows the rules.

Paths below are relative to this skill's folder unless they start with `<target>`.

## Steps

1. **Inputs.** Get four values. Take them from the request and ask once for the missing ones.
   - Target folder. It may exist, for example a fresh `gh repo clone`; the script never
     overwrites a file.
   - Package name: lower-case words joined by `-`. Offer the folder name as the default. The
     module name follows from it: `my-tool` becomes `MyTool`.
   - Synopsis: one noun phrase, capitalised, no final period, for example
     `A Haskell tool that renames photos`. It goes into the `.cabal` file, `README.md`,
     `AGENTS.md` and the stub's banner.
   - Reader: who reads the code. Never guess it. A noun phrase that completes "The reader
     is ...". It starts in lower case and has no final period, for example
     `a Go developer new to Haskell`. It goes into `AGENTS.md` and `CODING_STANDARDS.md` and sets
     how much the comments explain.

   Done when you have all four.

2. **Render.** Run `cabal update`, then
   `sh scripts/scaffold <target> <package> "<synopsis>" "<reader>"`. The script copies the
   template, fills in the names, the reader and the local tool versions, pins `index-state` to
   today, formats the Haskell files, runs `git init` when needed and enables the hooks in
   `.githooks/`. The project pins the `ghc` on `PATH`; to pin another version, run
   `ghcup set ghc <version>` first.
   - A tool is missing: propose `brew bundle --file=template/Brewfile.tmpl` (macOS), then
     `ghcup install ghc recommended`, `ghcup set ghc recommended` and
     `ghcup install cabal latest`. Run them only after the user agrees, then retry. Without
     Homebrew, name the missing tools and stop.
   - A file exists: report it and stop. The user's files stay untouched.

   Done when the script prints `Created ...` and the file list.

3. **Verify.** Run `<target>/scripts/check`. Done when its last line is `All checks passed.`
   On red, read the output. The likely cause is a dependency bound that the solver rejects. Fix
   it in `<target>`. When the template is at fault, tell the user what to change in
   `kgrigorev/skills`. This installed copy is overwritten on update. After two honest attempts,
   stop and report what is red.

4. **Hand over.** Report in one table: package, module, folder and the pinned versions from the
   script's output. Then list what is left for the owner:
   - Make the first commit. Commit only when the user asks.
   - Create the GitHub repository: `gh repo create <name> --private --source <target> --push`.
   - Protect `main` so the CI jobs `check` and `title` must pass.
   - Allow only squash merges, with the PR title and body as the commit message:

     ```sh
     gh repo edit --enable-squash-merge --squash-merge-commit-message pr-title-description \
       --enable-merge-commit=false --enable-rebase-merge=false --delete-branch-on-merge
     ```

   - Install HLS: `ghcup install hls latest`.
   - Vendor the skills this project needs into the repo: run `npx skills add <source> -s <skill>`
     without `-g` in `<target>`. This writes `.agents/skills/` and `skills-lock.json`.
   - For a harness that reads neither `AGENTS.md` nor `CLAUDE.md`, add its file as a one-line
     pointer to `AGENTS.md`, never a copy.

## Changing a gate

Each gate file states its reason in a comment. `DESIGN.md` holds the reasons a file cannot
carry. Read both before you change or loosen a gate.
