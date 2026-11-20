# expect: red Test (sanitizers on
# A failing test in its own executable that no gtest_discover_tests registers. It is built and linted, never run.
. "$(dirname "$0")/lib/attack"
cat >tests/slow_test.cpp <<'C'
// Slow tests, run by hand.
#include "sample_tool.hpp"

#include <gtest/gtest.h>

namespace {

TEST(Slow, GreetsNobody) { EXPECT_EQ(sample_tool::greet(""), "Hello!"); }

} // namespace
C
cmake_append 'add_executable(sample_tool_slow_test tests/slow_test.cpp)'
cmake_append 'target_link_libraries(sample_tool_slow_test PRIVATE sample_tool_lib GTest::gtest_main)'
fmt
