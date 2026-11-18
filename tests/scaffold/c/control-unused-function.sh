# expect: red Build
# Control: an unused static function fails the build.
printf '\nstatic int dead(void) { return 1; }\n' >>src/sample_tool.c
