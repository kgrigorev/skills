# expect: red Lint (clang-tidy
# mise.ci.toml, read when MISE_ENV=ci, puts a fake clang-tidy first on PATH.
. "$(dirname "$0")/lib/attack"
# env: MISE_ENV=ci
cast_body | add_extra
fmt
fake_tidy tools
printf '[env]\n_.path = ["{{config_root}}/tools"]\n' >mise.ci.toml
