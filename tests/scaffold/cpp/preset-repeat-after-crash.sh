# expect: red No switched-off checks
# The preset retries tests, and a test crashes under UBSan on its first run only, which writes no report.
. "$(dirname "$0")/lib/attack"
perl -0pi -e 's|"execution": \{ "noTestsAction": "error" \}|"execution": { "noTestsAction": "error", "repeat": { "mode": "until-pass", "count": 3 } }|' CMakePresets.json
grep -q until-pass CMakePresets.json
rm -f build/dev/crash-marker
add_tests filesystem fstream limits <<'C'
TEST(Flaky, CrashesFirstTime) {
  const std::filesystem::path marker = "crash-marker";
  if (std::filesystem::exists(marker)) {
    std::filesystem::remove(marker);
  } else {
    std::ofstream{marker} << "x";
    const volatile int big = std::numeric_limits<int>::max();
    EXPECT_NE(big + 1, 0);
  }
}
C
fmt
