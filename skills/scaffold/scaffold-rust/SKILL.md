---
name: scaffold-rust
description: Create a new Rust project with agent instructions and deterministic quality gates (format, Clippy, dependency rules, warnings as errors, tests, git hook, CI, agent stop hook). Use when the user wants to start, scaffold or bootstrap a Rust project or crate.
---

# Scaffold a Rust project

The template makes a single-crate Cargo project that agents can work in safely. One script,
`scripts/check`, holds every quality gate, and every runner calls it: people, the git hook, CI
and the agent hook. The rules for agents live in `AGENTS.md`. The quality floor comes from the
gates, so it holds whether or not an agent follows the rules.

mise installs every tool at a pinned version: Rust through rustup (the version is in
`rust-toolchain.toml`), plus cargo-nextest, cargo-deny and cargo-shear (in `mise.toml`, with
checksums in `mise.lock`).

Paths below are relative to this skill's folder unless they start with `<target>`.

## Steps

1. **Inputs.** Get four values. Take them from the request and ask once for the missing ones.
   - Target folder. It may exist, for example a fresh `gh repo clone`; the script never
     overwrites a file.
   - Package name: lower-case words joined by `-`. Offer the folder name as the default. Rust
     code names the crate with `_`: `my-tool` becomes `my_tool`.
   - Synopsis: one noun phrase, capitalised, no final period, for example
     `A Rust tool that renames photos`. It goes into `Cargo.toml`, `README.md`, `AGENTS.md`, the
     library's doc comment and the stub's banner.
   - Reader: who reads the code. Never guess it. A noun phrase that completes "The reader
     is ...". It starts in lower case and has no final period, for example
     `a Go developer new to Rust`. It goes into `AGENTS.md` and `CODING_STANDARDS.md` and sets
     how much the comments explain.

   No input may hold double quotes, backslashes, backticks or `{{`.

   Done when you have all four.

2. **Render.** Run `sh scripts/scaffold <target> <package> "<synopsis>" "<reader>"`. The script
   asks mise for the newest Rust, cargo-nextest, cargo-deny and cargo-shear, copies the
   template, fills in the names, the reader and the versions, installs the tools, adds proptest
   with `cargo add` (this writes `Cargo.lock`), formats the code, runs `git init` when needed and
   enables the hooks in `.githooks/`. It needs the network.
   - mise is missing: propose `brew install mise` (macOS). Run it only after the user agrees,
     then retry. Without Homebrew, point to the installers on mise.jdx.dev and stop.
   - A file exists: report it and stop. The user's files stay untouched.

   Done when the script prints `Created ...`, the versions and the file list.

3. **Verify.** Run `<target>/scripts/check`. Done when its last line is `All checks passed.`
   On red, read the output. A likely cause is a new Clippy lint that fires on the stub, or a
   setting in `~/.cargo/config.toml` that the check names. Fix it in `<target>`, or tell the
   user which line of their own config to move. When the template is at fault, tell the user
   what to change in `kgrigorev/skills`. This installed copy is overwritten on update. After two
   honest attempts, stop and report what is red.

4. **Hand over.** Report in one table: package, crate, folder and the pinned versions from the
   script's output. Then list what is left for the owner:
   - Make the first commit. Commit only when the user asks.
   - Create the GitHub repository: `gh repo create <name> --private --source <target> --push`.
   - Protect `main` so the CI jobs `check` and `title` must pass. Do not require the jobs in
     `scheduled.yml`: their result changes with time.
   - Allow only squash merges, with the PR title and body as the commit message:

     ```sh
     gh repo edit --enable-squash-merge --squash-merge-commit-message pr-title-description \
       --enable-merge-commit=false --enable-rebase-merge=false --delete-branch-on-merge
     ```

   - Install rust-analyzer for the pinned Rust:
     `mise exec -- rustup component add rust-analyzer`.
   - Vendor the skills this project needs into the repo: in `<target>`, run
     `npx skills add <source> -s <skill> -a <agents> -y`, without `-g`. `-a` names the harnesses
     that need links, such as `claude-code`; `-y` skips the prompts an agent cannot answer. This
     writes `.agents/skills/` and `skills-lock.json`.
   - For a harness that reads neither `AGENTS.md` nor `CLAUDE.md`, add its file as a one-line
     pointer to `AGENTS.md`, never a copy.

## Changing a gate

Each gate file states its reason in a comment. `DESIGN.md` holds the reasons a file cannot
carry. Read both before you change or loosen a gate.
