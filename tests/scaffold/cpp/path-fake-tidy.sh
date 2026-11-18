# expect: red Lint (clang-tidy
# A fake clang-tidy first on the caller PATH.
. "$(dirname "$0")/lib/attack"
# env: PATH=tools:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin
cast_body | add_extra
fmt
fake_tidy tools
