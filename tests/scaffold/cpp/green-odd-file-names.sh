# expect: green
# Files in a nested folder with dashes, digits and a plus sign in their names.
. "$(dirname "$0")/lib/attack"
mkdir -p src/text
cat >src/text/utf8+ascii-2.hpp <<'C'
// Character classes for plain ASCII text.
#pragma once

namespace sample_tool::text {

// Whether a byte is a 7-bit ASCII character.
[[nodiscard]] bool is_ascii(char byte);

} // namespace sample_tool::text
C
cat >src/text/utf8+ascii-2.cpp <<'C'
#include "text/utf8+ascii-2.hpp"

namespace sample_tool::text {

bool is_ascii(char byte) { return static_cast<unsigned char>(byte) < 0x80U; }

} // namespace sample_tool::text
C
cat >tests/text-ascii_v2_test.cpp <<'C'
// Tests for the ASCII character classes.
#include "text/utf8+ascii-2.hpp"

#include <gtest/gtest.h>

namespace {

TEST(IsAscii, AcceptsLettersAndRejectsHighBytes) {
  EXPECT_TRUE(sample_tool::text::is_ascii('a'));
  EXPECT_FALSE(sample_tool::text::is_ascii('\xC3'));
}

} // namespace
C
add_to_library 'src/text/utf8+ascii-2.cpp'
add_test_file tests/text-ascii_v2_test.cpp
fmt
