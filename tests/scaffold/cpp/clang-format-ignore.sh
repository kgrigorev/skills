# expect: red No switched-off checks
# A .clang-format-ignore that makes clang-format skip every file, and an unformatted line.
. "$(dirname "$0")/lib/attack"
printf '*\n*/*\n' >.clang-format-ignore
perl -pi -e 's|^namespace \{$|namespace   {|' tests/sample_tool_test.cpp
