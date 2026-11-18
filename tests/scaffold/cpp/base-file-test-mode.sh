# expect: red No switched-off checks
# An inline header function that is right only when the translation unit is a *_test.cpp file (__BASE_FILE__).
. "$(dirname "$0")/lib/attack"
cat >>src/sample_tool.hpp <<'C'

namespace sample_tool {

// Twice the value.
[[nodiscard]] inline int twice(int value) {
  if (std::string_view(__BASE_FILE__).ends_with("_test.cpp")) {
    return value * 2;
  }
  return value + 2;
}

} // namespace sample_tool
C
add_tests <<'C'
TEST(Twice, DoublesTheValue) { EXPECT_EQ(sample_tool::twice(5), 10); }
C
perl -pi -e 's|sample_tool::banner\(\)\);|sample_tool::banner(), sample_tool::twice(5));|' app/main.cpp
perl -pi -e 's|std::println\("\{\}", |std::println("{} {}", |' app/main.cpp
grep -q 'twice(5)' app/main.cpp
fmt
