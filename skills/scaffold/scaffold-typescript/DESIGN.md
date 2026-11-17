# Reasons the template files cannot carry

Every other gate states its reason in a comment in its own file.

## Files without comments

- `package.json` (JSON has no comments):
  - Every devDependency has an exact version, and `pnpm-lock.yaml` adds integrity hashes.
  - `devEngines` repeats the Node and pnpm versions from `mise.toml` with `onFail: "error"`.
    mise installs the tools; `devEngines` is the guard. pnpm refuses a wrong Node or pnpm,
    however it got on `PATH`, and npm refuses to run at all, so no agent can write a
    `package-lock.json`. Change both files together. A drift fails on the next pnpm command.
  - The `scripts` exist for people and agents (`pnpm test`, `pnpm fmt`), and because knip reads
    them. Without them knip reports oxlint, oxfmt and oxlint-tsgolint as unused, and the `start`
    script is what makes `src/main.ts` an entry point. `scripts/check` does not call them; it
    holds the exact flags itself.
- `.claude/settings.json`:
  - `sandbox.filesystem.allowWrite` lists the pnpm store and cache and the mise folders on macOS
    and Linux, so `scripts/check` runs inside the sandbox without a bypass. `node_modules/` is
    inside the project and needs no entry.
  - `sandbox.excludedCommands` holds `gh *`, because the macOS TLS check fails inside the
    sandbox. It only matches a plain `gh ...` call, without `cd`, a heredoc or a redirect.
  - `attribution` is empty, so commits and PRs describe the change only.
- `.githooks/pre-push` runs on push, not on commit, so small local commits stay fast.

## Tool choices

- **Node, not Bun or Deno.** Node 26 runs `.ts` files directly (type stripping), so there is no
  build step. Bun's test runner cannot fail on skipped tests. Deno's lint has no rules that use
  the type checker.
- **pnpm, not npm.** An import of a package that is not declared fails, install scripts are
  blocked, new releases wait one day (`minimumReleaseAge`), and the lockfile depends only on the
  dependency graph.
- **mise for Node and pnpm.** pnpm could download Node itself (`devEngines` with
  `onFail: "download"`), but then the editor and a plain `node src/main.ts` would see a
  different Node. mise puts the exact versions on `PATH` for everything, checks them against
  `mise.lock`, and CI reads the same files. The scaffold does not run `mise trust`: mise runs a
  `mise.toml` that holds only `[tools]` and `[settings]` without a trust record. CI sets
  `MISE_TRUSTED_CONFIG_PATHS` in case that default changes.
- **TypeScript 7 (the native `tsc`).** About ten times faster than TypeScript 6. Its defaults
  (strict on, no `@types` loaded, no `baseUrl`) match the template.
- **oxlint with oxlint-tsgolint, not ESLint with typescript-eslint.** typescript-eslint still
  needs TypeScript below 6.1, so it would need a second compiler next to TypeScript 7, and the
  two could disagree. oxlint's type-aware rules run on TypeScript 7 and cover almost all of
  typescript-eslint's type-aware rules. oxlint-tsgolint embeds its own TypeScript: bump it
  together with `typescript`. Two rules in `.oxlintrc.json` are in oxlint's `nursery` group
  (`no-unnecessary-condition`, `prefer-optional-chain`); the exact pin keeps them stable. Revisit
  when typescript-eslint supports TypeScript 7.
- **oxfmt, not Prettier.** Prettier's output style, much faster, and it formats JSON, YAML and
  Markdown too. It is still 0.x, so an upgrade may reformat files. Prettier is the fallback.
- **vitest, not `node:test`.** `node:test` ignores `.only` silently and passes `.skip` and
  `.todo`. vitest has `allowOnly`, `passWithNoTests` and `requireAssertions`. The reporter in
  `vitest.config.ts` uses vitest's public reporter API; an API change shows up as a type error on
  upgrade.
- **fast-check with a fixed seed.** Same commit, same result. To explore new inputs, change the
  seed in its own commit. `tests/setup.ts` uses `import * as fc` because the default import trips
  an oxlint rule on every `fc.assert`.
- **knip.** Unused files, exports and dependencies are the debris agents leave most. knip always
  treats exports tagged `@public`, `@beta` or `@alias` as used, and no setting turns that off, so
  `scripts/check` rejects those tags instead.

## Gates left out on purpose

- **pnpm's lockfile supply-chain policy.** It needs the registry, hangs without network, and a
  lockfile that fails today because a package is too young passes tomorrow. `scripts/check`
  passes `--trust-lockfile`; CI job `lockfile-policy` runs the policy and is not a required
  check. `pnpm add` applies the same policy locally.
- **`pnpm audit` and `pnpm outdated`.** The advisory database and the registry change daily. Use
  Dependabot alerts instead.
- **A coverage threshold.** Agents learn to meet a number with shallow tests. "New behaviour
  comes with a test" and `requireAssertions` target the real failure.
- **`isolatedDeclarations`.** It exists to emit `.d.ts` files for published libraries. Here it
  only adds noise.
- **Rejecting `.npmrc`, `vite.config.*` or a second `vitest.config.*`.** Tested to have no effect:
  pnpm reads its settings from `pnpm-workspace.yaml` only, and every tool gets its config file
  named on the command line. A `.mts` config fails the file-type gate anyway.
- **CODEOWNERS for the gate files.** It needs an owner name the template lacks, and with
  "Require review from Code Owners" a solo owner cannot merge the PRs an agent opens under
  their account. Gate-file edits show in every PR diff, and `AGENTS.md` asks for approval.
- **`knip --production`.** It would catch exports that only tests use, but it needs `src/main.ts!`
  as an entry, which the default run then reports as a redundant pattern
  (`--treat-config-hints-as-errors`). Review covers test-only exports (`CODING_STANDARDS.md`).
- **A `catch` that only holds a comment.** `eslint/no-empty` accepts it, and it at least names
  why the error is dropped. Review judges the reason.
- **A browser variant.** A browser app needs bundler resolution, the DOM types, `.tsx`, Vite and
  the React lint rules. That is a separate template.

## Keeping the template current

- The template comes from a working project. When you improve a gate in a project made from it,
  port the change here. Then scaffold a scratch project and run its `scripts/check`.
- CI in `kgrigorev/skills` does the same in `.github/workflows/scaffold-typescript.yml`, and
  checks that planted defects fail at the right gate. When you scaffold with a newer mise, bump
  `MISE_VERSION` at the top of that file to match.
- The tool versions are literal in `template/package.json.tmpl`, `template/mise.toml.tmpl` and
  `devEngines`. Pick versions at least one day old: a younger one makes pnpm write a long
  exclusion list into `pnpm-workspace.yaml`.
- Project-specific material (domain terms, reference documents) stays out of the template.
- The template works with any set of agent skills. It names no skill and holds no convention that
  comes from one, such as a glossary file or a folder of decision records. A project adds those
  itself.
- The reader profile is an input, not fixed text. How much the comments explain depends on who
  reads the code.
