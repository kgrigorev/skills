---
name: scaffold-c
description: Create a new C project with agent instructions and deterministic quality gates (pinned clang toolchain, format, clang-tidy, warnings as errors, sanitizers, example and property tests, git hook, CI, agent stop hook). Use when the user wants to start, scaffold or bootstrap a C project.
---

# Scaffold a C project

The template makes a C23 project with CMake that agents can work in safely. One script,
`scripts/check`, holds every quality gate, and every runner calls it: people, the git hook, CI
and the agent hook. The rules for agents live in `AGENTS.md`. The quality floor comes from the
gates, so it holds whether or not an agent follows the rules.

mise pins the whole toolchain: clang, clang-tidy, clang-format, clangd and llvm-cov from one LLVM
release, CMake and Ninja. So the same commit gives the same warnings on every machine and in CI.

Paths below are relative to this skill's folder unless they start with `<target>`.

## Steps

1. **Inputs.** Get four values. Take them from the request and ask once for the missing ones.
   - Target folder. It may exist, for example a fresh `gh repo clone`; the script never
     overwrites a file.
   - Package name: lower-case words joined by `-`. Offer the folder name as the default. The C
     prefix follows from it: `my-tool` becomes `my_tool_`. A few names are refused, such as
     `test` or `int`, because CMake or C reserve them.
   - Synopsis: one noun phrase, capitalised, no final period, for example
     `A C tool that renames photos`. It goes into `README.md`, `AGENTS.md` and the sample
     program's banner. `<package>: <synopsis>` must stay under 128 bytes.
   - Reader: who reads the code. Never guess it. A noun phrase that completes "The reader
     is ...". It starts in lower case and has no final period, for example
     `a Python developer new to C`. It goes into `AGENTS.md` and `CODING_STANDARDS.md` and sets
     how much the comments explain.

   Done when you have all four.

2. **Render.** Run `sh scripts/scaffold <target> <package> "<synopsis>" "<reader>"`. The script
   copies the template, fills in the names and the reader, runs `mise trust`, writes `mise.lock`
   for every platform, installs the pinned tools, formats the C files, runs `git init` when
   needed and enables the hooks in `.githooks/`. The first install downloads about 1 GB, so it
   needs the network and takes a few minutes.
   - A tool is missing: the script needs `mise` and `git`, and on macOS the Xcode Command Line
     Tools. Propose `brew install mise` and `xcode-select --install`. Run them only after the
     user agrees, then retry. Without Homebrew, name the missing tools and stop.
   - A file exists: report it and stop. The user's files stay untouched.

   Done when the script prints `Created ...` and the file list.

3. **Verify.** Run `<target>/scripts/check`. Done when its last line is `All checks passed.`
   On red, read the output. Fix it in `<target>`. When the template is at fault, tell the user
   what to change in `kgrigorev/skills`. This installed copy is overwritten on update. After two
   honest attempts, stop and report what is red.

4. **Hand over.** Report in one table: package, C prefix, folder and the pinned versions from the
   script's output. Then list what is left for the owner:
   - Make the first commit, with `mise.lock`. Commit only when the user asks.
   - Create the GitHub repository: `gh repo create <name> --private --source <target> --push`.
   - Protect `main` so the CI jobs `check` and `title` must pass, with review from code owners.
     Add `.github/CODEOWNERS` that names the owner for the gate files `AGENTS.md` lists. The check
     cannot guard edits to its own rules.
   - Allow only squash merges, with the PR title and body as the commit message:

     ```sh
     gh repo edit --enable-squash-merge --squash-merge-commit-message pr-title-description \
       --enable-merge-commit=false --enable-rebase-merge=false --delete-branch-on-merge
     ```

   - Point the editor's clangd at the pinned one (`mise which clangd`), as `README.md` says.
   - Vendor the skills this project needs into the repo: in `<target>`, run
     `npx skills add <source> -s <skill> -a <agents> -y`, without `-g`. `-a` names the harnesses
     that need links, such as `claude-code`; `-y` skips the prompts an agent cannot answer. This
     writes `.agents/skills/` and `skills-lock.json`.
   - For a harness that reads neither `AGENTS.md` nor `CLAUDE.md`, add its file as a one-line
     pointer to `AGENTS.md`, never a copy.

## Changing a gate

Each gate file states its reason in a comment. `DESIGN.md` holds the reasons a file cannot
carry. Read both before you change or loosen a gate.
