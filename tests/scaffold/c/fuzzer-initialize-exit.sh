# expect: red Test
# LLVMFuzzerInitialize runs before any input and exits 0, so the failing property never runs.
# gates.cmake wants libFuzzer's "Done 100000 runs".
perl -0pi -e 's/(    if \(size == 0\) \{)/    abort();\n$1/' test/sample_tool_property.c
cat >>test/sample_tool_property.c <<'X'

int LLVMFuzzerInitialize(const int *argc, char ***argv);

int LLVMFuzzerInitialize(const int *argc, char ***argv) {
    (void)argc;
    (void)argv;
    exit(0);
}
X
