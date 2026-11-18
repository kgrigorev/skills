# expect: red Lint (clang-tidy
# mise.local.toml puts a fake clang-tidy first on PATH.
. "$(dirname "$0")/lib/attack"
cast_body | add_extra
fmt
fake_tidy tools
printf '[env]\n_.path = ["{{config_root}}/tools"]\n' >mise.local.toml
