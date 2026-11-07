#!/usr/bin/env python3
"""Snapshot of a mise project, to orient in one pass.

Read-only: it never installs, trusts, or edits anything. When the project config is
untrusted it inspects in safe mode (MISE_SAFE=1), which loads config without running it.
Env var values are never printed, only names, so secrets stay out of logs.

Usage: mise_env_report.py [project-dir]   (defaults to the current directory)
"""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

USAGE = "Usage: mise_env_report.py [project-dir]"


def section(title: str) -> None:
    print(f"\n## {title}")


def main(argv: list[str]) -> int:
    if argv in (["-h"], ["--help"]):
        print(USAGE)
        return 0
    if len(argv) > 1:
        print(USAGE, file=sys.stderr)
        return 2
    directory = Path(argv[0] if argv else os.getcwd()).resolve()
    if not directory.is_dir():
        print(f"error: not a directory: {directory}", file=sys.stderr)
        return 2
    if shutil.which("mise") is None:
        print("mise is not on PATH: https://mise.jdx.dev/installing-mise.html", file=sys.stderr)
        return 127

    env = dict(os.environ)

    def mise(*args: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["mise", *args],
            cwd=directory,
            env=env,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )

    def show(result: subprocess.CompletedProcess[str], empty: str) -> None:
        text = result.stdout.strip()
        print(text if text else empty)

    section("mise")
    show(mise("--version"), "(unknown version)")
    print(f"directory: {directory}")

    section("trust")
    trust = mise("trust", "--show")
    show(trust, "(no project config)")
    untrusted = "untrusted" in trust.stdout
    if untrusted:
        env["MISE_SAFE"] = "1"
        print(
            "-> config is untrusted. Inspecting in safe mode: project [env], hooks and\n"
            "   tasks are not run. Ask the user before `mise trust`, `mise run` or `mise exec`,\n"
            "   which trust the project and run its code."
        )

    section("config files (closest first)")
    show(mise("config", "ls"), "(none)")

    section("active tools")
    show(mise("ls", "--current"), "(none)")

    section("tasks")
    show(mise("tasks", "ls"), "(none)")

    section("env var names set by mise (values hidden)")
    if untrusted:
        print("(skipped: safe mode ignores project [env])")
    else:
        names = mise("env", "--json")
        try:
            keys = sorted(json.loads(names.stdout))
        except json.JSONDecodeError:
            keys = []
            print(names.stdout.strip() or "(none)")
        secret = mise("env", "--redacted", "--json")
        try:
            redacted = set(json.loads(secret.stdout))
        except json.JSONDecodeError:
            redacted = set()
        for key in keys:
            print(f"  {key}{'  (redacted)' if key in redacted else ''}")

    section("doctor")
    doctor = mise("doctor", "--json")
    try:
        report = json.loads(doctor.stdout)
    except json.JSONDecodeError:
        show(doctor, "(no output)")
    else:
        for label in ("errors", "warnings"):
            for item in report.get(label) or []:
                text = str(item).strip().replace("\n", "\n    ")
                print(f"  {label[:-1]}: {text}")
        if not (report.get("errors") or report.get("warnings")):
            print("  no problems")

    print(
        "\nRun tools with `mise x -- <cmd>` or `mise run <task>`; shell activation does not"
        "\nreach a non-interactive shell."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
