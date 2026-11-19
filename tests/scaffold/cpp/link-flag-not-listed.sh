# expect: red Every project file is compiled
# A link flag outside the list. -Wl,--wrap or -Wl,-alias could swap a sanitizer handler the same way.
. "$(dirname "$0")/lib/attack"
cmake_append 'target_link_options(sample_tool_test PRIVATE -rdynamic)'
