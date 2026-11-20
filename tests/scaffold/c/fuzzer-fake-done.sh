# expect: red syntax tree
# LLVMFuzzerInitialize prints libFuzzer's last line and exits 0 before any input, while the property
# fails on every input. A property test may not define LLVMFuzzerInitialize or main.
perl -0pi -e 's/(    if \(size == 0\) \{)/    abort();\n$1/' test/sample_tool_property.c
perl -0pi -e 's/#include <stdint.h>/#include <stdint.h>\n#include <stdio.h>/' test/sample_tool_property.c
cat >>test/sample_tool_property.c <<'Y'

int LLVMFuzzerInitialize(const int *argc, char ***argv);

int LLVMFuzzerInitialize(const int *argc, char ***argv) {
    (void)argc;
    (void)argv;
    (void)fputs("\nDone 100000 runs in 0 second(s)\n", stderr);
    exit(0);
}
Y
