# expect: green
# An import needed only for annotations, under TYPE_CHECKING (Python 3.14 evaluates
# annotations lazily), and pathlib with the tmp_path fixture.
cat >src/sample_tool/files.py <<'PY'
"""Count words in files."""

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from pathlib import Path


def count_words(path: Path) -> int:
    """Return the number of words in a UTF-8 text file."""
    return len(path.read_text(encoding="utf-8").split())
PY
cat >tests/test_files.py <<'PY'
"""Tests for counting words."""

from pathlib import Path

from sample_tool.files import count_words


def test_count_words_reads_the_file(tmp_path: Path) -> None:
    path = tmp_path / "words.txt"
    path.write_text("one two\nthree\n", encoding="utf-8")
    assert count_words(path) == 3
PY
