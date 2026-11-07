# Reasons the template files cannot carry

Every other gate states its reason in a comment in its own file.

- `.claude/settings.json` (JSON has no comments):
  - `sandbox.filesystem.allowWrite` lists cabal's cache and state folders, so `scripts/check`
    runs inside the sandbox without a bypass.
  - `sandbox.excludedCommands` holds `gh *`, because the macOS TLS check fails inside the
    sandbox. It only matches a plain `gh ...` call, without `cd`, a heredoc or a redirect.
  - `attribution` is empty, so commits and PRs describe the change only.
- `.githooks/pre-push` runs on push, not on commit, so small local commits stay fast.
- GHC comes from ghcup, not Homebrew. ghcup keeps several versions side by side, and CI installs
  GHC with ghcup too. Ormolu and HLint stay on Homebrew, since ghcup does not ship them.
- `.gitignore` lists `.idea/`. The Stop hook treats any untracked file as uncommitted work.
- `scripts/check` passes `--ignore-dot-hspec`, because a `.hspec` file can turn every test into a
  dry run.

## Keeping the template current

- The template comes from a working project. When you improve a gate in a project made from it,
  port the change here. Then scaffold a scratch project and run its `scripts/check`.
- Project-specific material (domain terms, reference documents) stays out of the template.
- The template works with any set of agent skills. It names no skill and holds no convention that
  comes from one, such as a glossary file or a folder of decision records. A project adds those
  itself.
- The reader profile is an input, not fixed text. How much the comments explain depends on who
  reads the code.
