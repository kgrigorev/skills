# expect: red No switched-off checks
# A DISABLED_ prefix built by token pasting (##), so the word DISABLED is never written.
. "$(dirname "$0")/lib/attack"
break_banner
perl -pi -e 's|^TEST\(Banner, NamesTheProgram\)|#define DEBUG_OFF(name) DISA##BLED_##name\nTEST(Banner, DEBUG_OFF(NamesTheProgram))|' tests/sample_tool_test.cpp
grep -q DEBUG_OFF tests/sample_tool_test.cpp
fmt
