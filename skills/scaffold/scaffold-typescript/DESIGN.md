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
  an oxlint rule on every `fc.assert`. It installs a global fast-check plugin (fast-check 4.10 or
  later) that fails a property run with another seed or run count, or with plugins of its own (a
  `decorateRun` can report every run as passed). Options passed to `fc.assert` cannot remove a
  global plugin, and a search of the source cannot follow a computed key. The plugin records
  each problem where an `afterEach` in `tests/setup.ts` checks it, so a test that catches the
  plugin's error still fails. A property that failed is recorded without a throw: `fc.check`
  returns the failure instead of throwing it, and `fc.assert` still prints its counterexample.
  A property that is expected to fail cannot be tested this way.
- **The clock and random values in tests are checked at run time.** `tests/setup.ts` wraps
  `Date`, `Math.random`, `performance.now`, `process.hrtime`, `Temporal.Now` and the `crypto`
  random functions, and fails the call when the nearest caller is a file under `tests/`. A search
  of the source cannot see an alias (`const { now } = Date`). Code under `src/` keeps the real
  functions, because a log stamp or retry jitter is fine there. A call with no file on the stack
  (`.then(Math.random)`) counts as a test's. The callers come from structured call sites, with
  `Error.stackTraceLimit` and `Error.prepareStackTrace` set for the capture. The check fails
  closed when a test changed how stacks are captured: `globalThis.Error` swapped, an accessor on
  either property, or a capture that does not show `tests/setup.ts` itself. It uses copies of
  `captureStackTrace`, `Reflect` and the call site's `getFileName` taken before any test runs,
  and plain loops instead of `Array.prototype` and `String.prototype` methods, which a test could
  patch. File names are compared whole. The same `afterEach` fails a test that catches the error.
  `scripts/check` also rejects the plain names (`stackTraceLimit`, `__vitest_worker__`).
- **`TZ=UTC` and `LC_ALL=C` in `scripts/check`.** Dates and numbers print differently per time
  zone and locale (`getHours`, `toLocaleString`), and CI runs in UTC.
- **No install scripts.** `scripts/check` installs with `--ignore-scripts --ignore-pnpmfile`: a
  `prepare` script in `package.json` or a `.pnpmfile.cjs` would run before every gate and could
  replace the tools the gates call. pnpm loads `.pnpmfile.cjs` in `pnpm exec` anyway, so
  `scripts/check` rejects one in any letter case (macOS file names ignore case) before it runs
  pnpm. The template has no lifecycle scripts.
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
- **`eslint/no-await-in-loop` and `typescript/consistent-return`.** Both rejected good code in
  the green controls: a retry loop must await inside the loop, and an exhaustive `switch` over
  a union needs no `default`. With disable comments rejected, an agent could only contort the
  code. tsc's `noImplicitReturns` covers a missing return.
- **Holes that stay open.** Each was tried as an attack and passes the gates. Review catches them
  (`CODING_STANDARDS.md` lists them for the reviewer):
  - An overload signature that promises a narrower return type than the implementation
    (`function parse(t: string): Totals;` over an implementation that returns `unknown`). tsc
    accepts an overload whose return type relates to the implementation's in either direction,
    no oxlint rule compares them, and banning overloads would reject good code.
  - A type guard or assertion function that reads its argument but checks less than it claims.
    Only one that never reads the argument fails (`eslint/no-unused-vars`).
  - A test that catches its own failing assertion (`try { expect(...) } catch { /* flaky */ }`).
    `vitest/no-conditional-expect` covers an `expect` inside `catch` only, and a run-time check
    for swallowed assertion errors would also fail `vi.waitFor` and `expect.poll`, which retry a
    failing assertion on purpose.
  - A test that returns early after a trivial assertion (`if (process.platform !== "win32")
    return;`). `vitest/no-conditional-in-test` would catch it, but it also rejects the `&&`, `?:`
    and `if` that property tests and result checks need.
  - A test that mocks the module it tests (`vi.mock("../src/x.ts")`), and a `catch` that turns
    every error into a default value. Mocking a module under `src/` is often right, and the
    gates cannot tell an expected error from a bug.
  - Clock and random sources other than the wrapped ones: `Intl.DateTimeFormat().format()`
    without a date, `performance.timeOrigin`, `crypto.generateKeySync`, another realm
    (`vm.runInNewContext("Math.random()")`), a worker thread or a child process.
  - A test that reaches vitest's worker state under a computed name and changes its config
    (`requireAssertions`), or that patches a built-in that the clock check does not copy. Code
    in the same process can always undo a check written in JavaScript; the run-time checks stop
    the plain and the accidental cases, and fail closed where they can tell.
  - Plain JavaScript in a file without an extension, loaded with `createRequire` or a dynamic
    `import()` into an `unknown`. The file-type gate rejects known extensions only.
  - A `.ts` file that only `.git/info/exclude` ignores: `git grep` skips it, but tsc and vitest
    use it. It cannot be pushed, so CI fails, but a local run, such as the Stop hook, passes.
  - Edits to the gate files themselves (`scripts/check`, the lint, compiler, formatter and test
    configs, `tests/setup.ts`). Only the owner's review guards them; see CODEOWNERS above.
- **A browser variant.** A browser app needs bundler resolution, the DOM types, `.tsx`, Vite and
  the React lint rules. That is a separate template.

## Keeping the template current

- The template comes from a working project. When you improve a gate in a project made from it,
  port the change here. Then scaffold a scratch project and run its `scripts/check`.
- CI in `kgrigorev/skills` does the same in `.github/workflows/scaffold-typescript.yml`, and
  checks that planted defects fail at the right gate. It then replays every attack in
  `tests/scaffold/typescript/` with `scripts/test-scaffold typescript`: each must fail at its
  gate, and the green controls (good code an agent would write) must pass. When you close a hole,
  add its attack there; when a gate rejects good code, add a green control. When you scaffold
  with a newer mise, bump `MISE_VERSION` at the top of that file to match.
- The tool versions are literal in `template/package.json.tmpl`, `template/mise.toml.tmpl` and
  `devEngines`. Pick versions at least one day old: a younger one makes pnpm write a long
  exclusion list into `pnpm-workspace.yaml`.
- Project-specific material (domain terms, reference documents) stays out of the template.
- The template works with any set of agent skills. It names no skill and holds no convention that
  comes from one, such as a glossary file or a folder of decision records. A project adds those
  itself.
- The reader profile is an input, not fixed text. How much the comments explain depends on who
  reads the code.
