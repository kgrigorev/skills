# expect: green
# json.loads returns Any; the code narrows it with isinstance into a TypedDict, as
# CODING_STANDARDS.md asks.
cat >src/sample_tool/config.py <<'PY'
"""Read the tool's settings from JSON."""

import json
from typing import TypedDict


class Settings(TypedDict):
    """The settings the tool reads."""

    name: str
    retries: int


class SettingsError(ValueError):
    """The JSON does not hold valid settings."""


def parse_settings(text: str) -> Settings:
    """Read settings such as {"name": "x", "retries": 3}.

    Raises:
        SettingsError: a field is missing or has the wrong type.
    """
    data: object = json.loads(text)
    if not isinstance(data, dict):
        msg = "settings must be a JSON object"
        raise SettingsError(msg)
    name = data.get("name")
    retries = data.get("retries")
    # bool is a subclass of int, so `true` would pass the int check alone.
    if isinstance(retries, bool) or not isinstance(retries, int):
        msg = "retries must be an integer"
        raise SettingsError(msg)
    if not isinstance(name, str):
        msg = "name must be a string"
        raise SettingsError(msg)
    return Settings(name=name, retries=retries)
PY
cat >tests/test_config.py <<'PY'
"""Tests for reading settings."""

import pytest

from sample_tool.config import Settings, SettingsError, parse_settings


def test_parse_settings_reads_both_fields() -> None:
    settings = parse_settings('{"name": "x", "retries": 3}')
    assert settings == Settings(name="x", retries=3)


@pytest.mark.parametrize(
    "text",
    [
        "[]",
        '{"name": "x"}',
        '{"name": 1, "retries": 3}',
        '{"name": "x", "retries": true}',
    ],
)
def test_parse_settings_rejects_bad_settings(text: str) -> None:
    with pytest.raises(SettingsError):
        parse_settings(text)
PY
