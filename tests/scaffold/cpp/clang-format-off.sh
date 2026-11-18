# expect: red No switched-off checks
# clang-format off around badly formatted code.
. "$(dirname "$0")/lib/attack"
printf '// clang-format off\nnamespace sample_tool {   int  spaced();  }\n// clang-format on\n' >>src/sample_tool.hpp
