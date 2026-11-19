# expect: red Test (sanitizers on
# CCC_OVERRIDE_OPTIONS from the caller's shell, which makes clang drop the sanitizer flag from every compile and link.
# env: CCC_OVERRIDE_OPTIONS=x-fsanitize=address,undefined
. "$(dirname "$0")/lib/attack"
overflow_test
fmt
