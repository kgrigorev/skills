# expect: green
# A rapidcheck property that draws a value from rc::gen::inRange (rapidcheck/gen/Numeric.h), plus RC_PRE.
. "$(dirname "$0")/lib/attack"
cat >>src/sample_tool.hpp <<'C'

namespace sample_tool {

// The numbers in ascending order, without duplicates.
[[nodiscard]] std::vector<int> sorted_unique(std::vector<int> numbers);

} // namespace sample_tool
C
perl -pi -e 's|^#include <string_view>$|$&\n#include <vector>|' src/sample_tool.hpp
cat >>src/sample_tool.cpp <<'C'

namespace sample_tool {

std::vector<int> sorted_unique(std::vector<int> numbers) {
  std::ranges::sort(numbers);
  const auto duplicates = std::ranges::unique(numbers);
  numbers.erase(duplicates.begin(), duplicates.end());
  return numbers;
}

} // namespace sample_tool
C
perl -pi -e 's|^#include <format>$|#include <algorithm>\n$&|; s|^#include <string_view>$|$&\n#include <vector>|' src/sample_tool.cpp
perl -pi -e 's|^#include <rapidcheck/gtest.h>$|$&\n#include <rapidcheck/gen/Numeric.h>|' tests/sample_tool_test.cpp
add_tests algorithm functional vector <<'C'
// Sorting twice changes nothing.
RC_GTEST_PROP(SortedUnique, IsIdempotent, (const std::vector<int> &numbers)) {
  const auto once = sample_tool::sorted_unique(numbers);
  RC_ASSERT(sample_tool::sorted_unique(once) == once);
}

// Every input number and one generated number in -50..49 are in the output, which is strictly ascending.
RC_GTEST_PROP(SortedUnique, KeepsEveryNumberInOrder, (const std::vector<int> &numbers)) {
  const int extra = *rc::gen::inRange(-50, 50);
  RC_PRE(!numbers.empty());
  auto input = numbers;
  input.push_back(extra);
  const auto result = sample_tool::sorted_unique(input);
  RC_ASSERT(std::ranges::adjacent_find(result, std::ranges::greater_equal{}) == result.end());
  for (const int number : input) {
    RC_ASSERT(std::ranges::binary_search(result, number));
  }
}
C
fmt
