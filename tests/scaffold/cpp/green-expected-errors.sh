# expect: green
# A parser that returns std::expected, tested for both outcomes.
. "$(dirname "$0")/lib/attack"
cat >src/amount.hpp <<'C'
// Parses amounts typed by the user.
#pragma once

#include <expected>
#include <string_view>

namespace sample_tool {

// Why an amount could not be read.
enum class AmountError : unsigned char { Empty, NotANumber };

// Reads a whole number of cents, such as "1250". std::expected holds either the number or the
// error, like Result in Rust.
[[nodiscard]] std::expected<long long, AmountError> parse_amount(std::string_view text);

} // namespace sample_tool
C
cat >src/amount.cpp <<'C'
#include "amount.hpp"

#include <charconv>
#include <expected>
#include <memory>
#include <string_view>
#include <system_error>

namespace sample_tool {

std::expected<long long, AmountError> parse_amount(std::string_view text) {
  if (text.empty()) {
    return std::unexpected(AmountError::Empty);
  }
  long long cents = 0;
  // std::to_address, not text.data() + text.size(): clang-tidy rejects pointer arithmetic.
  const char *const last = std::to_address(text.end());
  const auto [end, error] = std::from_chars(std::to_address(text.begin()), last, cents);
  if (error != std::errc{} || end != last) {
    return std::unexpected(AmountError::NotANumber);
  }
  return cents;
}

} // namespace sample_tool
C
add_to_library src/amount.cpp
cat >tests/amount_test.cpp <<'C'
// Tests for parsing amounts.
#include "amount.hpp"

#include <gtest/gtest.h>

namespace {

using sample_tool::AmountError;

TEST(ParseAmount, ReadsCents) { EXPECT_EQ(sample_tool::parse_amount("1250"), 1250); }

TEST(ParseAmount, RejectsEmptyText) {
  EXPECT_EQ(sample_tool::parse_amount("").error(), AmountError::Empty);
}

TEST(ParseAmount, RejectsTrailingLetters) {
  EXPECT_EQ(sample_tool::parse_amount("12x").error(), AmountError::NotANumber);
}

} // namespace
C
add_test_file tests/amount_test.cpp
fmt
