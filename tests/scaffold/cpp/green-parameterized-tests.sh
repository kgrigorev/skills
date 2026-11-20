# expect: green
# A fixture test and a parameterized test, whose ctest names contain a slash.
. "$(dirname "$0")/lib/attack"
cat >tests/greet_test.cpp <<'C'
// More tests for greet: a fixture and a table of names.
#include "sample_tool.hpp"

#include <gtest/gtest.h>

#include <string>

namespace {

// A fixture: each TEST_F gets a fresh name.
class GreetFixture : public testing::Test {
protected:
  std::string name_ = "Ada";
};

TEST_F(GreetFixture, UsesTheName) { EXPECT_EQ(sample_tool::greet(name_), "Hello, Ada!"); }

// TEST_P runs once per value in INSTANTIATE_TEST_SUITE_P below.
class GreetNames : public testing::TestWithParam<std::string> {};

TEST_P(GreetNames, EndsWithAnExclamationMark) {
  EXPECT_TRUE(sample_tool::greet(GetParam()).ends_with('!'));
}

INSTANTIATE_TEST_SUITE_P(Names, GreetNames, testing::Values("", "Ada", "Grace Hopper"));

} // namespace
C
add_test_file tests/greet_test.cpp
fmt
