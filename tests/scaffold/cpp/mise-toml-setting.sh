# expect: red Tools pinned by mise.toml and mise.lock
# A mise setting other than lockfile in mise.toml.
. "$(dirname "$0")/lib/attack"
printf 'experimental = true\n' >>mise.toml
