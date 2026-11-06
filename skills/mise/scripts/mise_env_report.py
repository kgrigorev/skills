#!/usr/bin/env python3
"""Fast, structured snapshot of a mise project.

Orients an agent (or human) in an unfamiliar mise repo in one shot instead of
issuing several mise commands by hand. Read-only: it never installs, trusts, or
edits anything.

Usage: mise_env_report.py [project-dir]   (defaults to current directory)
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path

CONFIG_MARKERS = (
    "mise.toml",
    "mise.local.toml",
    ".mise.toml",
    "mise/config.toml",
    ".mise/config.toml",
    ".config/mise.toml",
    ".config/mise/config.toml",
    ".tool-versions",
)

PROBLEM_TOKENS = ("problem", "warn", "error", "untrusted", "missing")


def fail(message: str, *, status: int = 1) -> None:
    print(message, file=sys.stderr)
    raise SystemExit(status)


def print_captured(result: subprocess.CompletedProcess[str]) -> None:
    text = result.stdout
    if text:
        sys.stdout.write(text if text.endswith("\n") else text + "\n")


def emit(result: subprocess.CompletedProcess[str], *, on_fail: str | None = None) -> None:
    print_captured(result)
    if result.returncode != 0 and on_fail:
        print(on_fail)


def hr() -> None:
    print("----------------------------------------------------------------")


def section(title: str) -> None:
    hr()
    print(f"## {title}")
    hr()


def list_config_markers(directory: Path) -> list[str]:
    found = [name for name in CONFIG_MARKERS if (directory / name).exists()]
    found.extend(path.name for path in sorted(directory.glob("mise.*.toml")))
    conf_d = directory / ".config" / "mise" / "conf.d"
    if conf_d.is_dir():
        found.extend(
            path.relative_to(directory).as_posix()
            for path in sorted(conf_d.glob("*.toml"))
        )
    return list(dict.fromkeys(found))


def main(argv: list[str] | None = None) -> None:
    if argv is None:
        argv = sys.argv[1:]
    if argv == ["--help"]:
        print("Usage: mise_env_report.py [project-dir]")
        return
    if len(argv) > 1:
        fail("Usage: mise_env_report.py [project-dir]", status=2)

    directory = Path(argv[0] if argv else os.getcwd())
    try:
        resolved = directory.resolve()
        if not resolved.is_dir():
            raise OSError
    except OSError:
        fail(f"error: cannot cd to {directory}")
    directory = resolved

    def run_mise(*args: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["mise", *args],
            cwd=directory,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )

    if shutil.which("mise") is None:
        fail(
            "mise is not on PATH. Install: https://mise.jdx.dev/installing-mise.html",
            status=127,
        )

    section("mise version")
    print_captured(run_mise("--version"))

    section("directory")
    print(f"inspecting: {directory}")

    section("config files (active, most-specific first)")
    emit(
        run_mise("config"),
        on_fail="(no config detected — this may not be a mise project)",
    )

    print()
    print("config markers found on disk (current dir):")
    markers = list_config_markers(directory)
    if markers:
        for name in markers:
            print(f"  - {name}")
    else:
        print("  (none in this directory; mise may still resolve from a parent)")

    section("trust status")
    emit(run_mise("trust", "--show"), on_fail="(trust status unavailable)")

    section("active tools")
    current = run_mise("ls", "--current")
    if current.returncode == 0:
        print_captured(current)
    else:
        print_captured(run_mise("ls"))

    section("tasks")
    emit(run_mise("tasks"), on_fail="(no tasks defined)")

    section("environment variables from mise (redacted)")
    env = run_mise("env", "--redacted")
    if env.returncode == 0:
        print_captured(env)
    else:
        fallback = run_mise("env")
        if not fallback.stdout:
            print("(no env)")
        else:
            for line in fallback.stdout.splitlines():
                if "=" in line:
                    key, _sep, _value = line.partition("=")
                    print(f"{key}=<value>")
                else:
                    print(line)

    section("doctor (problems only)")
    problems = [
        line
        for line in run_mise("doctor").stdout.splitlines()
        if any(token in line.lower() for token in PROBLEM_TOKENS)
    ]
    print("\n".join(problems) if problems else "no problems reported")

    hr()
    print("Done. Reminder: in non-interactive shells run tools via 'mise exec -- <cmd>' or")
    print("'mise run <task>'; do not rely on 'mise activate'. See the mise skill for details.")


if __name__ == "__main__":
    main()
