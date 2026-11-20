# expect: green
# A Protocol with `...` bodies and an @overload pair: the stub lines never run.
cat >src/sample_tool/shapes.py <<'PY'
"""Shapes and their areas."""

from dataclasses import dataclass
from typing import Protocol, overload


class Shape(Protocol):
    """Anything with an area."""

    def area(self) -> float:
        """Return the area."""
        ...


@dataclass(frozen=True, slots=True)
class Square:
    """A square."""

    side: float

    def area(self) -> float:
        """Return the area."""
        return self.side * self.side


def total_area(shapes: list[Shape]) -> float:
    """Add up the areas."""
    return sum(shape.area() for shape in shapes)


@overload
def scale(value: int, factor: int) -> int: ...
@overload
def scale(value: float, factor: int) -> float: ...
def scale(value: float, factor: int) -> float:
    """Multiply the value by the factor."""
    return value * factor
PY
cat >tests/test_shapes.py <<'PY'
"""Tests for shapes."""

import pytest

from sample_tool.shapes import Square, scale, total_area


def test_total_area_adds_up() -> None:
    assert total_area([Square(2), Square(3)]) == pytest.approx(13.0)


def test_scale_keeps_ints() -> None:
    assert scale(2, 3) == 6
    assert scale(0.5, 3) == pytest.approx(1.5)
PY
