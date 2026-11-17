---
name: scaffold-python
description: Create a new Python project with uv, agent instructions and deterministic quality gates (ruff format and all lint rules, mypy --strict, pytest with warnings as errors, Hypothesis, 100 % branch coverage, git hook, CI, agent stop hook). Use when the user wants to start, scaffold or bootstrap a Python project.
---

# Scaffold a Python project

The template makes a uv project that agents can work in safely. One script, `scripts/check`,
holds every quality gate, and every runner calls it: people, the git hook, CI and the agent
hook. The rules for agents live in `AGENTS.md`. The quality floor comes from the gates, so it
holds whether or not an agent follows the rules.

Paths below are relative to this skill's folder unless they start with `<target>`.

## Steps

1. **Inputs.** Get four values. Take them from the request and ask once for the missing ones.
   - Target folder. It may exist, for example a fresh `gh repo clone`; the script never
     overwrites a file.
   - Package name: lower-case words joined by `-`. Offer the folder name as the default. The
     module name follows from it: `my-tool` becomes `my_tool`. It must not be a Python keyword or
     the name of a standard library module, such as `json`.
   - Synopsis: one noun phrase, capitalised, no final period, for example
     `A Python tool that renames photos`. It goes into `pyproject.toml`, `README.md`,
     `AGENTS.md` and the program's banner.
   - Reader: who reads the code. Never guess it. A noun phrase that completes "The reader
     is ...". It starts in lower case and has no final period, for example
     `a Go developer new to Python`. It goes into `AGENTS.md` and `CODING_STANDARDS.md` and sets
     how much the comments explain.

   Done when you have all four.

2. **Render.** Run `sh scripts/scaffold <target> <package> "<synopsis>" "<reader>"`. The
   script copies the template and fills in the names and the reader. It pins the uv version
   from the top of `scripts/scaffold` and the newest patch of its Python minor, adds the newest
   ruff, mypy, pytest, Hypothesis and coverage as exact pins, and writes `uv.lock` and
   `mise.lock`. Then it formats the Python files, runs `git init` when needed and enables the
   hooks in `.githooks/`. It needs the network.
   - A tool is missing: the script needs `mise` and `git`. Propose
     `brew bundle --file=template/Brewfile.tmpl` (macOS). Run it only after the user agrees,
     then retry. mise downloads the pinned uv by itself; the uv on `PATH` does not matter.
     Without Homebrew, name the missing tools and stop.
   - A file exists: report it and stop. The user's files stay untouched.
   - The package name is taken: ask for another one.

   Done when the script prints `Created ...` and the file list.

3. **Verify.** Run `<target>/scripts/check`. Done when its last line is `All checks passed.`
   On red, read the output. The likely cause is a new rule in the newest ruff or mypy that the
   sample code breaks. Fix it in `<target>`. When the template is at fault, tell the user what
   to change in `kgrigorev/skills`. This installed copy is overwritten on update. After two
   honest attempts, stop and report what is red.

4. **Hand over.** Report in one table: package, module, folder and the pinned versions from the
   script's output. Then list what is left for the owner:
   - Make the first commit, with `uv.lock` and `mise.lock`. Commit only when the user asks.
   - Create the GitHub repository: `gh repo create <name> --private --source <target> --push`.
   - Protect `main` so the CI jobs `check` and `title` must pass.
   - Allow only squash merges, with the PR title and body as the commit message:

     ```sh
     gh repo edit --enable-squash-merge --squash-merge-commit-message pr-title-description \
       --enable-merge-commit=false --enable-rebase-merge=false --delete-branch-on-merge
     ```

   - Every other clone runs `mise trust` once. mise reads only trusted `mise.toml` files.
   - Language server: install pyright (`npm install -g pyright`) and the Claude Code plugin
     `pyright-lsp`.
   - Vendor the skills this project needs into the repo: in `<target>`, run
     `npx skills add <source> -s <skill> -a <agents> -y`, without `-g`. `-a` names the harnesses
     that need links, such as `claude-code`; `-y` skips the prompts an agent cannot answer. This
     writes `.agents/skills/` and `skills-lock.json`.
   - For a harness that reads neither `AGENTS.md` nor `CLAUDE.md`, add its file as a one-line
     pointer to `AGENTS.md`, never a copy.

## Changing a gate

Each gate file states its reason in a comment. `DESIGN.md` holds the reasons a file cannot
carry. Read both before you change or loosen a gate.
