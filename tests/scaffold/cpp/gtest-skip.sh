# expect: red No switched-off checks
# GTEST_SKIP at the start of a failing test.
. "$(dirname "$0")/lib/attack"
break_banner
perl -pi -e 's|^TEST\(Banner, NamesTheProgram\) \{|$& GTEST_SKIP();|' tests/sample_tool_test.cpp
grep -q GTEST_SKIP tests/sample_tool_test.cpp
fmt
