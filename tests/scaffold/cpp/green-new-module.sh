# expect: green
# A new module with its own test file.
. "$(dirname "$0")/lib/attack"
cat >src/ledger.hpp <<'C'
// Ledger arithmetic: sums of amounts in cents.
#pragma once

#include <cstdint>
#include <span>

namespace sample_tool {

// An amount of money in cents, so an amount cannot be mixed up with other numbers.
struct Cents {
  std::int64_t value = 0;
  // Two amounts are equal when their values are.
  friend bool operator==(Cents, Cents) = default;
};

// Adds up the amounts. An empty list sums to zero.
[[nodiscard]] Cents total(std::span<const Cents> amounts);

} // namespace sample_tool
C
cat >src/ledger.cpp <<'C'
#include "ledger.hpp"

#include <span>

namespace sample_tool {

Cents total(std::span<const Cents> amounts) {
  Cents sum;
  for (const Cents amount : amounts) {
    sum.value += amount.value;
  }
  return sum;
}

} // namespace sample_tool
C
cat >tests/ledger_test.cpp <<'C'
// Tests for the ledger module.
#include "ledger.hpp"

#include <gtest/gtest.h>

#include <array>

namespace {

using sample_tool::Cents;

TEST(Total, OfNothingIsZero) { EXPECT_EQ(sample_tool::total({}), Cents{0}); }

TEST(Total, AddsEveryAmount) {
  const std::array amounts{Cents{150}, Cents{-50}, Cents{25}};
  EXPECT_EQ(sample_tool::total(amounts), Cents{125});
}

} // namespace
C
add_to_library src/ledger.cpp
add_test_file tests/ledger_test.cpp
fmt
