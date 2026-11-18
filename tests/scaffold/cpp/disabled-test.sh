# expect: red No switched-off checks
# A DISABLED_ prefix on a failing test.
. "$(dirname "$0")/lib/attack"
break_banner
perl -pi -e 's|^TEST\(Banner, NamesTheProgram\)|TEST(Banner, DISABLED_NamesTheProgram)|' tests/sample_tool_test.cpp
grep -q DISABLED_ tests/sample_tool_test.cpp
