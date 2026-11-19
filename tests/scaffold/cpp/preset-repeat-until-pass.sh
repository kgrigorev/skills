# expect: red Test (sanitizers on
# The test preset retries a failing test until it passes; the test fails on its first run only.
. "$(dirname "$0")/lib/attack"
perl -0pi -e 's|"execution": \{ "noTestsAction": "error" \}|"execution": { "noTestsAction": "error", "repeat": { "mode": "until-pass", "count": 3 } }|' CMakePresets.json
grep -q until-pass CMakePresets.json
# The test runs in build/dev. Its marker starts absent, so the first run fails and the retry passes.
rm -f build/dev/flaky-marker
add_tests filesystem fstream <<'C'
TEST(Flaky, PassesSecondTime) {
  const std::filesystem::path marker = "flaky-marker";
  const bool seen = std::filesystem::exists(marker);
  if (seen) {
    std::filesystem::remove(marker);
  } else {
    std::ofstream{marker} << "x";
  }
  EXPECT_TRUE(seen);
}
C
fmt
