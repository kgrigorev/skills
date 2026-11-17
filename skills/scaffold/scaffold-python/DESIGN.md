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
    `tests/conftest.py` fails only when tests are dropped without `-k`, `-m` or `--deselect`.
    `scripts/check` passes none of them, and it clears `PYTEST_ADDOPTS`.
  - A "test must assert" gate: no cheap, reliable tool. Counting passed asserts
    (`pytest_assertion_pass`) would fail every `pytest.raises` test. Review covers it, as it
    covers edits to the gate files; CODEOWNERS would need an owner name the template lacks.
  - `uv audit`, outdated packages and random Hypothesis examples change from day to day. They run
    in the weekly `audit.yml`, which never blocks a merge.
- Python lives only in `src/<module>/` and `tests/` (`test_*.py`, `conftest.py`). A script or
  tool folder elsewhere would be linted but not type-checked or covered; it goes into the
  package with a `[project.scripts]` entry instead.
- The text search in `scripts/check` and ruff's `banned-api` overlap on purpose. The search sees
  comments, which ruff cannot ban; ruff resolves aliases, which a text search cannot.
- `PYTHONHASHSEED=0` makes reruns identical. The cost: a bug that depends on set order stays
  hidden.
- Per-test Hypothesis settings are banned, even ones that run more examples. A test that needs
  more goes into a named profile in `tests/conftest.py`, with the owner's approval.
- `astral-sh/setup-uv` has no major tag, so it is pinned by commit and bumped by hand.

## Keeping the template current

- The template comes from a working project. When you improve a gate in a project made from it,
  port the change here. Then scaffold a scratch project and run its `scripts/check`.
- CI in `kgrigorev/skills` does the same in `.github/workflows/scaffold-python.yml`, weekly too,
  because the scaffold takes the newest dev tools from PyPI. When you bump `uv_version` in
  `scripts/scaffold`, bump `UV_VERSION` in that workflow too.
- Bump `python_minor` in `scripts/scaffold` when a newer minor has been out for about three
  months.
- Project-specific material (domain terms, reference documents) stays out of the template.
- The template works with any set of agent skills. It names no skill and holds no convention that
  comes from one, such as a glossary file or a folder of decision records. A project adds those
  itself.
- The reader profile is an input, not fixed text. How much the comments explain depends on who
  reads the code.
