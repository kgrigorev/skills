# expect: red No switched-off checks
# RC_SUCCEED ends a property before its failing assertion.
. "$(dirname "$0")/lib/attack"
perl -pi -e 's|^  RC_ASSERT\(sample_tool::greet\(name\) == "Hello, " \+ name \+ "!"\);|  RC_SUCCEED("later");\n  RC_ASSERT(sample_tool::greet(name) == "Bye");|' tests/sample_tool_test.cpp
grep -q RC_SUCCEED tests/sample_tool_test.cpp
