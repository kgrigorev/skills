---
name: scaffold-scala
description: Create a new Scala 3 project built with Scala CLI, with agent instructions and deterministic quality gates (format, WartRemover lint, warnings as errors, tests, git hook, CI, agent stop hook). Use when the user wants to start, scaffold or bootstrap a Scala or Scala 3 project.
---

# Scaffold a Scala 3 project

The template makes a Scala CLI project that agents can work in safely. One script,
`scripts/check`, holds every quality gate, and every runner calls it: people, the git hook, CI
and the agent hook. The rules for agents live in `AGENTS.md`. The quality floor comes from the
gates, so it holds whether or not an agent follows the rules.

Every version is fixed in the template: Scala 3.9 LTS, Temurin JDK 25 LTS and Scala CLI (through
mise), scalafmt, WartRemover, munit and munit-scalacheck. The scaffold never picks the newest
version on its own.

Paths below are relative to this skill's folder unless they start with `<target>`.

## Steps

1. **Inputs.** Get four values. Take them from the request and ask once for the missing ones.
   - Target folder. It may exist, for example a fresh `gh repo clone`; the script never
     overwrites a file.
   - Package name: lower-case words joined by `-`. Offer the folder name as the default. The
     Scala package drops the `-` and the main object joins the words: `my-tool` becomes package
     `mytool` and object `MyTool`.
   - Synopsis: one noun phrase, capitalised, no final period, for example
     `A Scala tool that renames photos`. It goes into `README.md` and `AGENTS.md`.
   - Reader: who reads the code. Never guess it. A noun phrase that completes "The reader
     is ...". It starts in lower case and has no final period, for example
     `a Go developer new to Scala 3`. It goes into `AGENTS.md` and `CODING_STANDARDS.md` and sets
     how much the comments explain.

   Done when you have all four.

2. **Render.** Run `sh scripts/scaffold <target> <package> "<synopsis>" "<reader>"`. The script
   copies the template and fills in the names and the reader. Then it trusts the project's
   `mise.toml`, writes `mise.lock` for every common platform, installs the JDK and Scala CLI,
   formats the Scala files, runs `git init` when needed and enables the hooks in `.githooks/`.
   It needs the network for the downloads.
   - mise is missing: propose the install from https://mise.jdx.dev/getting-started.html, for
     example `brew install mise` on macOS. Run it only after the user agrees, then retry.
   - A file exists: report it and stop. The user's files stay untouched.

   Done when the script prints `Created ...` and the file list.

3. **Verify.** Run `<target>/scripts/check`. It runs through `mise exec` on its own, so mise
   does not need to be activated in the shell. The first run downloads the compiler and
   libraries, about 100 MB. Done when its last line is `All checks passed.` On red, read the
   output and fix the cause in `<target>`. When the template is at fault, tell the user what to
   change in `kgrigorev/skills`. This installed copy is overwritten on update. After two honest
   attempts, stop and report what is red.

4. **Hand over.** Report in one table: package, Scala package and object, folder and the pinned
   versions from the script's output. Then list what is left for the owner:
   - Make the first commit. Commit only when the user asks.
   - Create the GitHub repository: `gh repo create <name> --private --source <target> --push`.
   - Protect `main` so the CI jobs `check` and `title` must pass.
   - Allow only squash merges, with the PR title and body as the commit message:

     ```sh
     gh repo edit --enable-squash-merge --squash-merge-commit-message pr-title-description \
       --enable-merge-commit=false --enable-rebase-merge=false --delete-branch-on-merge
     ```

   - Install the editor support: the "Scala (Metals)" extension, then in `<target>` run
     `mise exec -- scala-cli setup-ide project.scala src` once.
   - Vendor the skills this project needs into the repo: in `<target>`, run
     `npx skills add <source> -s <skill> -a <agents> -y`, without `-g`. `-a` names the harnesses
     that need links, such as `claude-code`; `-y` skips the prompts an agent cannot answer. This
     writes `.agents/skills/` and `skills-lock.json`.
   - For a harness that reads neither `AGENTS.md` nor `CLAUDE.md`, add its file as a one-line
     pointer to `AGENTS.md`, never a copy.

## Changing a gate

Each gate file states its reason in a comment. `DESIGN.md` holds the reasons a file cannot
carry. Read both before you change or loosen a gate.
