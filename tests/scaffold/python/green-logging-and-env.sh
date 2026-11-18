# expect: green
# Logging, an environment variable read with a default, and tests that use caplog and
# monkeypatch.
cat >src/sample_tool/greet.py <<'PY'
"""Greet the user."""

import logging
import os

logger = logging.getLogger(__name__)


def greeting() -> str:
    """Return a greeting for $USER, or for "friend" when it is not set."""
    name = os.environ.get("USER", "").strip()
    if not name:
        logger.info("USER is not set; greeting a friend")
        name = "friend"
    return f"Hello, {name}!"
PY
cat >tests/test_greet.py <<'PY'
"""Tests for the greeting."""

import logging

import pytest

from sample_tool.greet import greeting


def test_greeting_uses_user(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("USER", "ada")
    assert greeting() == "Hello, ada!"


def test_greeting_without_user_logs(
    monkeypatch: pytest.MonkeyPatch, caplog: pytest.LogCaptureFixture
) -> None:
    monkeypatch.delenv("USER", raising=False)
    with caplog.at_level(logging.INFO):
        assert greeting() == "Hello, friend!"
    assert "USER is not set" in caplog.text
PY
