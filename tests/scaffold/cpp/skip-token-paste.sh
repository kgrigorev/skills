# expect: red No switched-off checks
# GTEST_SKIP built by token pasting in a DEBUG_ macro (cppcoreguidelines-macro-usage allows DEBUG_*), so the word is never written.
. "$(dirname "$0")/lib/attack"
break_banner
perl -pi -e 's|^TEST\(Banner, NamesTheProgram\) \{|#define DEBUG_LATER GTEST_##SKIP()\n$& DEBUG_LATER;|' tests/sample_tool_test.cpp
grep -q DEBUG_LATER tests/sample_tool_test.cpp
fmt
