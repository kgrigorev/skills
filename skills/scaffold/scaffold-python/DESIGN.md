# Reasons the template files cannot carry

Every other gate states its reason in a comment in its own file.

- `.claude/settings.json` (JSON has no comments):
  - `sandbox.filesystem.allowWrite` lists uv's cache (`~/.cache/uv`) and Python folder
    (`~/.local/share/uv`), and mise's data, state and cache folders. `scripts/check` runs again
    under mise when the uv on `PATH` has the wrong version, so mise must be able to write too.
    The mise cache is `~/Library/Caches/mise` on macOS and `~/.cache/mise` on Linux.
  - `sandbox.excludedCommands` holds `gh *`, because the macOS TLS check fails inside the
    sandbox. It only matches a plain `gh ...` call, without `cd`, a heredoc or a redirect.
  - `attribution` is empty, so commits and PRs describe the change only.
- `.githooks/pre-push` runs on push, not on commit, so small local commits stay fast.
- `uv.lock` and `mise.lock` are not templates. The scaffold generates them, so they hold real
  hashes.
- One uv version, enforced by uv itself: `required-version` in `pyproject.toml`. CI gets it from
  `astral-sh/setup-uv`, which reads that line. People and agents get it from `mise.toml`, with
  the checksum in `mise.lock`. If the two drift, uv fails with "Required uv version ... does not
  match", so drift cannot pass silently. CI does not use mise: one tool fewer for one binary.
- `scripts/check` runs itself again under `mise exec` only when the uv on `PATH` is wrong. Agent
  shells do not activate mise, and the git hook and Stop hook call plain `scripts/check`.
- Python: the scaffold pins the newest minor that has been out for about three months (now
  3.14), not the newest minor. Compiled dependencies need time to ship wheels for a new minor.
- The dev tools are the newest at scaffold time, written as exact `==` pins. A floor such as
  `ruff>=0.17` would let a fresh lock change the rules.
- Gates left out on purpose:
  - Random test order and test timeouts: both make results change between runs.
  - A second type checker in the gate: duplicate findings in other words, and agents would fight
    two checkers. Pyright is only the editor's language server; mypy decides.
  - `ruff check --preview`: preview rules change between patch releases.
  - Failing on every deselected test: it would break `uv run pytest -k name`.
    `tests/conftest.py` fails only when tests are dropped without `-k`, `-m`, `--deselect`,
    `--lf` or `--sw`. `scripts/check` passes none of them, and it clears `PYTEST_ADDOPTS`.
  - A "test must assert" gate: no cheap, reliable tool. Counting passed asserts
    (`pytest_assertion_pass`) would fail every `pytest.raises` test, and a static "has an
    assert" rule passes `assert True` and rejects tests that call an asserting helper.
    Mutation testing would catch it but is slow. Review covers it, as it covers edits to the
    gate files (`scripts/check`, `pyproject.toml` `[tool.*]`, `tests/conftest.py`, `.github/`);
    CODEOWNERS would need an owner name the template lacks, and hashing the gate files would
    only move the edit to the hash.
  - `Any` that flows into a typed name (`value: int = json.loads(text)["port"]`). The only mypy
    check is `disallow_any_expr`, which also rejects `@given`, pytest's hook decorators and
    `json.loads` itself, even in `data: object = json.loads(text)`. CODING_STANDARDS.md asks to
    narrow such values at the boundary; review covers it.
  - `uv audit`, outdated packages and random Hypothesis examples change from day to day. They run
    in the weekly `audit.yml`, which never blocks a merge.
- Python lives only in `src/<module>/` and `tests/` (`test_*.py`, `conftest.py`). A script or
  tool folder elsewhere would be linted but not type-checked or covered; it goes into the
  package with a `[project.scripts]` entry instead.
- The text search in `scripts/check` and ruff's `banned-api` overlap on purpose. The search sees
  comments, which ruff cannot ban; ruff resolves aliases, which a text search cannot. Shapes
  that neither sees (an `else` after `if TYPE_CHECKING:`, a function renamed to `assert_never`,
  a test that expects a failing assert) are found in the parsed code (`ast`). What a test really
  runs with is checked at run time in `tests/conftest.py`: tests that a module defines but
  pytest does not collect, Hypothesis tests whose settings are not the active profile, and:
  - failures and tests that never ran, from the conftest's own record, not from pytest's counts,
    which a test can change (`session.testsfailed = 0`);
  - a test that registers or removes a pytest plugin: such a plugin can rewrite any report, so
    the run stops at once (`os._exit`). The one plugin pytest adds on the way (the `--lf`
    helper) is allowed by exact class and name, not by module;
  - a session whose final check never ran, for example because a test unregistered the
    conftest: an `atexit` handler fails the run. Tests may not use `atexit`, `os.exec*`,
    `os.spawn*`, `os.fork`, `posix`, `nt` or `ctypes`, which could replace the exit status
    after pytest;
  - the collect-only option as it was at startup, so a test cannot set it to skip the final
    check;
  - a passing test during which code caught an `AssertionError`, seen through
    `sys.monitoring` (`EXCEPTION_HANDLED`). This catches a failing assert swallowed by any name
    or context manager, which no static check can list. The monitoring tool is checked after
    each test, and tests may not use `sys.monitoring`;
  - a test whose warning filters differ from the ones pytest set up (`recwarn`,
    `resetwarnings`, a changed `warnings.filters`).
- `PYTHONHASHSEED=0` makes reruns identical. The cost: a bug that depends on set order stays
  hidden.
- Per-test Hypothesis settings are banned, even ones that run more examples. A test that needs
  more goes into a named profile in `tests/conftest.py`, with the owner's approval.
- `astral-sh/setup-uv` has no major tag, so it is pinned by commit and bumped by hand.
- `norecursedirs` lists only caches. pytest's default skips `build`, `dist`, `venv` and hidden
  folders without a word, so `tests/build/test_x.py` would never run. mypy still skips hidden
  folders, so the layout check rejects them.
- What coverage skips is decided by coverage's own parser, not by a search for its patterns:
  every line it excludes in the package must be one of the shapes that hide no code that runs.
  coverage matches its patterns over the whole file, across line breaks and inside strings.
- `.agents/` holds vendored agent skills. Nothing imports them, so ruff, the searches and the
  layout check skip the folder at the root; their Python would otherwise break the gates.
- `HYPOTHESIS_NO_PLUGINS=1`: Hypothesis runs code from installed packages' `hypothesis` entry
  points when it is imported, before `tests/conftest.py`, and `--disable-plugin-autoload` does
  not cover that.

## Not closed

Only the owner's review of every change catches these:

- Code that patches pytest, Hypothesis or `tests/conftest.py` itself at run time, for example
  through `type.__setattr__`, `getattr` with built names or `sys.modules`. Each run-time check
  can be switched off by code that runs before it; the checks close the plain forms.
- Reflection on private Hypothesis modules (`getattr(hypothesis, "_settings")`). The ast check
  rejects only their imports.
- A test without an assert (see above), and a test whose assert cannot fail.
- Changing module state of the standard library through `vars()` or built names, for example
  adding a warning filter with `vars(warnings)["filters"]` and removing it before the test
  ends. The run-time check compares the filters only before and after the test.
- A failing assert swallowed where `sys.monitoring` does not see it: in C code (a sqlite3
  user function, a `concurrent.futures` worker read with `future.exception()`), or in a
  fixture or teardown, which the caught-assert check does not watch.
- A tampered `.venv` or a local `.git/config`: they change only the local run. CI starts clean.

## Keeping the template current

- The template comes from a working project. When you improve a gate in a project made from it,
  port the change here. Then scaffold a scratch project and run its `scripts/check`.
- CI in `kgrigorev/skills` does the same in `.github/workflows/scaffold-python.yml`, weekly too,
  because the scaffold takes the newest dev tools from PyPI. It then replays the attacks in
  `tests/scaffold/python/` with `scripts/test-scaffold python`: each bad change must fail at its
  step, and each `green-*` control must pass. A gate change comes with a case there. When you bump `uv_version` in
  `scripts/scaffold`, bump `UV_VERSION` in that workflow too.
- Bump `python_minor` in `scripts/scaffold` when a newer minor has been out for about three
  months.
- Project-specific material (domain terms, reference documents) stays out of the template.
- The template works with any set of agent skills. It names no skill and holds no convention that
  comes from one, such as a glossary file or a folder of decision records. A project adds those
  itself.
- The reader profile is an input, not fixed text. How much the comments explain depends on who
  reads the code.
