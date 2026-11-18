# expect: green
# An enum, an exhaustive match that ends in `case _: assert_never(...)` and a fixture in the
# test file. The last case cannot run, so coverage must not ask for a test of it.
cat >src/sample_tool/status.py <<'PY'
"""The status of a job."""

from enum import Enum, auto
from typing import assert_never


class Status(Enum):
    """Where a job is."""

    WAITING = auto()
    RUNNING = auto()
    DONE = auto()


def label(status: Status) -> str:
    """Return the label shown for a status."""
    match status:
        case Status.WAITING:
            return "waiting"
        case Status.RUNNING:
            return "running"
        case Status.DONE:
            return "done"
        case _:
            assert_never(status)
PY
cat >tests/test_status.py <<'PY'
"""Tests for job status labels."""

import pytest

from sample_tool.status import Status, label


@pytest.fixture
def every_status() -> list[Status]:
    return list(Status)


def test_every_status_has_its_own_label(every_status: list[Status]) -> None:
    labels = [label(status) for status in every_status]
    assert len(set(labels)) == len(every_status)


@pytest.mark.parametrize(
    ("status", "text"), [(Status.WAITING, "waiting"), (Status.DONE, "done")]
)
def test_label(status: Status, text: str) -> None:
    assert label(status) == text
PY
