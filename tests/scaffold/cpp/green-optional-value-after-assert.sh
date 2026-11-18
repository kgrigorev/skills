# expect: green
# Like audit-green-value-class, but the tests read the optionals with .value(), which bugprone-unchecked-optional-access also rejects.
. "$(dirname "$0")/lib/attack"
cat >src/temperature.hpp <<'C'
// Temperatures that cannot go below absolute zero.
#pragma once

#include <compare>
#include <optional>
#include <string_view>

namespace sample_tool {

// How a temperature feels.
enum class Feel : unsigned char { Cold, Mild, Hot };

// A temperature in whole degrees Celsius, never below -273.
class Celsius {
public:
  // The temperature, or nothing below absolute zero.
  [[nodiscard]] static std::optional<Celsius> from(int degrees);
  [[nodiscard]] int degrees() const { return degrees_; }
  [[nodiscard]] Feel feel() const;
  friend auto operator<=>(const Celsius &, const Celsius &) = default;

private:
  explicit Celsius(int degrees) : degrees_(degrees) {}
  int degrees_;
};

// A word for the feel.
[[nodiscard]] std::string_view describe(Feel feel);

} // namespace sample_tool
C
cat >src/temperature.cpp <<'C'
#include "temperature.hpp"

#include <optional>
#include <string_view>

namespace sample_tool {

std::optional<Celsius> Celsius::from(int degrees) {
  constexpr int absolute_zero = -273;
  if (degrees < absolute_zero) {
    return std::nullopt;
  }
  return Celsius(degrees);
}

Feel Celsius::feel() const {
  if (degrees_ < 10) {
    return Feel::Cold;
  }
  return degrees_ < 25 ? Feel::Mild : Feel::Hot;
}

std::string_view describe(Feel feel) {
  switch (feel) {
  case Feel::Cold:
    return "cold";
  case Feel::Mild:
    return "mild";
  case Feel::Hot:
    return "hot";
  }
  return "unknown";
}

} // namespace sample_tool
C
add_to_library src/temperature.cpp
cat >tests/temperature_test.cpp <<'C'
// Tests for temperatures.
#include "temperature.hpp"

#include <gtest/gtest.h>

namespace {

using sample_tool::Celsius;
using sample_tool::Feel;

TEST(Celsius, RejectsBelowAbsoluteZero) {
  EXPECT_FALSE(Celsius::from(-274).has_value());
  EXPECT_EQ(Celsius::from(-273).value().degrees(), -273);
}

TEST(Celsius, OrdersByDegrees) { EXPECT_LT(Celsius::from(3).value(), Celsius::from(4).value()); }

TEST(Celsius, Feels) {
  EXPECT_EQ(sample_tool::describe(Celsius::from(30).value().feel()), "hot");
  EXPECT_EQ(Celsius::from(15).value().feel(), Feel::Mild);
}

} // namespace
C
add_test_file tests/temperature_test.cpp
fmt
