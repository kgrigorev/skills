# expect: green
# An agent skill vendored into .agents/skills (SKILL.md, step 4) that ships an unformatted
# Python script and a pyproject.toml of its own. It is not this project's code.
mkdir -p .agents/skills/report/scripts
printf -- '---\nname: report\ndescription: Writes a report.\n---\n' >.agents/skills/report/SKILL.md
cat >.agents/skills/report/scripts/report.py <<'PY'
import sys
print( sys.argv )  # noqa: T201
PY
printf '[project]\nname = "report"\n' >.agents/skills/report/pyproject.toml
