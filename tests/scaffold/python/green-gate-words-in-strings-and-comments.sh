# expect: green
# Words the switched-off search looks for, in ordinary prose, strings and names: help texts,
# a function named broadcast, memoryview.cast, a skip option, comments about warnings.
cat >src/sample_tool/lines.py <<'PY'
"""Line handling for the command.

Blank lines are skipped. Each field is cast to int where it can be; the cast never
hides an error. Settings for the reader come from the command line.
"""

from collections.abc import Callable, Iterable

SKIP_HELP = "--skip-blank: skip blank lines; a skipped line is not counted"
WARNING_HELP = "Warnings are errors. Use --strict to treat a type: mismatch as fatal."


def skip_blank(lines: Iterable[str]) -> list[str]:
    """Drop the lines that hold only spaces."""
    # Skip blank lines here, so later steps never see them.
    return [line for line in lines if line.strip()]


def broadcast(message: str, listeners: Iterable[Callable[[str], None]]) -> int:
    """Send the message to every listener; return how many got it."""
    count = 0
    for listener in listeners:
        listener(message)
        count += 1
    return count


def byte_values(data: bytes) -> list[int]:
    """Return the bytes as numbers, through memoryview.cast."""
    return list(memoryview(data).cast("B"))


def ignore_case(text: str) -> str:
    """Fold the text so comparisons ignore case."""
    return text.casefold()
PY
cat >tests/test_lines.py <<'PY'
"""Tests for line handling: skip, cast and broadcast."""

from sample_tool.lines import (
    SKIP_HELP,
    WARNING_HELP,
    broadcast,
    byte_values,
    ignore_case,
    skip_blank,
)


def test_skip_blank_drops_blank_lines() -> None:
    assert skip_blank(["a", "  ", "", "b"]) == ["a", "b"]


def test_broadcast_reaches_every_listener() -> None:
    heard: list[str] = []
    assert broadcast("hi", [heard.append, heard.append]) == 2
    assert heard == ["hi", "hi"]


def test_byte_values_cast_bytes_to_numbers() -> None:
    assert byte_values(b"AB") == [65, 66]


def test_ignore_case_folds() -> None:
    assert ignore_case("Straße") == "strasse"


def test_help_texts_name_their_options() -> None:
    # The help texts mention skip and type: words on purpose.
    assert SKIP_HELP.startswith("--skip-blank")
    assert "--strict" in WARNING_HELP
PY
