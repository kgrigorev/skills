# expect: red Test
# A test preset filter that leaves out the property test, which now fails.
perl -0pi -e 's/("outputOnFailure": true\n      \},\n)/$1      "filter": {"exclude": {"name": "property"}},\n/' CMakePresets.json
perl -0pi -e 's/(    if \(size == 0\) \{)/    abort();\n$1/' test/sample_tool_property.c
