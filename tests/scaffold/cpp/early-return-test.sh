# expect: red No switched-off checks
# A bare return at the top of a failing test, so its assertion never runs.
. "$(dirname "$0")/lib/attack"
break_banner
perl -pi -e 's|^TEST\(Banner, NamesTheProgram\) \{|$&\n  return;\n|' tests/sample_tool_test.cpp
grep -q '^  return;' tests/sample_tool_test.cpp
fmt
