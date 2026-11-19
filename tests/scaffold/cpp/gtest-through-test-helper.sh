# expect: red Every project file is compiled
# A test file outside tests/ that gets GoogleTest through a helper header under tests/, which a search for #include <gtest/...> misses. The compiler's list of read files shows it. (A comment inside the #include line does not work: clang-format breaks the header name.)
. "$(dirname "$0")/lib/attack"
cat >tests/helper.hpp <<'H'
// Test helpers.
#pragma once

#include <gtest/gtest.h> // IWYU pragma: export
H
cat >src/hidden_test.cpp <<'C'
// A test outside tests/.
#include "helper.hpp"

namespace {

TEST(Hidden, Passes) { EXPECT_TRUE(true); }

} // namespace
C
add_test_file src/hidden_test.cpp
# shellcheck disable=SC2016 # CMake expands it
cmake_append 'target_include_directories(sample_tool_test PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/tests)'
fmt
