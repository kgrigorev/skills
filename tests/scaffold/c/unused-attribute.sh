# expect: red No switched-off checks
# An unused attribute that hides a dead function from -Wunused-function.
printf '\n[[maybe_unused]] static int dead(void) { return 1; }\n' >>src/sample_tool.c
