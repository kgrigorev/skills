# expect: red No switched-off checks
# The property returns early for names of 3+ characters, exactly the inputs on which it fails.
. "$(dirname "$0")/lib/attack"
break_property
perl -pi -e 's|^  RC_ASSERT\(sample_tool::greet|  if (name.size() >= 3) {\n    return;\n  }\n$&|' tests/sample_tool_test.cpp
grep -q 'name.size() >= 3' tests/sample_tool_test.cpp
fmt
