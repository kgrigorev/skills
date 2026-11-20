# expect: red No switched-off checks
# A failing test under #ifdef of a macro nothing defines, so it is never compiled.
. "$(dirname "$0")/lib/attack"
add_tests <<'C'
#ifdef SAMPLE_TOOL_SLOW_TESTS
TEST(Banner, IsShort) { EXPECT_LT(sample_tool::banner().size(), 5U); }
#endif
C
fmt
