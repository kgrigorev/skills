---
name: scaffold-go
description: Create a new Go project with agent instructions and deterministic quality gates (pinned toolchain, format, lint, tests with the race detector, git hook, CI, agent stop hook). Use when the user wants to start, scaffold or bootstrap a Go project.
---

# Scaffold a Go project

The template makes a Go module that agents can work in safely. One script, `scripts/check`,
holds every quality gate, and every runner calls it: people, the git hook, CI and the agent
hook. mise pins Go and golangci-lint exactly, so every machine runs the same tools. The rules
for agents live in `AGENTS.md`. The quality floor comes from the gates, so it holds whether or
not an agent follows the rules.

Paths below are relative to this skill's folder unless they start with `<target>`.

## Steps

1. **Inputs.** Get four values. Take them from the request and ask once for the missing ones.
   - Target folder. It may exist, for example a fresh `gh repo clone`; the script never
     overwrites a file. When the folder has a GitHub `origin` remote, the module path is
     `github.com/<owner>/<repo>`. Otherwise it is `example.com/<package>`, which the owner must
     rename before anyone imports the module. So for a GitHub project, clone the empty
     repository first.
   - Package name: lower-case words joined by `-`. Offer the folder name as the default. The Go
     package name drops the dashes: `my-tool` becomes `mytool`. It must not be a Go keyword or
     `main`.
   - Synopsis: one noun phrase, capitalised, no final period, for example
     `A Go tool that renames photos`. It goes into `README.md`, `AGENTS.md`, the package comment
     and the stub's banner.
   - Reader: who reads the code. Never guess it. A noun phrase that completes "The reader
     is ...". It starts in lower case and has no final period, for example
     `a Python developer new to Go`. It goes into `AGENTS.md` and `CODING_STANDARDS.md` and sets
     how much the comments explain.

   Done when you have all four.

2. **Render.** Run `sh scripts/scaffold <target> <package> "<synopsis>" "<reader>"`. The script
   copies the template and fills in the names and the reader. Then it trusts the project's
   `mise.toml`, writes `mise.lock`, installs the pinned Go and golangci-lint, writes `go.sum`,
   formats the Go files, runs `git init` when needed and enables the hooks in `.githooks/`. The
   versions are fixed at the top of `scripts/scaffold`, not taken from your machine.
   - It needs the network: `proxy.golang.org`, `sum.golang.org`, `dl.google.com` and
     `github.com`. Inside a sandbox, ask the user before you run it outside the sandbox.
   - mise or git is missing: propose `brew install mise git` (macOS). Run it only after the user
     agrees, then retry. Without Homebrew, point to <https://mise.jdx.dev> and stop.
   - A file exists: report it and stop. The user's files stay untouched.

   Done when the script prints `Created ...` and the file list.

3. **Verify.** Run `<target>/scripts/check`. It runs under the pinned tools by itself, also
   when mise is not activated in your shell. Done when its last line is `All checks passed.`
   On red, read the output and fix the cause in `<target>`. When the template is at fault, tell
   the user what to change in `kgrigorev/skills`. This installed copy is overwritten on update.
   After two honest attempts, stop and report what is red.

4. **Hand over.** Report in one table: package, Go package, module path, folder and the pinned
   versions from the script's output. Then list what is left for the owner:
   - Make the first commit. Commit only when the user asks.
   - Create the GitHub repository: `gh repo create <name> --private --source <target> --push`.
     When the module path starts with `example.com/`, first run
     `mise exec -- go mod edit -module github.com/<owner>/<name>` in `<target>`, then update the
     two imports of the module path (in `cmd/<package>/main.go` and the test file) and the
     module path line in `AGENTS.md`, and rerun `scripts/check`.
   - Protect `main` so the CI jobs `check` and `title` must pass.
   - Allow only squash merges, with the PR title and body as the commit message:

     ```sh
     gh repo edit --enable-squash-merge --squash-merge-commit-message pr-title-description \
       --enable-merge-commit=false --enable-rebase-merge=false --delete-branch-on-merge
     ```

   - Activate mise in the shell, so `go` on `PATH` is the pinned one
     (<https://mise.jdx.dev/getting-started.html>).
   - Install gopls for the editor; the command is in `<target>/README.md`.
   - Vendor the skills this project needs into the repo: in `<target>`, run
     `npx skills add <source> -s <skill> -a <agents> -y`, without `-g`. `-a` names the harnesses
     that need links, such as `claude-code`; `-y` skips the prompts an agent cannot answer. This
     writes `.agents/skills/` and `skills-lock.json`.
   - For a harness that reads neither `AGENTS.md` nor `CLAUDE.md`, add its file as a one-line
     pointer to `AGENTS.md`, never a copy.

## Changing a gate

Each gate file states its reason in a comment. `DESIGN.md` holds the reasons a file cannot
carry. Read both before you change or loosen a gate.
