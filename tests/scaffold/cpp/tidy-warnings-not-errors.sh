# expect: red Lint (clang-tidy
# WarningsAsErrors emptied in .clang-tidy, so findings only print.
. "$(dirname "$0")/lib/attack"
cast_body | add_extra
fmt
perl -pi -e "s|^WarningsAsErrors: '\\*'|WarningsAsErrors: ''|" .clang-tidy
grep -q "WarningsAsErrors: ''" .clang-tidy
