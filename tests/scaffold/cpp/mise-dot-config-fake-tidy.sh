# expect: red Lint (clang-tidy
# .config/mise.toml puts a fake clang-tidy first on PATH.
. "$(dirname "$0")/lib/attack"
cast_body | add_extra
fmt
fake_tidy tools
mkdir -p .config
printf '[env]\n_.path = ["{{config_root}}/../tools"]\n' >.config/mise.toml
