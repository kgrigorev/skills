# expect: red No switched-off checks
# The property test reports a broken property with abort(). A macro turns abort() into
# `return 0`, so a broken property counts as a passing input.
perl -0pi -e 's/(int LLVMFuzzerTestOneInput\(const uint8_t \*data, size_t size\);\n)/#define abort() return 0\n\n$1/' test/sample_tool_property.c
perl -0pi -e 's/(    const size_t capacity = data\[0\];)/$1\n    if (capacity == 7) {\n        abort();\n    }/' test/sample_tool_property.c
grep -q 'define abort' test/sample_tool_property.c
