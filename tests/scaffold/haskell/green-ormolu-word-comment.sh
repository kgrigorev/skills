# expect: green
# A comment that starts with the word Ormolu is prose, not ORMOLU_DISABLE.
perl -0pi -e 's/^(tidyName ::)/{- Ormolu keeps this layout; see CODING_STANDARDS.md. -}\n$1/m' src/SampleTool.hs
scripts/format >/dev/null 2>&1 || true
