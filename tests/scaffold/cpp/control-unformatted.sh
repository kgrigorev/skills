# expect: red Format (clang-format
# Control: code that clang-format would change.
. "$(dirname "$0")/lib/attack"
printf 'namespace sample_tool {   int  spaced();  }\n' >>src/sample_tool.hpp
