# expect: red Tool pins in mise.toml and mise.lock
# A [ tools ] header with spaces, another spelling of the section.
perl -pi -e 's/^\[tools\]$/[ tools ]/' mise.toml
grep -q '^\[ tools \]$' mise.toml
