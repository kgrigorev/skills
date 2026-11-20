# expect: red Tools pinned by mise.toml and mise.lock
# A tool version in mise.toml that mise.lock does not pin.
. "$(dirname "$0")/lib/attack"
perl -pi -e 's|^cmake = "[^"]*"|cmake = "4.4.0"|' mise.toml
grep -q '^cmake = "4.4.0"' mise.toml
