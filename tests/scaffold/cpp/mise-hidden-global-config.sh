# expect: red Test (sanitizers on
# A file at the global config path that scripts/check gives mise, in the git-ignored build folder. Its env would drop UBSan; the check deletes it first.
. "$(dirname "$0")/lib/attack"
mkdir -p build
printf '[env]\nCCC_OVERRIDE_OPTIONS = "# s/-fsanitize=address,undefined/-fsanitize=address/"\n' >build/no-mise-config.toml
overflow_test
fmt
