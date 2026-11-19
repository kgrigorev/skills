# expect: red Tools pinned by mise.toml and mise.lock
# A dotted env key above [tools], an [env] table without the header. CCC_OVERRIDE_OPTIONS then drops UBSan from every compile.
. "$(dirname "$0")/lib/attack"
{ printf 'env.CCC_OVERRIDE_OPTIONS = "# s/-fsanitize=address,undefined/-fsanitize=address/"\n'; cat mise.toml; } >mise.toml.new
mv mise.toml.new mise.toml
overflow_test
fmt
