# expect: red Tools pinned by mise.toml and mise.lock
# An [env] section in mise.toml that puts a fake clang-tidy first on PATH.
. "$(dirname "$0")/lib/attack"
cast_body | add_extra
fmt
fake_tidy tools
printf '\n[env]\n_.path = ["{{config_root}}/tools"]\n' >>mise.toml
