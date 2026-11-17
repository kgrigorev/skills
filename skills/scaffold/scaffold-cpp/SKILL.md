---
name: scaffold-cpp
description: Create a new C++ project with agent instructions and deterministic quality gates (pinned clang toolchain, format, lint, warnings as errors, sanitizers, tests, git hook, CI, agent stop hook). Use when the user wants to start, scaffold or bootstrap a C++ project.
---

# Scaffold a C++ project

The template makes a CMake project in C++23 that agents can work in safely. One script,
`scripts/check`, holds every quality gate, and every runner calls it: people, the git hook, CI
and the agent hook. The rules for agents live in `AGENTS.md`. The quality floor comes from the
gates, so it holds whether or not an agent follows the rules.

Every build tool comes from mise at an exact version: clang, clang-tidy, clangd and clang-format
from one LLVM release on conda-forge, plus CMake and Ninja. `mise.lock` pins each download by
checksum. Apple's clang and the system compilers are never used.

Paths below are relative to this skill's folder unless they start with `<target>`.

## Steps

1. **Inputs.** Get four values. Take them from the request and ask once for the missing ones.
   - Target folder. It may exist, for example a fresh `gh repo clone`; the script never
     overwrites a file.
   - Package name: lower-case words joined by `-`. Offer the folder name as the default. It
     names the program. The C++ namespace and file names follow from it: `my-tool` becomes
     `my_tool`.
   - Synopsis: one noun phrase, capitalised, no final period, for example
     `A C++ tool that renames photos`. It goes into `README.md`, `AGENTS.md` and the stub's
     banner.
   - Reader: who reads the code. Never guess it. A noun phrase that completes "The reader
     is ...". It starts in lower case and has no final period, for example
     `a Go developer new to C++`. It goes into `AGENTS.md` and `CODING_STANDARDS.md` and sets
     how much the comments explain.

   Done when you have all four.

2. **Render.** Run `sh scripts/scaffold <target> <package> "<synopsis>" "<reader>"`. The script
   copies the template, fills in the names, the reader and the pinned tool versions, runs
   `git init` when needed, enables the hooks in `.githooks/`, writes `mise.lock` for macOS arm64
   and Linux x64 and arm64, and formats the C++ files. It needs the network. The first run
   installs the pinned clang-format (about 300 MB).
   - A tool is missing: propose `brew bundle --file=template/Brewfile.tmpl` (macOS). Run it only
     after the user agrees, then retry. Without Homebrew, name the missing tools and stop.
   - A file exists: report it and stop. The user's files stay untouched.

   Done when the script prints `Created ...` and the file list.

3. **Verify.** Run `<target>/scripts/check`. The first run installs the rest of the toolchain
   (about 1.2 GB once) and downloads GoogleTest and rapidcheck. Done when its last line is
   `All checks passed.` On red, read the output. Fix it in `<target>`. When the template is at
   fault, tell the user what to change in `kgrigorev/skills`. This installed copy is overwritten
   on update. After two honest attempts, stop and report what is red.

4. **Hand over.** Report in one table: package, namespace, folder and the pinned versions from
   the script's output. Then list what is left for the owner:
   - Make the first commit. Commit only when the user asks.
   - Create the GitHub repository: `gh repo create <name> --private --source <target> --push`.
   - Protect `main` so the CI jobs `check` and `title` must pass. CI runs on Linux; the git
     hook and the Stop hook run the same checks on the owner's Mac.
   - Allow only squash merges, with the PR title and body as the commit message:

     ```sh
     gh repo edit --enable-squash-merge --squash-merge-commit-message pr-title-description \
       --enable-merge-commit=false --enable-rebase-merge=false --delete-branch-on-merge
     ```

   - Point the editor's clangd at the pinned one: `mise which clangd`, run in `<target>`.
   - Vendor the skills this project needs into the repo: in `<target>`, run
     `npx skills add <source> -s <skill> -a <agents> -y`, without `-g`. `-a` names the harnesses
     that need links, such as `claude-code`; `-y` skips the prompts an agent cannot answer. This
     writes `.agents/skills/` and `skills-lock.json`.
   - For a harness that reads neither `AGENTS.md` nor `CLAUDE.md`, add its file as a one-line
     pointer to `AGENTS.md`, never a copy.

## Changing a gate

Each gate file states its reason in a comment. `DESIGN.md` holds the reasons a file cannot
carry. Read both before you change or loosen a gate.
