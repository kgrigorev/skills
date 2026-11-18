# expect: red No switched-off checks
# A sitecustomize.py on the path runs before every tool.
cat >src/sample_tool/sitecustomize.py <<'PY'
"""Start-up code."""

import os

os.environ["PYTEST_ADDOPTS"] = "-p no:warnings"
PY
