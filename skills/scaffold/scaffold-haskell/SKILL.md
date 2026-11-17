---
name: scaffold-haskell
description: Create a new Haskell project with agent instructions and deterministic quality gates (pinned tools, format, lint, warnings as errors, a dependency lock, tests with a property, git hook, CI, agent stop hook). Use when the user wants to start, scaffold or bootstrap a Haskell project.
---

# Scaffold a Haskell project

The template makes a cabal project that agents can work in safely. One script,
`scripts/check`, holds every quality gate, and every runner calls it: people, the git hook, CI
and the agent hook. The rules for agents live in `AGENTS.md`. The quality floor comes from the
gates, so it holds whether or not an agent follows the rules.

mise pins every tool except GHC (`mise.toml`, `mise.lock`). ghcup, pinned by mise, installs GHC.
`cabal.project.freeze` pins every dependency version.

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

2. **Render.** Run `sh scripts/scaffold <target> <package> "<synopsis>" "<reader>"`. The script
   installs the pinned tools with mise, runs `cabal update`, copies the template, fills in the
   names, the reader and the dependency bounds, pins `index-state` to today, formats the Haskell
   and cabal files, writes `cabal.project.freeze`, trusts the project's `mise.toml`, runs
   `git init` when needed and enables the hooks in `.githooks/`. It needs the network.
   - mise or git is missing: propose `brew bundle --file=template/Brewfile.tmpl` (macOS). Run it
     only after the user agrees, then retry. Without Homebrew, name the missing tools and stop.
   - GHC is missing: the script looks in `$GHCUP_INSTALL_BASE_PREFIX/.ghcup/bin` (default: the
     home folder). If the user's ghcup lives under another prefix, set that variable and retry.
     Otherwise the script prints a `ghcup install ghc` command. It downloads 1 to 2 GB, so run it
     only after the user agrees, then retry.
   - A file exists: report it and stop. The user's files stay untouched.

   Done when the script prints `Created ...` and the file list.

3. **Verify.** Run `<target>/scripts/check`. Done when its last line is `All checks passed.`
   The first run builds the dependencies and takes about a minute. On red, read the output.
   `mise which` errors or "not mise's" mean a broken mise install of that tool: run the
   `mise install --force` command it prints, then retry.
   Fix it in `<target>`. When the template is at fault, tell the user what to change in
   `kgrigorev/skills`. This installed copy is overwritten on update. After two honest attempts,
   stop and report what is red.

4. **Hand over.** Report in one table: package, module, folder and the pinned versions from the
   script's output. Then list what is left for the owner:
   - Make the first commit. Commit only when the user asks.
   - Create the GitHub repository: `gh repo create <name> --private --source <target> --push`.
   - Protect `main` so the CI jobs `check` and `title` must pass. `scheduled` is not a required
     check.
   - Allow only squash merges, with the PR title and body as the commit message:

     ```sh
     gh repo edit --enable-squash-merge --squash-merge-commit-message pr-title-description \
       --enable-merge-commit=false --enable-rebase-merge=false --delete-branch-on-merge
     ```

   - Install HLS for the editor: `mise exec -- ghcup install hls 2.15.0.0`, as the project's
     `README.md` says.
   - Vendor the skills this project needs into the repo: in `<target>`, run
     `npx skills add <source> -s <skill> -a <agents> -y`, without `-g`. `-a` names the harnesses
     that need links, such as `claude-code`; `-y` skips the prompts an agent cannot answer. This
     writes `.agents/skills/` and `skills-lock.json`.
   - For a harness that reads neither `AGENTS.md` nor `CLAUDE.md`, add its file as a one-line
     pointer to `AGENTS.md`, never a copy.

## Changing a gate

Each gate file states its reason in a comment. `DESIGN.md` holds the reasons a file cannot
carry. Read both before you change or loosen a gate.
