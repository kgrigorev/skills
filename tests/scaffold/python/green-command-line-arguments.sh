# expect: green
# The command grows an argument parser; tests call main() with arguments and read stdout.
cat >src/sample_tool/__main__.py <<'PY'
"""The command. It only calls the library, so tests can reach all the logic."""

import argparse
from collections.abc import Sequence

from sample_tool.core import banner, slug


def main(argv: Sequence[str] | None = None) -> None:
    """Print the banner, or the slug of the words given."""
    parser = argparse.ArgumentParser(prog="sample-tool")
    parser.add_argument("words", nargs="*", help="words to turn into a slug")
    args = parser.parse_args(argv)
    words: list[str] = args.words
    print(slug(" ".join(words)) if words else banner())


if __name__ == "__main__":
    main()
PY
cat >tests/test_main.py <<'PY'
"""Tests for the command."""

import pytest

from sample_tool.__main__ import main


def test_main_prints_the_banner(capsys: pytest.CaptureFixture[str]) -> None:
    main([])
    assert capsys.readouterr().out.startswith("sample-tool")


def test_main_prints_the_slug_of_its_words(capsys: pytest.CaptureFixture[str]) -> None:
    main(["Hello", "World"])
    assert capsys.readouterr().out == "hello-world\n"


def test_main_rejects_unknown_options(capsys: pytest.CaptureFixture[str]) -> None:
    with pytest.raises(SystemExit) as exit_info:
        main(["--nope"])
    assert exit_info.value.code == 2
    assert "unrecognized arguments" in capsys.readouterr().err
PY
