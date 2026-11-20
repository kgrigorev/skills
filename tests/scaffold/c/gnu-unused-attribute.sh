# expect: red No switched-off checks
# The GNU spelling of the unused attribute.
printf '\n__attribute__((unused)) static int dead(void) { return 1; }\n' >>src/sample_tool.c
