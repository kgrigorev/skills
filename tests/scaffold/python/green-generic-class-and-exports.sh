# expect: green
# A PEP 695 generic class, re-exports through __all__ in __init__.py, functools.cache and an
# exception chained with `from`.
cat >src/sample_tool/stack.py <<'PY'
"""A last-in, first-out stack."""

from functools import cache


class EmptyStackError(LookupError):
    """pop() on an empty stack."""


class Stack[T]:
    """A stack of items."""

    def __init__(self) -> None:
        """Start empty."""
        self._items: list[T] = []

    def push(self, item: T) -> None:
        """Put an item on top."""
        self._items.append(item)

    def pop(self) -> T:
        """Take the top item off.

        Raises:
            EmptyStackError: the stack is empty.
        """
        try:
            return self._items.pop()
        except IndexError as error:
            msg = "pop from an empty stack"
            raise EmptyStackError(msg) from error

    def __len__(self) -> int:
        """Return the number of items."""
        return len(self._items)


@cache
def fibonacci(index: int) -> int:
    """Return the Fibonacci number at the index."""
    if index <= 1:
        return index
    return fibonacci(index - 1) + fibonacci(index - 2)
PY
cat >src/sample_tool/__init__.py <<'PY'
"""A sample tool that tests the template."""

from sample_tool.stack import EmptyStackError, Stack, fibonacci

__all__ = ["EmptyStackError", "Stack", "fibonacci"]
PY
cat >tests/test_stack.py <<'PY'
"""Tests for the stack."""

import pytest

from sample_tool import EmptyStackError, Stack, fibonacci


def test_push_then_pop_returns_the_last_item() -> None:
    stack: Stack[int] = Stack()
    stack.push(1)
    stack.push(2)
    assert stack.pop() == 2
    assert len(stack) == 1


def test_pop_on_empty_stack_raises() -> None:
    with pytest.raises(EmptyStackError, match="empty"):
        Stack[str]().pop()


def test_fibonacci() -> None:
    assert [fibonacci(n) for n in range(7)] == [0, 1, 1, 2, 3, 5, 8]
PY
