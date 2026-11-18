# expect: red No switched-off checks
# A .clang-format in a subfolder that turns formatting off there.
. "$(dirname "$0")/lib/attack"
printf 'DisableFormat: true\n' >src/.clang-format
printf 'namespace sample_tool {   int  spaced();  }\n' >>src/sample_tool.hpp
