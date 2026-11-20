# expect: green
# A bool parameter of a parametrized test, and a library function and class named cast and Cast
# (a film's cast), which only the word matches.
cat >src/sample_tool/film.py <<'PY'
"""Films and their cast."""

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class Cast:
    """The actors of a film."""

    actors: tuple[str, ...]


def cast(*actors: str) -> Cast:
    """Build the cast of a film."""
    return Cast(actors)
PY
cat >tests/test_film.py <<'PY'
"""Tests."""

import pytest

from sample_tool.film import cast


@pytest.mark.parametrize(("actors", "empty"), [((), True), (("a",), False)])
def test_cast_is_empty_without_actors(actors: tuple[str, ...], empty: bool) -> None:
    assert (not cast(*actors).actors) is empty
PY
