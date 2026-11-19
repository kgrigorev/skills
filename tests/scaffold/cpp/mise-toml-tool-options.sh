# expect: red Tools pinned by mise.toml and mise.lock
# A tool entry as an inline table, which can carry options such as postinstall.
. "$(dirname "$0")/lib/attack"
perl -pi -e 's|^ninja = "([^"]*)"$|ninja = { version = "$1", postinstall = "true" }|' mise.toml
grep -q postinstall mise.toml
