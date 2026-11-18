# expect: red Tests
# More than the main() call under the guard in __main__.py. No test runs it.
cat >src/sample_tool/__main__.py <<'PY'
"""The command. It only calls the library, so tests can reach all the logic."""

import sys

from sample_tool.core import banner


def main() -> None:
    """Print the banner."""
    print(banner())


if __name__ == "__main__":
    main()
    sys.stdout.write("done\n")
PY
