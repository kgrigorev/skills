# expect: red after macro expansion
# __attribute__ behind a macro, so the source search does not see it next to "unused".
printf '\n#define SAMPLE_ATTR __attribute__\nSAMPLE_ATTR((unused)) static int dead(void) { return 1; }\n' >>src/sample_tool.c
