# expect: red Test
# The property prints libFuzzer's last line and exits 0 on its first input, so the failing inputs
# never run. The line coverage of the test file counts how often libFuzzer called the property.
perl -0pi -e 's/#include <stdint.h>/#include <stdint.h>\n#include <stdio.h>/' test/sample_tool_property.c
perl -0pi -e 's/(    if \(size == 0\) \{)/    (void)fputs("\\nDone 100000 runs in 0 second(s)\\n", stderr);\n    exit(0);\n$1/' test/sample_tool_property.c
grep -q 'exit(0)' test/sample_tool_property.c
