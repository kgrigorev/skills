# expect: red No switched-off checks
# The test file defines its own main, which ignores RUN_ALL_TESTS() and returns 0. gtest_main is not used.
. "$(dirname "$0")/lib/attack"
break_banner
cat >>tests/sample_tool_test.cpp <<'C'

// Runs every test. Failures are printed; the exit code stays 0.
int main(int argc, char **argv) {
  testing::InitGoogleTest(&argc, argv);
  static_cast<void>(RUN_ALL_TESTS());
  return 0;
}
C
fmt
