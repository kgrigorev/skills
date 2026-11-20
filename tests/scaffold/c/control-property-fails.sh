# expect: red Test
# Control: a property that does not hold fails the property test.
perl -0pi -e 's/(    const size_t capacity = data\[0\];)/$1\n    if (capacity == 7) {\n        abort();\n    }/' test/sample_tool_property.c
